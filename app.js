
/**
 * Module dependencies.
 */

var express = require('express');
require('coffee-script');
var fs = require('fs');
var Balancer = require('./lib/balancer');
var monitor = require('./lib/monitor')

var config = JSON.parse(fs.readFileSync('./config/config.json', 'utf8'));
var balancer = new Balancer(monitor);
balancer.listen(8080);


var app = monitor.createMonitor();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.compiler({ src: __dirname + '/public', enable: ['sass'] }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

// Only listen on $ node app.js

if (!module.parent) {
  app.listen(3000);
  console.log("Express server listening on port %d", app.address().port);
}
