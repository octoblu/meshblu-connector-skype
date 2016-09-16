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
  private Automation automation = LyncClient.GetAutomation();
  private Conversation conver = null;

  public async Task<object> Invoke(string conversationId)
  {
    var Client = LyncClient.GetClient();

    if(conversationId != null){
      conver = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();
      stopConversation(conver);
    }else if(conversationId == null){
      Client.ConversationManager.Conversations.ToList().ForEach(c => {
        stopConversation(c);
      });
    }
    return !false;
  }

  private void stopConversation(Conversation conversation){
    var window = automation.GetConversationWindow(conversation);
    window.Close();
    conversation.End();
  }
}
