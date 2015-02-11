'use strict'

module.exports = class Model
  keyName: (key) ->
    if key
      return this.constructor.name + '_' + key
    else
      return this.constructor.name + '_' + this[@key]
  del: (callback) ->
    DB.del self.keyName(), callback
  save: (callback) ->
    return unless this.savable?
    saveData = {}
    self = this
    this.presave ->
      for item, _p of self.savable
        saveData[item] = self[item] if self[item]?
      # LOG 'DB saving', self.keyName(), JSON.stringify(saveData)
      DB.set self.keyName(), JSON.stringify(saveData), (error) ->
        if error
          LOG 'DBERROR: Saving model', self.keyName(), 'Error:', error
          return callback error if callback?
        else
          callback false if callback?
  load: (key, callback) ->
    self = this
    DB.get self.keyName(key), (error, value) ->
      if error
        if error.type is 'NotFoundError'
          return callback false if callback?
        else
          LOG 'DBERROR: Getting model', self.keyName(), 'Error:', error
          return callback false if callback?
      else
        data = {}
        try data = JSON.parse value
        catch error
          LOG 'DBERROR: Loading model', error
          return callback false if callback?
        for properyName, propery of data
          self[properyName] = propery if self.savable[properyName]
        callback data if callback?
  presave: (callback) -> callback()
