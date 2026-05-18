<?php
/**
 * Backfill legacy buddylist data into user_social_links.
 *
 * Default mode is dry-run. Use --write to insert rows.
 *
 * Examples:
 *   php tools/database/backfill-social-links.php
 *   php tools/database/backfill-social-links.php --write
 *   php tools/database/backfill-social-links.php --limit=10
 */

if(PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This tool must be run from the command line.\n");
    exit(1);
}

$root = dirname(__DIR__, 2);

require_once $root . '/game-full/essential/config.php';
require_once $root . '/game-full/essential/identity_adapter.php';
require_once $root . '/game-full/essential/social_adapter.php';

$options = getopt('', ['write', 'limit::', 'help']);

if(isset($options['help'])) {
    echo "Backfill legacy buddylist data into user_social_links.\n\n";
    echo "Default mode: dry-run only.\n\n";
    echo "Options:\n";
    echo "  --write       Insert missing rows into user_social_links.\n";
    echo "  --limit=N     Process only the first N buddylist owners.\n";
    echo "  --help        Show this help text.\n";
    exit(0);
}

$writeMode = isset($options['write']);
$limit = isset($options['limit']) ? max(0, intval($options['limit'])) : 0;

$db = bw_identity_db();

if(!$db) {
    fwrite(STDERR, "Could not connect to database using game-full/essential/config.php settings.\n");
    exit(1);
}

function bw_backfill_has_social_link($db, $ownerUserId, $targetUserId, $targetLegacyUsername, $relationType) {
    if($targetUserId !== null) {
        $q = $db->prepare(
            "SELECT `id`
             FROM `user_social_links`
             WHERE `owner_user_id` = ?
               AND `target_user_id` = ?
               AND `relation_type` = ?
             LIMIT 1;"
        );

        if(!$q) {
            return false;
        }

        $q->bind_param('iis', $ownerUserId, $targetUserId, $relationType);
        $q->execute();
        $res = $q->get_result();
        return $res && $res->num_rows > 0;
    }

    $q = $db->prepare(
        "SELECT `id`
         FROM `user_social_links`
         WHERE `owner_user_id` = ?
           AND `target_user_id` IS NULL
           AND `target_legacy_username` = ?
           AND `relation_type` = ?
         LIMIT 1;"
    );

    if(!$q) {
        return false;
    }

    $q->bind_param('iss', $ownerUserId, $targetLegacyUsername, $relationType);
    $q->execute();
    $res = $q->get_result();
    return $res && $res->num_rows > 0;
}

function bw_backfill_insert_social_link($db, $ownerUserId, $targetUserId, $targetLegacyUsername, $relationType, $status) {
    $source = 'legacy_buddylist';

    $q = $db->prepare(
        "INSERT IGNORE INTO `user_social_links`
            (`owner_user_id`, `target_user_id`, `target_legacy_username`, `relation_type`, `status`, `source`)
         VALUES (?, ?, ?, ?, ?, ?);"
    );

    if(!$q) {
        return false;
    }

    $q->bind_param('iissss', $ownerUserId, $targetUserId, $targetLegacyUsername, $relationType, $status, $source);
    return $q->execute();
}

function bw_backfill_relationships_for_list($db, $ownerUser, $names, $relationType, $status, $writeMode, &$stats) {
    foreach($names as $targetUsername) {
        $targetUser = bw_get_user_by_username($targetUsername);
        $targetUserId = $targetUser ? intval($targetUser['user_id']) : null;

        if($targetUserId === null) {
            $stats['missing_targets']++;
        }

        $exists = bw_backfill_has_social_link(
            $db,
            intval($ownerUser['user_id']),
            $targetUserId,
            $targetUsername,
            $relationType
        );

        if($exists) {
            $stats['existing']++;
            continue;
        }

        if(!$writeMode) {
            $stats['would_insert']++;
            continue;
        }

        $ok = bw_backfill_insert_social_link(
            $db,
            intval($ownerUser['user_id']),
            $targetUserId,
            $targetUsername,
            $relationType,
            $status
        );

        if($ok) {
            $stats['inserted']++;
        } else {
            $stats['errors']++;
        }
    }
}

$sql = "SELECT `ownerName`, `namesList`, `blockList`, `requestList` FROM `buddylist` ORDER BY `id` ASC";

if($limit > 0) {
    $sql .= " LIMIT " . intval($limit);
}

$result = $db->query($sql);

if(!$result) {
    fwrite(STDERR, "Could not read legacy buddylist table. Has the clean schema been imported?\n");
    exit(1);
}

$stats = [
    'mode' => $writeMode ? 'write' : 'dry-run',
    'owners_seen' => 0,
    'owners_missing_user' => 0,
    'existing' => 0,
    'would_insert' => 0,
    'inserted' => 0,
    'missing_targets' => 0,
    'errors' => 0
];

while($row = $result->fetch_assoc()) {
    $stats['owners_seen']++;

    $ownerName = trim((string) $row['ownerName']);
    $ownerUser = bw_get_user_by_username($ownerName);

    if(!$ownerUser) {
        $stats['owners_missing_user']++;
        continue;
    }

    $buddies = bw_social_parse_packed_names($row['namesList']);
    $blocked = bw_social_parse_packed_names($row['blockList']);
    $requests = bw_social_parse_packed_names($row['requestList']);

    bw_backfill_relationships_for_list($db, $ownerUser, $buddies, 'buddy', 'accepted', $writeMode, $stats);
    bw_backfill_relationships_for_list($db, $ownerUser, $blocked, 'blocked', 'blocked', $writeMode, $stats);
    bw_backfill_relationships_for_list($db, $ownerUser, $requests, 'request', 'pending', $writeMode, $stats);
}

echo "Social links backfill complete.\n";
echo "Mode: " . $stats['mode'] . "\n";
echo "Owners seen: " . $stats['owners_seen'] . "\n";
echo "Owners missing user row: " . $stats['owners_missing_user'] . "\n";
echo "Existing rows skipped: " . $stats['existing'] . "\n";
echo "Missing target users preserved as legacy names: " . $stats['missing_targets'] . "\n";

if($writeMode) {
    echo "Rows inserted: " . $stats['inserted'] . "\n";
} else {
    echo "Rows that would be inserted: " . $stats['would_insert'] . "\n";
    echo "Run again with --write to insert them.\n";
}

if($stats['errors'] > 0) {
    echo "Errors: " . $stats['errors'] . "\n";
    exit(1);
}

exit(0);
