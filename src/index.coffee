async          = require 'async'
{EventEmitter} = require 'events'
_              = require 'lodash'
debug           = require('debug')('meshblu-connector-skype:index')

ONE_MINUTE = 60 * 10000

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @autoKillStack = []
    @Lync ?= require './lync-manager'
    @worker = async.queue async.timeout(@_handleDesiredState, ONE_MINUTE), 1

  start: (device, callback) =>
    @onConfig device, (error) =>
      return callback error if error
      setInterval @_refreshCurrentState, 5000
      @_refreshCurrentState null, callback

  close: (callback) =>
    return callback()

  onConfig: (device, callback=->) =>
    @_computeState (error, state) =>
      return callback error if error
      return @_emitNoClient {state}, callback unless state.hasClient

      desiredState = _.get device, 'desiredState', {}
      return callback() if _.isEmpty desiredState
      return callback() if _.isEqual @_lastJob, desiredState
      @_lastJob = desiredState

      @worker.push desiredState, (error) =>
        @_lastJob = null if _.isEqual desiredState, @_lastJob

        if error?
          console.error error.stack
          return callback error

        @_refreshCurrentState desiredState: {}, callback

  _refreshCurrentState: (update=null, callback=->) =>
    @_computeState (error, state) =>
      return callback error if error?
      if state.videoState == 'Connecting'
        @autoKillStack.push(state.videoState)
      else
        @autoKillStack.length = 0

      if _.size(@autoKillStack) > 3
        @Lync.stopMeetings null, (error) =>
          @worker.kill()
          @emit 'error', error if error?

      @_emitUpdate _.defaults({state}, update), callback

  _emitNoClient: ({state}, callback) =>
    @emit 'error', new Error('Cannot find running Lync Process')
    @_emitUpdate {state}, callback

  _emitUpdate: (update, callback) =>
    return callback() if _.isEqual update, @_previousUpdate
    @emit 'update', update
    @_previousUpdate = update
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

    setTimeout =>
      return @Lync.stopVideo null, callback unless desiredState.videoEnabled
      return @Lync.startVideo null, callback
    , 2000 # wait 2s. Just cause


module.exports = Connector
