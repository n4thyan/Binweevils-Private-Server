USE bwps;

DELETE FROM prestige_trophies;

UPDATE users
SET level = 1,
    xp = 0,
    xp1 = 0,
    xp2 = 30,
    prestige_count = 0,
    prestige_xp_base = 0;

SELECT COUNT(*) AS reset_users FROM users;
SELECT username, level, xp, xp1, xp2, prestige_count, prestige_xp_base, isModerator
FROM users
ORDER BY id
LIMIT 20;
