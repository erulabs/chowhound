'use strict'

Model = require './Model.coffee'

module.exports = class User extends Model
  constructor: ->
    @key = 'username'
    @savable = {
      password: true
      encrypted: true
      username: true
      registered: true
      teams: true
      dotw: true
      starttime: true
      endtime: true
    }
    @password = ''
    @encrypted = ''
    @username = ''
    @registered = false
    @teams = {}
    @dotw = {
      mon: 0
      tue: 0
      wed: 0
      thu: 0
      fri: 0
      sat: 0
      sun: 0
    }
    @starttime = new Date()
    @endtime = new Date()
  presave: (callback) ->
    self = this
    SHA1 self.password, (password) ->
      self.encrypted = password
      callback()
  newSessionToken: ->
    session = new Session()
    session.username = @username
    session.save()
    return session
