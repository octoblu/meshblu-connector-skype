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

  public Task WaitToConnect()
  {
    var conversation = GetConversation();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    var tcs = new TaskCompletionSource<bool>();

    EventHandler<ModalityStateChangedEventArgs> handler = (sender, e) => {
      if (e.NewState != ModalityState.Connected) return;
      avModality.ModalityStateChanged -= handler;
      tcs.TrySetResult(true);
    };

    avModality.ModalityStateChanged += handler;
    return tcs.Task;
  }

  public async Task<VideoChannel> GetVideoChannel()
  {
    var conversation = GetConversation();
    if (conversation == null) throw new System.InvalidOperationException("Cannot start video on non-extant conversation");

    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);

    if (avModality.State != ModalityState.Connected) {
      await WaitToConnect()
    }
    return avModality.VideoChannel;
  }

  public async Task<object> Invoke(string ignored)
  {
    var videoChannel = await GetVideoChannel();
    await Task.Factory.FromAsync(videoChannel.BeginStart, videoChannel.EndStart, null);

    return GetAllConversations().Count;
  }
}
