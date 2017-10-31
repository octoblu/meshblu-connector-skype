_             = require 'lodash'
StateManager  = require './index'
{EventEmitter} = require 'events'
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
    message = message.data
    jobType = _.get(message, 'metadata.jobType')
    return @stateManager.onConfig _.cloneDeep(StartSkypeState) if jobType == 'start-skype'
    return @stateManager.onConfig _.cloneDeep(EndSkypeState) if jobType == 'end-skype'
    return console.log "I don't know what this message means: #{jobType}"

  onConfig: (config) =>
    return @stateManager.onConfig config.data

  autoLaunchSkype: () =>
    @stateManager.onConfig autoLaunchSkype: true

module.exports = MessageToState
