'use strict'

class ProfileWindow extends AppWindow
  init: ->
    @show = true
  modalTrigger: ->
    $scope = @app.$scope
    modal = @app.$modal.open {
      templateUrl: 'profileModalContent'
      controller: 'chowhound'
      resolve: {
        profile: -> $scope.profile
        teams: -> $scope.teams
      }
    }
  logout: ->
    @app.post '/logout'
      .success (data, status, headers, config) =>
        if data.error
          alert data.error
        else
          @doLogoutAction()
      .error (data, status, headers, config) =>
        @doLogoutAction()
  doLogoutAction: ->
    @app.$cookieStore.remove 'x-chow-token'
    @app.$cookieStore.remove 'x-chow-token-expires'
    @app.$scope.login.show = yes
    @app.$scope.graph.show = no
    @app.$scope.datatable.show = no
    @app.$scope.profile.username = undefined
    @app.$scope.profile.show = no
    @app.$scope.manager.show = no
    @app.$scope.teams.show = no
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
