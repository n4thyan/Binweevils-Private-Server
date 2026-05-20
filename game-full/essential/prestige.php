<?php
/**
 * Prestige progression hook.
 *
 * Loaded after internal.php from backbone.php.
 *
 * Behaviour:
 * - XP remains lifetime/banked XP and is never reset.
 * - Reaching display level 80 with enough XP increments prestige_count.
 * - Display level resets to 1.
 * - prestige_xp_base stores the XP at the moment of prestige.
 * - Future prestige levels use scaled thresholds above prestige_xp_base.
 */

if(!function_exists('bw_prestige_scale')) {
    function bw_prestige_scale($prestigeCount) {
        $prestigeCount = max(0, intval($prestigeCount));
        return 1 + ($prestigeCount * 0.35);
    }

    function bw_prestige_columns_ready($db) {
        $needed = ['prestige_count', 'prestige_xp_base'];

        foreach($needed as $column) {
            $safeColumn = $db->real_escape_string($column);
            $res = $db->query("SHOW COLUMNS FROM `users` LIKE '{$safeColumn}'");

            if(!$res || $res->num_rows < 1) {
                return false;
            }
        }

        $res = $db->query("SHOW TABLES LIKE 'prestige_trophies'");
        return ($res && $res->num_rows > 0);
    }

    function bw_prestige_level_xp_required($db, $level) {
        $level = max(1, min(80, intval($level)));
        $q = $db->prepare("SELECT `xpRequired` FROM `levels` WHERE `level` = ? LIMIT 1;");

        if(!$q) {
            return 0;
        }

        $q->bind_param('i', $level);
        $q->execute();

        $res = $q->get_result();

        if($row = $res->fetch_assoc()) {
            return intval($row['xpRequired']);
        }

        return 0;
    }

    function bw_prestige_level_delta($db, $fromLevel, $toLevel, $prestigeCount) {
        $fromRequired = bw_prestige_level_xp_required($db, $fromLevel);
        $toRequired = bw_prestige_level_xp_required($db, $toLevel);
        $rawDelta = max(1, $toRequired - $fromRequired);

        return max(1, intval(round($rawDelta * bw_prestige_scale($prestigeCount))));
    }

    function bw_prestige_threshold_for_level($db, $baseXp, $displayLevel, $prestigeCount) {
        $displayLevel = max(1, min(80, intval($displayLevel)));
        $threshold = intval($baseXp);

        for($level = 1; $level < $displayLevel; $level++) {
            $threshold += bw_prestige_level_delta($db, $level, $level + 1, $prestigeCount);
        }

        return $threshold;
    }

    function bw_prestige_record_trophy($db, $weevilId, $username, $prestigeCount, $level) {
        $q = $db->prepare(
            "INSERT IGNORE INTO `prestige_trophies`
                (`weevil_id`, `username`, `prestige_count`, `level`)
             VALUES (?, ?, ?, ?);"
        );

        if(!$q) {
            return false;
        }

        $weevilId = intval($weevilId);
        $prestigeCount = intval($prestigeCount);
        $level = intval($level);

        $q->bind_param('isii', $weevilId, $username, $prestigeCount, $level);
        $q->execute();

        return ($q->affected_rows >= 0);
    }

    function bw_apply_prestige_progression() {
        if(!isset($_COOKIE['weevil_name']) || !isset($_COOKIE['sessionId'])) {
            return;
        }

        if(!function_exists('confirmSessionKey')) {
            return;
        }

        $username = trim((string) $_COOKIE['weevil_name']);
        $sessionId = trim((string) $_COOKIE['sessionId']);

        if($username === '' || $sessionId === '') {
            return;
        }

        if(confirmSessionKey($username, $sessionId) !== true) {
            return;
        }

        $db = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

        if($db->connect_errno) {
            return;
        }

        if(!bw_prestige_columns_ready($db)) {
            return;
        }

        $q = $db->prepare(
            "SELECT `id`, `username`, `level`, `xp`, `xp1`, `xp2`, `prestige_count`, `prestige_xp_base`
             FROM `users`
             WHERE `username` = ?
             LIMIT 1;"
        );

        if(!$q) {
            return;
        }

        $q->bind_param('s', $username);
        $q->execute();

        $res = $q->get_result();
        $user = $res ? $res->fetch_assoc() : null;

        if(!$user) {
            return;
        }

        $weevilId = intval($user['id']);
        $level = intval($user['level']);
        $xp = intval($user['xp']);
        $xp1 = intval($user['xp1']);
        $xp2 = intval($user['xp2']);
        $prestigeCount = intval($user['prestige_count']);
        $baseXp = intval($user['prestige_xp_base']);

        if($level >= 80 && $xp2 > 0 && $xp >= $xp2) {
            $newPrestigeCount = $prestigeCount + 1;
            $newBaseXp = $xp;
            $newXp1 = $newBaseXp;
            $newXp2 = bw_prestige_threshold_for_level($db, $newBaseXp, 2, $newPrestigeCount);

            $update = $db->prepare(
                "UPDATE `users`
                 SET `prestige_count` = ?,
                     `prestige_xp_base` = ?,
                     `level` = 1,
                     `xp1` = ?,
                     `xp2` = ?
                 WHERE `username` = ?;"
            );

            if($update) {
                $update->bind_param('iiiis', $newPrestigeCount, $newBaseXp, $newXp1, $newXp2, $username);
                $update->execute();
            }

            return;
        }

        if($prestigeCount <= 0) {
            return;
        }

        if($baseXp <= 0) {
            $baseXp = max(0, $xp1);
        }

        $targetLevel = max(1, min(80, $level));

        while($targetLevel < 80) {
            $nextThreshold = bw_prestige_threshold_for_level($db, $baseXp, $targetLevel + 1, $prestigeCount);

            if($xp < $nextThreshold) {
                break;
            }

            $targetLevel++;
        }

        $newXp1 = bw_prestige_threshold_for_level($db, $baseXp, $targetLevel, $prestigeCount);
        $newXp2 = ($targetLevel >= 80)
            ? $newXp1
            : bw_prestige_threshold_for_level($db, $baseXp, $targetLevel + 1, $prestigeCount);

        if($targetLevel === $level && $newXp1 === $xp1 && $newXp2 === $xp2) {
            return;
        }

        $update = $db->prepare(
            "UPDATE `users`
             SET `level` = ?,
                 `xp1` = ?,
                 `xp2` = ?,
                 `prestige_xp_base` = ?
             WHERE `username` = ?;"
        );

        if(!$update) {
            return;
        }

        $update->bind_param('iiiis', $targetLevel, $newXp1, $newXp2, $baseXp, $username);
        $update->execute();

        if($targetLevel > 1) {
            for($earnedLevel = 2; $earnedLevel <= $targetLevel; $earnedLevel++) {
                bw_prestige_record_trophy($db, $weevilId, $username, $prestigeCount, $earnedLevel);
            }
        }
    }

    register_shutdown_function('bw_apply_prestige_progression');
}
?>