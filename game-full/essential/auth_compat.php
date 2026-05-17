<?php
/**
 * Phase 5 auth compatibility helper.
 *
 * New local accounts should store modern PHP password_hash() values.
 * Old local legacy rows can still be checked during migration.
 */

function bwps_auth_hash($plainValue) {
    return password_hash($plainValue, PASSWORD_DEFAULT);
}

function bwps_auth_is_modern_hash($storedValue) {
    if(!is_string($storedValue) || $storedValue === '') {
        return false;
    }

    $info = password_get_info($storedValue);
    return isset($info['algo']) && $info['algo'] !== 0;
}

function bwps_auth_verify($plainValue, $storedValue) {
    if(!is_string($plainValue) || !is_string($storedValue)) {
        return false;
    }

    if(bwps_auth_is_modern_hash($storedValue)) {
        return password_verify($plainValue, $storedValue);
    }

    return hash_equals($storedValue, $plainValue);
}
?>
