'use strict'

CONFIG          = require './../shared/config.js'
lib             = {}
lib.express     = require 'express'
lib.session     = require 'express-session'
lib.levelup     = require 'levelup'
lib.crypto      = require 'crypto'
lib.bodyParser  = require 'body-parser'
lib.multer      = require 'multer'
lib.randtoken   = require 'rand-token'
UID             = lib.randtoken.uid
DB              = {}

LOG = ->
  date = new Date()
  process.stdout.write(date.toTimeString().split(' ')[0] + ' ')
  console.log.apply this, arguments

SHA1 = (str, callback) ->
  hmac = lib.crypto.createHmac 'sha1', CONFIG.CRYPTOKEY
  hmac.setEncoding 'hex'
  hmac.end str, 'utf8', ->
    callback hmac.read()

class Model
  keyName: ->
    return this.constructor.name + '_' + @key
  save: (callback) ->
    return unless this.savable?
    saveData = {}
    this.presave ->
      for properyName, propery of this
        continue if properyName is 'savable'
        saveData[properyName] = propery if this.savable[properyName]
      DB.put @keyName(), saveData, (error) =>
        if error
          LOG 'DBERROR:', 'saving model', @keyName(), 'Error:', error
          return callback error if callback?
        else
          callback false, value if callback?
  load: (key, callback) ->
    DB.get @keyName(), (error, value) =>
      if error
        if error.type is 'NotFoundError'
          return callback false if callback?
        else
          @log 'DBERROR:', 'getting model', @keyName(), 'Error:', error
          return callback false if callback?
      else
        for properyName, propery of value
          this[properyName] = propery if this.savable[properyName]
        callback true, value if callback?
  presave: (callback) ->
    callback()

class Team extends Model
  constructor: ->
    @savable = {
      members: true
      name: true
      managers: true
    }

class User extends Model
  constructor: ->
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

class Session extends Model
  constructor: ->
    @savable = {
      username: true
      expires: true
      token: true
    }

newSessionToken = (req) ->
  session = new Session()
  session.token = UID 32
  session.expires = (new Date().getTime()) + CONFIG.SESSIONLENGTH
  req.session.token = session.token
  req.session.expires = session.expires
  session.save()

module.exports = class Server
  constructor: ->

  init: ->
    DB = lib.levelup CONFIG.DBPATH
    @app = lib.express()
    @app.use lib.session {
      secret: CONFIG.SESSIONSECRET
      resave: no
      saveUninitialized: yes
      proxy: CONFIG.REVERSEPROXY
    }
    @app.use(lib.bodyParser.json())
    @app.use(lib.bodyParser.urlencoded({ extended: true }))
    @app.use(lib.multer())

    @route 'post', '/login', @loginRequest
    @route 'post', '/register', @registerRequest
    @authedRoute 'get', '/data', @dataRequest

    @server = @app.listen CONFIG.LISTEN, =>
      host = @server.address().address
      port = @server.address().port
      LOG 'Listening at http://%s:%s', host, port

  route: (method, uri, functor) ->
    @app[method] '/api' + uri, (req, res) => functor.apply this, [req, res]

  authedRoute: (method, uri, functor) ->
    self = this
    @app[method] '/api' + uri, (req, res) ->
      if req.headers['x-chow-token']? and req.session.token? and req.headers['x-chow-token'] is req.session.token
        if req.session.expires > (new Date().getTime())
          functor.apply self, [req, res]
        else
          res.sendStatus 404
      else if req.headers['x-chow-token']?
        session = new Session()
        session.load req.headers['x-chow-token'], (found) ->
          if found and req.headers['x-chow-token'] is found.token and found.expires > (new Date().getTime())
            req.session.token = found.token
            req.session.expires = found.expires
            functor.apply self, [req, res]
          else
            req.session.token = undefined
            res.sendStatus 404
      else
        res.sendStatus 404

  dataRequest: (req, res) ->
    res.send 'Logged in!'

  registerRequest: (req, res) ->
    if !req.body.username? or !req.body.password?
      res.send { error: 'Supply a username and password' }
    else
      user = new User()
      user.load req.body.username, (found) ->
        if found
          res.send { error: 'Username already taken' }
        else
          user.username = req.body.username
          user.password = req.body.password
          user.registered = (new Date().getTime())
          newSessionToken req
          user.save ->
            LOG 'registerRequest: new user registered:', req.body.username
            res.send 'ok'

  loginRequest: (req, res) ->
    if req.body.username? and req.body.password?
      user = new User()
      user.load req.body.username, (found) ->
        if found
          SHA1 req.body.password, (password) ->
            if found.password is password
              newSessionToken req
              res.send {
                username: req.body.username
                token: session.token
                expires: session.expires
              }
            else
              LOG 'loginRequest: failed log in for:', req.body.username, '- Password does not match:', found.password, password
              req.session.token = undefined
              res.redirect '/'
        else
          LOG 'loginRequest: failed log in for:', req.body.username, '- No username found by name', req.body.username
          req.session.token = undefined
          res.redirect '/'
    else
      req.session.token = undefined
      res.redirect '/'

