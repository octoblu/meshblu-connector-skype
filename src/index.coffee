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
    desiredState = _.get device, 'desiredState', {}

    @_handleMeetingUrl desiredState, (error) =>
      return callback error if error?

      @_handleEnableAudio desiredState, (error) =>
        return callback error if error?

        @_computeState (error, state) =>
          return callback error if error?
          @emit 'update', {state, desiredState: {}}

  _computeState: (callback) =>
    @Lync.getConferenceUri (error, meetingUrl) =>
      return callback error if error?
      return callback null, {meetingUrl}

  _handleEnableAudio: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'enableAudio'
    @Lync.unmute callback

  _handleMeetingUrl: (desiredState, callback) =>
    return callback() unless _.has desiredState, 'meetingUrl'
    {meetingUrl} = desiredState

    return @Lync.stopMeetings callback if _.isEmpty meetingUrl

    @Lync.getConferenceUri (error, currentMeetingUrl) =>
      return callback error if error?
      return callback() if currentMeetingUrl == meetingUrl
      @Lync.joinMeeting meetingUrl, callback

module.exports = Connector
