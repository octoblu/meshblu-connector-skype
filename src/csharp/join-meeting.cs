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
  private Conversation conversation = null;
  private ConversationWindow conversationWindow = null;
  private string conversationId = null;
  private VideoChannel _VideoChannel = null;
  private bool EnableVideo = false;
  private bool EnableMute = false;

  public async Task<object> Invoke(dynamic input)
  {
    string JoinUrl = (string)input.JoinUrl;
    EnableVideo = (bool)input.EnableVideo;
    EnableMute = (bool)input.EnableMute;

    Automation automation = LyncClient.GetAutomation();
    var Client = LyncClient.GetClient();

    if(JoinUrl != null){
      JoinUrl = JoinUrl + '?';
      var state = new Object();
      IAsyncResult ar = automation.BeginStartConversation(JoinUrl, 0, (result) => { }, state);
      conversationWindow = automation.EndStartConversation(ar);
    }else if(JoinUrl == null){
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
        avModality.BeginConnect((ar) => {
          avModality.EndConnect(ar);
        }, null);
      }
    }
  }

  public void HandleModalityStateChange(object sender, ModalityStateChangedEventArgs e)
  {
    if(e.NewState == ModalityState.Connected){
      var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;
      if (videoChannel.CanInvoke(ChannelAction.Start))
      {
        videoChannel.BeginStart((ar) => { videoChannel.EndStart(ar);}, null);
      }

      // var applicationModality = ((ApplicationSharingModality)conversation.Modalities[ModalityTypes.ApplicationSharing]);
      // applicationModality.BeginDisconnect(ModalityDisconnectReason.None, (ar) => { applicationModality.EndDisconnect(ar); }, null);

      if(EnableMute){
        var participant = conversation.Participants.Where(p => p.IsSelf).FirstOrDefault();
        if(participant.CanBeMuted())
        {
          participant.BeginSetMute(true, (a) => {participant.EndSetMute(null);}, null);
        }
        if (!(bool)participant.Properties[ParticipantProperty.IsPresenter])
       {
         participant.BeginSetProperty(ParticipantProperty.IsPresenter, true, (ar) => { participant.EndSetProperty(ar); }, null);
       }
      }
    }
  }
}
