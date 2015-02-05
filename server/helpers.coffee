'use strict'

crypto = require 'crypto'

global.LOG = ->
  date = new Date()
  process.stdout.write(date.toTimeString().split(' ')[0] + ' ')
  if CONFIG.LOGPATH is 'stdout'
    console.log.apply this, arguments
  else
    console.log 'ill write to a file when im not so lazy'

global.SHA1 = (str, callback) ->
  hmac = crypto.createHmac 'sha1', CONFIG.CRYPTOKEY
  hmac.setEncoding 'hex'
  hmac.end str, 'utf8', -> callback hmac.read()
