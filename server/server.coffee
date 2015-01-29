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
  keyName: (key) ->
    if key
      return this.constructor.name + '_' + key
    else
      return this.constructor.name + '_' + this[@key]
  del: (callback) ->
    DB.del self.keyName(), callback
  save: (callback) ->
    return unless this.savable?
    saveData = {}
    self = this
    this.presave ->
      for item, _p of self.savable
        saveData[item] = self[item] if self[item]?
      #LOG 'DB saving', self.keyName(), JSON.stringify(saveData)
      DB.put self.keyName(), JSON.stringify(saveData), (error) ->
        if error
          LOG 'DBERROR:', 'saving model', self.keyName(), 'Error:', error
          return callback error if callback?
        else
          callback false if callback?
  load: (key, callback) ->
    self = this
    DB.get self.keyName(key), (error, raw) ->
      if error
        if error.type is 'NotFoundError'
          return callback false if callback?
        else
          LOG 'DBERROR:', 'getting model', self.keyName(), 'Error:', error
          return callback false if callback?
      else
        try value = JSON.parse raw
        for properyName, propery of value
          self[properyName] = propery if self.savable[properyName]
        callback value if callback?
  presave: (callback) ->
    callback()

class Team extends Model
  constructor: ->
    @key = 'name'
    @savable = {
      members: true
      name: true
      managers: true
    }

class User extends Model
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

class Session extends Model
  constructor: ->
    @key = 'token'
    @savable = {
      username: true
      expires: true
      token: true
    }

module.exports = class Server
  constructor: ->

  init: ->
    DB = lib.levelup CONFIG.DBPATH
    @app = lib.express()
    @app.use lib.session {
      secret: CONFIG.SESSIONSECRET
      proxy: CONFIG.REVERSEPROXY
      resave: yes
      saveUninitialized: no
    }
    @app.use(lib.bodyParser.json())
    @app.use(lib.bodyParser.urlencoded({ extended: true }))
    @app.use(lib.multer())

    @route 'post', '/login', @loginRequest
    @route 'post', '/register', @registerRequest
    @authedRoute 'get', '/data', @dataRequest
    @authedRoute 'post', '/logout', @logoutRequest

    @server = @app.listen CONFIG.LISTEN, =>
      host = @server.address().address
      port = @server.address().port
      LOG 'Listening at http://%s:%s', host, port

  route: (method, uri, functor) ->
    @app[method] '/api' + uri, (req, res) => functor.apply this, [req, res]

  authedRoute: (method, uri, functor) ->
    self = this
    @app[method] '/api' + uri, (req, res) ->
      token = req.headers['x-chow-token']
      now = (new Date().getTime())
      #LOG 'incoming token', token, req.session.token
      if token? and req.session.token? and token is req.session.token and req.session.expires > now
        #LOG 'authed by session', token
        functor.apply self, [req, res]
      else if token?
        #LOG 'trying to load token', token, 'from db'
        session = new Session()
        session.load token, (found) ->
          #LOG 'found', found
          if found and token is found.token and found.expires > now
            req.session.token = found.token
            req.session.expires = found.expires
            functor.apply self, [req, res]
          else
            #LOG 'destroying session'
            DB.del 'Session_' + token
            req.session.destroy()
            res.sendStatus 404
      else
        res.sendStatus 404

  dataRequest: (req, res) ->
    res.send 'Logged in!'

  logoutRequest: (req, res) ->
    # delete session
    req.session.destroy()
    res.send 'ok'

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
          session = user.newSessionToken()
          req.session.token = session.token
          req.session.expires = session.expires
          user.save ->
            LOG 'registerRequest: new user registered:', req.body.username
            res.send {
              error: false
              username: user.username
              token: session.token
              expires: session.expires
            }

  loginRequest: (req, res) ->
    if req.body.username? and req.body.password?
      user = new User()
      user.load req.body.username, (found) ->
        if found
          SHA1 req.body.password, (password) ->
            # LOG 'found user', found
            if found.password is password
              session = user.newSessionToken()
              req.session.token = session.token
              req.session.expires = session.expires
              username = req.body.username
              template = '<html><body><script>'
              template += 'document.cookie="x-chow-token=' + session.token + '; path=/";'
              template += 'document.cookie="x-chow-token-expires=' + session.expires + '; path=/";'
              template += 'document.location.href = "/";'
              template += '</script></body><html>'
              res.set 'Content-Type', 'text/html'
              res.send new Buffer template
            else
              #LOG 'loginRequest: failed log in for:', req.body.username, '- Password does not match:', found.password, password
              req.session.destroy()
              res.redirect '/'
        else
          #LOG 'loginRequest: failed log in for:', req.body.username, '- No username found by name', req.body.username
          req.session.destroy()
          res.redirect '/'
    else
      req.session.destroy()
      res.redirect '/'

