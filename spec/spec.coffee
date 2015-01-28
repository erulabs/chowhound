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

  it 'should redirect back to the index on a login submission', (done) ->
    setTimeout ->
      request.post HOST + '/api/login', { username: 'asgfd24352', password: 'fake' }, (error, resp, body) ->
        expect(resp.body).to.equal('Moved Temporarily. Redirecting to /')
        done()
    , 1000
