<?php
/**
 * Read-only user identity adapter.
 *
 * This file starts the database normalisation track without changing the old
 * SWF/PHP response shapes. New code can resolve stable numeric users.id values
 * while legacy endpoints can continue using username/ownerName/weevilName where
 * the Flash client expects them.
 *
 * Rules:
 * - read-only helper layer for now
 * - no table rewrites
 * - no response shape changes
 * - no login/logout/session behaviour changes
 */

if(!function_exists('bw_identity_db')) {
    function bw_identity_db() {
        static $bw_identity_connection = null;

        if($bw_identity_connection instanceof mysqli && !$bw_identity_connection->connect_errno) {
            return $bw_identity_connection;
        }

        $bw_identity_connection = @new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

        if($bw_identity_connection->connect_errno) {
            return null;
        }

        if(method_exists($bw_identity_connection, 'set_charset')) {
            @$bw_identity_connection->set_charset('utf8mb4');
        }

        return $bw_identity_connection;
    }

    function bw_identity_normalise_username($username) {
        $username = trim((string) $username);

        if($username === '') {
            return '';
        }

        return $username;
    }

    function bw_identity_user_public_shape($row) {
        if(!$row || !is_array($row)) {
            return null;
        }

        return [
            'user_id' => intval($row['id']),
            'id' => intval($row['id']),
            'username' => (string) $row['username'],
            'level' => isset($row['level']) ? intval($row['level']) : 1,
            'xp' => isset($row['xp']) ? intval($row['xp']) : 0,
            'mulch' => isset($row['mulch']) ? intval($row['mulch']) : 0,
            'dosh' => isset($row['dosh']) ? intval($row['dosh']) : 0,
            'tycoon' => isset($row['tycoon']) ? intval($row['tycoon']) : 0,
            'isModerator' => isset($row['isModerator']) ? intval($row['isModerator']) : 0,
            'active' => isset($row['active']) ? intval($row['active']) : 1,
            'bannedUntil' => isset($row['bannedUntil']) ? intval($row['bannedUntil']) : 0
        ];
    }

    function bw_get_user_by_username($username) {
        $username = bw_identity_normalise_username($username);

        if($username === '') {
            return null;
        }

        $db = bw_identity_db();

        if(!$db) {
            return null;
        }

        $q = $db->prepare(
            "SELECT `id`, `username`, `level`, `xp`, `mulch`, `dosh`, `tycoon`, `isModerator`, `active`, `bannedUntil`
             FROM `users`
             WHERE `username` = ?
             LIMIT 1;"
        );

        if(!$q) {
            return null;
        }

        $q->bind_param('s', $username);
        $q->execute();

        $res = $q->get_result();
        $row = $res ? $res->fetch_assoc() : null;

        return bw_identity_user_public_shape($row);
    }

    function bw_get_user_by_id($userId) {
        $userId = intval($userId);

        if($userId <= 0) {
            return null;
        }

        $db = bw_identity_db();

        if(!$db) {
            return null;
        }

        $q = $db->prepare(
            "SELECT `id`, `username`, `level`, `xp`, `mulch`, `dosh`, `tycoon`, `isModerator`, `active`, `bannedUntil`
             FROM `users`
             WHERE `id` = ?
             LIMIT 1;"
        );

        if(!$q) {
            return null;
        }

        $q->bind_param('i', $userId);
        $q->execute();

        $res = $q->get_result();
        $row = $res ? $res->fetch_assoc() : null;

        return bw_identity_user_public_shape($row);
    }

    function bw_resolve_user_id($username) {
        $user = bw_get_user_by_username($username);

        if(!$user) {
            return null;
        }

        return intval($user['user_id']);
    }

    function bw_resolve_username($userId) {
        $user = bw_get_user_by_id($userId);

        if(!$user) {
            return null;
        }

        return (string) $user['username'];
    }

    function bw_get_current_user() {
        if(!isset($_COOKIE['weevil_name']) || !isset($_COOKIE['sessionId'])) {
            return null;
        }

        $username = bw_identity_normalise_username($_COOKIE['weevil_name']);
        $sessionId = trim((string) $_COOKIE['sessionId']);

        if($username === '' || $sessionId === '') {
            return null;
        }

        if(function_exists('confirmSessionKey') && confirmSessionKey($username, $sessionId) !== true) {
            return null;
        }

        return bw_get_user_by_username($username);
    }
}
?>
