'use strict';

var set = {};

set.ENV = 'dev';
if (process.env.ENV !== undefined) {
  set.ENV = process.env.ENV;
}

set.LISTEN = 9000;
if (process.env.LISTEN !== undefined) {
  set.LISTEN = process.env.LISTEN;
}

set.LOGPATH = 'stdout';
if (process.env.LOGPATH !== undefined) {
  set.LOGPATH = process.env.LOGPATH;
}

// Only used if in "dev" mode and using LevelDB instead of Redis
set.DBPATH = 'tmp/chow.db';
if (process.env.DBPATH !== undefined) {
  set.DBPATH = process.env.DBPATH;
}
set.DBSERVER = '127.0.0.1';
if (process.env.DBSERVER !== undefined) {
  set.DBSERVER = process.env.DBSERVER;
}
set.DBPORT = 6379;
if (process.env.DBPORT !== undefined) {
  set.DBPORT = process.env.DBPORT;
}

set.SESSIONLENGTH = 100000 * 1000;
if (process.env.SESSIONLENGTH !== undefined) {
  set.SESSIONLENGTH = process.env.SESSIONLENGTH;
}

set.CRYPTOKEY = 'I am a random key, this should be changed';
if (process.env.CRYPTOKEY !== undefined) {
  set.CRYPTOKEY = process.env.CRYPTOKEY;
}

set.SESSIONSECRET = 'I am different, but should also be changed';
if (process.env.SESSIONSECRET !== undefined) {
  set.SESSIONSECRET = process.env.SESSIONSECRET;
}

// Obey X-Forwarded-Proto - set to true if behind a load balancer, for instance.
set.REVERSEPROXY = false;
if (process.env.REVERSEPROXY !== undefined) {
  set.REVERSEPROXY = process.env.REVERSEPROXY;
}

module.exports = set;
