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
  public Conversation GetConversation()
  {
    return LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
  }

  public async Task<object> Invoke(string ignored)
  {
    Conversation conversation = GetConversation();
    var participant = conversation.Participants.FirstOrDefault(p => p.IsSelf);

    await Task.Factory.FromAsync(participant.BeginSetMute, participant.EndSetMute, false, null);

    return null;
  }
}
