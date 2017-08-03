LyncManager   = require './lync-manager'
stopped       = false
INTERVAL_TIME = 20000

autoCheck = =>
  return if stopped
  _checkLync (error) =>
    console.error 'lync error', error if error?
    setTimeout autoCheck, INTERVAL_TIME

stopAutoCheck = =>
  stopped = true

_checkLync = (callback) =>
  LyncManager.getState null, (error, state) =>
    return callback error if error?
    return callback() if state.hasClient
    LyncManager.startClient null, (error) =>
      return callback error if error?
      callback()

module.exports = { autoCheck, stopAutoCheck }
