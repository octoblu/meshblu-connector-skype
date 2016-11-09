async = require 'async'
{EventEmitter}  = require 'events'
_     = require 'lodash'
# debug           = require('debug')('meshblu-connector-skype:index')

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @Lync ?= require './lync-manager'

  start: (arg, callback) =>
    return callback()

  close: (callback) =>
    return callback()

  onConfig: (device, callback) =>
    console.log 'onConfig'
    desiredState = _.get device, 'desiredState', {}

    @_handleMeetingUrl desiredState, (error) =>
      return callback error if error?

      @_handleAudioEnabled desiredState, (error) =>
        return callback error if error?

        @_computeState (error, state) =>
          return callback error if error?
          @emit 'update', {state, desiredState: {}}

  _computeState: (callback) =>
    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback null, state

  _handleAudioEnabled: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'audioEnabled'
    @Lync.getState null, (error, state) =>
      console.log 'state', JSON.stringify state
      return callback error if error?
      return callback() if _.isEmpty state.conversationId

      return @Lync.unmute state.conversationId, callback if desiredState.audioEnabled
      return @Lync.mute state.conversationId, callback

  _handleMeetingUrl: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'meetingUrl'
    {meetingUrl} = desiredState

    return @Lync.stopMeetings callback if _.isEmpty meetingUrl

    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback() if meetingUrl == _.get(state, 'meetingUrl')
      @Lync.joinMeeting meetingUrl, callback

module.exports = Connector
