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
  private async Task stopConversation(Conversation conversation) {
    var tcs = new TaskCompletionSource<bool>();
    conversation.StateChanged += (sender, e) => {
      if (e.NewState != ConversationState.Terminated) return;
      tcs.TrySetResult(true);
    };

    conversation.End();
    await tcs.Task;
    return;
  }

  public async Task<object> Invoke(dynamic ignored)
  {
    foreach(Conversation conversation in LyncClient.GetClient().ConversationManager.Conversations) {
      await stopConversation(conversation);
    }

    return null;
  }
}
