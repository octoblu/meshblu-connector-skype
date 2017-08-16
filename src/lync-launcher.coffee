LyncManager   = require './lync-manager'
debug         = require('debug')('meshblu-connector-skype:lync-launcher')
INTERVAL_TIME = 20000
autoCheckTimeout = null

autoCheck = =>
  clearTimeout(autoCheckTimeout) if autoCheckTimeout?
  _checkLync (error) =>
    console.error 'LyncLauncher->autoCheck', { error } if error?
    autoCheckTimeout = setTimeout autoCheck, INTERVAL_TIME

stopAutoCheck = =>
  debug 'stopAuthCheck'
  clearTimeout(autoCheckTimeout)

_checkLync = (callback) =>
  debug 'checkLync'
  LyncManager.getState null, (error, state) =>
    debug 'lyncManager.getState', JSON.stringify { error, state }, null, 2
    return callback error if error?
    return callback() if state.hasClient
    LyncManager.startClient null, (error) =>
      debug 'lyncManager.startClient', JSON.stringify { error }, null, 2
      return callback error if error?
      callback()

module.exports = { autoCheck, stopAutoCheck }
