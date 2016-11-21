async            = require 'async'
{EventEmitter}   = require 'events'
_                = require 'lodash'
debug            = require('debug')('meshblu-connector-skype:index')
LyncEventEmitter = require './lync-event-emitter'

class Connector extends EventEmitter
  constructor: ({@Lync}) ->
    @Lync ?= require './lync-manager'
    @lyncEventEmitter = new LyncEventEmitter()

  start: (device, callback) =>
    @lyncEventEmitter.on 'config', @truthAndReconcilliation
    @Lync.emitEvents @lyncEventEmitter.handle
    { @uuid } = device
    @onConfig device, (error) =>
      return callback error if error
      setInterval @_refreshCurrentState, 5000
      @_refreshCurrentState null, callback

  close: (callback) =>
    return callback()

  onConfig: ({@desiredState}={}, callback) =>
    @truthAndReconcilliation()
    callback()

  startMeeting: (callback) =>
    console.log "startMeeting"
    finishStartMeetingHandler = (conversations) =>
      currentState = _.first _.values conversations
      conversationUrl = _.get currentState, 'properties.ConferenceAccessInformation.ExternalUrl'
      if conversationUrl
        @lyncEventEmitter.off 'config', finishStartMeetingHandler
        callback null, {conversationUrl}

    @Lync.stopMeetings null, (error) =>
      console.log "MEETINGS HAVE BEEN STOPPED"
      @lyncEventEmitter.on 'config', finishStartMeetingHandler
      @Lync.createMeeting null

  truthAndReconcilliation: =>
    try
      console.log 'truthAndReconcilliation'
      currentState = _.first _.values @lyncEventEmitter.conversations
      debug "truthAndReconcilliation", {currentState, @desiredState}
      return unless currentState?
      return unless @desiredState?
      # @_handleMeeting {currentState, @desiredState}
      @_handleAudioEnabled {currentState, @desiredState}
      @_handleVideoEnabled {currentState, @desiredState}

    catch error
      console.log "ERROR!", error
    return true

  updateDesiredState: (desiredState) =>
    @emit 'update', {desiredState}

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

  _computeState: (callback) =>
    debug '_computeState'
    @Lync.getState null, (error, state) =>
      return callback error if error?
      return callback null, state

  _handleAudioEnabled: ({currentState, desiredState}, callback=->) =>
    debug '_handleAudioEnabled'

    return callback() unless _.has desiredState, 'audioEnabled'
    return callback() unless _.has currentState, 'self'
    self = currentState.participants[currentState.self]
    debug desiredState.audioEnabled, self.isMuted
    return callback() if desiredState.audioEnabled != self.IsMuted

    return @Lync.unmute null, callback if desiredState.audioEnabled
    return @Lync.mute null, callback

  _handleMeeting: ({currentState, desiredState}, callback=->) =>
    debug '_handleMeeting'
    return callback() unless _.has desiredState, 'meeting'
    {meeting} = desiredState

    @Lync.stopMeetings null, (error) =>
      return callback error if error?
      return callback() if _.isEmpty meeting
      return @Lync.createMeeting null, callback if _.isEmpty meeting.url

      @Lync.joinMeeting meeting.url, callback

  _handleVideoEnabled: ({currentState, desiredState}, callback=->) =>
    debug '_handleVideoEnabled', desiredState
    return callback() unless _.has desiredState, 'videoEnabled'

    return @Lync.stopVideo null, callback unless desiredState.videoEnabled
    return callback() unless desiredState.videoEnabled
    return @_startVideo {currentState, desiredState}, callback

  _startVideo: ({currentState, desiredState}, callback) =>
    debug "trying to _startVideo"

    videoState = _.get currentState, 'video.state'
    if videoState == 'Send' || videoState == 'SendReceive'
      debug "videoState was #{videoState}. We're done!"
      return callback()

    unless _.get(currentState, 'modality.state') == 'Connected'
      debug 'not connected. waiting till next time'

    unless _.get(currentState, 'video.actions.Start') || _.get(currentState, 'video.actions.Resume')
      debug "I can't resume or start the video. waiting until next time"

    debug "Starting video"
    @Lync.startVideo(null)


module.exports = Connector
