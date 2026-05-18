-- Legacy-compatible beta database sanitiser.
--
-- Intended use:
--   1. Create/import a fresh local database from the original legacy bwps.sql.
--   2. Run this file against that new beta database.
--   3. Run the newer rewrite migrations after this file.
--   4. Create fresh local_/beta_ accounts with tools/create_local_account.py.
--
-- This keeps old shop/game/catalogue/reference rows, but removes old user,
-- private player, session, inventory, progress, and runtime rows.
--
-- Do not run this against a database that contains real user data you want to keep.

SET FOREIGN_KEY_CHECKS = 0;

DROP PROCEDURE IF EXISTS bwps_truncate_if_exists;

DELIMITER //
CREATE PROCEDURE bwps_truncate_if_exists(IN p_table_name VARCHAR(128))
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = p_table_name
  ) THEN
    SET @bwps_truncate_sql = CONCAT('TRUNCATE TABLE `', REPLACE(p_table_name, '`', '``'), '`');
    PREPARE bwps_stmt FROM @bwps_truncate_sql;
    EXECUTE bwps_stmt;
    DEALLOCATE PREPARE bwps_stmt;
  END IF;
END //
DELIMITER ;

-- Account/auth/session rows.
CALL bwps_truncate_if_exists('users');
CALL bwps_truncate_if_exists('buddylist');
CALL bwps_truncate_if_exists('buddyalerts');
CALL bwps_truncate_if_exists('user_social_links');

-- Owned inventory/state rows.
CALL bwps_truncate_if_exists('weevilitems');
CALL bwps_truncate_if_exists('weevilhats');
CALL bwps_truncate_if_exists('gardeninventory');
CALL bwps_truncate_if_exists('pets');
CALL bwps_truncate_if_exists('petacquiredskills');
CALL bwps_truncate_if_exists('nest');
CALL bwps_truncate_if_exists('nestinfo');

-- Player progress/gameplay rows.
CALL bwps_truncate_if_exists('weevilgames');
CALL bwps_truncate_if_exists('singleplayergames_stats');
CALL bwps_truncate_if_exists('taskscompletedbyusers');
CALL bwps_truncate_if_exists('questscompleted');
CALL bwps_truncate_if_exists('achievementscompleted');
CALL bwps_truncate_if_exists('achievementcounters');
CALL bwps_truncate_if_exists('crossworduserprogress');
CALL bwps_truncate_if_exists('wordsearchuserprogress');
CALL bwps_truncate_if_exists('redeemedcodes');
CALL bwps_truncate_if_exists('prestige_trophies');

-- Runtime/live rows.
CALL bwps_truncate_if_exists('camerapics');
CALL bwps_truncate_if_exists('bubblehunts');
CALL bwps_truncate_if_exists('gameinvites');
CALL bwps_truncate_if_exists('game-logs');
CALL bwps_truncate_if_exists('leaderboardhighscores');

DROP PROCEDURE IF EXISTS bwps_truncate_if_exists;

SET FOREIGN_KEY_CHECKS = 1;

-- Keep reference/catalogue/rule tables intact, including examples such as:
-- appareltypes, itemtype, itemtypets, gardenitemtype, seeds, levels,
-- specialmoves, singleplayergames, multiplayergames, leaderboardgames,
-- achievements, achievementtypes, achievementtags, rewardcodes, game-rewards,
-- newspapers, newspaperissues, quests, questtasks, tasks, crosswords, wordsearches.

SELECT 'Legacy beta database sanitiser complete. Create fresh local_/beta_ accounts next.' AS status;
