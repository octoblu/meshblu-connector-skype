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
    if (conversationId == null) {
      throw new System.ArgumentException("Parameter cannot be null", "conversationId");
    }

    Conversation conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault(c => c.Properties[ConversationProperty.Id].ToString() == conversationId);
    var participant = conversation.Participants.FirstOrDefault(p => p.IsSelf);
    participant.BeginSetMute(true, null, null);
    participant.EndSetMute(null);

    return conversationId;
  }
}
