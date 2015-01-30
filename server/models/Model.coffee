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
      #LOG 'DB saving', self.keyName(), JSON.stringify(saveData)
      putCallback = (error) ->
        if error
          LOG 'DBERROR:', 'saving model', self.keyName(), 'Error:', error
          return callback error if callback?
        else
          callback false if callback?
      # LevelDB in development
      if ENV is 'dev'
        DB.put self.keyName(), JSON.stringify(saveData), putCallback
      # Redis in production
      else
        DB.hmset self.keyName(), saveData, putCallback
  load: (key, callback) ->
    self = this
    if ENV is 'dev' then method = 'get' else method = 'hgetall'
    DB[method] self.keyName(key), (error, raw) ->
      if error
        if error.type is 'NotFoundError'
          return callback false if callback?
        else
          LOG 'DBERROR:', 'getting model', self.keyName(), 'Error:', error
          return callback false if callback?
      else
        if ENV is 'dev'
          try value = JSON.parse raw
        else
          value = raw
        for properyName, propery of value
          self[properyName] = propery if self.savable[properyName]
        callback value if callback?
  presave: (callback) -> callback()
