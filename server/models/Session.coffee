'use strict'

Model = require './Model.coffee'

module.exports = class Session extends Model
  constructor: ->
    @key = 'token'
    @savable = {
      username: true
      expires: true
      token: true
    }
