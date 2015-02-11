'use strict'

class BreakWindow extends AppWindow
  init: ->
    @show = no
  modalTrigger: ->
    $scope = @app.$scope
    modal = @app.$modal.open {
      templateUrl: 'breakModalContent'
      controller: 'chowhound'
      resolve: {
        profile: -> $scope.profile
        teams: -> $scope.teams
      }
    }

module.exports = BreakWindow
