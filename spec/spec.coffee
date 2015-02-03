'use strict'

CONFIG = require './../shared/config.js'
request = require 'request'

Server = require './../server/Server.coffee'
Model = require './../server/models/Model.coffee'
Session = require './../server/models/Session.coffee'
Team = require './../server/models/Team.coffee'
User = require './../server/models/User.coffee'
UserCtrl = require './../server/controllers/User.coffee'

HOST = 'http://localhost:' + CONFIG.LISTEN

describe 'Model behavior', ->
  describe 'should have core functions', ->
    it 'keyName', -> expect(Model::keyName).to.be.a 'function'
    it 'del', -> expect(Model::del).to.be.a 'function'
    it 'save', -> expect(Model::save).to.be.a 'function'
    it 'load', -> expect(Model::load).to.be.a 'function'
    it 'presave', -> expect(Model::presave).to.be.a 'function'
  it 'should return an instance of a model without exception', ->
    myModel = new Model()
    expect(myModel).to.be.an.instanceof Model
  describe 'instance behavior', ->
    it 'should return a proper keyName', ->
      myModel = new Model()
      expect(myModel.keyName('foo')).to.equal 'Model_foo'
  describe 'extended class behavior', ->
    it 'should return a proper keyName', ->
      myModel = new Session()
      myModel.token = 'foobar'
      expect(myModel.keyName()).to.equal 'Session_foobar'

describe 'Session behavior', ->
  myModel = new Session()
  describe 'token', ->
    it 'is created', -> expect(myModel.token).to.be.a('string')
    it 'is properly formatted', -> expect(myModel.token.length).to.equal(32)

describe 'API security', ->
  it 'should not be hosting anything at the root path', (done) ->
    request HOST + '/', (error, resp, body) ->
      expect(resp.statusCode).to.equal(404)
      done()

  it 'should not allow you to get data without authing', (done) ->
    request HOST + '/api/data', (error, resp, body) ->
      expect(resp.statusCode).to.equal(404)
      done()

  it 'should redirect back to the index on a login submission', (done) ->
    request.post HOST + '/api/login', { username: 'asgfd24352', password: 'fake' }, (error, resp, body) ->
      expect(resp.body).to.equal('Moved Temporarily. Redirecting to /')
      done()
