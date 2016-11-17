using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;

public class ConversationEvent {
  public string conversationId;
  public string eventSource;
  public string eventType;
  public object data;
};

public class ConversationListener {
  Conversation conversation;
  String conversationId;
  Func<object, Task<object>> callback;

  public ConversationListener(Conversation conversation, Func<object, Task<object>> callback) {
    this.conversation = conversation;
    this.callback = callback;
    this.conversationId = (string) conversation.Properties[ConversationProperty.Id];
  }

  public void listen() {
    BindToConversationChanges();
    BindToAvModalityChanges();
  }

  private void BindToVideoChannelChanges() {
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    videoChannel.ActionAvailabilityChanged += (sender, e) => {
      System.Console.WriteLine("videoChannelActionAvailibilityChanged");
      callback(new ConversationEvent { conversationId=conversationId, eventSource= "VideoChannel", eventType= "ActionAvailabilityChanged", data= e});
    };

    videoChannel.StateChanged += (sender, e) => {
      System.Console.WriteLine("videoChannelStateChanged");
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "VideoChannel", eventType= "StateChanged", data= e});
    };
  }

  private void BindToConversationChanges() {
    conversation.StateChanged += (sender, e) => {
      System.Console.WriteLine("ConversationStateChanged");
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "Conversation", eventType= "StateChanged", data= e});
    };
  }

  private void BindToAvModalityChanges() {
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    var videoChannelBound = false;

    avModality.ActionAvailabilityChanged += (sender, e) => {
      System.Console.WriteLine("ActionAvailabilityChanged");
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "AvModality", eventType= "ActionAvailabilityChanged", data= e});
      BindToVideoChannelChanges();
    };

    avModality.ModalityStateChanged += (sender, e) => {
      System.Console.WriteLine("ModalityStateChanged");
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "AvModality", eventType= "ModalityStateChanged", data= e});
    };
  }
}

public class Startup
{
  public Task<object> BindToConversationManagerChanges(Func<object, Task<object>> callback) {
    var ConversationManager = LyncClient.GetClient().ConversationManager;
    ConversationManager.ConversationAdded += (sender, e) => {
      string conversationId = (string) e.Conversation.Properties[ConversationProperty.Id];
      System.Console.WriteLine("ConversationAdded");
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "ConversationManager", eventType= "ConversationAdded" });
      var listener = new ConversationListener(e.Conversation, callback);
      listener.listen();
    };

    ConversationManager.ConversationRemoved += (sender, e) => {
      string conversationId = (string) e.Conversation.Properties[ConversationProperty.Id];
      System.Console.WriteLine("ConversationRemoved");
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "ConversationManager", eventType= "ConversationRemoved"});
    };

    return null;
  }

  public async Task<object> Invoke(Func<object, Task<object>> callback)
  {
    BindToConversationManagerChanges(callback);
    return null;
  }

}
