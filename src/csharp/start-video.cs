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

  private async Task ConnectAVModality(AVModality avModality)
  {
    if (avModality.State != ModalityState.Disconnected) return;

    System.Console.WriteLine("start-video:waitTillAVModalityIsConnected");
    var tcs = new TaskCompletionSource<bool>();

    EventHandler<ModalityActionAvailabilityChangedEventArgs> handler = null;
    handler = (sender, e) => {
      if (!((AVModality)sender).CanInvoke(ModalityAction.Connect)) return;
      avModality.ActionAvailabilityChanged -= handler;
      tcs.TrySetResult(true);
    };

    if (!avModality.CanInvoke(ModalityAction.Connect)) {
      avModality.ActionAvailabilityChanged += handler;
      await tcs.Task;
    }

    await Task.Factory.FromAsync(avModality.BeginConnect, avModality.EndConnect, null);
    return;
  }

  public async Task WaitTillCanStartVideoChannel(VideoChannel videoChannel)
  {
    System.Console.WriteLine("start-video:WaitTillCanStartVideoChannel");
    if (videoChannel.CanInvoke(ChannelAction.Start)) return;

    var tcs = new TaskCompletionSource<bool>();

    EventHandler<ChannelActionAvailabilityEventArgs> handler = null;
    handler = (sender, e) => {
      if (!((VideoChannel)sender).CanInvoke(ChannelAction.Start)) return;
      videoChannel.ActionAvailabilityChanged -= handler;
      tcs.TrySetResult(true);
    };

    videoChannel.ActionAvailabilityChanged += handler;
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

    await ConnectAVModality(avModality);
    await WaitTillCanStartVideoChannel(avModality.VideoChannel);

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
    System.Console.WriteLine("start-video:gotVideo");
    if (videoChannel == null) return null;
    System.Console.WriteLine("start-video:it wasn't null");
    if (videoChannel.State == ChannelState.Connecting) await waitTillConnected(videoChannel);
    System.Console.WriteLine("start-video:now I'm connected");
    if (videoChannel.State == ChannelState.Send) return null;
    System.Console.WriteLine("start-video:wasn't sending");
    if (videoChannel.State == ChannelState.SendReceive) return null;
    System.Console.WriteLine("start-video:wasn't sending and receiving");

    System.Console.WriteLine("start-video:am currently" + videoChannel.State);
    await Task.Factory.FromAsync(videoChannel.BeginStart, videoChannel.EndStart, null);
    System.Console.WriteLine("start-video:video has started");
    return null;
  }
}
