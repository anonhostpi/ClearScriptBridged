$dump = & {

    Write-Host "- Dumping:"

    $files = @{
        "dump" = Join-Path $paths.dump "dump.json"
        "dumper" = Join-Path $paths.dump "dumper.js"
        "target" = Join-Path $paths.dump "target.js"
    }

    $global:result = node $files.dumper $files.target $files.dump
    
    # Write-Host "- Setting Up API: " -NoNewline;

    [PSCustomObject]@{
        Log = $result
        Source = Get-Content (Join-Path $paths.dump "dump.json")
        Traces = @{}
    }
}