const Weevil = require('./Weevil');

const CHAT_MAX_LENGTH = 70;
const SYMBOL_COMMAND_PREFIXES = ['!', '/'];
const WORD_COMMAND_PREFIX = 'cmd';
const CHAT_DEBUG = process.env.BW_CHAT_DEBUG === '1';

const CHAT_MUTES = new Map();

const INVISIBLE_OR_CONTROL_CHARS = /[\u0000-\u001F\u007F-\u009F\u00AD\u034F\u061C\u115F\u1160\u17B4\u17B5\u180E\u200B-\u200F\u202A-\u202E\u2060-\u206F\u2800\u3164\uFE00-\uFE0F\uFEFF]/u;
const SAFE_CHAT_CHARS = /^[\u0020-\u007E\u00A1-\u00AC\u00AE-\u00FF£]+$/u;

const BASIC_SLUR_PATTERNS = [
    /\bn[\W_]*[i1!][\W_]*[gq9][\W_]*[gq9][\W_]*[e3][\W_]*r\b/i,
    /\bn[\W_]*[i1!][\W_]*[gq9][\W_]*[gq9][\W_]*a\b/i,
    /\bc[\W_]*o[\W_]*o[\W_]*n\b/i,
    /\bp[\W_]*a[\W_]*k[\W_]*[i1!]\b/i,
    /\bch[\W_]*[i1!][\W_]*n[\W_]*k\b/i,
    /\bk[\W_]*[i1!][\W_]*k[\W_]*[e3]\b/i,
    /\bs[\W_]*p[\W_]*[i1!][\W_]*c\b/i
];

function extractRoomId(data) {
    const match = data.match(/<body[^>]*\sr=['"]([^'"]+)['"]/);
    return match ? match[1] : '-1';
}

function extractMessage(data) {
    const match = data.match(/<!\[CDATA\[([\s\S]*?)\]\]>/);
    return match ? match[1] : '';
}

function normalizeMessage(message) {
    if (message == null) return '';

    return message
        .toString()
        .replace(/<[^>]*>/g, '')
        .replace(/[<>]/g, '')
        .replace(/\]\]>/g, '')
        .replace(/\s+/g, ' ')
        .trim();
}

function validateMessage(message) {
    if (!message) return 'empty';
    if (INVISIBLE_OR_CONTROL_CHARS.test(message)) return 'invisible';
    if (!SAFE_CHAT_CHARS.test(message)) return 'unsupported';
    return null;
}

function containsBlockedSlur(message) {
    return BASIC_SLUR_PATTERNS.some(pattern => pattern.test(message));
}

function cleanSystemText(message) {
    return String(message == null ? '' : message)
        .replace(/[<>]/g, '')
        .replace(/&/g, 'and')
        .replace(/\s+/g, ' ')
        .trim()
        .substring(0, 180);
}

function systemMsg(weevil, message) {
    if (weevil && typeof weevil.modMsg === 'function') {
        weevil.modMsg(cleanSystemText(message));
    }
}

function isModerator(weevil) {
    return weevil && String(weevil.isModerator) === '1';
}

function getDisplayName(weevil) {
    return weevil && weevil.nickname ? weevil.nickname : 'unknown';
}

function normaliseName(name) {
    return String(name == null ? '' : name).trim().toLowerCase();
}

function applyChatCooldown(weevil) {
    weevil.canSpeak = false;
    weevil.chatSpamTimer = setInterval(weevil.publicMessageTimer, 500, weevil);
}

function sendRoomMessage(weevil, roomId, message, weevilList, socketIdList) {
    const packet = "<msg t='sys'><body action='pubMsg' r='" + roomId + "'><user id='" + weevil.userID + "' /><txt><![CDATA[" + message + "]]></txt></body></msg>";

    for (const id in socketIdList) {
        const target = weevilList[parseInt(id)];
        if (target && target.currentRoomId == parseInt(roomId)) {
            target.send(packet);
        }
    }
}

function countOnline(weevilList, socketIdList) {
    let count = 0;
    for (const id in socketIdList) {
        const target = weevilList[parseInt(id)];
        if (target && target.loggedIn && !target.destroyed) count++;
    }
    return count;
}

function listOnlineMods(weevilList, socketIdList) {
    const mods = [];

    for (const id in socketIdList) {
        const target = weevilList[parseInt(id)];
        if (target && target.loggedIn && !target.destroyed && isModerator(target)) {
            mods.push(target.nickname);
        }
    }

    return mods;
}

function findOnlineWeevil(name, weevilList, socketIdList) {
    const wanted = normaliseName(name);

    for (const id in socketIdList) {
        const target = weevilList[parseInt(id)];
        if (target && target.loggedIn && target.nickname && target.nickname.toLowerCase() == wanted) {
            return target;
        }
    }

    return null;
}

