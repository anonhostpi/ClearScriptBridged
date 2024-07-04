$paths = @{
    "root" = $PSScriptRoot
    "setup" = "$PSScriptRoot/setup"
    "dump" = "$PSScriptRoot/dump"
    "analysis" = "$PSScriptRoot/analysis"

    "node" = "$PSScriptRoot/../../../node"
    "clearscript" = "$PSScriptRoot/../../../clearscript"
}

$setup = @{}
$dump = $null;
$analysis = @{}
$analysis.week = $paths.root | Split-Path -Leaf

$runtime = $null;
$engine = $null;

Start-Transcript -Path "$PSScriptRoot/RESULTS.log";

Write-Host
Write-Host "Preparing Test Environment:" $analysis.week;
Try {
    . ($paths.setup + "/setup.ps1")

    Write-Host "Test Environment: " -NoNewline; Write-Host "Initialized" -NoNewline -ForegroundColor Green; Write-Host;
    Write-Host
    Pause;
} Catch {
    Write-Host "Test Environment: " -NoNewline; Write-Host "Failed" -NoNewline -ForegroundColor Red; Write-Host;
    Write-Host $_.Exception.Message;
    Write-Host
    Stop-Transcript;
    Pause;
    Exit;
}

Write-Host "Performing Dump:"
Try {
    . ($paths.dump + "/dump.ps1")

    Write-Host "Dump: " -NoNewline; Write-Host "Completed" -NoNewline -ForegroundColor Green; Write-Host;
    Write-Host
    Pause;
} Catch {
    Write-Host "Dump: " -NoNewline; Write-Host "Failed" -NoNewline -ForegroundColor Red; Write-Host;
    Write-Host $_.Exception.Message;
    Write-Host
    Stop-Transcript;
    Pause;
    Exit;
}

Write-Host "Performing Analysis:"

Try {
    . ($paths.analysis + "/analysis.ps1")

    Write-Host "Analysis: " -NoNewline; Write-Host "Complete" -NoNewline -ForegroundColor Green; Write-Host;
    Write-Host
    Pause;
} Catch {
    Write-Host "Analysis: " -NoNewline; Write-Host "Critically Failed" -NoNewline -ForegroundColor Red; Write-Host;
    Write-Host $_.Exception.Message;
    Write-Host
    Stop-Transcript;
    Pause;
    Exit;
}

Write-Host
Stop-Transcript;