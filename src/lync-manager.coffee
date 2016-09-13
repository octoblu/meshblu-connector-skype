edge = require('edge')

goFullScreen = edge.func
  source: () =>
    ###
    using System;
    using System.Threading.Tasks;
    using Microsoft.Lync.Model;
    using Microsoft.Lync.Model.Extensibility;


    public class Startup
    {
      public async Task<object> Invoke(object input)
      {
        var client = LyncClient.GetClient();
        var automation = LyncClient.GetAutomation();
        return "Success?";
      }
    }
    ###
  references: [
    'Microsoft.Lync.Model.dll'
    'Microsoft.Lync.Controls.dll'
    'Microsoft.Lync.Utilities.dll'
    'Microsoft.Lync.Controls.Resources.dll'
    'Microsoft.Lync.Controls.Framework.dll'
    'Microsoft.Office.Uc.dll'
  ]


module.exports = {
  goFullScreen: goFullScreen
}
