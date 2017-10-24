{sinon, describe, it, expect, beforeEach} = global
MessageToState = require '..'

describe 'when we create a new MessageToState', ->
  beforeEach 'setup state manager', ->
    @stateManager = {
      start: sinon.stub()
      onConfig: sinon.stub()
    }

  beforeEach ->
    @sut = new MessageToState { @stateManager }

  it 'should exist', ->
    expect(@sut).to.exist

  describe 'when start is called', ->
    beforeEach 'start()', ->
      @callback = ->
      @sut.start @callback
    it 'should call start on stateManager with an empty device and a callback', ->
      expect(@stateManager.start).to.have.been.calledWith {}, @callback

  describe 'when called with a start-skype message', ->
    beforeEach ->
      startSkypeMessage =
        metadata:
          jobType: 'start-skype'
      @sut.onMessage startSkypeMessage

    it 'should call onConfig on the stateManager with the correct desiredState', ->
      state =
        desiredState:
          videoEnabled: true
          audioEnabled: true
          meeting:
            url: null
        autoLaunchSkype: true

      expect(@stateManager.onConfig).to.have.been.calledWith state

  describe 'when called with an end-skype message', ->
    beforeEach ->
      startSkypeMessage =
        metadata:
          jobType: 'end-skype'
      @sut.onMessage startSkypeMessage

    it 'should call onConfig on the stateManager with the correct desiredState', ->
      state =
        desiredState: meeting: null
        autoLaunchSkype: true

      expect(@stateManager.onConfig).to.have.been.calledWith state

  describe 'when autoLaunchSkype is called', ->
    beforeEach ->
      @sut.autoLaunchSkype()

    it 'should call onConfig on the stateManager with the correct desiredState', ->
      state = autoLaunchSkype: true

      expect(@stateManager.onConfig).to.have.been.calledWith state
