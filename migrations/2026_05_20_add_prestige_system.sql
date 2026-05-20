USE bwps;

DROP PROCEDURE IF EXISTS add_prestige_columns;

DELIMITER //

CREATE PROCEDURE add_prestige_columns()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'users'
          AND COLUMN_NAME = 'prestige_count'
    ) THEN
        ALTER TABLE users ADD COLUMN prestige_count INT NOT NULL DEFAULT 0 AFTER level;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'users'
          AND COLUMN_NAME = 'prestige_xp_base'
    ) THEN
        ALTER TABLE users ADD COLUMN prestige_xp_base INT NOT NULL DEFAULT 0 AFTER prestige_count;
    END IF;
END//

DELIMITER ;

CALL add_prestige_columns();

DROP PROCEDURE IF EXISTS add_prestige_columns;

CREATE TABLE IF NOT EXISTS prestige_trophies (
    id INT NOT NULL AUTO_INCREMENT,
    weevil_id INT NOT NULL,
    username VARCHAR(64) NOT NULL,
    prestige_count INT NOT NULL,
    level INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_prestige_trophy_once (weevil_id, prestige_count, level),
    KEY idx_prestige_trophies_username (username),
    KEY idx_prestige_trophies_weevil (weevil_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SHOW COLUMNS FROM users LIKE 'prestige%';
SHOW TABLES LIKE 'prestige_trophies';
