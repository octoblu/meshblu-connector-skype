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
  public Conversation GetConversation(string conversationId) 
  {
    return LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault(c => c.Properties[ConversationProperty.Id].ToString() == conversationId);
  }

  public async Task<VideoChannel> GetVideoChannel(conversationId)
  {
    var conversation = GetConversation(conversationId);
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    await Task.Factory.FromAsync(avModality.BeginConnect, avModality.EndConnect, null);

    return avModality.VideoChannel;
  }

  public async Task<object> Invoke(string conversationId)
  {
    var videoChannel = await GetVideoChannel(conversationId);
    async Task.Factory.FromAsync(videoChannel.BeginStart, videoChannel.EndStart, null);
    return conversationId;
  }
}
