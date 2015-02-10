'use strict'

class TeamsWindow extends AppWindow
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

module.exports = TeamsWindow
