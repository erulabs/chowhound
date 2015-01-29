'use strict'

Model = require './Model.coffee'

module.exports = class User extends Model
  constructor: ->
    @key = 'username'
    @savable = {
      password: true
      username: true
      registered: true
    }
  presave: (callback) ->
    self = this
    SHA1 self.password, (password) ->
      self.password = password
      callback()
  newSessionToken: ->
    session = new Session()
    session.token = UID 32
    session.expires = (new Date().getTime()) + CONFIG.SESSIONLENGTH
    session.save()
    return session
