using System;
using System.Threading;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;

public class Startup {
  public string programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);

  public IEnumerable<string> installPaths = new List<string> {
      @"Microsoft Office\root\Office16\lync.exe",
      @"Microsoft Office\Office16\lync.exe",
      @"Microsoft Office\root\Office15\lync.exe",
      @"Microsoft Office\Office15\lync.exe"
  }

  public IEnumerable<string> paths = installPaths.Select(p => Path.Combine(programFiles, p));

  public async Task<object> StartClient(dynamic ignored) {
    try {
      var client = paths.First(File.Exists);
      Process.Start(client);
    } catch (InvalidOperationException) {
      throw new Exception("No Lync or Skype client installed");
    }
    return null;
  }
}
