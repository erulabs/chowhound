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
randtoken = require 'rand-token'
UID = randtoken.uid

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
    @app.get '/api/data', (req, res) => @dataRequest.apply this, [req, res]
    @app.post '/api/new/break', (req, res) => @newBreakRequest.apply this, [req, res]
    @app.get '/api/manager', (req, res) => @managerGetRequest.apply this, [req, res]
    @app.post '/api/manager/set', (req, res) => @managerPostRequest.apply this, [req, res]
    @app.post '/api/register', (req, res) => @registerRequest.apply this, [req, res]

    @server = @app.listen process.env.LISTEN, =>
      host = @server.address().address
      port = @server.address().port
      console.log 'Listening at http://%s:%s', host, port

    @dbget = (key, callback) =>
      @db.get key, (err, value) =>
        if err
          if err.type is 'NotFoundError'
            return callback undefined, undefined
          else
            @log 'DBERROR', err
            return callback err, undefined
        else
          callback false, value

    @dbput = (key, value, callback) =>
      @db.put key, value, (err) =>
        if err
          @log 'DBERROR', err
          return callback err
        else
          callback false, value

  registerRequest: (req, res) ->
    if !req.body.username? or !req.body.password?
      res.send { error: 'Supply a username and password' }
    else
      sha1 req.body.password, (pass) =>
        userObject = {
          password: pass
          username: req.body.username
        }
        this.dbget req.body.username, (e, user) =>
          if user
            res.send { error: 'email already taken' }
          else
            this.loginAction(userObject, req, res)

  loginAction: (userObject, req, res) ->
    userObject.token = UID(32)
    userObject.expires = (new Date().getTime()) + SESSIONLENGTH
    this.db.put req.body.username, JSON.stringify(userObject)
    req.session.userObject = userObject
    res.send {
      error: false
      token: userObject.token
      expires: userObject.expires
      username: req.body.username
    }

  newLoginRequest: (req, res) ->
    if req.body.token? and req.body.username?
      this.dbget req.body.username, (e, userObject) =>
        try userObject = JSON.parse(userObject)
        if userObject and userObject.token is req.body.token
          this.loginAction(userObject, req, res)
        else
          res.send { error: 'Login incorrect' }
    else if req.body.username? and req.body.password?
      sha1 req.body.password, (pass) =>
        this.dbget req.body.username, (e, userObject) =>
          try userObject = JSON.parse(userObject)
          if userObject and userObject.password is pass
            this.loginAction(userObject, req, res)
          else
            res.send { error: 'Login incorrect' }
    else
      res.send { error: 'Supply a username and password' }

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

  # Stub for proper logger
  log: ->
    date = new Date()
    process.stdout.write(date.toTimeString().split(' ')[0] + ' ')
    console.log.apply this, arguments
