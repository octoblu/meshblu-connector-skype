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
  private Conversation conversation = null;
  public async Task<object> Invoke(string conversationId)
  {
    Automation automation = LyncClient.GetAutomation();
    var Client = LyncClient.GetClient();

    conversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    conversation.Modalities[ModalityTypes.AudioVideo].ModalityStateChanged += HandleModalityStateChange;

    if(avModality.CanInvoke(ModalityAction.Disconnect)){
        avModality.BeginDisconnect(ModalityDisconnectReason.None, (ar) => {
            avModality.EndDisconnect(ar);
          }, null);
    }

    var id = conversation.Properties[ConversationProperty.Id].ToString();
    Thread.Sleep(3000);
    return id;
  }

  public void HandleModalityStateChange(object sender, ModalityStateChangedEventArgs e)
  {
    if(e.NewState == ModalityState.Disconnected){
      var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;
      if (videoChannel.CanInvoke(ChannelAction.Stop))
      {
          IAsyncResult ar = videoChannel.BeginStop((result) => {}, videoChannel);
          ((VideoChannel)ar.AsyncState).EndStop(ar);
      }
    }
  }
}