function parseCommand(message) {
    const prefix = message.charAt(0);

    if (SYMBOL_COMMAND_PREFIXES.includes(prefix)) {
        const parts = message.slice(1).trim().split(/\s+/).filter(Boolean);
        return {
            command: (parts.shift() || '').toLowerCase(),
            parts,
            style: 'symbol'
        };
    }

    const parts = message.trim().split(/\s+/).filter(Boolean);
    const first = (parts.shift() || '').toLowerCase();

    if (first !== WORD_COMMAND_PREFIX) {
        return null;
    }

    return {
        command: (parts.shift() || '').toLowerCase(),
        parts,
        style: 'word'
    };
}

function getMuteRemainingSeconds(username) {
    const key = normaliseName(username);
    const until = CHAT_MUTES.get(key);

    if (!until) return 0;

    const now = Math.floor(Date.now() / 1000);
    const remaining = until - now;

    if (remaining <= 0) {
        CHAT_MUTES.delete(key);
        return 0;
    }

    return remaining;
}

function muteUser(username, minutes) {
    const safeMinutes = Math.max(1, Math.min(parseInt(minutes, 10) || 5, 1440));
    const until = Math.floor(Date.now() / 1000) + (safeMinutes * 60);
    CHAT_MUTES.set(normaliseName(username), until);
    return { minutes: safeMinutes, until };
}

function unmuteUser(username) {
    return CHAT_MUTES.delete(normaliseName(username));
}

function formatDuration(seconds) {
    const mins = Math.ceil(seconds / 60);
    if (mins <= 1) return 'about 1 minute';
    return 'about ' + mins + ' minutes';
}

function requireModerator(weevil) {
    if (!isModerator(weevil)) {
        systemMsg(weevil, 'Unknown command. Try cmd help.');
        return false;
    }

    return true;
}

function handleCommand(weevil, message, weevilList, socketIdList) {
    const parsed = parseCommand(message);
    if (!parsed || !parsed.command) return false;

    const command = parsed.command;
    const parts = parsed.parts;

    switch (command) {
        case 'help':
        case 'commands':
            systemMsg(weevil, 'Commands: cmd help, /help, !help, cmd ping, /online, /room, /where weevilname. Mods can use /modhelp.');
            break;

        case 'ping':
            systemMsg(weevil, 'Pong.');
            break;

        case 'online':
            systemMsg(weevil, 'Online weevils: ' + countOnline(weevilList, socketIdList));
            break;

        case 'room':
            systemMsg(weevil, 'Current room: ' + (weevil.currentRoomName || 'unknown') + ' #' + weevil.currentRoomId + '.');
            break;

        case 'where': {
            const name = parts.join(' ');
            if (!name) {
                systemMsg(weevil, 'Usage: /where weevilname');
                break;
            }

            const target = findOnlineWeevil(name, weevilList, socketIdList);
            if (!target) {
                systemMsg(weevil, name + ' is not online.');
                break;
            }

            systemMsg(weevil, target.nickname + ' is in ' + (target.currentRoomName || 'an unknown room') + ' #' + target.currentRoomId + '.');
            break;
        }

        case 'modhelp':
        case 'adminhelp':
            if (!requireModerator(weevil)) break;
            systemMsg(weevil, 'Mod commands: /warn user reason, /mute user minutes reason, /unmute user, /kick user reason, /whois user, /mods.');
            break;

        case 'mods': {
            if (!requireModerator(weevil)) break;
            const mods = listOnlineMods(weevilList, socketIdList);
            systemMsg(weevil, 'Online mods: ' + (mods.length ? mods.join(', ') : 'none'));
            break;
        }

        case 'whois': {
            if (!requireModerator(weevil)) break;

            const targetName = parts.shift();
            const target = targetName ? findOnlineWeevil(targetName, weevilList, socketIdList) : null;

            if (!target) {
                systemMsg(weevil, 'Usage: /whois weevilname');
                break;
            }

            const muteRemaining = getMuteRemainingSeconds(target.nickname);
            systemMsg(
                weevil,
                target.nickname +
                ' | id ' + target.idx +
                ' | socket ' + target.socketID +
                ' | mod ' + target.isModerator +
                ' | room ' + (target.currentRoomName || 'unknown') + ' #' + target.currentRoomId +
                ' | loc ' + target.currentLocId +
                ' | muted ' + (muteRemaining > 0 ? formatDuration(muteRemaining) : 'no')
            );
            break;
        }

        case 'warn': {
            if (!requireModerator(weevil)) break;

            const targetName = parts.shift();
            const warning = parts.join(' ') || 'Please follow the room rules.';
            const target = targetName ? findOnlineWeevil(targetName, weevilList, socketIdList) : null;

            if (!target) {
                systemMsg(weevil, 'Usage: /warn weevilname message');
                break;
            }

            systemMsg(target, 'Moderator warning: ' + warning);
            systemMsg(weevil, 'Warning sent to ' + target.nickname + '.');
            console.log('[MOD][warn][' + getDisplayName(weevil) + ' -> ' + getDisplayName(target) + '] ' + warning);
            break;
        }

        case 'mute': {
            if (!requireModerator(weevil)) break;

            const targetName = parts.shift();
            const minutesRaw = parts.shift();
            const target = targetName ? findOnlineWeevil(targetName, weevilList, socketIdList) : null;

            if (!target || !minutesRaw) {
                systemMsg(weevil, 'Usage: /mute weevilname minutes reason');
                break;
            }

            if (target.socketID === weevil.socketID) {
                systemMsg(weevil, 'You cannot mute yourself.');
                break;
            }

            const reason = parts.join(' ') || 'No reason given.';
            const mute = muteUser(target.nickname, minutesRaw);

            systemMsg(target, 'You have been muted for ' + mute.minutes + ' minute(s). Reason: ' + reason);
            systemMsg(weevil, target.nickname + ' muted for ' + mute.minutes + ' minute(s).');
            console.log('[MOD][mute][' + getDisplayName(weevil) + ' -> ' + getDisplayName(target) + '][' + mute.minutes + 'm] ' + reason);
            break;
        }

        case 'unmute': {
            if (!requireModerator(weevil)) break;

            const targetName = parts.shift();

            if (!targetName) {
                systemMsg(weevil, 'Usage: /unmute weevilname');
                break;
            }

            const target = findOnlineWeevil(targetName, weevilList, socketIdList);
            const removed = unmuteUser(targetName);

            if (target) {
                systemMsg(target, 'You have been unmuted by a moderator.');
            }

            systemMsg(weevil, removed ? targetName + ' unmuted.' : targetName + ' was not muted.');
            console.log('[MOD][unmute][' + getDisplayName(weevil) + ' -> ' + targetName + ']');
            break;
        }

        case 'kick': {
            if (!requireModerator(weevil)) break;

            const targetName = parts.shift();
            const target = targetName ? findOnlineWeevil(targetName, weevilList, socketIdList) : null;

            if (!target) {
                systemMsg(weevil, 'Usage: /kick weevilname reason');
                break;
            }

            if (target.socketID === weevil.socketID) {
                systemMsg(weevil, 'You cannot kick yourself.');
                break;
            }

            const reason = parts.join(' ') || 'No reason given.';

            systemMsg(target, 'You have been kicked by a moderator. Reason: ' + reason);
            systemMsg(weevil, target.nickname + ' has been kicked.');
            console.log('[MOD][kick][' + getDisplayName(weevil) + ' -> ' + getDisplayName(target) + '] ' + reason);

            setTimeout(function() {
                try {
                    target.socket.end();
                    target.socket.destroy();
                }
                catch (err) {
                    console.log('[MOD][kick-error][' + getDisplayName(target) + '] ' + err.message);
                }
            }, 250);
            break;
        }

        default:
            systemMsg(weevil, 'Unknown command. Try cmd help.');
            break;
    }

    console.log('[CHAT_COMMAND][' + parsed.style + '][' + getDisplayName(weevil) + '] ' + message);
    return true;
}

