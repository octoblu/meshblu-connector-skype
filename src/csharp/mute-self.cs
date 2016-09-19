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

    if(conversationId != null)
    {
      Conversation conversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();

      var participant = conversation.Participants.Where(p => p.IsSelf).FirstOrDefault();
      if(participant.CanBeMuted())
      {
        participant.BeginSetMute(true, (a) => {participant.EndSetMute(null);}, null);
      }
    }

    return conversationId;
  }
}
