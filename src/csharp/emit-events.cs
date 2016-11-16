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
    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    videoChannel.ActionAvailabilityChanged += (sender, e) => {
      callback(new KeyValuePair<String, Object>("VideoChannel:ActionAvailabilityChanged", e));
    };

    videoChannel.StateChanged += (sender, e) => {
      callback(new KeyValuePair<String, Object>("VideoChannel:StateChanged", e));
    };

    return null;
  }

  public Task<object> BindToAvModalityChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToAvModalityChanges");

    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    var videoChannelBound = false;

    avModality.ActionAvailabilityChanged += (sender, e) => {
      callback(new KeyValuePair<String, Object>("AvModality:ActionAvailabilityChanged:", e));
      if ( !videoChannelBound && ((AVModality)sender).CanInvoke(ModalityAction.Connect) ) {
        videoChannelBound = true;
        BindToVideoChannelChanges(callback);
      }
    };

    avModality.ModalityStateChanged += (sender, e) => {
      callback(new KeyValuePair<String, Object>("AvModality:ModalityStateChanged:", e));
    };

    return null;
  }

  public Task<object> BindToConversationChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToConversationChanges");

    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();

    conversation.StateChanged += (sender, e) => {
      callback(new KeyValuePair<String, Object>("Conversation:StateChanged", null));
    };

    return null;
  }

  public Task<object> BindToConversationManagerChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToConversationManagerChanges");

    var ConversationManager = LyncClient.GetClient().ConversationManager;

    ConversationManager.ConversationAdded += (sender, e) => {
      callback(new KeyValuePair<String, Object>("ConversationManager:ConversationAdded", null));
      BindToConversationChanges(callback);
      BindToAvModalityChanges(callback);
    };

    ConversationManager.ConversationRemoved += (sender, e) => {
      callback(new KeyValuePair<String, Object>("ConversationManager:ConversationRemoved", null));
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
