'use strict'

module.exports = class UserController
  constructor: (@app) ->

  newTeam: (req, res) ->
    res.send 'ok'

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
              username = req.body.username
              template = '<html><body><script>'
              template += 'document.cookie="x-chow-token=' + session.token + '; max-age=' + CONFIG.SESSIONLENGTH + '; path=/";'
              template += 'document.cookie="x-chow-token-expires=' + session.expires + '; '
              template += 'max-age=' + CONFIG.SESSIONLENGTH + '; path=/";'
              template += 'document.location.href = "/";'
              template += '</script></body><html>'
              res.set 'Content-Type', 'text/html'
              res.send new Buffer template
            else
              #LOG 'loginRequest: failed log in for:', req.body.username, '- Password does not match:', found.password, password
              req.session.destroy()
              res.redirect '/'
        else
          #LOG 'loginRequest: failed log in for:', req.body.username, '- No username found by name', req.body.username
          req.session.destroy()
          res.redirect '/'
    else
      req.session.destroy()
      res.redirect '/'

  register: (req, res) ->
    if !req.body.username? or !req.body.password?
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
          session = user.newSessionToken()
          req.session.token = session.token
          req.session.expires = session.expires
          user.save ->
            LOG 'registerRequest: new user registered:', req.body.username
            res.send {
              error: false
              username: user.username
              token: session.token
              expires: session.expires
            }
