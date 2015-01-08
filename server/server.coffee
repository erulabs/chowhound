'use strict'

LISTEN = 9000
if process.env.LISTEN? then LISTEN = process.env.LISTEN

DBPATH = 'tmp/chow.db'
if process.env.DBPATH? then DBPATH = process.env.DBPATH

express = require 'express'
levelup = require 'levelup'

module.exports = class Server
  constructor: ->
    @app = express()
    @db = levelup DBPATH

    @app.post '/api/new/login', @newLoginRequest
    @app.get '/api/data', @dataRequest
    @app.post '/api/new/break', @newBreakRequest
    @app.get '/api/manager', @managerGetRequest
    @app.post '/api/manager/set', @managerPostRequest

    @server = @app.listen process.env.LISTEN, =>
      host = @server.address().address
      port = @server.address().port
      console.log 'Listening at http://%s:%s', host, port

  newLoginRequest: (req, res) ->

  dataRequest: (req, res) ->
    res.send {
      message: 'Hello'
    }

  newBreakRequest: (req, res) ->

  managerGetRequest: (req, res) ->

  managerPostRequest: (req, res) ->

