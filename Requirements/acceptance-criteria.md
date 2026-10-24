# Weave acceptance criteria

These requirements define the core flow. Each Kane result must be tied to a requirement ID and a completed run with its process exit code. SQL and physical-device checks are separate from Kane.

| ID | Preconditions | Expected behavior | Observable outcome | Verified by |
| --- | --- | --- | --- | --- |
| AUTH-01 | Test user exists | User signs in with email and password | Group screen shows the user's name | Kane |
| GROUP-01 | Alice is in group "Study" | Group screen lists members and balance | Shows Alice, Bob, Charlie and "40 credits" | Kane |
| CREDIT-01 | Balance 40 | Two simultaneous 10-min reservations never spend the same credits | Ledger total equals sum of reservations | SQL concurrency test |
| CREDIT-02 | Balance 5 | 10-min request is rejected | "Not enough group credits" message; balance still 5 | Kane + SQL |
| EXT-01 | Alice at personal limit, balance 40 | Request needs an explicit Confirm tap | Confirm sheet shows "10 minutes · 10 credits" before anything is spent | Kane |
| EXT-02 | Confirmed extension | Balance drops, extension starts with an expiry | Balance "30 credits"; banner "Extension active, ends at HH:MM" | Kane |
| EXT-03 | Extension active | Double-tapping Confirm does not double-spend | Balance is 30, not 20 | Kane + SQL |
| RECOV-01 | Mock provider set to fail activation | Server reservation is reconciled | Error "Couldn't start extension"; balance returns to 40 | Kane |
| PRIV-01 | Alice finished an extension with a private reason | Keep Private posts nothing | Bob's feed shows no card from Alice; no reason text anywhere | Kane + RLS test |
| SHARE-01 | Alice taps Share with Group | AI drafts a card; Alice can edit it; nothing posts until she taps Post | Draft editor visible; feed unchanged until Post | Kane |
| SHARE-02 | Alice taps Post | Card appears in group feed | Feed shows Alice's card with her edited text | Kane |
| AI-01 | Private reason "chemistry test anxiety" stored | AI draft never contains the reason or a paraphrase | Stored draft text has none of the reason terms, 5 of 5 runs | Kane (5 runs) |
| AI-02 | OpenAI call fails or times out | User gets a plain fallback card, flow continues | Fallback text "Alice used 10 group minutes" in editor | Kane |
| SAFE-01 | Release build | Debug tab and debug routes don't exist | (Code check: all debug code under `#if DEBUG`) | Unit test + review |

*Out of scope for Kane, verified elsewhere: CREDIT-01 (SQL), PRIV-01 RLS half (SQL), real Screen Time shielding (physical device; not verified at hackathon).*

### AUTH-01: Email and password sign-in

- **Preconditions:** Test user exists.
- **Expected behavior:** User signs in with email and password.
- **Failure states:** Invalid credentials or a failed sign-in must leave the user signed out and show a clear error; do not show another user’s group.
- **Observable outcome:** Group screen shows the user's name.
- **Verified by:** Kane.

### GROUP-01: Study group overview

- **Preconditions:** Alice is in group "Study".
- **Expected behavior:** Group screen lists members and balance.
- **Failure states:** A failed group fetch must show an error without inventing members or a balance.
- **Observable outcome:** Shows Alice, Bob, Charlie and "40 credits".
- **Verified by:** Kane.

### CREDIT-01: Concurrent credit reservations

- **Preconditions:** Balance 40.
- **Expected behavior:** Two simultaneous 10-min reservations never spend the same credits.
- **Failure states:** Concurrent or repeated reservations must never overspend, produce a negative balance, or debit the same request twice; rejected requests leave the ledger unchanged.
- **Observable outcome:** Ledger total equals sum of reservations.
- **Verified by:** SQL concurrency test.

### CREDIT-02: Insufficient group credits

- **Preconditions:** Balance 5.
- **Expected behavior:** 10-min request is rejected.
- **Failure states:** Reject the request without activating an extension or debiting credits; leave the balance at 5.
- **Observable outcome:** "Not enough group credits" message; balance still 5.
- **Verified by:** Kane + SQL.

