_ = require 'lodash'
EventEmitter = require 'eventemitter2'
class LyncEventHandler extends EventEmitter
  constructor: ->
    @conversations = {}

  handle: ({conversationId, eventSource, eventType, data}) =>
    console.log {conversationId, eventSource, eventType, data}
    @handleConversationManagerEvent {conversationId, eventType, data} if eventSource == 'ConversationManager'
    @handleConversationEvent {conversationId, eventType, data} if eventSource == 'Conversation'
    @handleVideoChannelEvent {conversationId, eventType, data} if eventSource == 'VideoChannel'
    @handleAVModalityEvent {conversationId, eventType, data} if eventSource == 'AvModality'
    
    @emit @conversations


  handleConversationEvent: ({conversationId, eventType, data}) =>
    if eventType == 'StateChanged'
      _.set @conversations, "#{conversationId}.state", data.NewState

  handleConversationManagerEvent: ({conversationId, eventType, data}) =>
    if eventType == 'ConversationAdded'
      _.set @conversations, "#{conversationId}.properties", data

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

module.exports = LyncEventHandler
