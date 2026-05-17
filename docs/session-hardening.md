# Session hardening

Blank usernames or blank session keys must never be accepted as valid authentication.

Logout rotates `sessionKey` and `loginKey` to fresh non-empty values, and `confirmSessionKey()` rejects empty username/session-key input before querying the database.
