'use strict'

app = angular.module 'app', ['ngCookies', 'ui.bootstrap']

class AppWindow
  constructor: (@app, @show) ->
    if !@show? then @show = no

global.AppWindow = AppWindow

LoginWindow = require './controllers/login.coffee'
RegisterWindow = require './controllers/register.coffee'
ProfileWindow = require './controllers/profile.coffee'

class BreakWindow extends AppWindow
  init: ->
    @show = no

TeamsWindow = require './controllers/teams.coffee'

class GraphWindow extends AppWindow
  init: (initialData) ->
    @show = yes
    @chart = {}
    angular.element(document).ready =>
      @chart = new Chartist.Line('.ct-chart', initialData.graphdata, {
        low: 0,
        showArea: true
      })

  update: (data) ->
    console.log 'new data for graph', data
    @chart.update data.graphdata

class DatatableWindow extends AppWindow
  init: ->
    @show = yes

class ManagerWindow extends AppWindow

app.controller 'chowhound', [
  '$scope',
  '$http',
  '$cookies',
  '$cookieStore',
  '$location',
  '$modal',
  class Chowhound
    constructor: (@$scope, @$http, @$cookies, @$cookieStore, @$location, @$modal) ->
      this.STATS_INTERVAL = 10
      @$scope.login = new LoginWindow this
      @$scope.register = new RegisterWindow this
      @$scope.profile = new ProfileWindow this
      @$scope.graph = new GraphWindow this
      @$scope.teams = new TeamsWindow this
      @$scope.datatable = new DatatableWindow this
      @$scope.manager = new ManagerWindow this
      @$scope.break = new BreakWindow this
      token = @$cookies['x-chow-token']
      expires = @$cookies['x-chow-token-expires']
      if expires < (new Date().getTime())
        token = undefined
        @logout()
      if token?
        @initData()
      else
        @$scope.login.show = yes
    logout: ->
      @$cookieStore.remove 'x-chow-token'
      @$cookieStore.remove 'x-chow-token-expires'
      @$scope.login.show = yes
    initData: ->
      @get '/data'
        .success (data, status, headers) =>
          if data.error
            @logout()
          else
            @$scope.login.login(data)
        .error (data, status, headers) => if status is 404 then @logout()
    http: (options) ->
      options.headers = {} unless options.headers?
      if @$cookies['x-chow-token']?
        options.headers['x-chow-token'] = @$cookies['x-chow-token'].replace /"/g, ''
      return @$http options
    get: (uri) ->
      return @http {
        method: 'GET'
        url: '/api' + uri
      }
    post: (uri, data) ->
      data = {} unless data?
      return @http {
        method: 'POST'
        url: '/api' + uri
        data: data
      }
  ]
