$analysis.cland.bindings = & {
    $results = Search-SourceFiles `
        -Repo 'Node' `
        -SearchRoot 'src' `
        -FilePatterns @('*.cc', '*.c') `
        -Regex 'NODE_BINDING_CONTEXT_AWARE_INTERNAL\(\s*(\S+)\s*,\s*(\S+)\s*\)'

    $results.Values | ForEach-Object {
        $result = $_

        $result.Bindings = $result.Matches | ForEach-Object {
            @{
                "Name" = $_.Groups[1].Value
                "Register" = $_.Groups[2].Value
            }
        }
    }

    $unordered = @{}

    $results.Values | ForEach-Object {
        $result = $_

        $result.Bindings | ForEach-Object {
            If( -not $unordered.ContainsKey( $_.Name ) ){
                $unordered[$_.Name] = @{}
            }

            $unordered[$_.Name][$result.File] = $result
        }
    }

    $ordered = [ordered]@{}

    $unordered.Keys | Sort-Object | ForEach-Object {
        $key = $_

        $ordered[$key] = $unordered[$key]
    }

    $ordered.GetEnumerator() | ForEach-Object {
        $binding = $_.Key
    
        Write-Host "Internal Binding: " -NoNewLine; Write-Host $binding -ForegroundColor Magenta -NoNewLine; Write-Host;
    
        $_.Value.GetEnumerator() | ForEach-Object {
            $file = $_.Key
            $mapping = $_.Value.Bindings
            Write-Host "- File: " -NoNewLine -ForegroundColor DarkGray; Write-Host $file -ForegroundColor Cyan -NoNewLine; Write-Host;
            $mapping | ForEach-Object {
                Write-Host "- Register: " -NoNewLine -ForegroundColor DarkGray; Write-Host $_.Register -ForegroundColor Yellow -NoNewLine; Write-Host;
            }
        }
    
        Write-Host
    }

    $ordered
}