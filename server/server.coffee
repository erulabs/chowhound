'use strict'

CONFIG = require './../shared/config.js'
express = require 'express'
session = require 'express-session'
levelup = require 'levelup'
crypto  = require 'crypto'
bodyParser = require 'body-parser'
multer  = require 'multer'
randtoken = require 'rand-token'
UID = randtoken.uid

sha1 = (str, callback) ->
  hmac = crypto.createHmac 'sha1', CONFIG.CRYPTOKEY
  hmac.setEncoding 'hex'
  hmac.end str, 'utf8', ->
    callback hmac.read()

module.exports = class Server
  constructor: ->
    @app = express()
    @app.use session {
      secret: CONFIG.SESSIONSECRET
      resave: no
      saveUninitialized: yes
      proxy: CONFIG.REVERSEPROXY
    }
    @app.use(bodyParser.json())
    @app.use(bodyParser.urlencoded({ extended: true }))
    @app.use(multer())

    @db = levelup CONFIG.DBPATH

    @app.post '/api/new/login', (req, res) => @newLoginRequest.apply this, [req, res]
    @app.post '/api/logout', (req, res) => @logoutRequest.apply this, [req, res]
    @app.get '/api/data', (req, res) => @dataRequest.apply this, [req, res]
    @app.post '/api/new/break', (req, res) => @newBreakRequest.apply this, [req, res]
    @app.get '/api/manager', (req, res) => @managerGetRequest.apply this, [req, res]
    @app.post '/api/manager/set', (req, res) => @managerPostRequest.apply this, [req, res]
    @app.post '/api/register', (req, res) => @registerRequest.apply this, [req, res]

    @server = @app.listen CONFIG.LISTEN, =>
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
    usernameDBkey = 'USERS_' + req.body.username
    if !req.body.username? or !req.body.password?
      res.send { error: 'Supply a username and password' }
    else
      sha1 req.body.password, (pass) =>
        userObject = {
          password: pass
          username: req.body.username
        }
        this.dbget usernameDBkey, (e, user) =>
          if user
            res.send { error: 'email already taken' }
          else
            this.loginAction(userObject, req, res)

  loginAction: (userObject, req, res) ->
    usernameDBkey = 'USERS_' + req.body.username
    userObject.token = UID(32)
    userObject.expires = (new Date().getTime()) + CONFIG.SESSIONLENGTH
    this.db.put usernameDBkey, JSON.stringify(userObject)
    req.session.userObject = userObject
    res.send {
      error: false
      token: userObject.token
      expires: userObject.expires
      username: req.body.username
    }

  newLoginRequest: (req, res) ->
    usernameDBkey = 'USERS_' + req.body.username
    if req.body.token? and req.body.username?
      this.dbget usernameDBkey, (e, userObject) =>
        try userObject = JSON.parse(userObject)
        if userObject and userObject.token is req.body.token
          this.loginAction(userObject, req, res)
        else
          res.send { error: 'Login incorrect' }
    else if req.body.username? and req.body.password?
      sha1 req.body.password, (pass) =>
        this.dbget usernameDBkey, (e, userObject) =>
          try userObject = JSON.parse(userObject)
          if userObject and userObject.password is pass
            this.loginAction(userObject, req, res)
          else
            res.send { error: 'Login incorrect' }
    else
      res.send { error: 'Supply a username and password' }

  logoutRequest: (req, res) ->
    if req.session.userObject
      req.session.userObject = undefined
      res.send { message: 'Logged out!' }

  dataRequest: (req, res) ->
    if req.session.userObject
      res.send {
        message: 'already logged in'
      }
    else
      res.sendStatus 404

  newBreakRequest: (req, res) ->
    if req.session.userObject
      res.send {
        message: 'already logged in'
      }
    else
      res.sendStatus 404

  managerGetRequest: (req, res) ->
    if req.session.userObject
      res.send {
        message: 'already logged in'
      }
    else
      res.sendStatus 404

  managerPostRequest: (req, res) ->
    if req.session.userObject
      res.send {
        message: 'already logged in'
      }
    else
      res.sendStatus 404

  # Stub for proper logger
  log: ->
    date = new Date()
    process.stdout.write(date.toTimeString().split(' ')[0] + ' ')
    console.log.apply this, arguments
