convert = require 'xml-js'
fs      = require 'fs'
_       = require 'lodash'

disable = (callback) =>
  skypeXml = fs.readFileSync "C:\#{process.env.HOMEPATH}\AppData\Roaming\Skype\shared.xml", 'utf8'
  skypeJson = convert.xml2json skypeXml, { compact: true, spaces: 4 }
  _.unset skypeJson, 'Lib.StatsSender'
  result = convert.json2xml skypeJson, { ignoreText: true, spaces: 4 }
  fs.writeFile "C:\#{process.env.HOMEPATH}\AppData\Roaming\Skype\shared.xml", result, 'utf8', callback

module.exports = {
  disable
}
