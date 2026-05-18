var db = require('./db');

function normaliseUsername(username) {
    if(username === undefined || username === null) {
        return '';
    }

    return String(username).trim();
}

function getUserByUsername(username) {
    username = normaliseUsername(username);

    return new Promise(resolve => {
        if(username === '') {
            resolve(null);
            return;
        }

        db.query(
            'SELECT id, username FROM users WHERE username = ? LIMIT 1',
            [username],
            function(err, result) {
                if(err || !result || result.length === 0) {
                    if(err) console.log(err);
                    resolve(null);
                    return;
                }

                resolve({
                    id: parseInt(result[0].id),
                    username: result[0].username
                });
            }
        );
    });
}

function upsertSocialLink(ownerUserId, targetUserId, targetLegacyUsername, relationType, status, source) {
    return new Promise(resolve => {
        ownerUserId = parseInt(ownerUserId);
        targetUserId = targetUserId === null || targetUserId === undefined ? null : parseInt(targetUserId);
        targetLegacyUsername = normaliseUsername(targetLegacyUsername);
        source = source || 'dual_write';

        if(!ownerUserId || !relationType || !status) {
            resolve(false);
            return;
        }

        db.query(
            `INSERT INTO user_social_links
                (owner_user_id, target_user_id, target_legacy_username, relation_type, status, source)
             VALUES (?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
                status = VALUES(status),
                source = VALUES(source),
                updated_at = CURRENT_TIMESTAMP`,
            [ownerUserId, targetUserId, targetLegacyUsername, relationType, status, source],
            function(err) {
                if(err) {
                    console.log('[socialLinks] dual-write failed:', err);
                    resolve(false);
                    return;
                }

                resolve(true);
            }
        );
    });
}

async function recordPendingBuddyRequest(senderUsername, targetUsername) {
    senderUsername = normaliseUsername(senderUsername);
    targetUsername = normaliseUsername(targetUsername);

    if(senderUsername === '' || targetUsername === '' || senderUsername === targetUsername) {
        return false;
    }

    var sender = await getUserByUsername(senderUsername);
    var target = await getUserByUsername(targetUsername);

    if(!sender || !target) {
        return false;
    }

    return upsertSocialLink(
        target.id,
        sender.id,
        sender.username,
        'request',
        'pending',
        'dual_write'
    );
}

module.exports = {
    getUserByUsername,
    upsertSocialLink,
    recordPendingBuddyRequest
};
