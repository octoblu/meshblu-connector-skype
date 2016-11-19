http = require 'http'
_    = require 'lodash'

class StartMeeting
  constructor: ({@connector}) ->
    throw new Error 'missing required parameter: connector' unless @connector?

  do: (job, callback) =>
    {audioEnabled, videoEnabled} = _.get job, 'data', {}
    @connector.updateDesiredState {
      meeting: {}
      audioEnabled: audioEnabled
      videoEnabled: videoEnabled
    }

    @connector.startMeeting (meeting, error) =>
      return callback error if error?
      callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: meeting
      }

module.exports = StartMeeting
