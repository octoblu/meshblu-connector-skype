{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-skype:index')
Lync            = require './lync-manager'

class Connector extends EventEmitter
  constructor: ->
    @conversationId = null

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options
    @handleStateChange @options

  handleStateChange: (options={}) =>
    { url, state, enable_video } = options
    return @stopMeetings(null) if state == "End Meeting"
    return @joinMeeting(url, enable_video) if state == "Join Meeting"

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  joinMeeting: (url=null, enable_video=true) =>
    input = {
      JoinUrl: url
      EnableVideo: enable_video
    }

    Lync.joinMeeting input, (error, result) =>
      throw error if error
      @conversationId = result

  stopMeetings: (id) =>
    Lync.stopMeetings id, (error, result) =>
      throw error if error
      @conversationId = null



module.exports = Connector