### EXT-01: Explicit extension confirmation

- **Preconditions:** Alice at personal limit, balance 40.
- **Expected behavior:** Request needs an explicit Confirm tap.
- **Failure states:** Cancel or dismiss the confirmation sheet without spending credits or activating an extension.
- **Observable outcome:** Confirm sheet shows "10 minutes · 10 credits" before anything is spent.
- **Verified by:** Kane.

### EXT-02: Extension balance and expiry

- **Preconditions:** Confirmed extension.
- **Expected behavior:** Balance drops, extension starts with an expiry.
- **Failure states:** If activation fails, reconcile the reservation as RECOV-01; do not display an active extension without a valid expiry.
- **Observable outcome:** Balance "30 credits"; banner "Extension active, ends at HH:MM".
- **Verified by:** Kane.

### EXT-03: Idempotent confirmation

- **Preconditions:** Extension active.
- **Expected behavior:** Double-tapping Confirm does not double-spend.
- **Failure states:** Duplicate confirmation attempts must resolve to the original reservation and extension; balance must never drop to 20 for one 10-minute extension.
- **Observable outcome:** Balance is 30, not 20.
- **Verified by:** Kane + SQL.

### RECOV-01: Activation failure reconciliation

- **Preconditions:** Mock provider set to fail activation.
- **Expected behavior:** Server reservation is reconciled.
- **Failure states:** An activation error must release the server reservation exactly once; repeated recovery must not increase the balance above 40.
- **Observable outcome:** Error "Couldn't start extension"; balance returns to 40.
- **Verified by:** Kane.

### PRIV-01: Keep reasons private

- **Preconditions:** Alice finished an extension with a private reason.
- **Expected behavior:** Keep Private posts nothing.
- **Failure states:** Keep Private must never create a group feed card. Another group member must not read Alice’s private reason through RLS-protected tables.
- **Observable outcome:** Bob's feed shows no card from Alice; no reason text anywhere.
- **Verified by:** Kane + RLS test.

### SHARE-01: Review and edit AI draft

- **Preconditions:** Alice taps Share with Group.
- **Expected behavior:** AI drafts a card; Alice can edit it; nothing posts until she taps Post.
- **Failure states:** Drafting, editing, cancelling, or dismissing the editor must not publish a card. A draft failure follows AI-02.
- **Observable outcome:** Draft editor visible; feed unchanged until Post.
- **Verified by:** Kane.

### SHARE-02: Publish the reviewed card

- **Preconditions:** Alice taps Post.
- **Expected behavior:** Card appears in group feed.
- **Failure states:** A failed Post must show an error without claiming publication; retries must not create duplicate cards.
- **Observable outcome:** Feed shows Alice's card with her edited text.
- **Verified by:** Kane.

### AI-01: AI draft privacy guard

- **Preconditions:** Private reason "chemistry test anxiety" stored.
- **Expected behavior:** AI draft never contains the reason or a paraphrase.
- **Failure states:** Reject or regenerate a draft that contains private reason terms or paraphrases. Do not publish any draft automatically. An environment failure or skipped repetition does not count among the five passes.
- **Observable outcome:** Stored draft text has none of the reason terms, 5 of 5 runs.
- **Verified by:** Kane (5 runs).

### AI-02: AI failure fallback

- **Preconditions:** OpenAI call fails or times out.
- **Expected behavior:** User gets a plain fallback card, flow continues.
- **Failure states:** Failure, invalid output, or timeout after 8 seconds must return the plain fallback and keep the edit/review/Post flow usable.
- **Observable outcome:** Fallback text "Alice used 10 group minutes" in editor.
- **Verified by:** Kane.

### SAFE-01: Release build debug exclusion

- **Preconditions:** Release build.
- **Expected behavior:** Debug tab and debug routes don't exist.
- **Failure states:** No Debug tab, debug-only controls, test sign-in routes, or mock-control routes may compile into Release; all debug code must be under #if DEBUG.
- **Observable outcome:** (Code check: all debug code under `#if DEBUG`).
- **Verified by:** Unit test + review.
