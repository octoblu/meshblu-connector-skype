{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @Lync =
      getConferenceUri: sinon.stub().yields()
      joinMeeting:      sinon.stub()
      stopMeetings:     sinon.stub()
      unmute:           sinon.stub()
    @sut = new Connector {@Lync}
    @sut.start {}, done

  afterEach (done) ->
    @sut.close done

  describe 'Enable Audio', ->
    beforeEach (done) ->
      @sut.on 'update', => done()
      @Lync.unmute.yields()
      @sut.onConfig desiredState: {enableAudio: true}

    it 'should call Lync.unmute', ->
      expect(@Lync.unmute).to.have.been.called

  describe 'Disable Audio', ->

  describe 'Start a Meeting', ->

  describe 'Join a Meeting', ->
    describe 'When the connector is not currently in a meeting', ->
      beforeEach ->
        @Lync.getConferenceUri.onFirstCall().yields(null, null)

      describe 'And a config event with a url comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.joinMeeting.yields()
          @Lync.getConferenceUri.onSecondCall().yields null, 'https://meet.go.co/alskdjf'
          @sut.onConfig {
            desiredState:
              meetingUrl: 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'
          }

        it 'should join the meeting', ->
          expect(@Lync.joinMeeting).to.have.been.called

        it 'should emit an update with an empty desiredState, and the new actual state', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meetingUrl:  'https://meet.go.co/alskdjf'
          }

    describe 'When the connector is already in a meeting', ->
      beforeEach ->
        @Lync.getConferenceUri.onFirstCall().yields(null, 'https://meeting.i.was.already.in')

      describe 'And a config event with a different meetingUrl comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.joinMeeting.yields()
          @Lync.getConferenceUri.onSecondCall().yields(null, 'https://meeting.im.in.now')
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
          @Lync.getConferenceUri.onSecondCall().yields(null, 'https://meeting.i.was.already.in')
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
          }

  describe 'Leave a Meeting', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.stopMeetings.yields()
      @Lync.getConferenceUri.yields null, null
      @sut.onConfig {
        desiredState:
          meetingUrl: null
      }

    it 'should stop all meetings', ->
      expect(@Lync.stopMeetings).to.have.been.called

    it 'should emit an update with an empty desiredState', ->
      expect(@update).to.deep.equal {desiredState: {}, state: {meetingUrl: null}}

  describe 'Enable Video', ->
  describe 'Disable Video', ->


  xdescribe 'Start', ->
    it 'should start', ->
