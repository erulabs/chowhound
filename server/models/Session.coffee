'use strict'

Model = require './Model.coffee'
rand_token = require 'rand-token'
UID = rand_token.uid

module.exports = class Session extends Model
  constructor: ->
    @key = 'token'
    @savable = {
      username: true
      expires: true
      token: true
    }
    @token = UID 32
    @expires = (new Date().getTime()) + CONFIG.SESSIONLENGTH
    @username = ''
