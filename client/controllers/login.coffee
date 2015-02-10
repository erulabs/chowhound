'use strict'

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
    @app.$scope.teams.init()
    @app.$scope.teams.show = yes
    @app.$scope.teams.teams = Object.keys(data.teams)
    @app.$scope.teams.begin(@app.STATS_INTERVAL)
    if @app.$scope.teams.teams.length > 0
      @app.$scope.graph.init(data)

module.exports = LoginWindow
