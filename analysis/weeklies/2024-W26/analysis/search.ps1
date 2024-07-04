function Get-LineNumberFromIndex {
    param (
        [string] $String,
        [int] $Index
    )

    # Initialize line number and character count
    $lineNumber = 1

    # Iterate through the string character by character
    for ($i = 0; $i -lt $String.Length; $i++) {
        # If the current index matches the given index, return the line number
        if ($i -eq $index) {
            return $lineNumber
        }

        # If we encounter a newline character, increment the line number and reset character count
        if ($String[$i] -match "[`r`n]") {
            if( $String[$i] -eq "`r" -and $String[$i+1] -eq "`n" ){
                $i++
            }
                
            $lineNumber++
        }
    }

    # If the index is out of range, return -1
    return -1
}

function Search-SourceFiles {
    param(
        [ValidateSet('Node','ClearScript')]
        [string] $Repo = 'Node',
        [string] $SearchRoot = 'src',
        [string[]] $FilePatterns = @('*.cc', '*.c'),
        [scriptblock[]] $ContentFilters, # = { $_.File $_.Content ... }
        [string] $Regex = 'NODE_BINDING_CONTEXT_AWARE_INTERNAL\(\s*(\S+)\s*,\s*\S+\s*\)'
    )

    $_search_root = $SearchRoot

    # Validation:
    If (-not [System.IO.Path]::IsPathRooted( $_search_root )) {
        $_search_root = Join-Path $paths[$Repo] $_search_root
    }
    # Check if path exists
    If (-not (Test-Path $_search_root)) {
        Throw "Path does not exist: $_search_root"
    }

    $files = New-Object System.Collections.ArrayList

    Write-Host "Getting files in $_search_root..."

    $FilePatterns | ForEach-Object {
        Get-ChildItem -Path $_search_root -Filter $_ -Recurse | ForEach-Object {
            $files.Add( $_ ) | Out-Null
        }
    }

    Write-Host "Files found: $($files.Count)"

    If( $files.Count ){
        
        Write-Host "Dumping files..."

        $map = $files | ForEach-Object -Begin { $i = 0 } -Process {
            $i++;
            Write-Host "- Dumping file: $i/$($files.Count)"
            @{
                "File" = $_.FullName
                "Content" = Get-Content -Path $_.FullName -Raw
            }
        }

        If( $ContentFilters.Count ){
            Write-Host "Filtering files..."
        
            $ContentFilters | ForEach-Object -Begin { $f = 0 } -Process {
                $f++;
                Write-Host "Applying filter: $f/$($ContentFilters.Count)"
                $map = $map | ForEach-Object -Begin { $i = 0 } -Process {
                    $i++;
                    Write-Host "- Filtering file: $i/$($map.Count)"
                    $_
                } | Where-Object -FilterScript $_
            }
        }

        Write-Host "Performing regex search..."

        $parsed_regex = [regex]::new($Regex)

        $Out = @{}

        $map | ForEach-Object -Begin { $i = 0 } -Process {
            $i++;
            Write-Host "- Searching file: $i/$($map.Count)"

            $_map = $_

            $m = $parsed_regex.Matches( $_map.Content )

            $m | ForEach-Object {
                $_ | Add-Member `
                    -Name "LineNumber" `
                    -MemberType NoteProperty `
                    -Value (Get-LineNumberFromIndex -String $_map.Content -Index $_.Index)
            }
            
            If( $m.Count ){

                $Out[$_map.File] = @{
                    "File" = $_map.File
                    "Content" = $_map.Content
                    "Matches" = $m
                    "Lines" = $m.LineNumber | Sort-Object -Unique
                }
            }
        }

        Write-Host "Search completed."

        $Out
    }
}