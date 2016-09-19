{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-skype:index')
Lync            = require './lync-manager'

class Connector extends EventEmitter
  constructor: ->
    @conversationId = null
    @video_on = false
    @in_meeting = false

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
    { url, state, enable_video, mute_toggle } = options
    return @stopMeetings() if state == "End Meeting"
    return @joinMeeting(url, enable_video, mute_toggle) if state == "Join Meeting"

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  joinMeeting: (url=null, enable_video=false, mute_toggle) =>
    return @handleMute mute_toggle if @in_meeting

    input = {
      JoinUrl: url
      EnableVideo: enable_video
    }

    if !@in_meeting
      Lync.joinMeeting input, (error, result) =>
        throw error if error
        @conversationId = result
        @video_on = true
        @in_meeting = true
        @handleMute mute_toggle

  stopMeetings: () =>
    if @video_on
      Lync.stopVideo @conversationId, (error, result) =>
        throw error if error
        @video_on = false
        Lync.stopMeetings null, (error, result) =>
          throw error if error
          @conversationId = null
          @in_meeting = false
    else if !@video_on
      Lync.stopMeetings @conversationId, (error, result) =>
        throw error if error
        @conversationId = null
        @in_meeting = false

  handleMute: (toggle) =>
    if toggle
      Lync.mute @conversationId, (error, result) =>
        throw error if error
    else
      Lync.unmute @conversationId, (error, result) =>
        throw error if error


module.exports = Connector
