-- Prestige system follow-up for PR #55.
-- Safe to run once. Keeps XP as lifetime/banked XP.

ALTER TABLE `users`
    ADD COLUMN IF NOT EXISTS `prestige_count` INT NOT NULL DEFAULT 0 AFTER `level`,
    ADD COLUMN IF NOT EXISTS `prestige_xp_base` INT NOT NULL DEFAULT 0 AFTER `prestige_count`;

CREATE TABLE IF NOT EXISTS `prestige_trophies` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `weevil_id` INT NOT NULL,
    `username` VARCHAR(64) NOT NULL,
    `prestige_count` INT NOT NULL,
    `level` INT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_prestige_trophy_once` (`weevil_id`, `prestige_count`, `level`),
    KEY `idx_prestige_trophies_username` (`username`),
    KEY `idx_prestige_trophies_weevil` (`weevil_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
