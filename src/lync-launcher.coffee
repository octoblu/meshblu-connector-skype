ps = require 'ps-node'
_  = require 'lodash'
exec = require('child_process').exec
LyncManager = require './lync-manager'

intervalId = null

autoCheck = (intervalTime=20000) =>
  if !intervalId
    intervalId = setInterval _checkLync, intervalTime

stopAutoCheck = () =>
  if intervalId
    intervalId = clearInterval intervalId

_checkLync = () =>
  LyncManager.getState null, (error, state) =>
    if !state.hasClient
      exec 'cd C:\\ && start lync.exe'

module.exports = {
  autoCheck,
  stopAutoCheck
}
