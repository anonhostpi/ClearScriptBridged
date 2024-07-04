Write-Host "- Types:"

$setup.csharp = @{
    "loadcallback" = @{
        "source" = @"
using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Windows.Threading;
using Microsoft.ClearScript;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

public class LoadCallback
{
    public static object Runtime { get; set; }
    public static Action Callback { get; set; }
    public static Hashtable Shared { get; set; }

    public static void Run( ref Microsoft.ClearScript.DocumentInfo documentInfo )
    {
        ConcurrentQueue<Microsoft.ClearScript.DocumentInfo> q = (ConcurrentQueue<Microsoft.ClearScript.DocumentInfo>) Shared["DocumentQueue"];
        q.Enqueue( documentInfo );
        if (Runtime is System.Windows.Threading.Dispatcher wpfDispatcher)
        {
            wpfDispatcher.InvokeAsync(Callback).Task.GetAwaiter().GetResult();
        }
        else
        {
            var dispatcherType = Runtime.GetType();
            var method = dispatcherType.GetMethod("InvokeAsync", new Type[] { typeof(Action) });

            if (method != null)
            {
                var task = (Task) method.Invoke(Runtime, new object[] { Callback });
                task.GetAwaiter().GetResult();
            }
            else
            {
                throw new InvalidOperationException("Dispatcher must have an InvokeAsync method.");
            }
        }
    }
}
"@
        "Assemblies" = @(
            & {
                $assembly = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_ -like "*WindowsBase*" }
                $assembly.Location
            }
            "ClearScript.Core"
            "System.Collections.Concurrent"
            "Microsoft.CSharp"
            "System.Linq"
            "System.Console"
        )
        "Trailing" = @{
            "IgnoreWarnings" = $true
        }
    }
}

$setup.types = @{}

Write-Host "  - LoadCallback: " -NoNewline

Try {
    & {
        $trailing = $setup.csharp.loadcallback.trailing
        $setup.types.loadcallback = Add-Type `
            -TypeDefinition $setup.csharp.loadcallback.source `
            -ReferencedAssemblies $setup.csharp.loadcallback.assemblies `
            -PassThru `
            -ErrorAction Stop `
            @trailing
        Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
    }
} Catch {
    Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
    Write-Host "Types are likely already declared. Would you like to continue? [Y/N]"
    $response = Read-Host
    if( $response -ne "Y" ) {
        throw $_
    }
}