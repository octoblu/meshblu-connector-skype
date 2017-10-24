edge = require 'edge'
path = require 'path'

references = [
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Lync.Model.dll')
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Lync.Controls.dll')
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Lync.Utilities.dll')
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Lync.Controls.Resources.dll')
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Lync.Controls.Framework.dll')
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Lync.Controls.Framework.Resources.dll')
  path.join(__dirname, '..', 'assets/dlls/Microsoft.Office.Uc.dll')
]

createMeeting = edge.func
  source: path.join __dirname, '..', 'assets/csharp/create-meeting.cs'
  references: references

joinMeeting = edge.func
  source: path.join __dirname, '..', 'assets/csharp/join-meeting.cs'
  references: references

startVideo = edge.func
  source: path.join __dirname, '..', 'assets/csharp/start-video.cs'
  references: references

stopVideo = edge.func
  source: path.join __dirname, '..', 'assets/csharp/stop-video.cs'
  references: references

stopMeetings = edge.func
  source: path.join __dirname, '..', 'assets/csharp/stop-meetings.cs'
  references: references

mute = edge.func
  source: path.join __dirname, '..', 'assets/csharp/mute-self.cs'
  references: references

unmute = edge.func
  source: path.join __dirname, '..', 'assets/csharp/unmute-self.cs'
  references: references

getConferenceUri = edge.func
  source: path.join __dirname, '..', 'assets/csharp/get-conferencing-uri.cs'
  references: references

getState = edge.func
  source: path.join __dirname, '..', 'assets/csharp/get-state.cs'
  references: references

startClient = edge.func
  source: path.join __dirname, '..', 'assets/csharp/start-client.cs'
  references: references

emitEvents = edge.func
  source: path.join __dirname, '..', 'assets/csharp/emit-events.cs'
  references: references

killFeedback = edge.func
  source: path.join __dirname, '..', 'assets/csharp/kill-feedback.cs'
  references: references

module.exports = {
  createMeeting,
  joinMeeting,
  startVideo,
  stopVideo,
  stopMeetings,
  mute,
  unmute,
  getConferenceUri,
  getState,
  emitEvents,
  killFeedback,
  startClient,
}
