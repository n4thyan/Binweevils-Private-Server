const Weevil = require('./Weevil');
const filter = require('leo-profanity');

const FILTER_LANGUAGES = ['en', 'de', 'fr', 'es', 'it', 'pt', 'hi'];
const CHAT_MAX_LENGTH = 70;
const COMMAND_PREFIXES = ['!', '/'];
const INVISIBLE_OR_CONTROL_CHARS = /[\u0000-\u001F\u007F-\u009F\u00AD\u034F\u061C\u115F\u1160\u17B4\u17B5\u180E\u200B-\u200F\u202A-\u202E\u2060-\u206F\u2800\u3164\uFE00-\uFE0F\uFEFF]/u;
const SAFE_CHAT_CHARS = /^[\u0020-\u007E\u00A1-\u00AC\u00AE-\u00FF€£]+$/u;
const WORD_COMMANDS = ['help', 'commands', 'ping', 'online', 'room', 'modhelp'];

for (const language of FILTER_LANGUAGES) {
    try {
        filter.loadDictionary(language);
    }
    catch (error) {
        // leo-profanity only ships some dictionaries. Missing languages stay non-fatal.
    }
}

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

function findOnlineWeevil(name, weevilList, socketIdList) {
    const wanted = name.toLowerCase();

    for (const id in socketIdList) {
        const target = weevilList[parseInt(id)];
        if (target && target.loggedIn && target.nickname.toLowerCase() == wanted) {
            return target;
        }
    }

    return null;
}

function parseCommand(message) {
    const lower = message.toLowerCase();
    const prefix = message.charAt(0);

    if (COMMAND_PREFIXES.includes(prefix)) {
        const parts = message.slice(1).trim().split(/\s+/).filter(Boolean);
        return {
            command: (parts.shift() || '').toLowerCase(),
            parts,
            style: 'prefix'
        };
    }

    const parts = message.trim().split(/\s+/).filter(Boolean);
    const first = (parts.shift() || '').toLowerCase();

    if (first === 'cmd') {
        return {
            command: (parts.shift() || '').toLowerCase(),
            parts,
            style: 'word'
        };
    }

    if (WORD_COMMANDS.includes(lower)) {
        return {
            command: lower,
            parts: [],
            style: 'word'
        };
    }

    if (lower.startsWith('where ')) {
        return {
            command: 'where',
            parts: message.slice(6).trim().split(/\s+/).filter(Boolean),
            style: 'word'
        };
    }

    return null;
}

function handleCommand(weevil, message, weevilList, socketIdList) {
    const parsed = parseCommand(message);
    if (!parsed || !parsed.command) return false;

    const command = parsed.command;
    const parts = parsed.parts;

    switch (command) {
        case 'help':
        case 'commands':
            weevil.modMsg('Commands: help, ping, online, room, where weevil, cmd help. Symbols like slash or exclamation may not work in the old SWF chat box.');
            break;
        case 'ping':
            weevil.modMsg('Pong.');
            break;
        case 'online':
            weevil.modMsg('Online weevils: ' + countOnline(weevilList, socketIdList));
            break;
        case 'room':
            weevil.modMsg('Current room: ' + (weevil.currentRoomName || 'unknown') + ' #' + weevil.currentRoomId + '.');
            break;
        case 'where': {
            const name = parts.join(' ');
            if (!name) {
                weevil.modMsg('Usage: where weevilname');
                break;
            }

            const target = findOnlineWeevil(name, weevilList, socketIdList);
            if (!target) {
                weevil.modMsg(name + ' is not online.');
                break;
            }

            weevil.modMsg(target.nickname + ' is in ' + (target.currentRoomName || 'an unknown room') + ' #' + target.currentRoomId + '.');
            break;
        }
        case 'modhelp':
            if (weevil.isModerator == '1') {
                weevil.modMsg('Mod commands: cmd warn weevil message, cmd kick weevil. Prefix versions also work if the SWF allows them.');
            }
            else {
                weevil.modMsg('Unknown command. Try help.');
            }
            break;
        case 'warn': {
            if (weevil.isModerator != '1') {
                weevil.modMsg('Unknown command. Try help.');
                break;
            }

            const targetName = parts.shift();
            const warning = parts.join(' ') || 'Please follow the room rules.';
            const target = targetName ? findOnlineWeevil(targetName, weevilList, socketIdList) : null;

            if (!target) {
                weevil.modMsg('Usage: cmd warn weevilname message');
                break;
            }

            target.modMsg('Moderator warning: ' + warning);
            weevil.modMsg('Warning sent to ' + target.nickname + '.');
            console.log('[MOD][warn][' + weevil.nickname + ' -> ' + target.nickname + '] ' + warning);
            break;
        }
        case 'kick': {
            if (weevil.isModerator != '1') {
                weevil.modMsg('Unknown command. Try help.');
                break;
            }

            const targetName = parts.shift();
            const target = targetName ? findOnlineWeevil(targetName, weevilList, socketIdList) : null;

            if (!target) {
                weevil.modMsg('Usage: cmd kick weevilname');
                break;
            }

            target.modMsg('You have been kicked by a moderator.');
            console.log('[MOD][kick][' + weevil.nickname + ' -> ' + target.nickname + ']');
            target.socket.end();
            target.socket.destroy();
            break;
        }
        default:
            weevil.modMsg('Unknown command. Try help.');
            break;
    }

    console.log('[CHAT_COMMAND][' + parsed.style + '][' + weevil.nickname + '] ' + message);
    return true;
}

Weevil.prototype.sendPublicMessage = function(data, weevilList = undefined, socketIdList = undefined) {
    if (!this.loggedIn) {
        this.socket.end();
        this.socket.destroy();
        return;
    }

    if (!this.canSpeak) {
        this.chatSpamCount++;
        if (this.chatSpamCount >= 10) {
            this.modMsg('Slow down a bit.');
            this.socket.end();
            this.socket.destroy();
        }
        return;
    }

    const roomId = extractRoomId(data);
    let message = normalizeMessage(extractMessage(data));
    const validationError = validateMessage(message);

    if (validationError) {
        this.modMsg('That message contains unsupported or invisible characters.');
        console.log('[CHAT_REJECT][' + validationError + '][' + this.nickname + ']');
        return;
    }

    if (message.length > CHAT_MAX_LENGTH) {
        message = message.substring(0, CHAT_MAX_LENGTH);
    }

    applyChatCooldown(this);

    if (handleCommand(this, message, weevilList, socketIdList)) {
        return;
    }

    if (this.chatFilter && this.chatFilter.check(message.toLowerCase())) {
        this.warnAmt++;
        this.modMsg('That word is filtered. The message was cleaned before being sent.');
        message = this.chatFilter.clean(message);
    }

    console.log('[CHAT][' + roomId + '][' + this.nickname + '] ' + message);
    sendRoomMessage(this, roomId, message, weevilList, socketIdList);
};

module.exports = {
    CHAT_MAX_LENGTH,
    FILTER_LANGUAGES,
    COMMAND_PREFIXES,
    WORD_COMMANDS
};
