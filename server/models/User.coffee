'use strict'

Model = require './Model.coffee'

module.exports = class User extends Model
  constructor: ->
    @key = 'username'
    @savable = {
      password: true
      username: true
      registered: true
      teams: true
    }
    @password = ''
    @username = ''
    @registered = false
    @teams = {}
  presave: (callback) ->
    self = this
    SHA1 self.password, (password) ->
      self.password = password
      callback()
  newSessionToken: ->
    session = new Session()
    session.save()
    return session
