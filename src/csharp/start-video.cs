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

    EventHandler<ModalityStateChangedEventArgs> handler = null;
    handler = (sender, e) => {
      if (e.NewState != ModalityState.Connected) return;
      if (!((AVModality)sender).VideoChannel.CanInvoke(ChannelAction.Start)) return;
      avModality.ModalityStateChanged -= handler;
      tcs.TrySetResult(true);
    };

    avModality.ModalityStateChanged += handler;
    return tcs.Task;
  }

  public async Task<VideoChannel> GetVideoChannel()
  {
    var conversation = GetConversation();
    if (conversation == null) throw new System.InvalidOperationException("Cannot enable video on non-extant conversation");

    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);

    if (avModality.State != ModalityState.Connected) {
      await WaitToConnect();
    }

    return avModality.VideoChannel;
  }

  private Task waitTillConnected(VideoChannel videoChannel)
  {
    var tcs = new TaskCompletionSource<bool>();

    videoChannel.StateChanged += (sender, e) => {
      if (e.NewState == ChannelState.Connecting) return;
      tcs.TrySetResult(true);
    };

    return tcs.Task;
  }

  public async Task<object> Invoke(string ignored)
  {
    var videoChannel = await GetVideoChannel();
    if (videoChannel.State == ChannelState.Connecting) await waitTillConnected(videoChannel);
    if (videoChannel.State == ChannelState.Send) return null;
    if (videoChannel.State == ChannelState.SendReceive) return null;

    videoChannel.BeginStart(null, null);
    return null;
  }
}
