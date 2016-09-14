{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-skype:index')
Lync            = require './lync-manager'

class Connector extends EventEmitter
  constructor: ->

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  joinMeeting: (url) =>
    Lync.joinMeeting url, (error, result) =>
      throw error if error
      console.log result

  startConversation: () =>
    Lync.startConversation null, (error, result) =>
      throw error if error
      console.log result


module.exports = Connector
