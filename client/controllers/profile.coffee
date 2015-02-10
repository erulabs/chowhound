'use strict'

class ProfileWindow extends AppWindow
  init: ->
    @username = @app.$cookies['x-chow-user']
    @show = true
  modalTrigger: ->
    modal = @app.$modal.open {
      templateUrl: 'breakModalContent'
    }
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
          @app.$scope.teams.show = no
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

module.exports = ProfileWindow
