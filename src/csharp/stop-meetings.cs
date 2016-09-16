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

    if(conversationId != null){
      Conversation conversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();
      stopConversation(conversation);

    }else if(conversationId == null){
      Client.ConversationManager.Conversations.ToList().ForEach(c => {
        stopConversation(c);
      });
    }
    return !false;
  }

  private void stopConversation(Conversation conversation){
    Automation automation = LyncClient.GetAutomation();

    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);

    conversation.Modalities[ModalityTypes.AudioVideo].ModalityStateChanged += HandleModalityStateChanged;

    if(avModality.CanInvoke(ModalityAction.Disconnect)){
        IAsyncResult ar = avModality.BeginDisconnect(ModalityDisconnectReason.None, (result) => {
          Console.WriteLine( result.state.ToString());
           }, null);
        // avModality.EndDisconnect(ar);
    }

    var window = automation.GetConversationWindow(conversation);
    window.Close();
    conversation.End();
  }

  private void HandleModalityStateChanged(object Sender, ModalityStateChangedEventArgs e){
    Console.WriteLine(e.NewState.ToString());
  }
}
