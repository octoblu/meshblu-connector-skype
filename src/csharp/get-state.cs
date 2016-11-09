using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;

public class ReturnValue
{
  public string conversationId;
  public string meetingUrl;
  public bool audioEnabled;
  public bool videoEnabled;

  public ReturnValue() {
    conversationId = null;
    meetingUrl = null;
    audioEnabled = false;
    videoEnabled = false;
  }

  public ReturnValue(string conversationId, string meetingUrl, bool audioEnabled, bool videoEnabled) {
    this.conversationId = conversationId;
    this.meetingUrl = meetingUrl;
    this.audioEnabled = audioEnabled;
    this.videoEnabled = videoEnabled;
  }
}

public class Startup
{
  public async Task<object> Invoke(string ignored)
  {
    var Client = LyncClient.GetClient();
    Thread.Sleep(3000);

    Conversation conversation = Client.ConversationManager.Conversations.FirstOrDefault();
    if (conversation == null) {
      return new ReturnValue();
    }
    var participant = conversation.Participants.FirstOrDefault(p => p.IsSelf);
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    string conversationId = conversation.Properties[ConversationProperty.Id].ToString();
    string meetingUrl     = conversation.Properties[ConversationProperty.ConferencingUri].ToString();
    bool audioEnabled     = !participant.IsMuted;
    bool videoEnabled     = videoChannel.IsContributing;

    return new ReturnValue(conversationId, meetingUrl, audioEnabled, videoEnabled);
  }
}
