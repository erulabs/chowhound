'use strict'

class RegisterWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
    @groups = ''
    @starttime = new Date()
    @endtime = new Date()
  starttimeChanged: ->
    console.log @starttime
  submit: ->
    @app.post('/register', {
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
          @app.$cookies['x-chow-user'] = @username
          @app.$cookies['x-chow-token-expires'] = data.expires
          @app.$scope.login.login(data)
      .error (data, status, headers, config) ->
        console.log 'error', data
  back: ->
    @show = false
    @app.$scope.login.show = yes

module.exports = RegisterWindow
