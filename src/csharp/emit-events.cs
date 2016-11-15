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
  public Task<object> BindToConversationChanges(Func<object, Task<object>> callback) {

    var ConversationManager = LyncClient.GetClient().ConversationManager;

    ConversationManager.ConversationAdded += (sender, e) => {
      callback(e);
    };

    return null;

  }

  public async Task<object> Invoke(Func<object, Task<object>> callback)
  {
    BindToConversationChanges(callback);
    return null;
  }

}
