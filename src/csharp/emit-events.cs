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
  public Task<object> BindToAvModalityChanges(Func<object, Task<object>> callback) {
    var conversation = LyncClient.GetClient().ConversationManager.Conversations.FirstOrDefault();
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);

    avModality.ActionAvailabilityChanged += (sender, e) => {
      System.Console.WriteLine("emit-events:avModality:ActionAvailabilityChanged");
      callback(e.Action);
      System.Console.WriteLine("emit-events:avModality:ActionAvailabilityChanged after callback");
    };

    return null;
  }

  public Task<object> BindToConversationChanges(Func<object, Task<object>> callback) {
    System.Console.WriteLine("emit-events:BindToConversationChanges");

    var ConversationManager = LyncClient.GetClient().ConversationManager;

    ConversationManager.ConversationAdded += (sender, e) => {
      System.Console.WriteLine("emit-events:ConversationAdded");
      callback("Conversation:Added");
      System.Console.WriteLine("emit-events:ConversationAdded after callback");

      BindToAvModalityChanges(callback);
    };

    ConversationManager.ConversationRemoved += (sender, e) => {
      System.Console.WriteLine("emit-events:ConversationRemoved");
      callback("Conversation:Removed");
      System.Console.WriteLine("emit-events:ConversationRemoved after callback");
    };

    return null;

  }

  public async Task<object> Invoke(Func<object, Task<object>> callback)
  {
    System.Console.WriteLine("emit-events:Invoke");

    BindToConversationChanges(callback);
    return null;
  }

}
