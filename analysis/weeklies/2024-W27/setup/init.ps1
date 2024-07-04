Write-Host "- Initialization:"
Write-Host "  - Runtime: " -NoNewline

Try {
    $runtime = [Microsoft.ClearScript.V8.V8Runtime]::new( $setup.options.runtime, $setup.options.port )

    $runtime.DocumentSettings.AccessFlags = $setup.options.document
    $runtime.DocumentSettings.SearchPath = $pwd
    $runtime.DocumentSettings.LoadCallback = [Microsoft.ClearScript.DocumentLoadCallback][LoadCallback]::Run

    Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
} Catch {
    Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
    throw $_
    Pause
}

Write-Host "  - Engine: " -NoNewline

Try {

    # $engine = [Microsoft.ClearScript.V8.V8ScriptEngine]::new( $options.engine, 9223 )
    # $engine.DocumentSettings.AccessFlags = $options.document
    # $engine.DocumentSettings.SearchPath = $pwd
    # $engine.DocumentSettings.LoadCallback = [Microsoft.ClearScript.DocumentLoadCallback][LoadCallback]::Run

    $engine = $runtime.CreateScriptEngine( $options.engine )
    $engine.DocumentSettings.AccessFlags = $runtime.DocumentSettings.AccessFlags
    $engine.DocumentSettings.SearchPath = $runtime.DocumentSettings.SearchPath
    $engine.DocumentSettings.LoadCallback = $runtime.DocumentSettings.LoadCallback
    $engine.AllowReflection = $true

    Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
} Catch {
    Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
    throw $_
    Pause
}

Write-Host "  - Descriptors: " -NoNewline

$setup.descriptors = @{
    "es6" = New-Object Microsoft.ClearScript.DocumentInfo -Property @{
        "Category" = [Microsoft.ClearScript.JavaScript.ModuleCategory]::Standard
    } -ArgumentList "[PowerShell ES6-Module eval]"
    "commonjs" = New-Object Microsoft.ClearScript.DocumentInfo -Property @{
        "Category" = [Microsoft.ClearScript.JavaScript.ModuleCategory]::CommonJS
    } -ArgumentList "[PowerShell CommonJS-Module eval]"
    "script" = New-Object Microsoft.ClearScript.DocumentInfo -Property @{
        "Category" = [Microsoft.ClearScript.DocumentCategory]::Script
    } -ArgumentList "[PowerShell Script eval]"
    "json" = New-Object Microsoft.ClearScript.DocumentInfo -Property @{
        "Category" = [Microsoft.ClearScript.DocumentCategory]::JSON
    } -ArgumentList "[PowerShell JSON eval]"
}

Write-Host "Done" -ForegroundColor Green;