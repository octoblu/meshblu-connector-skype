using System;
using System.Diagnostics;

public class Startup
{
  public async Task<object> Invoke(string ignored)
  {
    Process[] processes = Process.GetProcesses();

    foreach (Process process in processes)
    {
       if (process.MainWindowTitle == "Skype for Business") {
         process.Kill();
       }
    }

    return null;
  }
}
