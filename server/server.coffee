'use strict'

global.CONFIG   = require './../shared/config.js'
global.ENV      = CONFIG.ENV
if ENV isnt 'dev' then require 'newrelic'
lib             = {}
lib.express     = require 'express'
lib.session     = require 'express-session'
lib.bodyParser  = require 'body-parser'
lib.multer      = require 'multer'

global.DB       = {}

global.Model = require './models/Model.coffee'
global.Team = require './models/Team.coffee'
global.User = require './models/User.coffee'
global.Session = require './models/Session.coffee'

require './helpers.coffee'

module.exports = class Server
  init: ->
    if ENV is 'dev'
      lib.levelup = require 'levelup'
      LOG 'Connecting to LevelDB at %s', CONFIG.DBPATH
      global.DB = lib.levelup CONFIG.DBPATH
    else
      lib.redis = require 'redis'
      LOG 'Connecting to Redis at %s:%s', CONFIG.DBSERVER, CONFIG.DBPORT
      global.DB = lib.redis.createClient CONFIG.DBPORT, CONFIG.DBSERVER, {}

    @app = lib.express()
    @app.use lib.session {
      secret: CONFIG.SESSIONSECRET
      proxy: CONFIG.REVERSEPROXY
      resave: yes
      saveUninitialized: no
    }
    @app.use lib.bodyParser.json()
    @app.use lib.bodyParser.urlencoded({ extended: true })
    @app.use lib.multer()

    @ctrlr = {}
    @ctrlr.User = new (require './controllers/User.coffee') this

    @route 'post', '/login', @ctrlr.User.login
    @route 'post', '/register', @ctrlr.User.register
    @authedRoute 'post', '/logout', @ctrlr.User.logout
    @authedRoute 'post', '/new/team', @ctrlr.User.newTeam
    @authedRoute 'get', '/data', @ctrlr.User.dataRequest

    @server = @app.listen CONFIG.LISTEN, =>
      host = @server.address().address
      port = @server.address().port
      LOG 'Listening in %s mode at http://%s:%s', ENV, host, port

  route: (method, uri, functor) ->
    @app[method] '/api' + uri, (req, res) => functor.apply this, [req, res]

  authedRoute: (method, uri, functor) ->
    self = this
    @app[method] '/api' + uri, (req, res) ->
      token = req.headers['x-chow-token']
      now = (new Date().getTime())
      #LOG 'incoming token', token, req.session.token
      if token? and req.session.token? and token is req.session.token and req.session.expires > now and req.session.username?
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
            req.session.username = found.username
            functor.apply self, [req, res]
          else
            #LOG 'destroying session'
            DB.del 'Session_' + token
            req.session.destroy()
            res.sendStatus 404
      else
        res.sendStatus 404
