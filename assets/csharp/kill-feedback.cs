using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

public class Startup
{
  public async Task<object> Invoke(dynamic ignored)
  {
    return null;
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
