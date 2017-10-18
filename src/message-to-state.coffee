_             = require 'lodash'
StateManager  = './index'

StartSkypeState =
  desiredState:
    videoEnabled: true
    audioEnabled: true
    meeting:
      url: null

EndSkypeState =
  desiredState:
    meeting: null

class MessageToState
  constructor: ({@stateManager}={}) ->
    @stateManager = new StateManager() unless @stateManager?

  start: (callback) =>
    @stateManager.start {}, callback

  onMessage: (message) =>
    jobType = _.get(message, 'metadata.jobType')
    return @stateManager.onConfig StartSkypeState if jobType == 'start-skype'
    return @stateManager.onConfig EndSkypeState if jobType == 'end-skype'
    return console.log "I don't know what this message means: #{jobType}"

module.exports = MessageToState
