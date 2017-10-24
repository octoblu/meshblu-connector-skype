{EventEmitter}      = require 'events'
_                   = require 'lodash'
moment              = require 'moment'
debug               = require('debug')('meshblu-connector-skype:index')
LyncEventEmitter    = require './lync-event-emitter'
LyncLauncher        = require './lync-launcher'
LyncDisableFeedback = require './lync-disable-feedback'

class Connector extends EventEmitter
  constructor: ({@Lync}={}) ->
    @Lync ?= require('./lync-manager')
    @lyncEventEmitter = new LyncEventEmitter()

  start: (device, callback) =>
    @_killFeedbackInterval = setInterval @killFeedback, 10000
    @lyncEventEmitter.on 'config', @truthAndReconcilliation
    @lyncEventEmitter.on 'config', _.throttle (=> @_refreshCurrentState()), 1000
    LyncDisableFeedback.disable (error) =>
      return callback error if error?
    { @uuid } = device
    @onConfig device, (error) =>
      return callback error if error
      @_refreshCurrentState callback

  close: (callback) =>
    clearInterval @_killFeedbackInterval
    return callback()

  onConfig: ({desiredState, autoLaunchSkype}={}, callback=->) =>
    callback()
    debug 'autoLaunchSkype', autoLaunchSkype
    LyncLauncher.stopAutoCheck()
    LyncLauncher.autoCheck() if autoLaunchSkype

    return if _.isEmpty desiredState
    @Lync.emitEvents @lyncEventEmitter.handle
    @desiredState = desiredState
    @updateDesiredState {}
    @truthAndReconcilliation()

  killFeedback: =>
    @Lync.killFeedback (error) =>
      console.error '@Lync.killFeedback', error.stack if error?

  startMeeting: ({audioEnabled, videoEnabled}, callback) =>
    finishStartMeetingHandler = (conversations) =>
      currentState = _.first _.values conversations
      conversationUrl = _.get currentState, 'properties.conferenceAccessInformation.ExternalUrl'
      if conversationUrl
        @lyncEventEmitter.off 'config', finishStartMeetingHandler
        callback null, meeting: url: conversationUrl

    @Lync.stopMeetings null, (error) =>
      console.error '@Lync.stopMeetings', error.stack if error?
      @lyncEventEmitter.on 'config', finishStartMeetingHandler
      @updateDesiredState {audioEnabled, videoEnabled, meeting: {}}

  truthAndReconcilliation: =>
    currentState = _.first _.values @lyncEventEmitter.conversations
    debug "truthAndReconcilliation", {currentState, @desiredState}
    return unless @desiredState?

    @_handleMeeting currentState, (error) =>
      console.error '@_handleMeeting', error.stack if error?
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
    @emit 'update', _.defaults {connectorUpdatedAt: moment().utc().toISOString()}, update
    @_previousUpdate = update
    callback()

  _computeState: (callback) =>
    debug '_computeState'
    currentState = _.first _.values @lyncEventEmitter.conversations
    return callback null, {meeting: null} unless currentState?
    conversationUrl = _.get currentState, 'properties.conferenceAccessInformation.ExternalUrl'
    conversationUrl = null if _.isEmpty conversationUrl
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
    return callback() unless _.lowerCase(currentState?.state) == 'active'

    self = _.get currentState, "participants.#{currentState.self}"
    debug @desiredState.audioEnabled, self.isMuted

    if @desiredState.audioEnabled
      debug 'unmuting'
      return @Lync.unmute null, (error) =>
        debug 'unmuted', error
        return callback error if error?
        delete @desiredState.audioEnabled
        callback()

    debug 'muting'
    return @Lync.mute null, (error) =>
      debug 'muted', error
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
    return callback() unless _.lowerCase(currentState?.state) == 'active'

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
    @Lync.startVideo null, callback

module.exports = Connector
