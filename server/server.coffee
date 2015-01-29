'use strict'

global.CONFIG   = require './../shared/config.js'
global.ENV      = CONFIG.ENV
lib             = {}
lib.express     = require 'express'
lib.session     = require 'express-session'
lib.bodyParser  = require 'body-parser'
lib.multer      = require 'multer'
lib.randtoken   = require 'rand-token'
lib.levelup     = require 'levelup'
global.UID      = lib.randtoken.uid
global.DB       = {}

require './helpers.coffee'

module.exports = class Server
  init: ->
    global.DB = lib.levelup CONFIG.DBPATH
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

    global.Model = require './models/Model.coffee'
    global.Team = require './models/Team.coffee'
    global.User = require './models/User.coffee'
    global.Session = require './models/Session.coffee'

    @ctrlr = {}
    @ctrlr.User = new (require './controllers/User.coffee') this

    @route 'post', '/login', @ctrlr.User.login
    @route 'post', '/register', @ctrlr.User.register
    @authedRoute 'post', '/logout', @ctrlr.User.logout
    @authedRoute 'post', '/new/team', @ctrlr.User.newTeam
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


