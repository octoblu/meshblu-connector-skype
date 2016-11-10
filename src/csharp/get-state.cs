using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;

public class Meeting
{
  public string url;

  public Meeting(string url) {
    this.url = url;
  }
}

public class ReturnValue
{
  public string conversationId;
  public Meeting meeting;
  public bool audioEnabled;
  public bool videoEnabled;
  public string videoState;

  public ReturnValue() {
    conversationId = null;
    meeting = null;
    audioEnabled = false;
    videoEnabled = false;
    videoState = null;
  }

  public ReturnValue(string conversationId, string meetingUrl, bool audioEnabled, bool videoEnabled, string videoState) {
    this.conversationId = conversationId;
    this.meeting = new Meeting(meetingUrl);
    this.audioEnabled = audioEnabled;
    this.videoEnabled = videoEnabled;
    this.videoState = videoState;
  }
}

public class Startup
{
  public async Task<object> Invoke(string ignored)
  {
    Conversation conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
    if (conversation == null) {
      return new ReturnValue();
    }
    var participant = conversation.Participants.FirstOrDefault(p => p.IsSelf);
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    string conversationId = conversation.Properties[ConversationProperty.Id].ToString();
    string meetingUrl     = conversation.Properties[ConversationProperty.ConferencingUri].ToString();
    bool audioEnabled     = !participant.IsMuted;
    bool videoEnabled     = (videoChannel.State != ChannelState.None);
    string videoState     = videoChannel.State.ToString();

    return new ReturnValue(conversationId, meetingUrl, audioEnabled, videoEnabled, videoState);
  }
}
