spawn = require('child_process').spawn
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
      options =
      stdio: ['pipe', 'pipe', 'pipe', 'ipc']
      shell: true
      detached: true

      child = spawn 'cd C:\\ && start lync.exe', options
      child.unref()

module.exports = {
  autoCheck,
  stopAutoCheck
}
