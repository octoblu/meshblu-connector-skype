fs      = require 'fs'

disable = (callback) =>
  skypePath = "#{process.env.APPDATA}\\Skype\\shared.xml"
  fs.access skypePath, fs.constants.R_OK | fs.constants.W_OK, (error) =>
    return callback error if error?
    fs.unlinkSync skypePath, (error) =>
      return callback error if error?
      callback null

module.exports = {
  disable
}
