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
  public bool hasClient;
  public bool hasConversation;
  public string conversationId;
  public Meeting meeting;
  public bool audioEnabled;
  public bool videoEnabled;
  public string videoState;

  public ReturnValue(bool hasClient, bool hasConversation) {
    this.hasClient = hasClient;
    this.hasConversation = hasConversation;
    this.conversationId = null;
    this.meeting = null;
    this.audioEnabled = false;
    this.videoEnabled = false;
    this.videoState = null;
  }

  public ReturnValue(bool hasClient, bool hasConversation, string conversationId, string meetingUrl, bool audioEnabled, bool videoEnabled, string videoState) {
    this.hasClient = hasClient;
    this.hasConversation = hasConversation;
    this.conversationId = conversationId;
    this.meeting = new Meeting(meetingUrl);
    this.audioEnabled = audioEnabled;
    this.videoEnabled = videoEnabled;
    this.videoState = videoState;
  }
}

public class Startup
{

  private LyncClient getClientOrNull(){
    try {
      return LyncClient.GetClient();
    } catch (ClientNotFoundException e) {
      return null;
    }
  }

  public async Task<object> Invoke(string ignored)
  {
    var client = getClientOrNull();

    if (client == null) {
      return new ReturnValue(false, false);
    }

    var conversation = client.ConversationManager.Conversations.FirstOrDefault();
    if (conversation == null) {
      return new ReturnValue(true, false);
    }

    var participant = conversation.Participants.FirstOrDefault(p => p.IsSelf);
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    string conversationId = conversation.Properties[ConversationProperty.Id].ToString();
    string meetingUrl     = conversation.Properties[ConversationProperty.ConferencingUri].ToString();
    bool audioEnabled     = !participant.IsMuted;
    bool videoEnabled     = (videoChannel.State == ChannelState.Send || videoChannel.State == ChannelState.SendReceive);
    string videoState     = videoChannel.State.ToString();

    return new ReturnValue(true, true, conversationId, meetingUrl, audioEnabled, videoEnabled, videoState);
  }
}
