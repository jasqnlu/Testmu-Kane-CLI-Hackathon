import os
import testmu_appium
from testmu_appium import var, set_var

testmu_appium.configure(
    kane_run_v4=True,
    platform="ios",
    app="lt://APP1016032341792865566198624",
    device_name="iPhone.*",
    platform_version="26.5",
    build="23425c47-00e3-4e57-b693-30381abcb43d",
    name="Verify Sign-In Screen Elements",
    tc_id="TC-2",
    variables={"sign_in_control_visible": "true", "sign_in_screen_visible": "true", "email_control_visible": "true", "password_control_visible": "true"},
    global_variables=[{"id": 464435, "name": "valid_email", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}, {"id": 464436, "name": "unrecognized_email", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}, {"id": 464437, "name": "sign_in_failure_fixture", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}, {"id": 464438, "name": "expected_user_name", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}, {"id": 464439, "name": "balance_40_fixture", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}, {"id": 464440, "name": "balance_5_fixture", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}, {"id": 464441, "name": "activation_failure_fixture", "value": "", "session_value": "", "is_persist": False, "environment_id": 0, "environment_name": "No Env"}],
    default_action_timeout_ms=10000,
)

@testmu_appium.test
def test(driver):
    with testmu_appium.step('the sign-in screen is visible with Email, Password, and Sign in controls', instruction_id='0cf45111-2f80-4dd0-af2e-c530e43f4034'):
        testmu_appium.verify_assertion(driver, tree={'operator': ['equals'], 'assertion_operands': [], 'left_operand': None, 'right_operand': None, 'operands': [], 'sub_results': [{'description': 'the sign-in screen is visible', 'passed': True, 'operator': 'equals', 'transforms': [], 'json_path': None, 'expected': 'true', 'extracted_value': '{{sign_in_screen_visible}}', 'store_key': 'sign_in_screen_visible', 'variable_refs': {'{{sign_in_screen_visible}}': 'true'}}, {'description': 'the Email control is visible', 'passed': True, 'operator': 'equals', 'transforms': [], 'json_path': None, 'expected': 'true', 'extracted_value': '{{email_control_visible}}', 'store_key': 'email_control_visible', 'variable_refs': {'{{email_control_visible}}': 'true'}}, {'description': 'the Password control is visible', 'passed': True, 'operator': 'equals', 'transforms': [], 'json_path': None, 'expected': 'true', 'extracted_value': '{{password_control_visible}}', 'store_key': 'password_control_visible', 'variable_refs': {'{{password_control_visible}}': 'true'}}, {'description': 'the Sign in control is visible', 'passed': True, 'operator': 'equals', 'transforms': [], 'json_path': None, 'expected': 'true', 'extracted_value': '{{sign_in_control_visible}}', 'store_key': 'sign_in_control_visible', 'variable_refs': {'{{sign_in_control_visible}}': 'true'}}], 'sub_checks': [{'description': 'the sign-in screen is visible', 'store_key': 'sign_in_screen_visible', 'expected_value': 'true', 'extracted_value': '{{sign_in_screen_visible}}', 'operator': 'equals', 'transforms': []}, {'description': 'the Email control is visible', 'store_key': 'email_control_visible', 'expected_value': 'true', 'extracted_value': '{{email_control_visible}}', 'operator': 'equals', 'transforms': []}, {'description': 'the Password control is visible', 'store_key': 'password_control_visible', 'expected_value': 'true', 'extracted_value': '{{password_control_visible}}', 'operator': 'equals', 'transforms': []}, {'description': 'the Sign in control is visible', 'store_key': 'sign_in_control_visible', 'expected_value': 'true', 'extracted_value': '{{sign_in_control_visible}}', 'operator': 'equals', 'transforms': []}], 'composite_operator': 'and', 'claim': 'the sign-in screen is visible with Email, Password, and Sign in controls'}, description='the sign-in screen is visible with Email, Password, and Sign in controls')


def _apply_test_config(path, instance_id):
    import json
    with open(path) as f:
        groups = json.load(f)
    entry = None
    for tests in groups.values():
        for candidate in tests:
            if instance_id in (None, "", candidate.get("test_instance_id")):
                entry = candidate
                break
        if entry is not None:
            break
    if entry is None:
        raise SystemExit(
            "test instance %r not found in %s" % (instance_id, path)
        )
    testmu_appium.configure(**testmu_appium.test_config_overrides(entry))


if __name__ == "__main__":
    import argparse
    _parser = argparse.ArgumentParser()
    _parser.add_argument("--test-config")
    _parser.add_argument("--test-instance-id")
    # Accepted for run.sh compatibility; the V4 artifact has no ops metadata.
    _parser.add_argument("--operations-meta-data")
    _args, _ = _parser.parse_known_args()
    if _args.test_config:
        _apply_test_config(_args.test_config, _args.test_instance_id)
    testmu_appium.run(test)
