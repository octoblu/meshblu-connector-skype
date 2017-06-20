// Generated by CoffeeScript 1.12.6
(function() {
  var EventEmitter2, LyncEventEmitter, _, debug,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  debug = require('debug')('meshblu-connector-skype:lync-event-emitter');

  EventEmitter2 = require('eventemitter2').EventEmitter2;

  LyncEventEmitter = (function(superClass) {
    extend(LyncEventEmitter, superClass);

    function LyncEventEmitter() {
      this.handleAVModalityEvent = bind(this.handleAVModalityEvent, this);
      this.handleVideoChannelEvent = bind(this.handleVideoChannelEvent, this);
      this.handleConversationManagerEvent = bind(this.handleConversationManagerEvent, this);
      this.handleConversationEvent = bind(this.handleConversationEvent, this);
      this.handleParticipantEvent = bind(this.handleParticipantEvent, this);
      this.handle = bind(this.handle, this);
      this.conversations = {};
    }

    LyncEventEmitter.prototype.handle = function(arg) {
      var conversationId, data, eventSource, eventType, participantId;
      conversationId = arg.conversationId, eventSource = arg.eventSource, eventType = arg.eventType, participantId = arg.participantId, data = arg.data;
      debug({
        conversationId: conversationId,
        eventSource: eventSource,
        eventType: eventType
      });
      if (eventSource === 'ConversationManager') {
        this.handleConversationManagerEvent({
          conversationId: conversationId,
          eventType: eventType,
          data: data
        });
      }
      if (eventSource === 'Conversation') {
        this.handleConversationEvent({
          conversationId: conversationId,
          eventType: eventType,
          data: data
        });
      }
      if (eventSource === 'VideoChannel') {
        this.handleVideoChannelEvent({
          conversationId: conversationId,
          eventType: eventType,
          data: data
        });
      }
      if (eventSource === 'AvModality') {
        this.handleAVModalityEvent({
          conversationId: conversationId,
          eventType: eventType,
          data: data
        });
      }
      if (eventSource === 'Participant') {
        this.handleParticipantEvent({
          conversationId: conversationId,
          participantId: participantId,
          eventType: eventType,
          data: data
        });
      }
      debug(JSON.stringify(this.conversations, null, 2));
      if (!_.isEqual(this.conversations, this.previousConversations)) {
        this.emit('config', this.conversations);
        return this.previousConversations = _.cloneDeep(this.conversations);
      }
    };

    LyncEventEmitter.prototype.handleParticipantEvent = function(arg) {
      var conversationId, data, eventType, participantId, safeId;
      conversationId = arg.conversationId, participantId = arg.participantId, eventType = arg.eventType, data = arg.data;
      if (eventType === 'MutedChanged') {
        safeId = _.replace(participantId, /\./g, '-');
        return _.set(this.conversations, conversationId + ".participants." + safeId + ".isMuted", data);
      }
    };

    LyncEventEmitter.prototype.handleConversationEvent = function(arg) {
      var conversationId, data, eventType, safeId;
      conversationId = arg.conversationId, eventType = arg.eventType, data = arg.data;
      if (eventType === 'StateChanged') {
        if (data.NewState === 'Terminated') {
          delete this.conversations[conversationId];
        } else {
          _.set(this.conversations, conversationId + ".state", data.NewState);
        }
      }
      if (eventType === 'PropertyChanged') {
        _.set(this.conversations, conversationId + ".properties." + (_.camelCase(data.Property)), data.Value);
      }
      if (eventType === 'ParticipantAdded') {
        safeId = _.replace(data.id, /\./g, '-');
        _.set(this.conversations, conversationId + ".participants." + safeId, data);
        if (data.isSelf) {
          _.set(this.conversations, conversationId + ".self", safeId);
        }
      }
      if (eventType === 'ParticipantRemoved') {
        safeId = _.replace(data.id, /\./g);
        return _.unset(this.conversations, conversationId + ".participants." + safeId);
      }
    };

    LyncEventEmitter.prototype.handleConversationManagerEvent = function(arg) {
      var conversationId, data, eventType;
      conversationId = arg.conversationId, eventType = arg.eventType, data = arg.data;
      if (eventType === 'ConversationAdded') {
        _.set(this.conversations, conversationId + ".properties", data || {});
      }
      if (eventType === 'ConversationRemoved') {
        return delete this.conversations[conversationId];
      }
    };

    LyncEventEmitter.prototype.handleVideoChannelEvent = function(arg) {
      var conversationId, data, eventType;
      conversationId = arg.conversationId, eventType = arg.eventType, data = arg.data;
      if (eventType === 'ActionAvailabilityChanged') {
        _.set(this.conversations, conversationId + ".video.actions." + data.Action, data.IsAvailable);
      }
      if (eventType === 'StateChanged') {
        return _.set(this.conversations, conversationId + ".video.state", data.NewState);
      }
    };

    LyncEventEmitter.prototype.handleAVModalityEvent = function(arg) {
      var conversationId, data, eventType;
      conversationId = arg.conversationId, eventType = arg.eventType, data = arg.data;
      if (eventType === 'ActionAvailabilityChanged') {
        _.set(this.conversations, conversationId + ".modality.actions." + data.Action, data.IsAvailable);
      }
      if (eventType === 'ModalityStateChanged') {
        return _.set(this.conversations, conversationId + ".modality.state", data.NewState);
      }
    };

    return LyncEventEmitter;

  })(EventEmitter2);

  module.exports = LyncEventEmitter;

}).call(this);

//# sourceMappingURL=lync-event-emitter.js.map