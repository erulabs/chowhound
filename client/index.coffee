'use strict'

app = angular.module 'app', ['ngCookies']

STATS_INTERVAL = 10

class AppWindow
  constructor: (@app, @show) ->
    if !@show? then @show = no

class LoginWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    if @app.$cookies['x-chow-user']?
      @username = @app.$cookies['x-chow-user']
    @password = ''
  register: ->
    @show = false
    @app.$scope.register.show = yes
  login: (data) ->
    @app.$scope.datatable.init()
    @app.$scope.profile.init()
    @app.$scope.stats.init()
    @app.$scope.stats.show = yes
    @app.$scope.stats.teams = Object.keys(data.teams)
    @app.$scope.stats.begin(STATS_INTERVAL)
    if @app.$scope.stats.teams.length > 0
      @app.$scope.graph.init(data)

class RegisterWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
    @groups = ''
  submit: ->
    @app.post('/register', {
      username: @username
      password: @password
      groups: @groups
    })
      .success (data, status, headers, config) =>
        if data.error
          alert data.error
        else
          @show = false
          @app.$cookies['x-chow-token'] = data.token
          @app.$cookies['x-chow-user'] = @username
          @app.$cookies['x-chow-token-expires'] = data.expires
          @app.$scope.login.login(data)
      .error (data, status, headers, config) ->
        console.log 'error', data
  back: ->
    @show = false
    @app.$scope.login.show = yes

class ProfileWindow extends AppWindow
  init: ->
    @show = no
    @username = @app.$cookies['x-chow-user']
  logout: ->
    @app.post '/logout'
      .success (data, status, headers, config) =>
        if data.error
          alert data.error
        else
          @app.$cookieStore.remove 'x-chow-token'
          @app.$cookieStore.remove 'x-chow-token-expires'
          @app.$scope.login.show = yes
          @app.$scope.graph.show = no
          @app.$scope.datatable.show = no
          @app.$scope.profile.show = no
          @app.$scope.manager.show = no
          @app.$scope.stats.show = no
      .error (data, status, headers, config) ->
        console.log 'error', data
  createTeam: (teamName) ->
    @app.post '/new/team', { name: teamName }
      .success (data, status, headers, config) =>
        if data.error
          alert data.error
        else
          @app.initData()
      .error (data, status, headers, config) ->
        console.log 'error', data

class BreakWindow extends AppWindow
  init: ->
    @show = no

class StatsWindow extends AppWindow
  init: ->
    @show = no
    @teams = []
    @isManager = false
    @graphData = {}
  # Update the stats every interval
  begin: (interval) ->
    setInterval =>
      @app.get '/data'
        .success (data, status, headers) =>
          if data.error
            @logout()
          else
            if data.teams.length > 0
              @app.$scope.graph.update data
        .error (data, status, headers) => if status is 404 then @logout()
    , interval * 1000

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

app.controller 'chowhound', class Chowhound
  constructor: (@$scope, @$http, @$cookies, @$cookieStore, @$location) ->
    @$scope.login = new LoginWindow this
    @$scope.register = new RegisterWindow this
    @$scope.profile = new ProfileWindow this
    @$scope.graph = new GraphWindow this
    @$scope.stats = new StatsWindow this
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
