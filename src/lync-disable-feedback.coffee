fs      = require 'fs'

disable = (callback) =>
  skypePath = "#{process.env.APPDATA}\\Skype\\shared.xml"
  fs.access skypePath, (error) =>
    if error
      if error.code == 'ENOENT'
        return callback null
      else
        return callback error
    fs.unlinkSync skypePath, (error) =>
      return callback error if error?
      callback null

module.exports = {
  disable
}
