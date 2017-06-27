edge = require 'edge'
path = require 'path'

references = [
  path.join(process.cwd(), 'assets/dlls/Microsoft.Lync.Model.dll')
  path.join(process.cwd(), 'assets/dlls/Microsoft.Lync.Controls.dll')
  path.join(process.cwd(), 'assets/dlls/Microsoft.Lync.Utilities.dll')
  path.join(process.cwd(), 'assets/dlls/Microsoft.Lync.Controls.Resources.dll')
  path.join(process.cwd(), 'assets/dlls/Microsoft.Lync.Controls.Framework.dll')
  path.join(process.cwd(), 'assets/dlls/Microsoft.Lync.Controls.Framework.Resources.dll')
  path.join(process.cwd(), 'assets/dlls/Microsoft.Office.Uc.dll')
]

createMeeting = edge.func
  source: path.join process.cwd(), 'assets/csharp/create-meeting.cs'
  references: references

joinMeeting = edge.func
  source: path.join process.cwd(), 'assets/csharp/join-meeting.cs'
  references: references

startVideo = edge.func
  source: path.join process.cwd(), 'assets/csharp/start-video.cs'
  references: references

stopVideo = edge.func
  source: path.join process.cwd(), 'assets/csharp/stop-video.cs'
  references: references

stopMeetings = edge.func
  source: path.join process.cwd(), 'assets/csharp/stop-meetings.cs'
  references: references

mute = edge.func
  source: path.join process.cwd(), 'assets/csharp/mute-self.cs'
  references: references

unmute = edge.func
  source: path.join process.cwd(), 'assets/csharp/unmute-self.cs'
  references: references

getConferenceUri = edge.func
  source: path.join process.cwd(), 'assets/csharp/get-conferencing-uri.cs'
  references: references

getState = edge.func
  source: path.join process.cwd(), 'assets/csharp/get-state.cs'
  references: references

emitEvents = edge.func
  source: path.join process.cwd(), 'assets/csharp/emit-events.cs'
  references: references

killFeedback = edge.func
  source: path.join process.cwd(), 'assets/csharp/kill-feedback.cs'
  references: references

module.exports = {
  createMeeting: createMeeting
  joinMeeting: joinMeeting
  startVideo: startVideo
  stopVideo: stopVideo
  stopMeetings: stopMeetings
  mute: mute
  unmute: unmute
  getConferenceUri: getConferenceUri
  getState: getState
  emitEvents: emitEvents
  killFeedback: killFeedback
}
