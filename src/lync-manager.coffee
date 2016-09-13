edge = require('edge')

references = [
  'Microsoft.Lync.Model.dll'
  'Microsoft.Lync.Controls.dll'
  'Microsoft.Lync.Utilities.dll'
  'Microsoft.Lync.Controls.Resources.dll'
  'Microsoft.Lync.Controls.Framework.dll'
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


        },
        null);

        return "Boom";
      }
    }
    ###
  references: references


module.exports = {
  startConversation: startConversation
}
