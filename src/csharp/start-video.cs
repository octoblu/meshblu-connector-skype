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
  private VideoChannel _VideoChannel = null;
  public async Task<object> Invoke(string conversationId)
  {
    var Client = LyncClient.GetClient();
    Automation automation = LyncClient.GetAutomation();

    Conversation conversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();

    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    conversation.Modalities[ModalityTypes.AudioVideo].ModalityStateChanged += HandleModalityStateChange;
    avModality.BeginConnect((ar) => {
      avModality.EndConnect(ar);
    }, null);

    return !false;
  }

  public void HandleModalityStateChange(object sender, ModalityStateChangedEventArgs e)
  {
    if(e.NewState == ModalityState.Connected){
      if (_VideoChannel == null)
      {
          _VideoChannel = ((AVModality)sender).VideoChannel;
      }
      if (_VideoChannel.CanInvoke(ChannelAction.Start))
      {
          IAsyncResult ar = _VideoChannel.BeginStart((result) => {}, _VideoChannel);
          ((VideoChannel)ar.AsyncState).EndStart(ar);
      }
    }
  }
}
