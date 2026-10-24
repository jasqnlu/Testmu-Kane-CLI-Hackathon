#!/usr/bin/env python3
"""Provision only Weave's owned fixtures; never print credentials or key material."""
import json
import os
from pathlib import Path
import secrets
import subprocess
import sys
import tempfile
import urllib.request
import urllib.error

ROOT = Path(__file__).resolve().parent.parent
PROJECT = 'wwlbaihtcyyfxoesyytr'
URL = f'https://{PROJECT}.supabase.co'
GROUP_ID = 'a11ce000-0000-4000-8000-000000000001'
OWNER = 'weave-hackathon-20261024'


def save_private(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.parent.chmod(0o700)
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    path.chmod(0o600)


def cli(*args):
    result = subprocess.run(['supabase', *args], cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f'Supabase CLI {args[0]} failed (exit {result.returncode}); private output was not printed.')
    try:
        start = min(i for i in [result.stdout.find('{'), result.stdout.find('[')] if i >= 0)
        return json.loads(result.stdout[start:])
    except (ValueError, json.JSONDecodeError):
        raise RuntimeError('Supabase returned an unexpected response; private output was not printed.')


def query(sql):
    (ROOT / '.supabase').mkdir(exist_ok=True)
    with tempfile.NamedTemporaryFile(mode='w', suffix='.sql', prefix='admin-query-', dir=ROOT / '.supabase', delete=False) as temporary:
        temporary.write(sql)
        path = Path(temporary.name)
    path.chmod(0o600)
    try:
        return cli('db', 'query', '--linked', '--project-ref', PROJECT, '--file', str(path), '--output', 'json')
    finally:
        path.unlink(missing_ok=True)


def api(path, key, data=None, method=None, bearer=None):
    request = urllib.request.Request(URL + path, data=None if data is None else json.dumps(data).encode(),
        headers={'apikey': key, 'Authorization': 'Bearer ' + (bearer or key), 'Content-Type': 'application/json'},
        method=method or ('POST' if data is not None else 'GET'))
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            body = response.read()
            return json.loads(body) if body else None
    except urllib.error.HTTPError as error:
        # Error bodies may echo submitted credentials. Never expose them.
        raise RuntimeError(f'Backend request {path.split("?")[0]} failed with HTTP {error.code}.') from None


def configure():
    keys = cli('projects', 'api-keys', '--project-ref', PROJECT, '--reveal', '--output', 'json')
    if isinstance(keys, dict):
        keys = keys.get('api_keys', keys.get('keys', []))
    by_name = {k.get('name'): k.get('api_key', k.get('key')) for k in keys}
    admin = by_name.get('service_role')
    anon = by_name.get('anon')
    if not admin or not anon:
        raise RuntimeError('Project legacy anon/service_role keys were not returned; no secret values were printed.')
    save_private(ROOT / '.supabase/admin-keys.json', {'url': URL, 'serviceKey': admin})
    save_private(ROOT / 'Config/Backend.json', {'url': URL, 'anonKey': anon})
    accounts_path = ROOT / 'Config/TestAccounts.json'
    accounts = json.loads(accounts_path.read_text()) if accounts_path.exists() else {}
    users = api('/auth/v1/admin/users?page=1&per_page=1000', admin).get('users', [])
    existing = {u['email'].lower(): u for u in users if u.get('email')}
    for name in ['alice', 'bob', 'charlie']:
        email = f'{name}@weave.test'
        user = existing.get(email)
        if user:
            if user.get('user_metadata', {}).get('weave_test_owner') != OWNER or name not in accounts:
                raise RuntimeError(f'Reserved {name} account already exists without this fixture ownership/credentials; left unchanged.')
            if accounts[name].get('id') != user['id']:
                raise RuntimeError(f'Stored {name} identity does not match the owned fixture; left unchanged.')
        else:
            password = secrets.token_urlsafe(30)
            user = api('/auth/v1/admin/users', admin, {'email': email, 'password': password, 'email_confirm': True,
                'user_metadata': {'display_name': name.title(), 'weave_test_owner': OWNER}})
            accounts[name] = {'email': email, 'password': password, 'id': user['id']}
            save_private(accounts_path, accounts)
    variables_path = ROOT / '.testmuai/variables/assurance.json'
    variables = json.loads(variables_path.read_text()) if variables_path.exists() else {}
    values = {'valid_email': (accounts['alice']['email'], True), 'valid_password': (accounts['alice']['password'], True),
        'expected_user_name': ('Alice', False), 'bob_email': (accounts['bob']['email'], True),
        'bob_password': (accounts['bob']['password'], True), 'incorrect_password': (secrets.token_urlsafe(30), True),
        'unrecognized_email': ('missing-user@weave.test', True),
        'balance_40_fixture': ('In the Debug tab tap Seed: normal, then Set usage at limit.', False),
        'balance_5_fixture': ('In the Debug tab tap Seed: low-balance, then Set usage at limit.', False)}
    for name, (value, secret) in values.items():
        variables.setdefault(name, {})
        variables[name].update({'value': value, 'secret': secret})
    save_private(variables_path, variables)
    schema = query("select to_regclass('public.profiles') is not null as exists")
    if not schema['rows'][0]['exists']:
        cli('db', 'query', '--linked', '--project-ref', PROJECT, '--file',
            str(ROOT / 'Supabase/migrations/202610240001_m1_auth_groups.sql'), '--output', 'json')
    seed_normal(accounts, anon)
    print('Weave M1 configured: owned test accounts confirmed, schema present, Study seeded at 40 credits. Secrets saved only in ignored private files.')


def seed_normal(accounts=None, anon=None):
    if accounts is None:
        accounts = json.loads((ROOT / 'Config/TestAccounts.json').read_text())
    if anon is None:
        anon = json.loads((ROOT / 'Config/Backend.json').read_text())['anonKey']
    owned_ids = [accounts[n]['id'] for n in ['alice', 'bob', 'charlie']]
    # UUID values are validated before interpolation; no names/passwords enter SQL.
    import uuid
    for value in owned_ids:
        uuid.UUID(value)
    profile_values = ','.join(f"('{accounts[n]['id']}'::uuid,'{n.title()}')" for n in ['alice','bob','charlie'])
    member_values = ','.join(f"('{GROUP_ID}'::uuid,'{user}'::uuid)" for user in owned_ids)
    registry_values = ','.join(f"('{user}'::uuid,'{GROUP_ID}'::uuid)" for user in owned_ids)
    query(f"""begin;
insert into public.groups(id,name,balance) values ('{GROUP_ID}','Study',40)
  on conflict (id) do update set name='Study';
insert into public.profiles(id,display_name) values {profile_values}
  on conflict (id) do update set display_name=excluded.display_name;
insert into public.group_members(group_id,user_id) values {member_values} on conflict do nothing;
insert into weave_private.test_members(user_id,group_id) values {registry_values} on conflict do nothing;
commit;""")
    alice = accounts['alice']
    session = api('/auth/v1/token?grant_type=password', anon, {'email': alice['email'], 'password': alice['password']})
    result = api('/rest/v1/rpc/debug_reset_normal', anon, {}, bearer=session['access_token'])
    if result.get('balance') != 40 or result.get('group_name') != 'Study' or sorted(m['name'] for m in result.get('members', [])) != ['Alice','Bob','Charlie']:
        raise RuntimeError('Seed snapshot did not match normal fixture; no success claimed.')
    summary = {'project_ref': PROJECT, 'scenario': 'normal', 'group_name': result['group_name'],
        'balance': result['balance'], 'members': [m['name'] for m in result['members']],
        'verification': 'authenticated password grant and debug_reset_normal RPC; not a Kane UI pass'}
    (ROOT / 'evidence/backend-m1-seed.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('Normal fixture verified through authenticated RPC: Study, Alice/Bob/Charlie, 40 credits.')


def seed_low_balance(accounts=None, anon=None):
    if accounts is None:
        accounts = json.loads((ROOT / 'Config/TestAccounts.json').read_text())
    if anon is None:
        anon = json.loads((ROOT / 'Config/Backend.json').read_text())['anonKey']
    alice = accounts['alice']
    session = api('/auth/v1/token?grant_type=password', anon, {'email': alice['email'], 'password': alice['password']})
    result = api('/rest/v1/rpc/debug_seed_low_balance', anon, {}, bearer=session['access_token'])
    if result.get('balance') != 5 or result.get('group_name') != 'Study':
        raise RuntimeError('Seed snapshot did not match the low-balance fixture; no success claimed.')
    summary = {'project_ref': PROJECT, 'scenario': 'low-balance', 'group_name': result['group_name'],
        'balance': result['balance'], 'verification': 'authenticated debug_seed_low_balance RPC; not a Kane UI pass'}
    (ROOT / 'evidence/backend-m2-low-seed.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('Low-balance fixture verified through authenticated RPC: Study, 5 credits.')


def seed_private_reason(accounts=None, anon=None):
    if accounts is None:
        accounts = json.loads((ROOT / 'Config/TestAccounts.json').read_text())
    if anon is None:
        anon = json.loads((ROOT / 'Config/Backend.json').read_text())['anonKey']
    alice = accounts['alice']
    session = api('/auth/v1/token?grant_type=password', anon, {'email': alice['email'], 'password': alice['password']})
    result = api('/rest/v1/rpc/debug_seed_private_reason', anon, {}, bearer=session['access_token'])
    completed = result.get('completed_extension') or {}
    if result.get('balance') != 40 or completed.get('reason') != 'chemistry test anxiety':
        raise RuntimeError('Private-reason fixture did not match the owned test scenario; no success claimed.')
    summary = {'project_ref': PROJECT, 'scenario': 'private-reason', 'group_name': result['group_name'],
        'balance': result['balance'], 'verification': 'authenticated debug_seed_private_reason RPC; not a Kane UI pass'}
    (ROOT / 'evidence/backend-m4-private-seed.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('Private-reason fixture verified through authenticated RPC for the owned Study test group.')


if __name__ == '__main__':
    os.umask(0o077)
    try:
        if sys.argv[1:] == ['--seed-normal']:
            seed_normal()
        elif sys.argv[1:] == ['--seed-low']:
            seed_low_balance()
        elif sys.argv[1:] == ['--seed-private-reason']:
            seed_private_reason()
        elif not sys.argv[1:]:
            configure()
        else:
            raise RuntimeError('Usage: Scripts/configure-backend.py [--seed-normal|--seed-low|--seed-private-reason]')
    except (RuntimeError, OSError, ValueError, KeyError) as error:
        print(f'Backend setup stopped: {error}', file=sys.stderr)
        sys.exit(2)
