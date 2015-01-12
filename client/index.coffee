'use strict'

app = angular.module 'app', ['ngCookies']

class AppWindow
  constructor: (@app, @show) ->
    if !@show? then @show = no

class LoginWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
  submit: ->
    @app.$http.post('/api/new/login', {
      username: @username
      password: @password
    })
      .success (data, status, headers, config) =>
        if data.error
          alert data.error
        else
          @show = false
          @login(data)
          # if manager...
      .error (data, status, headers, config) ->
        console.log 'error', data
  tokenLogin: (username, token) ->
    @app.$http.post '/api/new/login', { username: username, token: token }
      .success (data, status, headers, config) =>
        if data.error
          alert data.error
          @app.$cookieStore.remove 'token'
          @app.$scope.login.show = yes
        else
          @show = false
          @login(data)
          # if manager...
      .error (data, status, headers, config) ->
        console.log 'error', data
  register: ->
    @show = false
    @app.$scope.register.show = yes
  login: (data) ->
    @app.$scope.loading.show = no
    @app.$scope.graph.init()
    @app.$scope.datatable.init()
    @app.$scope.profile.init()
    @app.$cookies.token = data.token
    @app.$cookies.username = data.username

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
          @app.$scope.login.login(data)
      .error (data, status, headers, config) ->
        console.log 'error', data
  back: ->
    @show = false
    @app.$scope.login.show = yes

class ProfileWindow extends AppWindow
  init: ->
    @show = yes

class GraphWindow extends AppWindow
  init: ->
    @show = yes

class DatatableWindow extends AppWindow
  init: ->
    @show = yes

class ManagerWindow extends AppWindow

app.controller 'chowhound', class Chowhound
  constructor: (@$scope, @$http, @$cookies, @$cookieStore) ->
    @$scope.loading = new AppWindow this, yes
    @$scope.login = new LoginWindow this
    @$scope.register = new RegisterWindow this
    @$scope.profile = new ProfileWindow this
    @$scope.graph = new GraphWindow this
    @$scope.datatable = new DatatableWindow this
    @$scope.manager = new ManagerWindow this
    if @$cookies.token and @$cookies.username
      @$scope.login.tokenLogin @$cookies.username, @$cookies.token
    else
      @$scope.loading.show = no
      @$scope.login.show = yes

  loadData: ->
    self = this
    if @$cookies.token
      @$http { url: '/api/data' }
        .success (data, status, headers, config) ->
          self.$scope.loading.show = no
        .error (data, status, headers, config) ->
          console.log 'error', data
