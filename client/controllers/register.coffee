'use strict'

class RegisterWindow extends AppWindow
  constructor: (@app, @show) ->
    @username = ''
    @password = ''
    @password_confirm = ''
    @starttime = new Date()
    @starttime.setHours 9
    @starttime.setMinutes 0
    @endtime = new Date()
    @endtime.setMinutes 0
    @endtime.setHours 17
    @dotw = {
      mon: 1
      tue: 1
      wed: 1
      thu: 1
      fri: 1
      sat: 0
      sun: 0
    }
  starttimeChanged: ->
    console.log @starttime
  submit: ->
    if @password isnt @password_confirm
      return alert 'Passwords do not match'
    @app.post('/register', {
      username: @username
      password: @password
      starttime: @starttime
      endtime: @endtime
      dotw: @dotw
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
