# Weave iOS test context

Current milestone: M0 blank sign-in shell. The backend and Debug tab are not implemented yet. The behaviors below describe the acceptance target for later milestones, not existing functionality. For the M0 smoke objective, verify the sign-in screen only.

Weave is an iOS app built with SwiftUI and Supabase. It turns extra screen time into a shared group credit budget. Private reasons remain private unless the user deliberately shares a reviewed activity card.

Seeded test users are Alice, Bob, and Charlie. Their group is Study. The normal scenario starts with 40 credits; the low-balance scenario starts with 5 credits. Credits appear on screen as "N credits". A 10-minute extension costs 10 credits and requires an explicit Confirm tap.

Debug builds include a Debug tab with Reset, Sign in as Alice, Sign in as Bob, Seed: normal, Seed: low-balance, Seed: private-reason, Set usage at limit, and Fail next activation controls. Use these controls to reset test state and control the deterministic mock ScreenTimeProvider. Real Screen Time enforcement is not available in the simulator.

The confirmation sheet displays "10 minutes · 10 credits". Successful activation displays "Extension active, ends at HH:MM" and a 30-credit balance. Insufficient credits display "Not enough group credits". Failed activation displays "Couldn't start extension" and restores the reservation.

Keep Private creates no group feed card. Share with Group opens an editable AI draft; it posts only after Post. The private-reason scenario uses "chemistry test anxiety"; the AI draft must not quote or paraphrase that reason. On AI failure the editor shows "Alice used 10 group minutes".

Use only seeded test accounts. Credentials live in ignored .testmuai/variables files with secret: true; never include credentials in objectives or evidence summaries.
