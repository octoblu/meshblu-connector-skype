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

  public IList<Conversation> GetAllConversations()
  {
    return LyncClient.GetClient().ConversationManager.Conversations;
  }

  public async Task<VideoChannel> GetVideoChannel()
  {
    var conversation = GetConversation();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);

    if (avModality.State == ModalityState.Connected) return avModality.VideoChannel;

    await Task.Factory.FromAsync(avModality.BeginConnect, avModality.EndConnect, null);

    return avModality.VideoChannel;
  }

  public async Task<object> Invoke(string ignored)
  {
    var videoChannel = await GetVideoChannel();
    await Task.Factory.FromAsync(videoChannel.BeginStart, videoChannel.EndStart, null);

    return GetAllConversations().Count;
  }
}
