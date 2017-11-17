_             = require 'lodash'
StateManager  = require './index'
{EventEmitter} = require 'events'
debug = require("debug")("meshblu-connector-skype:message-to-state")

StartSkypeState =
  desiredState:
    videoEnabled: true
    audioEnabled: true
    meeting:
      url: null
  autoLaunchSkype: true

EndSkypeState =
  desiredState: meeting: null
  autoLaunchSkype: true

class MessageToState extends EventEmitter
  constructor: ({@stateManager}={}) ->
    @stateManager = new StateManager() unless @stateManager?
    @stateManager.on 'update', (config) => @emit 'update', config

  start: (callback) =>
    @stateManager.start {autoLaunchSkype: true}, callback

  onMessage: (message) =>
    type = message.metadata.route[0].type
    return @onConfig(message) if type == 'configure.sent'
    message = message.data
    jobType = _.get(message, 'metadata.jobType')
    debug("message received", JSON.stringify({ message, jobType }, null, 2))
    config = _.cloneDeep(StartSkypeState) if jobType == 'start-skype'
    config = _.cloneDeep(EndSkypeState) if jobType == 'end-skype'
    debug("sending config": JSON.stringify(config,null,2))
    return @stateManager.onConfig config if config?
    return console.log "I don't know what this message means: #{jobType}"

  onConfig: (config) =>
    return @stateManager.onConfig config.data

  autoLaunchSkype: () =>
    @stateManager.onConfig autoLaunchSkype: true

module.exports = MessageToState
