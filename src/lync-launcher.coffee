ps = require 'ps-node'
_  = require 'lodash'
{spawn} = require('child_process')

intervalId = null

autoCheck = (intervalTime=10000) =>
  if !intervalId
    intervalId = setInterval _checkLync, intervalTime

stopAutoCheck = () =>
  if intervalId
    intervalId = clearInterval intervalId

_checkLync = () =>
  ps.lookup {command: 'lync'}, (error, result) =>
    return unless _.isEmpty result
    options =
      shell: true
      stdio: 'ignore'
      detached: true

    child = spawn 'cd C:\\ && start lync.exe', options
    child.unref()

module.exports = {
  autoCheck,
  stopAutoCheck
}
