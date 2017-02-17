_       = require 'lodash'
convert = require 'xml-js'
fs      = require 'fs'
path    = require 'path'


disable = (callback) =>
  skypePath = "#{process.env.APPDATA}\\Skype\\shared.xml"
  skypeXml = fs.readFileSync skypePath, 'utf8'
  skypeJson = convert.xml2json skypeXml, { compact: true, spaces: 4 }
  _.unset skypeJson, 'Lib.StatsSender'
  result = convert.json2xml skypeJson, { ignoreText: true, spaces: 4 }
  fs.writeFile skypePath, result, 'utf8', callback

module.exports = {
  disable
}
