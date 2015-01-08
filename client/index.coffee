'use strict'

app = angular.module 'app', []

class AppWindow
  constructor: (show) ->
    @show = show

app.controller 'chowhound', class Chowhound
  constructor: (@$scope, @$http) ->
    @$scope.loading = new AppWindow no
    @$scope.login = new AppWindow no
    @$scope.profile = new AppWindow no
    @$scope.graph = new AppWindow no
    @$scope.datatable = new AppWindow no
    @$scope.manager = new AppWindow no
    @loadData()

  loadData: ->
    self = this
    @$http { url: '/api/data' }
      .success (data, status, headers, config) ->
        console.log 'done loading', data
        self.$scope.loading.show = true
      .error (data, status, headers, config) ->
        console.log 'error', data
