'use strict'

CONFIG = require './../shared/config.js'
request = require 'request'

HOST = 'http://localhost:' + CONFIG.LISTEN

describe 'API security', ->
  it 'should not allow you to get data without authing', (done) ->
    setTimeout ->
      request HOST + '/api/data', (error, resp, body) ->
        expect(resp.statusCode).to.equal(404)
        done()
    , 1000

  it 'should reject nonsense logins', (done) ->
    setTimeout ->
      request.post HOST + '/api/login', { username: 'asgfd24352', password: 'fake' }, (error, resp, body) ->
        reply = JSON.parse(resp.body)
        expect(reply.error).to.equal('Supply a username and password')
        done()
    , 1000
