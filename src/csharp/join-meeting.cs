using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.Sharing;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;


public class Startup
{
  private ConversationWindow conversationWindow = null;

  public async Task<object> Invoke(string JoinUrl)
  {
    Automation automation = LyncClient.GetAutomation();
    var Client = LyncClient.GetClient();

    JoinUrl = JoinUrl + '?';
    var state = new Object();
    IAsyncResult ar = automation.BeginStartConversation(JoinUrl, 0, (result) => { }, state);
    conversationWindow = automation.EndStartConversation(ar);

    conversationId = conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
    return conversationId;
  }

  public void HandleStateChange(object Sender, ConversationStateChangedEventArgs e)
  {
    if(e.NewState.ToString() == "Active"){
      Thread.Sleep(3000);
      conversationWindow.ShowContent();
      conversationWindow.ShowFullScreen(0);
    }
  }
}
