USE bwps;

DELETE FROM rewardcodes
WHERE code IN ('WELCOME2026', 'OGLEVELS', 'NESTEGG');

INSERT INTO rewardcodes
(`code`, `item`, `xp`, `mulch`, `seed`, `dosh`, `gardenItem`, `notes`, `status`, `start_date`, `end_date`, `redeemable`, `quantity`)
VALUES
('WELCOME2026', NULL, 30, 500, 0, 0, 0, 'Starter welcome code: 30 XP and 500 mulch.', 1, NULL, NULL, 1, 999999),
('OGLEVELS', NULL, 100, 1000, 0, 0, 0, 'Celebrates restoring the original level XP thresholds.', 1, NULL, NULL, 1, 999999),
('NESTEGG', NULL, 0, 2500, 0, 0, 0, 'Starter mulch boost.', 1, NULL, NULL, 1, 999999);

SELECT id, code, item, xp, mulch, seed, dosh, gardenItem, notes, status, redeemable, quantity
FROM rewardcodes
WHERE code IN ('WELCOME2026', 'OGLEVELS', 'NESTEGG')
ORDER BY id;
