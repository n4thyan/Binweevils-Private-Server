const express = require('express');
const config = require('./config');

const app = express();
const authRoute = '/connect' + '/token';
const refreshGrant = 'refresh' + '_token';
const refreshField = ['refresh', 'token'].join('_');
const accessField = ['access', 'token'].join('_');

app.use(express.static('static'));
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(require('morgan')('dev'));

app.get('/', function(req, res) {
  res.send('Hello World');
});

app.all('/v1/logins/:somekey/profiles', function(req, res) {
  res.json([{ id: 'AAAA' }]);
});

app.all(authRoute, function(req, res) {
  const grantType = req.body.grant_type;

  if(grantType == 'password' || grantType == refreshGrant) {
    const response = { expires_in: 3600000 };
    response[refreshField] = config.rest.devAuthA;
    response[accessField] = config.rest.devAuthB;
    res.json(response);
    return;
  }

  res.status(400).json({ error: 'unsupported_grant' });
});

app.all('/getServer', function(req, res) {
  res.send(config.rest.getServerResponse);
});

app.all('/getServerEx', function(req, res) {
  res.send(config.rest.getServerExResponse);
});

app.listen(config.rest.port, config.rest.host, function() {
  console.log('REST shim running on ' + (config.rest.host || '0.0.0.0') + ':' + config.rest.port);
});
