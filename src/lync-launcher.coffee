ps = require 'ps-node'
_  = require 'lodash'
exec = require('child_process').exec

intervalId = null

autoCheck = (intervalTime=10000) =>
  if !intervalId
    intervalId = setInterval _checkLync, intervalTime

stopAutoCheck = () =>
  if intervalId
    intervalId = clearInterval intervalId

_checkLync = () =>
  ps.lookup {command: 'lync'}, (error, result) =>
    exec('cd C:\\ && start lync.exe', shell: true, (err, stdout, stderr) => {}) if _.isEmpty result

module.exports = {
  autoCheck,
  stopAutoCheck
}
