using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.Sharing;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;


public class Startup
{
  private ConversationWindow conversationWindow = null;

  //
  public async Task<ConversationWindow> StartConversation(string joinUrl, long parentHwnd) {
    Automation automation = LyncClient.GetAutomation();

    return await Task<ConversationWindow>.Factory.FromAsync(
      automation.BeginStartConversation,
      automation.EndStartConversation,
      joinUrl, parentHwnd, null // args passed to automation.BeginStartConversation
    );
  }

  public async Task<object> Invoke(string joinUrl)
  {
    joinUrl = joinUrl + '?';
    var conversationWindow = await StartConversation(joinUrl, 0);

    var tcs = new TaskCompletionSource<bool>();
    conversationWindow.Conversation.StateChanged += (sender, e) => {
      if (e.NewState.ToString() != "Active") return;
      tcs.TrySetResult(true);
    };
    await tcs.Task;

    conversationWindow.ShowContent();
    conversationWindow.ShowFullScreen(0);
    return conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
  }
}
