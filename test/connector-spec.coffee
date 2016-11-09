{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

Connector = require '../'

describe 'Connector', ->
  beforeEach (done) ->
    @Lync =
      createMeeting:    sinon.stub()
      getConferenceUri: sinon.stub().yields()
      getState:         sinon.stub().yields()
      joinMeeting:      sinon.stub()
      startVideo:       sinon.stub()
      stopVideo:        sinon.stub()
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
      setTimeout done, 100

    it 'should not emit update', ->
      # getting here is good enough

  describe 'Enable Audio', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.unmute.yields()
      @Lync.getState.yields null, {
        meeting:
          url: 'https://meet.go.co/alskdjf'
        conversationId: '123'
        audioEnabled: true
      }
      @sut.onConfig desiredState: {audioEnabled: true}

    it 'should call Lync.unmute', ->
      expect(@Lync.unmute).to.have.been.called

    it 'should emit an update with an empty desiredState, and the new actual state', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meeting:
            url: 'https://meet.go.co/alskdjf'
          conversationId: '123'
          audioEnabled:   true
      }

  describe 'Disable Audio', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.mute.yields()
      @Lync.getState.yields null, {
        meeting:
          url: 'https://meet.go.co/alskdjf'
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
          meeting:
            url: 'https://meet.go.co/alskdjf'
          conversationId: '321'
          audioEnabled: false
      }

  describe 'Enable Video', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.startVideo.yields()
      @Lync.getState.yields null, {
        meeting:
          url: 'https://meet.go.co/alskdjf'
        conversationId: '123'
        audioEnabled: true
        videoEnabled: true
      }
      @sut.onConfig desiredState: {videoEnabled: true}

    it 'should call Lync.startVideo', ->
      expect(@Lync.startVideo).to.have.been.called

    it 'should emit an update with an empty desiredState, and the new actual state', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meeting:
            url: 'https://meet.go.co/alskdjf'
          conversationId: '123'
          audioEnabled:   true
          videoEnabled:   true
      }

  describe 'Disable Video', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.stopVideo.yields()
      @Lync.getState.yields null, {
        meeting:
          url: 'https://meet.go.co/alskdjf'
        conversationId: '123'
        audioEnabled: true
        videoEnabled: false
      }
      @sut.onConfig desiredState: {videoEnabled: false}

    it 'should call Lync.stopVideo', ->
      expect(@Lync.stopVideo).to.have.been.called

    it 'should emit an update with an empty desiredState, and the new actual state', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meeting:
            url: 'https://meet.go.co/alskdjf'
          conversationId: '123'
          audioEnabled:   true
          videoEnabled:   false
      }

  describe 'Start a Meeting', ->

  describe 'Join a Meeting', ->
    describe 'When the connector is not currently in a meeting', ->
      beforeEach ->
        @Lync.getConferenceUri.onFirstCall().yields(null, null)

      describe 'And a config event with a url comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.stopMeetings.yields()
          @Lync.joinMeeting.yields()
          @Lync.getState.yields null, {
            meeting:
              url: 'https://meet.go.co/alskdjf'
            audioEnabled: false
          }
          @sut.onConfig {
            desiredState:
              meeting:
                url: 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'
          }

        it 'should join the meeting', ->
          expect(@Lync.joinMeeting).to.have.been.calledWith 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'

        it 'should emit an update with an empty desiredState, and the new actual state', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meeting:
                url: 'https://meet.go.co/alskdjf'
              audioEnabled: false
          }

      describe 'And a config event with a null url comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.stopMeetings.yields()
          @Lync.createMeeting.yields()
          @Lync.getState.yields null, {
            meeting:
              url: 'https://meet.go.co/alskdjf'
            audioEnabled: false
          }
          @sut.onConfig {
            desiredState:
              meeting:
                url: null
          }

        it 'should create a meeting', ->
          expect(@Lync.createMeeting).to.have.been.called

        it 'should emit an update with an empty desiredState, and the new actual state', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meeting:
                url: 'https://meet.go.co/alskdjf'
              audioEnabled: false
          }

    describe 'When the connector is already in a meeting', ->
      beforeEach ->
        @Lync.getConferenceUri.onFirstCall().yields(null, 'https://meeting.i.was.already.in')

      describe 'And a config event with a different meetingUrl comes in', ->
        beforeEach (done) ->
          @sut.on 'update', (@update) => done()
          @Lync.stopMeetings.yields()
          @Lync.joinMeeting.yields()
          @Lync.getState.yields null, {
            meeting:
              url: 'https://meeting.im.in.now'
          }
          @sut.onConfig {
            desiredState:
              meeting:
                url: 'https://meet.citrix.com/roy.vandewater/OYKTG6CI'
          }

        it 'should join the meeting', ->
          expect(@Lync.joinMeeting).to.have.been.called

        it 'should emit an update with an empty desiredState', ->
          expect(@update).to.deep.equal {
            desiredState: {}
            state:
              meeting:
                url: 'https://meeting.im.in.now'
          }

  describe 'Leave a Meeting', ->
    beforeEach (done) ->
      @sut.on 'update', (@update) => done()
      @Lync.stopMeetings.yields()
      @Lync.getState.yields null, {
        meeting:
          url: 'https://meeting.i.was.already.in'
        audioEnabled: false
      }
      @sut.onConfig {
        desiredState:
          meeting: null
      }

    it 'should stop all meetings', ->
      expect(@Lync.stopMeetings).to.have.been.called

    it 'should emit an update with an empty desiredState', ->
      expect(@update).to.deep.equal {
        desiredState: {}
        state:
          meeting:
            url: 'https://meeting.i.was.already.in'
          audioEnabled: false
      }

  describe 'Start', ->
    xit 'should start', ->
      @sut.start.should.do.something
