async          = require 'async'
{EventEmitter} = require 'events'
_              = require 'lodash'
debug           = require('debug')('meshblu-connector-skype:index')

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @Lync ?= require './lync-manager'

  start: (device, callback) =>
    setInterval @_updateCurrentState, 15000

    @onConfig device, (error) =>
      return callback error if error
      @_updateCurrentState callback

  close: (callback) =>
    return callback()

  onConfig: (device, callback=->) =>
    desiredState = _.get device, 'desiredState', {}
    return callback() if _.isEmpty desiredState

    @_handleDesiredState desiredState, (error) =>
      if error
        console.error error.stack
        return callback error

      @_updateCurrentState callback

  _updateCurrentState: (callback=->) =>
    @_computeState (error, state) =>
      return callback error if error?
      @emit 'update', {state, desiredState: {}}
      callback()

  _handleDesiredState: (desiredState, callback) =>
    async.series [
      async.apply(@_handleMeeting,   desiredState)
      async.apply(@_handleAudioEnabled, desiredState)
      async.apply(@_handleVideoEnabled, desiredState)
    ], callback

  _computeState: (callback) =>
    debug '_computeState'
    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback null, state

  _handleAudioEnabled: (desiredState, callback) =>
    debug '_handleAudioEnabled'
    return callback() unless _.has desiredState, 'audioEnabled'

    return @Lync.unmute null, callback if desiredState.audioEnabled
    return @Lync.mute null, callback

  _handleMeeting: (desiredState, callback) =>
    debug '_handleMeeting'
    return callback() unless _.has desiredState, 'meeting'
    {meeting} = desiredState

    @Lync.stopMeetings null, (error) =>
      return callback error if error?
      return callback() if _.isEmpty meeting
      return @Lync.createMeeting null, callback if _.isEmpty meeting.url

      @Lync.joinMeeting meeting.url, callback

  _handleVideoEnabled: (desiredState, callback) =>
    debug '_handleVideoEnabled'
    return callback() unless _.has desiredState, 'videoEnabled'

    return @Lync.stopVideo null, callback unless desiredState.videoEnabled
    return @Lync.startVideo null, callback


module.exports = Connector
