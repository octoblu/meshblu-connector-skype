http = require 'http'

class JoinMeeting
  constructor: ({@connector}) ->
    throw new Error 'JoinMeeting Now requires connector' unless @connector?

  do: ({data}, callback) =>
    return callback @_userError(422, 'data.url is required') unless data?.url?

    @connector.joinMeeting(data.url)

    # metadata =
    #   code: 200
    #   status: http.STATUS_CODES[200]

    callback null

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = JoinMeeting
