{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-skype:index')
Lync            = require './lync-manager'

class Connector extends EventEmitter
  constructor: ->
    @conversationId = null

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}) =>
    { @options } = device
    debug 'on config', @options
    @handleStateChange @options

  handleStateChange: (options={}) =>
    { url, state } = options
    return @endMeeting(@conversationId) if state == "End Meeting" && @conversationId?
    return @startConversation() if !url? && state == "Join Meeting"
    return @joinMeeting url if url? && state == "Join Meeting"

  start: (device, callback) =>
    debug 'started'
    # @joinMeeting("https://meet.citrix.com/moheeb.zara/4KBKB5SJ");
    @onConfig device
    callback()

  joinMeeting: (url) =>
    Lync.joinMeeting url, (error, result) =>
      throw error if error
      @conversationId = result

  startConversation: () =>
    Lync.startConversation null, (error, result) =>
      throw error if error
      @conversationId = result

  endMeeting: (id) =>
    Lync.stopMeeting id, (error, result) =>
      throw error if error
      debug result
      @conversationId = null

  stopAllMeetings: (callback) =>
    Lync.stopAllMeetings id, (error, result) =>
      throw error if error
      @conversationId = null
      callback result



module.exports = Connector
