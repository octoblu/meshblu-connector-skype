edge = require('edge')

references = [
  'Microsoft.Lync.Model.dll'
  'Microsoft.Lync.Controls.dll'
  'Microsoft.Lync.Utilities.dll'
  'Microsoft.Lync.Controls.Resources.dll'
  'Microsoft.Lync.Controls.Framework.dll'
  'Microsoft.Lync.Controls.Framework.Resources.dll'
  'Microsoft.Office.Uc.dll'
]

startConversation = edge.func
  source: () =>
    ###
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Conversation;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      private Conversation conversation = null;
      private ConversationWindow conversationWindow = null;
      private string conversationId = null;

      public async Task<object> Invoke(string input)
      {
        Automation automation = LyncClient.GetAutomation();
        var Client = LyncClient.GetClient();

        IAsyncResult ar = automation.BeginMeetNow((result) => { }, null);
        conversationWindow = automation.EndMeetNow(ar);
        conversation = conversationWindow.Conversation;
        conversationId = conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
        conversation.StateChanged += HandleStateChange;
        return conversationId;
      }

      public void HandleStateChange(object Sender, ConversationStateChangedEventArgs e)
      {
        if(e.NewState.ToString() == "Active"){
          Thread.Sleep(2000);
          conversationWindow.ShowContent();
          conversationWindow.ShowFullScreen(0);
        }
      }
    }
    ###
  references: references


joinMeeting = edge.func
  source: () =>
    ###
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Conversation;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      private Conversation conversation = null;
      private ConversationWindow conversationWindow = null;
      private string conversationId = null;

      public async Task<object> Invoke(string JoinUrl)
      {
        Automation automation = LyncClient.GetAutomation();
        var Client = LyncClient.GetClient();
        JoinUrl = JoinUrl + '?';

        IAsyncResult ar = automation.BeginStartConversation(JoinUrl, 0, (result) => { }, null);
        conversationWindow = automation.EndStartConversation(ar);
        conversation = conversationWindow.Conversation;
        conversationId = conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
        conversation.StateChanged += HandleStateChange;

        return conversationId;
      }

      public void HandleStateChange(object Sender, ConversationStateChangedEventArgs e)
      {
        if(e.NewState.ToString() == "Active"){
          Thread.Sleep(2000);
          conversationWindow.ShowContent();
          conversationWindow.ShowFullScreen(0);
        }
      }
    }
    ###
  references: references

stopMeeting = edge.func
  source: () =>
    ###
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Conversation;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      public async Task<object> Invoke(string conversationId)
      {
        var Client = LyncClient.GetClient();
        var currentConversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();

        currentConversation.End();
        return !false;
      }

    }
    ###
  references: references

stopAllMeetings = edge.func
  source: () =>
    ###
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Conversation;
    using Microsoft.Lync.Model.Extensibility;

    public class Startup
    {
      public async Task<object> Invoke(string conversationId)
      {
        var Client = LyncClient.GetClient();
        Client.ConversationManager.Conversations.ToList().ForEach(c => {
          c.End();
        });
        return !false;
      }
    }
    ###
  references: references


module.exports = {
  startConversation: startConversation
  joinMeeting: joinMeeting
  stopMeeting: stopMeeting
  stopAllMeetings: stopAllMeetings
}
