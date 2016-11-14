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
    System.Console.WriteLine("start-video:GetConversation");
    return LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
  }

  public async Task WaitToConnect(Conversation conversation)
  {
    System.Console.WriteLine("start-video:WaitToConnect");
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
    await tcs.Task;
    return;
  }

  public async Task<VideoChannel> GetVideoChannel()
  {
    System.Console.WriteLine("start-video:GetVideoChannel");
    var conversation = GetConversation();
    if (conversation == null) return null;

    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    if (avModality == null) throw new System.InvalidOperationException("Cannot start video if avModality is null");

    if (avModality.State != ModalityState.Connected) {
      await WaitToConnect(conversation);
    }

    return avModality.VideoChannel;
  }

  private Task waitTillConnected(VideoChannel videoChannel)
  {
    System.Console.WriteLine("start-video:waitTillConnected");
    var tcs = new TaskCompletionSource<bool>();

    videoChannel.StateChanged += (sender, e) => {
      if (e.NewState == ChannelState.Connecting) return;
      tcs.TrySetResult(true);
    };

    return tcs.Task;
  }

  public async Task<object> Invoke(string ignored)
  {
    System.Console.WriteLine("start-video:Invoke");
    var videoChannel = await GetVideoChannel();
    if (videoChannel == null) return null;
    if (videoChannel.State == ChannelState.Connecting) await waitTillConnected(videoChannel);
    if (videoChannel.State == ChannelState.Send) return null;
    if (videoChannel.State == ChannelState.SendReceive) return null;

    await Task.Factory.FromAsync(videoChannel.BeginStart, videoChannel.EndStart, null);
    return null;
  }
}
