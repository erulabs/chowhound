'use strict'

crypto = require 'crypto'

global.LOG = ->
  date = new Date()
  process.stdout.write(date.toTimeString().split(' ')[0] + ' ')
  console.log.apply this, arguments

global.SHA1 = (str, callback) ->
  hmac = crypto.createHmac 'sha1', CONFIG.CRYPTOKEY
  hmac.setEncoding 'hex'
  hmac.end str, 'utf8', -> callback hmac.read()
