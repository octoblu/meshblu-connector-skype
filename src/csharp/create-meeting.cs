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
  public async Task<ConversationWindow> StartConversation()
  {
    Automation automation = LyncClient.GetAutomation();
    var conversationWindow = await Task<ConversationWindow>.Factory.FromAsync(automation.BeginMeetNow, automation.EndMeetNow, null);
    var conversation = conversationWindow.Conversation;
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);

    await Task.Factory.FromAsync(avModality.BeginConnect, avModality.EndConnect, null);
    return conversationWindow;
  }

  public async Task WaitTillCanFullscreen(ConversationWindow conversationWindow)
  {
    var tcs = new TaskCompletionSource<bool>();

    conversationWindow.ActionAvailabilityChanged += (sender, e) => {
      if (!conversationWindow.CanInvoke(ConversationWindowAction.FullScreen)) return;

      tcs.TrySetResult(true);
    };

    await tcs.Task;
  }

  public async Task<object> Invoke(string ignored)
  {
    var conversationWindow = await StartConversation();

    if (!conversationWindow.CanInvoke(ConversationWindowAction.FullScreen)) {
      await WaitTillCanFullscreen(conversationWindow);
    }

    conversationWindow.ShowContent();
    conversationWindow.ShowFullScreen(0);
    return conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
  }
}
