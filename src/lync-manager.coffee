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
    using Microsoft.Lync.Model.Conversation.AudioVideo;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      private Conversation conversation = null;
      private ConversationWindow conversationWindow = null;
      private string conversationId = null;
      private VideoChannel _VideoChannel = null;
      private bool EnableVideo = false;

      public async Task<object> Invoke(dynamic input)
      {
        string JoinUrl = (string)input.JoinUrl;
        EnableVideo = (bool)input.EnableVideo;

        Automation automation = LyncClient.GetAutomation();
        var Client = LyncClient.GetClient();

        if(JoinUrl != null){
          JoinUrl = JoinUrl + '?';
          var state = new Object();
          IAsyncResult ar = automation.BeginStartConversation(JoinUrl, 0, (result) => { }, state);
          conversationWindow = automation.EndStartConversation(ar);
        }else if(JoinUrl == null){
          EnableVideo = false;
          var state = new Object();
          IAsyncResult ar = automation.BeginMeetNow((result) => { }, state);
          conversationWindow = automation.EndMeetNow(ar);
        }

        conversation = conversationWindow.Conversation;
        conversationId = conversationWindow.Conversation.Properties[ConversationProperty.Id].ToString();
        conversation.StateChanged += HandleStateChange;

        return conversationId;
      }

      public void HandleStateChange(object Sender, ConversationStateChangedEventArgs e)
      {
        if(e.NewState.ToString() == "Active"){
          Thread.Sleep(3000);
          conversationWindow.ShowContent();
          conversationWindow.ShowFullScreen(0);

          if(EnableVideo){
            var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
            conversation.Modalities[ModalityTypes.AudioVideo].ModalityStateChanged += HandleModalityStateChange;
            IAsyncResult ar = avModality.BeginConnect((result) => { }, null);
            avModality.EndConnect(ar);
          }
        }
      }

      public void HandleModalityStateChange(object sender, ModalityStateChangedEventArgs e)
      {
        if(e.NewState == ModalityState.Connected){
          if (_VideoChannel == null)
          {
              _VideoChannel = ((AVModality)sender).VideoChannel;
          }
          if (_VideoChannel.CanInvoke(ChannelAction.Start))
          {
              IAsyncResult ar = _VideoChannel.BeginStart((result) => {}, _VideoChannel);
              ((VideoChannel)ar.AsyncState).EndStart(ar);
          }
        }
      }
    }
    ###
  references: references


stopMeetings = edge.func
  source: () =>
    ###
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
      public async Task<object> Invoke(string conversationId)
      {
        var Client = LyncClient.GetClient();

        if(conversationId != null){
          Conversation conversation = Client.ConversationManager.Conversations.Where(c => c.Properties[ConversationProperty.Id].ToString() == conversationId).FirstOrDefault();
          stopConversation(conversation);

        }else if(conversationId == null){
          Client.ConversationManager.Conversations.ToList().ForEach(c => {
            stopConversation(c);
          });
        }
        return !false;
      }

      private void stopConversation(Conversation conversation){
        Automation automation = LyncClient.GetAutomation();

        var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
        if(avModality.CanInvoke(ModalityAction.Disconnect)){
            IAsyncResult ar = avModality.BeginDisconnect(ModalityDisconnectReason.None,(result) => { }, null);
            avModality.EndDisconnect(ar);
        }

        var window = automation.GetConversationWindow(conversation);
        window.Close();
        conversation.End();
      }
    }
    ###
  references: references


module.exports = {
  joinMeeting: joinMeeting
  stopMeetings: stopMeetings
}
