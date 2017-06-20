module.exports = 
title: "Default Configuration"
type: "object"
properties:
  autoLaunchSkype:
    title: "Auto Launch Skype (Skype4Business on Windows only)"
    type: "boolean"
    default: false
  desiredState:
    title: "Desired State"
    type: "object"
    properties:
      meeting:
        type: "object"
        properties:
          url:
            title: "Meeting Url"
            type: "string"
      videoEnabled:
        title: "Enable Video"
        type: "boolean"
        default: false
      audioEnabled:
        title: "Enable Audio"
        type: "boolean"
        default: false
