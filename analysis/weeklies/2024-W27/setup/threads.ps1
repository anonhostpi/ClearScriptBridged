Write-Host "- Threads:"

$setup.threads = @{
    "loadcallback" = & {
        Write-Host "  - LoadCallback: " -NoNewline

        Try {
            $shared = [hashtable]::Synchronized(@{
                "DocumentQueue" = [System.Collections.Concurrent.ConcurrentQueue[Microsoft.ClearScript.DocumentInfo]]::new()
            })
            $thread = New-ThreadController -SessionProxies @{
                "Shared" = $shared
            }
            $thread | Add-Member `
                -Name "Shared" `
                -MemberType NoteProperty `
                -Value $shared
            $thread
            Write-Host "Done" -ForegroundColor Green -NoNewline; Write-Host;
        } Catch {
            Write-Host "Failed" -ForegroundColor Red -NoNewline; Write-Host;
            throw $_
            Pause
        }
    } 
}