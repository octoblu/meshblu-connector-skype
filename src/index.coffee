async          = require 'async'
{EventEmitter} = require 'events'
_              = require 'lodash'
# debug           = require('debug')('meshblu-connector-skype:index')

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @Lync ?= require './lync-manager'

  start: (device, callback) =>
    @onConfig device, (error) =>
      return callback error if error
      @_updateCurrentState callback

  close: (callback) =>
    return callback()

  onConfig: (device, callback=->) =>
    desiredState = _.get device, 'desiredState', {}
    console.log 'onConfig', JSON.stringify desiredState
    return callback() if _.isEmpty desiredState

    @_handleDesiredState desiredState, (error) =>
      if error
        console.error error.stack
        return callback error

      @_updateCurrentState callback

  _updateCurrentState: (callback) =>
    @_computeState (error, state) =>
      return callback error if error?
      console.log 'state', JSON.stringify {state, desiredState: {}}
      @emit 'update', {state, desiredState: {}}
      callback()

  _handleDesiredState: (desiredState, callback) =>
    async.series [
      async.apply(@_handleMeetingUrl,   desiredState)
      async.apply(@_handleAudioEnabled, desiredState)
      async.apply(@_handleVideoEnabled, desiredState)
    ], callback

  _computeState: (callback) =>
    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback null, state

  _handleAudioEnabled: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'audioEnabled'
    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback() if _.isEmpty state.conversationId

      return @Lync.unmute state.conversationId, callback if desiredState.audioEnabled
      return @Lync.mute state.conversationId, callback

  _handleMeetingUrl: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'meetingUrl'
    {meetingUrl} = desiredState

    @Lync.stopMeetings null, (error) =>
      return callback error if error?
      return callback() if _.isEmpty meetingUrl

      @Lync.getState null, (error, state) =>
        return callback error if error?
        return callback() if meetingUrl == _.get(state, 'meetingUrl')
        @Lync.joinMeeting meetingUrl, callback

  _handleVideoEnabled: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'videoEnabled'
    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback() if _.isEmpty state.conversationId

      return @Lync.startVideo state.conversationId, callback if desiredState.videoEnabled
      return @Lync.stopVideo state.conversationId, callback


module.exports = Connector
