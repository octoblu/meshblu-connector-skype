http = require 'http'

class Ping
  do: ({data}, callback) =>
    callback null, {
      metadata:
        code: 200
        status: http.STATUS_CODES[200]
      data:
        pong: "#{new Date().valueOf()}"
    }

module.exports = Ping
