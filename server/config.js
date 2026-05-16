const fs = require('fs');
const path = require('path');

function loadEnvFile(filePath) {
    if (!fs.existsSync(filePath)) return;

    const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);

    lines.forEach(line => {
        const trimmed = line.trim();

        if (!trimmed || trimmed.startsWith('#')) return;

        const equalsIndex = trimmed.indexOf('=');
        if (equalsIndex === -1) return;

        const key = trimmed.slice(0, equalsIndex).trim();
        let value = trimmed.slice(equalsIndex + 1).trim();

        if (!key || Object.prototype.hasOwnProperty.call(process.env, key)) return;

        if (
            (value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))
        ) {
            value = value.slice(1, -1);
        }

        process.env[key] = value;
    });
}

[
    path.resolve(__dirname, '..', '.env'),
    path.resolve(__dirname, '.env')
].forEach(loadEnvFile);

function stringValue(name, fallback) {
    const value = process.env[name];
    return value === undefined || value === '' ? fallback : value;
}

function intValue(name, fallback) {
    const value = process.env[name];
    if (value === undefined || value === '') return fallback;

    const parsed = parseInt(value, 10);
    return Number.isNaN(parsed) ? fallback : parsed;
}

module.exports = {
    db: {
        host: stringValue('DB_HOST', 'localhost'),
        user: stringValue('DB_USER', 'root'),
        password: stringValue('DB_PASSWORD', ''),
        database: stringValue('DB_NAME', 'bwps'),
        port: intValue('DB_PORT', 3306)
    },

    server: {
        bindHost: stringValue('NODE_BIND_HOST', ''),
        gameSocketPort: intValue('GAME_SOCKET_PORT', 9339),
        webSocketPort: intValue('WEB_SOCKET_PORT', 2087)
    },

    rest: {
        host: stringValue('REST_HOST', ''),
        port: intValue('REST_PORT', 1122),
        getServerResponse: stringValue('REST_GET_SERVER_RESPONSE', '127-0-0-1:10843'),
        getServerExResponse: stringValue('REST_GET_SERVER_EX_RESPONSE', '127-0-0-1:10842'),
        devAuthA: stringValue('REST_DEV_AUTH_A', 'dev-auth-a'),
        devAuthB: stringValue('REST_DEV_AUTH_B', 'dev-auth-b')
    },

    legacyShim: {
        host: stringValue('LEGACY_SHIM_HOST', '127.0.0.1'),
        port: intValue('LEGACY_SHIM_PORT', 10843)
    }
};
