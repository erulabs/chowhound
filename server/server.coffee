'use strict'

LISTEN = 9000
if process.env.LISTEN? then LISTEN = process.env.LISTEN

DBPATH = 'tmp/chow.db'
if process.env.DBPATH? then DBPATH = process.env.DBPATH

SESSIONLENGTH = 43200
if process.env.SESSIONLENGTH? then SESSIONLENGTH = process.env.SESSIONLENGTH

CRYPTOKEY = 'I am a random key, this should be changed'
if process.env.CRYPTOKEY? then CRYPTOKEY = process.env.CRYPTOKEY

SESSIONSECRET = 'I am different, but should also be changed'
if process.env.SESSIONSECRET? then SESSIONSECRET = process.env.SESSIONSECRET

# Obey X-Forwarded-Proto - set to true if behind a load balancer, for instance.
REVERSEPROXY = no
if process.env.REVERSEPROXY? then REVERSEPROXY = process.env.REVERSEPROXY

express = require 'express'
session = require 'express-session'
levelup = require 'levelup'
crypto  = require 'crypto'
bodyParser = require 'body-parser'
multer  = require 'multer'

sha1 = (str, callback) ->
  hmac = crypto.createHmac 'sha1', CRYPTOKEY
  hmac.setEncoding 'hex'
  hmac.end str, 'utf8', ->
    callback hmac.read()

module.exports = class Server
  constructor: ->
    @app = express()
    @app.use session {
      secret: SESSIONSECRET
      resave: no
      saveUninitialized: yes
      proxy: REVERSEPROXY
    }
    @app.use(bodyParser.json())
    @app.use(bodyParser.urlencoded({ extended: true }))
    @app.use(multer())

    @db = levelup DBPATH

    @app.post '/api/new/login', (req, res) => @newLoginRequest.apply this, [req, res]
    @app.get '/api/data', @dataRequest
    @app.post '/api/new/break', @newBreakRequest
    @app.get '/api/manager', @managerGetRequest
    @app.post '/api/manager/set', @managerPostRequest
    @app.post '/api/register', @registerRequest

    @server = @app.listen process.env.LISTEN, =>
      host = @server.address().address
      port = @server.address().port
      console.log 'Listening at http://%s:%s', host, port

    @dbget = (key, callback) =>
      @db.get key, (err, value) ->
        if err
          if err.type is 'NotFoundError'
            return callback undefined, undefined
          else
            return callback err, undefined
        else
          callback false, value

    @dbput: (key, value, callback) =>
      @db.put key, value, (err) ->
        if err
          return callback err
        else
          callback false, value

  registerRequest: (req, res) ->
    self = this
    if !req.body.username? or !req.body.password?
      res.send { error: 'Supply a username and password' }
    else
      sha1 req.body.password, (pass) ->
        userObject = {
          password: pass
        }
        self.dbget req.body.username, (e, user) ->
          if user
            res.send {
              error: 'email already taken'
            }
          else
            self.dbput req.body.username, userObject, (e, user) ->

  newLoginRequest: (req, res) ->
    self = this
    if !req.body.username? or !req.body.password?
      res.send { error: 'Supply a username and password' }
    else
      sha1 req.body.password, (pass) ->
        self.dbget req.body.username, (e, user) ->
          if user
            console.log user
          else
            res.send {
              error: 'no such user'
            }

  dataRequest: (req, res) ->
    if req.session.apikey
      res.send {
        message: 'already logged in'
      }
    else
      res.send {
        message: 'Hello'
      }

  newBreakRequest: (req, res) ->
    res.send {
      message: 'already logged in'
    }

  managerGetRequest: (req, res) ->
    res.send {
      message: 'already logged in'
    }

  managerPostRequest: (req, res) ->
    res.send {
      message: 'already logged in'
    }
