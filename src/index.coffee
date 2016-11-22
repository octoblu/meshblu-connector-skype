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
    @lyncEventEmitter.on 'config', _.throttle (=> @_refreshCurrentState()), 500
    # @lyncEventEmitter.on 'config', (config) => console.log JSON.stringify config, null, 2
    @Lync.emitEvents @lyncEventEmitter.handle
    { @uuid } = device
    @onConfig device, (error) =>
      return callback error if error
      @_refreshCurrentState callback

  close: (callback) =>
    return callback()

  onConfig: ({desiredState}={}, callback) =>
    callback()
    return if _.isEmpty desiredState
    @desiredState = desiredState
    @updateDesiredState {}
    @truthAndReconcilliation()

  startMeeting: ({audioEnabled, videoEnabled}, callback) =>
    finishStartMeetingHandler = (conversations) =>
      currentState = _.first _.values conversations
      conversationUrl = _.get currentState, 'properties.conferenceAccessInformation.ExternalUrl'
      if conversationUrl
        @lyncEventEmitter.off 'config', finishStartMeetingHandler
        callback null, meeting: url: conversationUrl

    @Lync.stopMeetings null, (error) =>
      @lyncEventEmitter.on 'config', finishStartMeetingHandler
      @updateDesiredState {audioEnabled, videoEnabled, meeting: {}}

  truthAndReconcilliation: =>
    currentState = _.first _.values @lyncEventEmitter.conversations
    debug "truthAndReconcilliation", {currentState, @desiredState}
    return unless @desiredState?

    @_handleMeeting currentState, (error) =>
      delete @desiredState.meeting

    @_handleAudioEnabled currentState

    @_handleVideoEnabled currentState

  updateDesiredState: (desiredState) =>
    @emit 'update', {desiredState}

  _refreshCurrentState: (callback=->) =>
    @_computeState (error, state) =>
      return callback error if error?
      @_emitUpdate {state}, callback

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
    currentState = _.first _.values @lyncEventEmitter.conversations
    return callback null, {meeting: null} unless currentState?
    conversationUrl = _.get currentState, 'properties.conferenceAccessInformation.ExternalUrl'
    self = currentState.participants?[currentState.self]
    videoState = _.get currentState, 'video.state'

    ourKindaState =
      meeting:
        url: conversationUrl
        subject: _.get currentState, 'subject'
        participants: _.get currentState, 'participants'
      conversationId: _.get currentState, 'properties.id'
      videoState: _.get currentState, 'video.state'
      videoEnabled: videoState == 'Send' || videoState == 'SendReceive'
      videoActions: _.get currentState, 'video.actions'
      audioEnabled: !self?.isMuted

    callback null, ourKindaState

  _handleAudioEnabled: (currentState, callback=->) =>
    debug '_handleAudioEnabled', {currentState, @desiredState}

    return callback() unless _.has @desiredState, 'audioEnabled'
    return callback() unless _.has currentState, 'self'

    self = currentState.participants[currentState.self]
    debug @desiredState.audioEnabled, self.isMuted

    if @desiredState.audioEnabled
      return @Lync.unmute null, (error) =>
        return callback error if error?
        delete @desiredState.audioEnabled
        callback()

    return @Lync.mute null, =>
      return callback error if error?
      delete @desiredState.audioEnabled
      callback()

  _handleMeeting: (currentState, callback=->) =>
    debug '_handleMeeting', {@desiredState, currentState}
    {meeting} = @desiredState
    delete @desiredState.meeting
    return callback() if meeting == undefined
    return @Lync.stopMeetings null, callback if meeting == null

    conversationUrl = _.get currentState, 'properties.conferenceAccessInformation.ExternalUrl'
    return callback() if conversationUrl && meeting.url == conversationUrl

    debug 'stopping meetings'
    @Lync.stopMeetings null, (error) =>
      return callback error if error?
      return @Lync.createMeeting null, callback if _.isEmpty meeting.url
      @Lync.joinMeeting meeting.url, callback

  _handleVideoEnabled: (currentState, callback=->) =>
    debug '_handleVideoEnabled', @desiredState
    return callback() unless _.has @desiredState, 'videoEnabled'

    return @Lync.stopVideo null, callback unless @desiredState.videoEnabled
    return @_startVideo currentState, callback

  _startVideo: (currentState, callback) =>
    debug "trying to _startVideo"

    videoState = _.get currentState, 'video.state'
    if videoState == 'Send' || videoState == 'SendReceive'
      debug "videoState was #{videoState}. We're done!"
      delete @desiredState.videoEnabled
      return callback()

    unless _.get(currentState, 'modality.state') == 'Connected'
      debug 'not connected. waiting till next time'
      return callback()

    unless _.get(currentState, 'video.actions.Start') || _.get(currentState, 'video.actions.Resume')
      debug "I can't resume or start the video. waiting until next time"
      return callback()

    debug "Starting video"
    @Lync.startVideo null, (error) =>
      return callback error if error?
      delete @desiredState.videoEnabled
      callback()

module.exports = Connector
