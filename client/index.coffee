'use strict'

app = angular.module 'app', []

SECRET = {
  token: {
    id: false
    expires: false
  }
}

class AppWindow
  constructor: (@app, @show) ->

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
        if data.error?
          alert data.error
        else
          @show = false
          @app.$scope.graph.init()
          @app.$scope.datatable.init()
          @app.$scope.profile.init()
          # if manager...
      .error (data, status, headers, config) ->
        console.log 'error', data
  register: ->
    @show = false
    @app.$scope.register.show = yes

class RegisterWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
  submit: ->
    @app.$http.post('/api/register', {
      username: @username
      password: @password
    })
      .success (data, status, headers, config) ->
        if data.error?
          alert data.error
      .error (data, status, headers, config) ->
        console.log 'error', data
  back: ->
    @show = false
    @app.$scope.login.show = yes

class ProfileWindow extends AppWindow
  init: ->
    console.log 'ProfileWindow init'
    @show = yes

class GraphWindow extends AppWindow
  init: ->
    console.log 'GraphWindow init'
    @show = yes

class DatatableWindow extends AppWindow
  init: ->
    console.log 'DatatableWindow init'
    @show = yes

class ManagerWindow extends AppWindow

app.controller 'chowhound', class Chowhound
  constructor: (@$scope, @$http) ->
    @$scope.loading = new AppWindow this, no
    @$scope.login = new LoginWindow this, no
    @$scope.register = new RegisterWindow this, no
    @$scope.profile = new ProfileWindow this, no
    @$scope.graph = new GraphWindow this, no
    @$scope.datatable = new DatatableWindow this, no
    @$scope.manager = new ManagerWindow this, no
    if SECRET.token.id
      @loadData()
    else
      @$scope.login.show = yes

  loadData: ->
    self = this
    if SECRET.token.id
      @$http { url: '/api/data' }
        .success (data, status, headers, config) ->
          console.log 'done loading', data
          self.$scope.loading.show = true
        .error (data, status, headers, config) ->
          console.log 'error', data
