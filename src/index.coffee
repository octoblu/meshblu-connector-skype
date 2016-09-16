{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-skype:index')
Lync            = require './lync-manager'

class Connector extends EventEmitter
  constructor: ->
    @conversationId = null
    @video_on = false

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options
    @configHandler @options

  configHandler: (options={}) =>
    { url, state, enable_video } = options
    return @stopMeetings() if state == "End Meeting"
    return @joinMeeting(url, enable_video) if state == "Join Meeting"

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  joinMeeting: (url=null, enable_video=false) =>
    input = {
      JoinUrl: url
      EnableVideo: enable_video
    }

    Lync.joinMeeting input, (error, result) =>
      throw error if error
      @conversationId = result
      @video_on = true

  stopMeetings: () =>
    if @video_on
      Lync.stopVideo @conversationId, (error, result) =>
        throw error if error
        @video_on = false
        Lync.stopMeetings null, (error, result) =>
          throw error if error
          @conversationId = null
    else if !@video_on
      Lync.stopMeetings @conversationId, (error, result) =>
        throw error if error
        @conversationId = null


module.exports = Connector
