{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @Lync =
      getConferenceUri: sinon.stub().yields()
      getState:         sinon.stub()
      joinMeeting:      sinon.stub()
      stopMeetings:     sinon.stub()
      mute:             sinon.stub()
      unmute:           sinon.stub()
    @sut = new Connector {@Lync}
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe 'Empty desiredState', ->
    beforeEach (done) ->
      @sut.on 'update', => done new Error ('this should not happen')
      @sut.onConfig desiredState: {}, =>
      setInterval done, 1000

    it 'should not emit update', ->
      # getting here is good enough

  describe 'Enable Audio', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.unmute.yields()
      @Lync.getState.yields null, {
        meetingUrl:     'https://meet.go.co/alskdjf'
        conversationId: '123'
        audioEnabled: true
      }
      @sut.onConfig desiredState: {audioEnabled: true}

    it 'should call Lync.unmute', ->
      expect(@Lync.unmute).to.have.been.calledWith '123'

    it 'should emit an update with an empty desiredState, and the new actual state', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meetingUrl:     'https://meet.go.co/alskdjf'
          conversationId: '123'
          audioEnabled:   true
      }

  describe 'Disable Audio', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.mute.yields()
      @Lync.getState.yields null, {
        meetingUrl: 'https://meet.go.co/alskdjf'
        conversationId: '321'
        audioEnabled: false
      }
      @sut.onConfig desiredState: {audioEnabled: false}

    it 'should call Lync.mute', ->
      expect(@Lync.mute).to.have.been.called

    it 'should emit an update with an empty desiredState, and the new actual state', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meetingUrl: 'https://meet.go.co/alskdjf'
          conversationId: '321'
          audioEnabled: false
      }

  describe 'Start a Meeting', ->

  describe 'Join a Meeting', ->
    describe 'When the connector is not currently in a meeting', ->
      beforeEach ->
        @Lync.getConferenceUri.onFirstCall().yields(null, null)

      describe 'And a config event with a url comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.joinMeeting.yields()
          @Lync.getState.yields null, {
            meetingUrl:   'https://meet.go.co/alskdjf'
            audioEnabled: false
          }
          @sut.onConfig {
            desiredState:
              meetingUrl: 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'
          }

        it 'should join the meeting', ->
          expect(@Lync.joinMeeting).to.have.been.calledWith 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'

        it 'should emit an update with an empty desiredState, and the new actual state', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meetingUrl:  'https://meet.go.co/alskdjf'
              audioEnabled: false
          }

    describe 'When the connector is already in a meeting', ->
      beforeEach ->
        @Lync.getConferenceUri.onFirstCall().yields(null, 'https://meeting.i.was.already.in')

      describe 'And a config event with a different meetingUrl comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.joinMeeting.yields()
          @Lync.getState.yields null, {
            meetingUrl: 'https://meeting.im.in.now'
          }
          @sut.onConfig {
            desiredState:
              meetingUrl: 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'
          }

        it 'should join the meeting', ->
          expect(@Lync.joinMeeting).to.have.been.called

        it 'should emit an update with an empty desiredState', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meetingUrl: 'https://meeting.im.in.now'
          }

      describe 'And a config event with the same meetingUrl comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.joinMeeting.yields()
          @Lync.getState.yields null, {
            meetingUrl: 'https://meeting.i.was.already.in'
            audioEnabled: false
          }
          @sut.onConfig {
            desiredState:
              meetingUrl: 'https://meeting.i.was.already.in'
          }

        it 'should not try to join the meeting', ->
          expect(@Lync.joinMeeting).not.to.have.been.called

        it 'should emit an update with an empty desiredState', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meetingUrl: 'https://meeting.i.was.already.in'
              audioEnabled: false
          }

  describe 'Leave a Meeting', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.stopMeetings.yields()
      @Lync.getState.yields null, {
        meetingUrl: 'https://meeting.i.was.already.in'
        audioEnabled: false
      }
      @sut.onConfig {
        desiredState:
          meetingUrl: null
      }

    it 'should stop all meetings', ->
      expect(@Lync.stopMeetings).to.have.been.called

    it 'should emit an update with an empty desiredState', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meetingUrl: 'https://meeting.i.was.already.in'
          audioEnabled: false
      }

  describe 'Enable Video', ->
  describe 'Disable Video', ->

  describe 'Start', ->
    xit 'should start', ->
      @sut.start.should.do.something
