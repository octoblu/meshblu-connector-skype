http = require 'http'
_    = require 'lodash'

class StartMeeting
  constructor: ({@connector}) ->
    throw new Error 'missing required parameter: connector' unless @connector?

  do: (job, callback) =>
    {audioEnabled, videoEnabled} = _.get job, 'data', {}

    @connector.updateDesiredState {
      meeting:
        url: null
      audioEnabled: audioEnabled
      videoEnabled: videoEnabled
    }

    callback null, {
      metadata:
        code: 204
        status: http.STATUS_CODES[204]
    }

module.exports = StartMeeting
