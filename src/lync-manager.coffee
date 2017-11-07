path = require 'path'
isEmpty = require("lodash/isEmpty")

class LyncManager
  constructor({ dirname }={}) ->
    edge = require 'edge' # don't require edge until the constructor is called, needed for EDGE_CS env vars
    if isEmpty(dirname)
      dirname = path.join(__dirname, '..')

    references = [
      path.join(dirname, 'assets/dlls/Microsoft.Lync.Model.dll')
      path.join(dirname, 'assets/dlls/Microsoft.Lync.Controls.dll')
      path.join(dirname, 'assets/dlls/Microsoft.Lync.Utilities.dll')
      path.join(dirname, 'assets/dlls/Microsoft.Lync.Controls.Resources.dll')
      path.join(dirname, 'assets/dlls/Microsoft.Lync.Controls.Framework.dll')
      path.join(dirname, 'assets/dlls/Microsoft.Lync.Controls.Framework.Resources.dll')
      path.join(dirname, 'assets/dlls/Microsoft.Office.Uc.dll')
    ]

    @createMeeting = edge.func
      source: path.join dirname, 'assets/csharp/create-meeting.cs'
      references: references

    @joinMeeting = edge.func
      source: path.join dirname, 'assets/csharp/join-meeting.cs'
      references: references

    @startVideo = edge.func
      source: path.join dirname, 'assets/csharp/start-video.cs'
      references: references

    @stopVideo = edge.func
      source: path.join dirname, 'assets/csharp/stop-video.cs'
      references: references

    @stopMeetings = edge.func
      source: path.join dirname, 'assets/csharp/stop-meetings.cs'
      references: references

    @mute = edge.func
      source: path.join dirname, 'assets/csharp/mute-self.cs'
      references: references

    @unmute = edge.func
      source: path.join dirname, 'assets/csharp/unmute-self.cs'
      references: references

    @getConferenceUri = edge.func
      source: path.join dirname, 'assets/csharp/get-conferencing-uri.cs'
      references: references

    @getState = edge.func
      source: path.join dirname, 'assets/csharp/get-state.cs'
      references: references

    @startClient = edge.func
      source: path.join dirname, 'assets/csharp/start-client.cs'
      references: references

    @emitEvents = edge.func
      source: path.join dirname, 'assets/csharp/emit-events.cs'
      references: references

    @killFeedback = edge.func
      source: path.join dirname, 'assets/csharp/kill-feedback.cs'
      references: references

module.exports = LyncManager
