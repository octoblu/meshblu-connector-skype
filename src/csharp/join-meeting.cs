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
  public async Task<ConversationWindow> StartConversation(string joinUrl, long parentHwnd)
  {
    System.Console.WriteLine("join-meeting:StartConversation");
    Automation automation = LyncClient.GetAutomation();

    return await Task<ConversationWindow>.Factory.FromAsync(
      automation.BeginStartConversation,
      automation.EndStartConversation,
      joinUrl, parentHwnd, null // args passed to automation.BeginStartConversation
    );
  }

  public async Task WaitTillCanFullscreen(ConversationWindow conversationWindow)
  {
    System.Console.WriteLine("join-meeting:WaitTillCanFullscreen");
    var tcs = new TaskCompletionSource<bool>();

    conversationWindow.ActionAvailabilityChanged += (sender, e) => {
      if (!conversationWindow.CanInvoke(ConversationWindowAction.FullScreen)) return;

      tcs.TrySetResult(true);
    };

    await tcs.Task;
  }

  public async Task<object> Invoke(string joinUrl)
  {
    System.Console.WriteLine("join-meeting:Invoke");
    joinUrl = joinUrl + '?';
    var conversationWindow = await StartConversation(joinUrl, 0);

    if (!conversationWindow.CanInvoke(ConversationWindowAction.FullScreen)) {
      await WaitTillCanFullscreen(conversationWindow);
    }

    conversationWindow.ShowFullScreen(0);
    return conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
  }
}
