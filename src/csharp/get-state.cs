using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;

public class Startup
{
  public async Task<object> Invoke(string conversationId)
  {
    var Client = LyncClient.GetClient();
    Thread.Sleep(3000);

    Conversation conversation = Client.ConversationManager.Conversations.FirstOrDefault();
    var participant = conversation.Participants.Where(p => p.IsSelf).FirstOrDefault();
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    return new {
      conversationId = conversation.Properties[ConversationProperty.Id].ToString(),
      meetingUrl     = conversation.Properties[ConversationProperty.ConferencingUri].ToString(),
      audioEnabled   = participant.IsMuted,
      videoEnabled   = videoChannel.IsContributing,
    };
  }
}
