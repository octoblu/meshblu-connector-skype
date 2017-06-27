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

  public async Task<object> Invoke(dynamic ignored)
  {
    var conversation = GetConversation();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    var videoChannel = avModality.VideoChannel;
    videoChannel.BeginStart(null, null);
    return null;
  }
}
