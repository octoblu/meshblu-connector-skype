using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.Sharing;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;

public class Startup
{
  [DllImport("user32.dll")]
  [return: MarshalAs(UnmanagedType.Bool)]
  static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int x, int y, int cx, int cy, uint uFlags);

  static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);

  const uint SWP_NOSIZE = 0x0001;
  const uint SWP_NOMOVE = 0x0002;
  const uint TOPMOST_FLAGS = SWP_NOMOVE | SWP_NOSIZE;

  public static void SetTopMostWindow(IntPtr handle)
  {
      SetWindowPos(handle, HWND_TOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
  }

  public Task<ConversationWindow> StartConversation(string joinUrl, long parentHwnd)
  {
    Automation automation = LyncClient.GetAutomation();

    return Task<ConversationWindow>.Factory.FromAsync(
      automation.BeginStartConversation,
      automation.EndStartConversation,
      joinUrl, parentHwnd, null // args passed to automation.BeginStartConversation
    );
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

  public async Task<object> Invoke(string joinUrl)
  {
    joinUrl = joinUrl + '?';
    var conversationWindow = await StartConversation(joinUrl, 0);

    if (!conversationWindow.CanInvoke(ConversationWindowAction.FullScreen)) {
      await WaitTillCanFullscreen(conversationWindow);
    }

    conversationWindow.ShowFullScreen(0);
    SetTopMostWindow(conversationWindow.Handle);
    return conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
  }
}
