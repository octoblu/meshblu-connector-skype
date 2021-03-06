using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using Microsoft.Lync.Model.Extensibility;

public class ConversationEvent {
  public string conversationId;
  public string participantId;
  public string eventSource;
  public string eventType;
  public object data;
};

public class ParticipantListener {
  Participant participant;
  string conversationId;
  string participantId;

  Func<object, Task<object>> callback;

  public ParticipantListener(Participant participant, String conversationId, Func<object, Task<object>> callback) {
    this.participant = participant;
    this.participantId = participant.Contact.Uri;
    this.callback = callback;
    this.conversationId = conversationId;
  }

  public void listen() {
    participant.IsMutedChanged += (sender, e) => {
      callback(new ConversationEvent { participantId= participantId, conversationId= conversationId, eventSource= "Participant", eventType= "MutedChanged", data= e.IsMuted});
    };
  }
}

public class ConversationListener {
  Conversation conversation;
  String conversationId;
  Func<object, Task<object>> callback;

  public ConversationListener(Conversation conversation, Func<object, Task<object>> callback) {
    this.conversation = conversation;
    this.callback = callback;
    this.conversationId = (string) conversation.Properties[ConversationProperty.Id];
  }

  public void listen() {
    BindToConversationChanges();
    BindToAvModalityChanges();
    BindToVideoChannelChanges();
  }

  private void BindToVideoChannelChanges() {
    var videoChannel = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]).VideoChannel;

    videoChannel.ActionAvailabilityChanged += (sender, e) => {
      callback(new ConversationEvent { conversationId=conversationId, eventSource= "VideoChannel", eventType= "ActionAvailabilityChanged", data= e});
    };

    videoChannel.StateChanged += (sender, e) => {
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "VideoChannel", eventType= "StateChanged", data= e});
    };
  }

  private void BindToConversationChanges() {
    conversation.StateChanged += (sender, e) => {
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "Conversation", eventType= "StateChanged", data= e});
    };

    conversation.PropertyChanged += (sender, e) => {
      if(e.Property != ConversationProperty.ConferencingUri && e.Property != ConversationProperty.ConferenceAccessInformation ) return;
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "Conversation", eventType= "PropertyChanged", data=e});
    };

    conversation.ParticipantAdded += (sender, e) => {
      var listener = new ParticipantListener(e.Participant, conversationId, callback);
      listener.listen();
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "Conversation", eventType= "ParticipantAdded", data= getSerializableParticipant(e.Participant)});

    };

    conversation.ParticipantRemoved += (sender, e) => {
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "Conversation", eventType= "ParticipantRemoved", data=getSerializableParticipant(e.Participant)});
    };
  }

  private IDictionary<string, object> getSerializableParticipant(Participant participant) {
    var serializableParticipant = new Dictionary<string, object>();
    serializableParticipant["isSelf"] = participant.IsSelf;
    serializableParticipant["isMuted"] = participant.IsMuted;
    serializableParticipant["name"] = participant.Properties[ParticipantProperty.Name];
    serializableParticipant["id"] = participant.Contact.Uri;
    return serializableParticipant;
  }

  private void BindToAvModalityChanges() {
    var avModality = ((AVModality)conversation.Modalities[ModalityTypes.AudioVideo]);
    avModality.ActionAvailabilityChanged += (sender, e) => {
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "AvModality", eventType= "ActionAvailabilityChanged", data= e});
    };

    avModality.ModalityStateChanged += (sender, e) => {
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "AvModality", eventType= "ModalityStateChanged", data= e});
    };
  }
}

public class Startup
{
  int currentHashCode = 0;

  public Task<object> BindToConversationManagerChanges(Func<object, Task<object>> callback) {
    var Client = LyncClient.GetClient();
    var newHashCode = Client.GetHashCode();

    if (currentHashCode == newHashCode) {
      return null;
    }
    currentHashCode = newHashCode;

    var ConversationManager = Client.ConversationManager;

    ConversationManager.ConversationAdded += (sender, e) => {
      string conversationId = (string) e.Conversation.Properties[ConversationProperty.Id];
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "ConversationManager", eventType= "ConversationAdded", data= getSerializableConversation(e.Conversation) });
      var listener = new ConversationListener(e.Conversation, callback);
      listener.listen();
    };

    ConversationManager.ConversationRemoved += (sender, e) => {
      string conversationId = (string) e.Conversation.Properties[ConversationProperty.Id];
      callback(new ConversationEvent { conversationId= conversationId, eventSource= "ConversationManager", eventType= "ConversationRemoved"});
    };

    return null;
  }

  private IDictionary<string, object> getSerializableConversation(Conversation conversation) {
    var serializableConversation = new Dictionary<string, object>();
    serializableConversation["id"] = conversation.Properties[ConversationProperty.Id];
    serializableConversation["subject"] = conversation.Properties[ConversationProperty.Subject];
    serializableConversation["conferencingUri"] = conversation.Properties[ConversationProperty.ConferencingUri];
    serializableConversation["conferenceAccessInformation"] = conversation.Properties[ConversationProperty.ConferenceAccessInformation];

    return serializableConversation;
  }


  public async Task<object> Invoke(Func<object, Task<object>> callback)
  {
    BindToConversationManagerChanges(callback);
    return null;
  }

}
