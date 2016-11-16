http = require 'http'
_    = require 'lodash'

class JoinMeeting
  constructor: ({@connector}) ->
    throw new Error 'missing required parameter: connector' unless @connector?

  do: (job, callback) =>
    {meetingUrl, audioEnabled, videoEnabled} = _.get job, 'data', {}
    return callback @_userError 422, 'Missing required parameter data.meetingUrl' if _.isEmpty meetingUrl
    @connector.updateDesiredState {
      meeting:
        url: meetingUrl
      audioEnabled: audioEnabled
      videoEnabled: videoEnabled
    }

    callback null, {
      metadata:
        code: 204
        status: http.STATUS_CODES[204]
    }

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = JoinMeeting
