ps = require 'ps-node'
_  = require 'lodash'
exec = require('child_process').exec

checkLync = () =>
  ps.lookup {command: 'lync'}, (error, result) =>
    exec('cd C:\\ && start lync.exe', (err, stdout, stderr) => {}) if _.isEmpty result

autoCheck = (intervalTime=10000) =>
  setInterval checkLync, intervalTime

module.exports = {
  autoCheck,
  checkLync
}
