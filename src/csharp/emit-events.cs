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

  public Task<object> BindToVideoChannelChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToVideoChannelChanges");

    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    videoChannel.ActionAvailabilityChanged += (sender, e) => {
      System.Console.WriteLine("emit-events:videoChannel:ActionAvailabilityChanged");
      callback("videoChannel:ActionAvailabilityChanged:"+e.Action);
      System.Console.WriteLine("emit-events:videoChannel:ActionAvailabilityChanged after callback");
    };

    videoChannel.StateChanged += (sender, e) => {
      System.Console.WriteLine("emit-events:videoChannel:StateChanged");
      callback("videoChannel:StateChanged:"+e.NewState);
      System.Console.WriteLine("emit-events:videoChannel:StateChanged after callback");
    };

    return null;
  }

  public Task<object> BindToAvModalityChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToAvModalityChanges");

    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    var videoChannelBound = false;

    avModality.ActionAvailabilityChanged += (sender, e) => {
      System.Console.WriteLine("emit-events:avModality:ActionAvailabilityChanged");
      callback("avModality:ActionAvailabilityChanged:"+e.Action);
      System.Console.WriteLine("emit-events:avModality:ActionAvailabilityChanged after callback");

      if ( !videoChannelBound && ((AVModality)sender).CanInvoke(ModalityAction.Connect) ) {
        videoChannelBound = true;
        BindToVideoChannelChanges(callback);
      }
    };

    avModality.ModalityStateChanged += (sender, e) => {
      System.Console.WriteLine("emit-events:avModality:ModalityStateChanged");
      callback("avModality:ModalityStateChanged:"+e.NewState);
      System.Console.WriteLine("emit-events:avModality:ModalityStateChanged after callback");
    };

    return null;
  }

  public Task<object> BindToConversationChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToConversationChanges");

    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();

    conversation.StateChanged += (sender, e) => {
      System.Console.WriteLine("emit-events:conversation:StateChanged");
      callback("conversation:StateChanged:"+e.NewState);
      System.Console.WriteLine("emit-events:conversation:StateChanged after callback");
    };

    return null;
  }

  public Task<object> BindToConversationManagerChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToConversationManagerChanges");

    var ConversationManager = LyncClient.GetClient().ConversationManager;

    ConversationManager.ConversationAdded += (sender, e) => {
      System.Console.WriteLine("emit-events:ConversationAdded");
      callback("ConversationManager:ConversationAdded");
      System.Console.WriteLine("emit-events:ConversationAdded after callback");

      BindToConversationChanges(callback);
      BindToAvModalityChanges(callback);
    };

    ConversationManager.ConversationRemoved += (sender, e) => {
      System.Console.WriteLine("emit-events:ConversationRemoved");
      callback("ConversationManager:ConversationRemoved");
      System.Console.WriteLine("emit-events:ConversationRemoved after callback");
    };

    return null;
  }

  public async Task<object> Invoke(Func<object, Task<object>> callback)
  {
    System.Console.WriteLine("emit-events:Invoke");

    BindToConversationManagerChanges(callback);
    return null;
  }

}
