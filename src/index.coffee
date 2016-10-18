{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-skype:index')
Lync            = require './lync-manager'

class Connector extends EventEmitter
  constructor: ->
    @conversationId = null
    @video_on = false
    @in_meeting = false
    @conferencing_uri = null
    @joining = false

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
    { url, state, enable_video, enable_audio } = options
    enable_audio = !enable_audio

    return @stopMeetings() if state == "End Meeting"
    return @meetNow( enable_video, enable_audio ) if state == "Meet Now"
    return @joinMeeting(url, enable_video, enable_audio) if state == "Join Meeting"

  start: (device, callback) =>
    debug 'started'
    @onConfig device
    callback()

  joinMeeting: (url, enable_video=false, enable_audio) =>
    return if !url?
    return @handleMute enable_audio if @in_meeting

    input = {
      JoinUrl: url
      EnableVideo: enable_video
      EnableMute: enable_audio
    }

    if !@in_meeting && !@joining
      @joining = true
      Lync.joinMeeting input, (error, result) =>
        throw error if error
        @conversationId = result
        @video_on = true
        @in_meeting = true
        @joining = false

        state = {
          currentState:
            conferencing_uri: url
            in_meeting: @in_meeting
            video_on: @video_on
          }
        @emit 'update', state

  meetNow: (enable_video=false, enable_audio) =>
    return @handleMute enable_audio if @in_meeting

    input = {
      JoinUrl: null
      EnableVideo: enable_video
      EnableMute: enable_audio
    }

    if !@in_meeting && !@joining
      @joining = true
      Lync.joinMeeting input, (error, result) =>
        throw error if error
        @conversationId = result
        @video_on = true
        @in_meeting = true
        Lync.getConferenceUri @conversationId, (error, result) =>
          throw error if error
          @conferencing_uri = result
          @joining = false
          state = {
            currentState:
              conferencing_uri: result
              in_meeting: @in_meeting
              video_on: @video_on
            }
          @emit 'update', state

  stopMeetings: () =>
    if @video_on
      Lync.stopVideo @conversationId, (error, result) =>
        throw error if error
        @video_on = false
        Lync.stopMeetings null, (error, result) =>
          throw error if error
          @conversationId = null
          @in_meeting = false
          state = {
            currentState:
              conferencing_uri: null
              in_meeting: @in_meeting
              video_on: @video_on
            }
          @emit 'update', state
    else if !@video_on
      Lync.stopMeetings @conversationId, (error, result) =>
        throw error if error
        @conversationId = null
        @in_meeting = false
        state = {
          currentState:
            conferencing_uri: null
            in_meeting: @in_meeting
            video_on: @video_on
          }
        @emit 'update', state

  handleMute: (toggle) =>
    if toggle
      Lync.mute @conversationId, (error, result) =>
        throw error if error
    else
      Lync.unmute @conversationId, (error, result) =>
        throw error if error


module.exports = Connector
