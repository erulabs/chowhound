'use strict';

var set = {};

set.LISTEN = 9000;
if (process.env.LISTEN !== undefined) {
  set.LISTEN = process.env.LISTEN;
}

set.DBPATH = 'tmp/chow.db';
if (process.env.DBPATH !== undefined) {
  set.DBPATH = process.env.DBPATH;
}

set.SESSIONLENGTH = 43200;
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
