http = require 'http'

class MeetNow
  constructor: ({@connector}) ->
    throw new Error 'Meet Now requires connector' unless @connector?

  do: ({data}, callback) =>
    # return callback @_userError(422, 'data.example is required') unless data?.example?

    @connector.startConversation()

    # metadata =
    #   code: 200
    #   status: http.STATUS_CODES[200]

    callback null

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = MeetNow
