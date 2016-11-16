http = require 'http'

class StopMeeting
  constructor: ({@connector}) ->
    throw new Error 'missing required parameter: connector' unless @connector?

  do: (job, callback) =>
    @connector.updateDesiredState meeting: null

    callback null, {
      metadata:
        code: 204
        status: http.STATUS_CODES[204]
    }

module.exports = StopMeeting
