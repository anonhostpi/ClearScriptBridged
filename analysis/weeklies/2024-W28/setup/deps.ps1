Write-Host "- Dependencies:"
Write-Host "  - PowerShell Modules: "

@(
    "Import-Package"
    "New-ThreadController"
) | ForEach-Object {
    Try {
        Import-Module "$_"

        Write-Host "    - $_`: " -NoNewline
        Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
    } Catch {
        Write-Host "    - $_`: " -NoNewline
        Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
        throw $_
        Pause
    }
}

Write-Host "  - CSharp Packages: "

@(
    "Microsoft.ClearScript"
) | ForEach-Object {
    Write-Host "    - $_`: "
    Try {
        Import-Package $_ -ErrorAction Stop

        Write-Host "    - $_`: " -NoNewline
        Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
    } Catch {
        Write-Host "    - $_`: " -NoNewline
        Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
        throw $_
        Pause
    }
}

Write-Host "  - NodeJS Modules: "

@(
    "chrome-remote-interface"
    "yargs"
) | ForEach-Object {
    Try {
        If( -not ((npm list -g -p "$_").Trim().Length -or (npm install -g "$_").Trim().Length) ) {
            Throw "Missing Dependency: $_"
        }

        Write-Host "    - $_`: " -NoNewline
        Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
    } Catch {
        Write-Host "    - $_`: " -NoNewline
        Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
        throw $_
        Pause
    }
}