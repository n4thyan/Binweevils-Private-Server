require('./chatRuntimePatch');

var BinWeevils = require("./BinWeevils");
var BinWeevilsWeb = require("./BinWeevilsWeb");
var config = require("./config");

var s = new BinWeevils(config.server.bindHost, config.server.gameSocketPort);
var x = new BinWeevilsWeb(config.server.bindHost, config.server.webSocketPort);

s.runServer();
x.runServer();