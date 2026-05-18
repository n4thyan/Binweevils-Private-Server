-- Clean social relationship table for the database rewrite track.
-- This table is added beside the legacy buddylist table.
-- It does not replace buddylist yet and should not change old SWF/PHP output.

CREATE TABLE IF NOT EXISTS `user_social_links` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `owner_user_id` INT NOT NULL,
    `target_user_id` INT DEFAULT NULL,
    `target_legacy_username` VARCHAR(255) DEFAULT NULL,
    `relation_type` ENUM('buddy', 'blocked', 'request') NOT NULL,
    `status` ENUM('accepted', 'blocked', 'pending', 'removed') NOT NULL,
    `source` ENUM('legacy_buddylist', 'dual_write', 'manual', 'system') NOT NULL DEFAULT 'legacy_buddylist',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_user_social_link` (`owner_user_id`, `target_user_id`, `relation_type`),
    KEY `idx_user_social_owner` (`owner_user_id`),
    KEY `idx_user_social_target` (`target_user_id`),
    KEY `idx_user_social_relation_status` (`relation_type`, `status`),
    KEY `idx_user_social_legacy_name` (`target_legacy_username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
