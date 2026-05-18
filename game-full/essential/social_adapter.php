<?php
/**
 * Read-only social list adapter.
 *
 * This parses the legacy buddylist packed string columns into safer relationship
 * shaped data without changing legacy writes or Flash-facing output.
 */

if(!function_exists('bw_social_parse_packed_names')) {
    function bw_social_db() {
        if(function_exists('bw_identity_db')) {
            return bw_identity_db();
        }

        $db = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

        if($db->connect_errno) {
            return null;
        }

        if(method_exists($db, 'set_charset')) {
            @$db->set_charset('utf8mb4');
        }

        return $db;
    }

    function bw_social_parse_packed_names($packedNames) {
        $packedNames = trim((string) $packedNames);

        if($packedNames === '') {
            return [];
        }

        $parts = preg_split('/[,|;]+/', $packedNames);
        $seen = [];
        $names = [];

        foreach($parts as $part) {
            $name = trim((string) $part);

            if($name === '') {
                continue;
            }

            $key = function_exists('mb_strtolower')
                ? mb_strtolower($name, 'UTF-8')
                : strtolower($name);

            if(isset($seen[$key])) {
                continue;
            }

            $seen[$key] = true;
            $names[] = $name;
        }

        return $names;
    }

    function bw_social_relationship_rows($ownerUser, $names, $relationType, $status) {
        $rows = [];

        if(!$ownerUser || !is_array($ownerUser)) {
            return $rows;
        }

        foreach($names as $targetUsername) {
            $targetUser = function_exists('bw_get_user_by_username')
                ? bw_get_user_by_username($targetUsername)
                : null;

            $rows[] = [
                'owner_user_id' => intval($ownerUser['user_id']),
                'owner_username' => (string) $ownerUser['username'],
                'target_user_id' => $targetUser ? intval($targetUser['user_id']) : null,
                'target_username' => (string) $targetUsername,
                'relation_type' => (string) $relationType,
                'status' => (string) $status
            ];
        }

        return $rows;
    }

    function bw_get_social_lists_by_username($username) {
        $username = function_exists('bw_identity_normalise_username')
            ? bw_identity_normalise_username($username)
            : trim((string) $username);

        if($username === '') {
            return null;
        }

        $ownerUser = function_exists('bw_get_user_by_username')
            ? bw_get_user_by_username($username)
            : null;

        if(!$ownerUser) {
            return null;
        }

        $db = bw_social_db();

        if(!$db) {
            return null;
        }

        $q = $db->prepare(
            "SELECT `ownerName`, `namesList`, `blockList`, `requestList`
             FROM `buddylist`
             WHERE `ownerName` = ?
             LIMIT 1;"
        );

        if(!$q) {
            return null;
        }

        $q->bind_param('s', $username);
        $q->execute();

        $res = $q->get_result();
        $row = $res ? $res->fetch_assoc() : null;

        if(!$row) {
            return [
                'owner_user_id' => intval($ownerUser['user_id']),
                'owner_username' => (string) $ownerUser['username'],
                'buddies' => [],
                'blocked' => [],
                'requests' => [],
                'relationships' => []
            ];
        }

        $buddies = bw_social_parse_packed_names($row['namesList']);
        $blocked = bw_social_parse_packed_names($row['blockList']);
        $requests = bw_social_parse_packed_names($row['requestList']);

        $relationships = array_merge(
            bw_social_relationship_rows($ownerUser, $buddies, 'buddy', 'accepted'),
            bw_social_relationship_rows($ownerUser, $blocked, 'blocked', 'blocked'),
            bw_social_relationship_rows($ownerUser, $requests, 'request', 'pending')
        );

        return [
            'owner_user_id' => intval($ownerUser['user_id']),
            'owner_username' => (string) $ownerUser['username'],
            'buddies' => $buddies,
            'blocked' => $blocked,
            'requests' => $requests,
            'relationships' => $relationships
        ];
    }

    function bw_get_social_lists_by_user_id($userId) {
        if(!function_exists('bw_resolve_username')) {
            return null;
        }

        $username = bw_resolve_username($userId);

        if(!$username) {
            return null;
        }

        return bw_get_social_lists_by_username($username);
    }

    function bw_get_current_user_social_lists() {
        if(!function_exists('bw_get_current_user')) {
            return null;
        }

        $user = bw_get_current_user();

        if(!$user) {
            return null;
        }

        return bw_get_social_lists_by_username($user['username']);
    }
}
?>
