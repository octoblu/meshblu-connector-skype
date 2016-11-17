async            = require 'async'
{EventEmitter}   = require 'events'
_                = require 'lodash'
debug            = require('debug')('meshblu-connector-skype:index')
LyncEventEmitter = require './lync-event-emitter'

TWENTY_SECONDS = 20 * 1000

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @Lync ?= require './lync-manager'
    @worker = async.queue @_handleDesiredState, 1
    @lyncEventEmitter = new LyncEventEmitter()

  start: (device, callback) =>
    @Lync.emitEvents @lyncEventEmitter.handle

    { @uuid } = device
    @onConfig device, (error) =>
      return callback error if error
      setInterval @_refreshCurrentState, 5000
      @_refreshCurrentState null, callback

  close: (callback) =>
    return callback()

  _onConfig: ({desiredState}, callback=->) =>
    @_handleVideoEnabled desiredState, callback

  onConfig: (device, callback=->) =>
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
    debug '_handleVideoEnabled', desiredState
    return callback() unless _.has desiredState, 'videoEnabled'

    return @Lync.stopVideo null, callback unless desiredState.videoEnabled
    return callback() unless desiredState.videoEnabled
    return @_startVideo callback

  _startVideo: (callback) =>
    debug "trying to _startVideo"
    conversation = _.first _.values @lyncEventEmitter.conversations
    unless conversation?
      debug "You don't have a conversation bro. Giving up"
      return callback()
    videoState = _.get conversation, 'video.state'
    if videoState == 'Send' || videoState == 'SendReceive'
      debug "videoState was #{videoState}. We're done!"
      return callback()

    unless _.get(conversation, 'modality.state') == 'Connected'
      debug 'not connected. waiting till next time'
      @lyncEventEmitter.once 'change', => @_startVideo callback

    unless _.get(conversation, 'video.actions.Start') || _.get(conversation, 'video.actions.Resume')
      debug "I can't resume or start the video. waiting until next time"
      @lyncEventEmitter.once 'change', => @_startVideo callback

    @Lync.startVideo callback


module.exports = Connector
