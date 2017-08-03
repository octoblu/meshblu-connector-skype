LyncManager   = require './lync-manager'
debug         = require('debug')('meshblu-connector-skype:lync-launcher')
stopped       = false
INTERVAL_TIME = 20000

autoCheck = =>
  return stopped = false if stopped
  _checkLync (error) =>
    console.error 'LyncLauncher->autoCheck', { error } if error?
    setTimeout autoCheck, INTERVAL_TIME

stopAutoCheck = =>
  debug 'stopAuthCheck'
  stopped = true

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
