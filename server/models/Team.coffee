'use strict'

Model = require './Model.coffee'

module.exports = class Team extends Model
  constructor: ->
    @key = 'name'
    @savable = {
      members: true
      name: true
      managers: true
    }
