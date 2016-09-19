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
  private string uri = null;
  public async Task<object> Invoke(string conversationId)
  {
    var Client = LyncClient.GetClient();
    Thread.Sleep(3000);
    Conversation conversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();
    uri = conversation.Properties[ConversationProperty.ConferencingUri].ToString();
  
    return uri;
  }
}
