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
      .success (data, status, headers, config) ->
        console.log 'done logging in', data
      .error (data, status, headers, config) ->
        console.log 'error', data
  register: ->
    @show = false
    @app.$scope.register.show = yes

class RegisterWindow extends AppWindow
  constructor: (@app, @show) ->

app.controller 'chowhound', class Chowhound
  constructor: (@$scope, @$http) ->
    @$scope.loading = new AppWindow this, no
    @$scope.login = new LoginWindow this, no
    @$scope.register = new AppWindow this, no
    @$scope.profile = new AppWindow this, no
    @$scope.graph = new AppWindow this, no
    @$scope.datatable = new AppWindow this, no
    @$scope.manager = new AppWindow this, no
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
