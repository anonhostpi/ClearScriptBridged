. ($paths.analysis + "/search.ps1")
$analysis.cland = @{}
. ($paths.analysis + "/cland/bindings.ps1" )

$analysis.jsland = @{}
. ($paths.analysis + "/jsland/bindings.ps1" )

& {
    $diff = Compare-Object $analysis.cland.bindings.Keys $analysis.jsland.bindings.Keys

    $labeled_diff = @{
        "cland" = @()
        "jsland" = @()
    }

    $diff | ForEach-Object {
        $key = $_.InputObject
        $side = switch ($_.SideIndicator) {
            "<=" { "cland" }
            "=>" { "jsland" }
            Default {}
        }

        $labeled_diff[$side] += $key
    }

    If( $labeled_diff.cland.Count -or $labeled_diff.jsland.Count ){
        Write-Host "The following bindings declarations/calls were only found in one of the two `"lands`":" -ForegroundColor Red

        If( $labeled_diff.cland.Count ){
            Write-Host "- Found only in C++ Land" -ForegroundColor DarkGray
            
            $labeled_diff.cland | ForEach-Object {
                Write-Host "  - $_" 
            }
        }

        If( $labeled_diff.jsland.Count ){
            Write-Host "- Found only in JavaScript Land" -ForegroundColor DarkGray

            $labeled_diff.jsland | ForEach-Object {
                Write-Host "  - $_"
            }
        }
    }

    $keys = (($analysis.cland.bindings.Keys + $analysis.jsland.bindings.keys) | Select-Object -Unique) | Sort-Object

    $keys | ForEach-Object {
        $binding = $_

        $cland = $analysis.cland.bindings[$binding]
        $jsland = $analysis.jsland.bindings[$binding]

        Write-Host "Internal Binding: " -NoNewLine; Write-Host $binding -ForegroundColor Magenta -NoNewLine; Write-Host;

        If( $cland ){
            Write-Host "- C++ Land" -ForegroundColor DarkRed
            $cland.GetEnumerator() | ForEach-Object {
                $file = $_.Key
                $mapping = $_.Value.Bindings
                Write-Host "  - File: " -NoNewLine -ForegroundColor DarkGray; Write-Host $file -ForegroundColor Cyan -NoNewLine; Write-Host;
                $mapping | ForEach-Object {
                    Write-Host "  - Register ($( $_.Line )): " -NoNewLine -ForegroundColor DarkGray; Write-Host $_.Register -ForegroundColor Yellow -NoNewLine; Write-Host;
                }
            }
        }

        If( $jsland ){
            Write-Host "- JavaScript Land" -ForegroundColor DarkRed
            $jsland.GetEnumerator() | ForEach-Object {
                $file = $_.Key
                $mapping = $_.Value.Bindings
                Write-Host "  - File ($( (& {
                    If( $mapping.Count -gt 1 ){
                        "Lines: $( ($mapping | ForEach-Object { $_.Line }) -join ',' )"
                    } Else {
                        "Line: $( $mapping.Line )"
                    }
                }) )): " -NoNewLine -ForegroundColor DarkGray; Write-Host $file -ForegroundColor Cyan -NoNewLine; Write-Host;
            }
        }
    }
}