Weevil.prototype.sendPublicMessage = function(data, weevilList = undefined, socketIdList = undefined) {
    if (!this.loggedIn) {
        this.socket.end();
        this.socket.destroy();
        return;
    }

    const muteRemaining = getMuteRemainingSeconds(this.nickname);
    if (muteRemaining > 0) {
        systemMsg(this, 'You are muted for ' + formatDuration(muteRemaining) + '.');
        return;
    }

    if (!this.canSpeak) {
        this.chatSpamCount++;
        if (this.chatSpamCount >= 10) {
            systemMsg(this, 'Slow down a bit.');
            this.socket.end();
            this.socket.destroy();
        }
        return;
    }

    const roomId = extractRoomId(data);
    const rawMessage = extractMessage(data);
    let message = normalizeMessage(rawMessage);

    if (CHAT_DEBUG) {
        console.log('[CHAT_RAW][' + roomId + '][' + this.nickname + '] ' + JSON.stringify(rawMessage));
        console.log('[CHAT_NORMALIZED][' + roomId + '][' + this.nickname + '] ' + JSON.stringify(message));
    }

    const validationError = validateMessage(message);

    if (validationError) {
        systemMsg(this, 'That message contains unsupported or invisible characters.');
        console.log('[CHAT_REJECT][' + validationError + '][' + this.nickname + '] ' + JSON.stringify(message));
        return;
    }

    if (message.length > CHAT_MAX_LENGTH) {
        message = message.substring(0, CHAT_MAX_LENGTH);
    }

    applyChatCooldown(this);

    if (handleCommand(this, message, weevilList, socketIdList)) {
        return;
    }

    if (containsBlockedSlur(message)) {
        this.warnAmt++;
        systemMsg(this, 'That message is blocked.');
        console.log('[CHAT_BLOCKED_SLUR][' + this.nickname + '] ' + JSON.stringify(message));
        return;
    }

    console.log('[CHAT][' + roomId + '][' + this.nickname + '] ' + message);
    sendRoomMessage(this, roomId, message, weevilList, socketIdList);
};

module.exports = {
    CHAT_MAX_LENGTH,
    SYMBOL_COMMAND_PREFIXES,
    WORD_COMMAND_PREFIX,
    CHAT_DEBUG
};
