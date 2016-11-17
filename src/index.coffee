async            = require 'async'
{EventEmitter}   = require 'events'
_                = require 'lodash'
debug            = require('debug')('meshblu-connector-skype:index')
LyncEventHandler = require './lync-event-handler'

TWENTY_SECONDS = 20 * 1000

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @autoKillStack = []
    @Lync ?= require './lync-manager'
    @worker = async.queue async.timeout(@_handleDesiredState, TWENTY_SECONDS), 1
    @lyncEventHandler = new LyncEventHandler()

  start: (device, callback) =>
    @Lync.emitEvents @lyncEventHandler.handle

    { @uuid } = device
    @onConfig device, (error) =>
      return callback error if error
      setInterval @_refreshCurrentState, 5000
      @_refreshCurrentState null, callback

  close: (callback) =>
    return callback()

  onConfig: ({desiredState}, callback=->) =>
    @_handleVideoEnabled desiredState, callback

  _onConfig: (device, callback=->) =>
    return callback() unless _.isEqual @uuid, device.uuid
    @_computeState (error, state) =>
      return callback error if error
      return @_emitNoClient {state}, callback unless state.hasClient

      desiredState = _.get device, 'desiredState', {}
      return callback() if _.isEqual @_lastJob, desiredState
      @_lastJob = desiredState
      return callback() if _.isEmpty desiredState

      @worker.push desiredState, (error) =>
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

      if _.size(@autoKillStack) > 4
        @Lync.stopMeetings null, (error) =>
          @worker.kill()
          @_lastJob = undefined
          @emit 'error', error if error?
          @emit 'update', favoriteInteger: 1

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
      async.apply(@_handleMeeting,      desiredState)
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
    console.log '_handleVideoEnabled', desiredState
    return callback() unless _.has desiredState, 'videoEnabled'

    # return @_stopVideo null, callback unless desiredState.videoEnabled
    return callback() unless desiredState.videoEnabled
    return @_startVideo callback

  _startVideo: (callback) =>
    console.log JSON.stringify @lyncEventHandler.conversations
    conversation = _.first _.values @lyncEventHandler.conversations
    console.log 'conversation', JSON.stringify conversation, null, 2
    return callback() unless conversation?
    videoState = _.get conversation, 'video.state'
    return callback() if videoState == 'Send' || videoState == 'Receive' || videoState == 'SendReceive'
    return @Lync.connectToVideo callback if _.get conversation, 'modality.actions.Connect'
    @lyncEventHandler.once => _startVideo callback


module.exports = Connector
