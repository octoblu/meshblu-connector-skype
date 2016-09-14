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
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Conversation;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      private ConversationWindow _ConversationWindow = null;
      private Conversation _Conversation = null;

      public async Task<object> Invoke(object input)
      {
        var Automation = LyncClient.GetAutomation();
        var Client = LyncClient.GetClient();

        Automation.BeginMeetNow((ar) =>
        {
          _ConversationWindow = Automation.EndMeetNow(ar);
          _Conversation = _ConversationWindow.Conversation;

          var id = _ConversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
          Console.WriteLine(id);
        },
        null);

        return "success";
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
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Conversation;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      private ConversationWindow _ConversationWindow = null;
      private Conversation _Conversation = null;

      public async Task<object> Invoke(string JoinUrl)
      {

        var Automation = LyncClient.GetAutomation();
        var Client = LyncClient.GetClient();
        JoinUrl = JoinUrl + '?';

        Automation.BeginStartConversation(JoinUrl, 0, (ar) =>
        {
          _ConversationWindow = Automation.EndStartConversation(ar);
          _Conversation = _ConversationWindow.Conversation;
          var conversationId = _ConversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();

          _Conversation.StateChanged += HandleStateChange;
        },
        null);

        return 5 + 5;
      }

      public void HandleStateChange(object Sender, ConversationStateChangedEventArgs e)
      {
        if(e.NewState.ToString() == "Active"){
          Console.WriteLine("Going");
          var Automation = LyncClient.GetAutomation();
          Automation.GetConversationWindow(_Conversation).ShowFullScreen(0);
        }
      }
    }
    ###
  references: references



module.exports = {
  startConversation: startConversation
  joinMeeting: joinMeeting
}
