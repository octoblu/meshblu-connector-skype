_ = require 'lodash'
debug = require('debug')('meshblu-connector-skype:lync-event-emitter')
EventEmitter = require 'eventemitter2'
class LyncEventEmitter extends EventEmitter
  constructor: ->
    @conversations = {}

  handle: ({conversationId, eventSource, eventType, participantId, data}) =>
    console.log {conversationId, eventSource, eventType}
    @handleConversationManagerEvent {conversationId, eventType, data} if eventSource == 'ConversationManager'
    @handleConversationEvent {conversationId, eventType, data} if eventSource == 'Conversation'
    @handleVideoChannelEvent {conversationId, eventType, data} if eventSource == 'VideoChannel'
    @handleAVModalityEvent {conversationId, eventType, data} if eventSource == 'AvModality'
    @handleParticipantEvent {conversationId, participantId, eventType, data} if eventSource == 'Participant'
    debug JSON.stringify(@conversations, null, 2)
    @emit 'change', @conversations


  handleParticipantEvent: ({conversationId, participantId, eventType, data}) =>
    if eventType == 'MutedChanged'
      safeId = _.replace participantId, /\./g, '-'
      _.set @conversations, "#{conversationId}.participants.#{safeId}.IsMuted", data

  handleConversationEvent: ({conversationId, eventType, data}) =>
    if eventType == 'StateChanged'
      _.set @conversations, "#{conversationId}.state", data.NewState

    if eventType == 'PropertyChanged'
      console.log "PropertyChanged", JSON.stringify(data, null, 2)
      _.set @conversations, "#{conversationId}.properties.#{data.Property}", data.Value

    if eventType == 'ParticipantAdded'
      safeId = _.replace data.Id, /\./g, '-'
      _.set @conversations, "#{conversationId}.participants.#{safeId}", data
      _.set @conversations, "#{conversationId}.self", safeId if data.IsSelf

    if eventType == 'ParticipantRemoved'
      console.log "ParticipantRemoved", JSON.stringify(data, null, 2)
      safeId = _.replace data.Id, /\./g
      _.unset @conversations, "#{conversationId}.participants.#{safeId}"

  handleConversationManagerEvent: ({conversationId, eventType, data}) =>
    if eventType == 'ConversationAdded'
      _.set @conversations, "#{conversationId}.properties", data || {}

    if eventType == 'ConversationRemoved'
      delete @conversations[conversationId]

  handleVideoChannelEvent: ({conversationId, eventType, data}) =>
    if eventType == 'ActionAvailabilityChanged'
      _.set @conversations, "#{conversationId}.video.actions.#{data.Action}", data.IsAvailable

    if eventType == 'StateChanged'
      _.set @conversations, "#{conversationId}.video.state", data.NewState

  handleAVModalityEvent: ({conversationId, eventType, data}) =>
    if eventType == 'ActionAvailabilityChanged'
      _.set @conversations, "#{conversationId}.modality.actions.#{data.Action}", data.IsAvailable

    if eventType == 'ModalityStateChanged'
      _.set @conversations, "#{conversationId}.modality.state", data.NewState

module.exports = LyncEventEmitter
