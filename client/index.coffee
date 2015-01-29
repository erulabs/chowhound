'use strict'

app = angular.module 'app', ['ngCookies']

class AppWindow
  constructor: (@app, @show) ->
    if !@show? then @show = no

class LoginWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
  register: ->
    @show = false
    @app.$scope.register.show = yes
  login: (data) ->
    @app.$scope.graph.init()
    @app.$scope.datatable.init()
    @app.$scope.profile.init()
    @app.$scope.stats.show = yes

class RegisterWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
    @groups = ''
  submit: ->
    @app.$http.post('/api/register', {
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
    console.log 'creating team', teamName


class BreakWindow extends AppWindow
  init: ->
    @show = no

class StatsWindow extends AppWindow
  init: ->
    @show = no

class GraphWindow extends AppWindow
  init: ->
    @show = yes
    date = new Date()
    thisHour = date.getHours()
    ampm = 'am'
    if thisHour > 11 then ampm = 'pm'
    if thisHour > 12 then thisHour = thisHour - 12
    if thisHour is 0 then thisHour = 12

    hourList = []
    for hour in [(thisHour - 1)..(thisHour + 7)]
      if hour > 12
        hour = hour - 12
        hourList.push hour + 'am'
      else
        hourList.push hour + 'pm'

    angular.element(document).ready ->
      new Chartist.Line('.ct-chart', {
        labels: hourList,
        series: [
          [5, 9, 7, 8, 5, 3, 5, 8]
        ]
      }, {
        low: 0,
        showArea: true
      })

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
      @$cookieStore.remove 'x-chow-token'
      @$cookieStore.remove 'x-chow-token-expires'
    if token?
      @get '/data'
        .success (data, status, headers) =>
          @$scope.login.login(data)
        .error (data, status, headers) =>
          if status is 404
            @$cookieStore.remove 'x-chow-token'
            @$cookieStore.remove 'x-chow-token-expires'
            @$scope.login.show = yes
    else
      @$scope.login.show = yes
  http: (options) ->
    options.headers = {} unless options.headers?
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
