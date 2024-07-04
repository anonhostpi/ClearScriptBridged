Write-Host "- Configuration:"
Write-Host "  - LoadCallback: " -NoNewline

Try {
    $setup.types.loadcallback::Runtime = $setup.threads.loadcallback.Dispatcher
    $setup.types.loadcallback::Shared = $setup.threads.loadcallback.Shared
    $setup.types.loadcallback::Callback = [System.Action] {
        [Microsoft.ClearScript.DocumentInfo] $DocumentInfo = [Microsoft.ClearScript.DocumentInfo]::new("");
        $count = 0
        While( $Shared.DocumentQueue.TryDequeue( [ref] $DocumentInfo ) ){
            Write-Host "Loading document: $($DocumentInfo.Name)"
            $count++
        }
        If( $count ){
            $Shared.LastDocument = $DocumentInfo
        }
    }.Ast.GetScriptBlock()

    Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
} Catch {
    Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
    throw $_
    Pause
}

Write-Host "  - ClearScript: " -NoNewline

$setup.options = @{
    "port" = 9222
    "runtime" = [Enum]::Parse(
        [Microsoft.ClearScript.V8.V8RuntimeFlags],
        @(
            # "None"
            "EnableDebugging"
            # "EnableRemoteDebugging"
            "EnableDynamicModuleImports"
        ) -join ", "   
    )
    "engine" = [Enum]::Parse(
        [Microsoft.ClearScript.V8.V8ScriptEngineFlags],
        @(
            "EnableDebugging"
            # "DisableGlobalMembers"
            # "EnableRemoteDebugging"
            # "AwaitDebuggerAndPauseOnStart"
            # "EnableDateTimeConversion"
            # "EnableDynamicModuleImports"
            # "MarshalUnsafeLongAsBigInt"
            # "MarshalAllLongAsBigInt"
            "EnableTaskPromiseConversion"
            # "EnableValueTaskPromiseConversion"
            # "UseCaseInsensitiveMemberBinding"
            # "EnableStringifyEnhancements"
            # "HideHostExceptions"
            # "AddSynchronizationContexts"
            "AddPerformanceObject"
            # "SetTimerResolution"
        ) -join ", "
    )
    "document" = [Enum]::Parse(
        [Microsoft.ClearScript.DocumentAccessFlags],
        @(
            # "None"
            "EnableFileLoading"
            # "EnableWebLoading"
            # "EnableAllLoading"
            "EnforceRelativePrefix"
            "AllowCategoryMismatch"
            # "UseAsyncLoadCallback"
        ) -join ", "
    )
}

Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;