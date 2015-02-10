'use strict'

module.exports = class UserController
  dataRequest: (req, res) ->
    user = new User()
    user.load req.session.username, (found) ->
      if found
        console.log 'found your user, you have the following teams:', found.teams
        date = new Date()
        thisHour = date.getHours()
        ampm = 'am'
        if thisHour > 11 then ampm = 'pm'
        if thisHour > 12 then thisHour = thisHour - 12
        if thisHour is 0 then thisHour = 12

        hourList = []
        for hour in [(thisHour - 1)..(thisHour + 7)]
          if hour > 12
            hour = hour - 12
            hourList.push hour + 'am'
          else
            hourList.push hour + 'pm'
        res.send {
          error: no,
          teams: found.teams,
          graphdata: {
            labels: hourList,
            series: [
              [5, 9, 7, 8, 0, 0, 0, 0]
            ]
          }
        }
      else
        LOG 'The user', req.session.username, 'doesnt have a DB entry...'
        res.send { error: 'youre not a real user...' }

  newTeam: (req, res) ->
    if req.body.name?
      team = new Team()
      team.load req.body.name, (found) ->
        if found
          res.send { error: 'That team name is already taken' }
        else
          team.members[req.session.username] = true
          team.name = req.body.name
          user = new User()
          user.load req.session.username, (found) ->
            if found
              user.teams[team.name] = true
              user.save()
              team.save()
              res.send { error: no, message: 'ok' }
            else
              LOG 'The user', req.session.username, 'doesnt have a DB entry...'
              res.send { error: 'youre not a real user...' }
    else
      res.send { error: 'Provide a name' }

  logout: (req, res) ->
    req.session.destroy()
    res.send 'ok'

  login: (req, res) ->
    if req.body.username? and req.body.password?
      user = new User()
      user.load req.body.username, (found) ->
        if found
          SHA1 req.body.password, (password) ->
            # LOG 'found user', found
            if found.password is password
              session = user.newSessionToken()
              req.session.token = session.token
              req.session.expires = session.expires
              req.session.username = req.body.username
              template = '<html><body><script>'
              session_string = 'max-age=' + CONFIG.SESSIONLENGTH + '; path=/";'
              template += 'document.cookie="x-chow-token=' + session.token + '; ' + session_string
              template += 'document.cookie="x-chow-token-expires=' + session.expires + '; ' + session_string
              template += 'document.cookie="x-chow-user=' + req.body.username + '; ' + session_string
              template += 'document.location.href = "/";'
              template += '</script></body></html>'
              res.set 'Content-Type', 'text/html'
              res.send new Buffer template
            else
              LOG 'loginRequest: failed log in for:', req.body.username, '- Password does not match:', found.password, password
              req.session.destroy()
              res.redirect '/'
        else
          LOG 'loginRequest: failed log in for:', req.body.username, '- No username found by name', req.body.username
          req.session.destroy()
          res.redirect '/'
    else
      req.session.destroy()
      res.redirect '/'

  register: (req, res) ->
    if !req.body.username? or !req.body.password? or !req.body.starttime? or !req.body.endtime? or !req.body.dotw?
      console.log 'request body was', req.body
      res.send { error: 'Supply a username and password' }
    else
      user = new User()
      user.load req.body.username, (found) ->
        if found
          res.send { error: 'Username already taken' }
        else
          user.username = req.body.username
          user.password = req.body.password
          user.registered = (new Date().getTime())
          user.starttime = req.body.starttime
          user.endtime = req.body.endtime
          user.dotw = req.body.dotw
          session = user.newSessionToken()
          req.session.token = session.token
          req.session.expires = session.expires
          req.session.username = req.body.username
          user.save ->
            LOG 'registerRequest: new user registered:', req.body.username
            res.send {
              error: false
              username: req.body.username
              token: session.token
              expires: session.expires
            }
