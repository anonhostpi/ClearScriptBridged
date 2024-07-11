$analysis.cland.bindings = & {

    Write-Host

    $results = Search-SourceFiles `
        -Repo 'Node' `
        -SearchRoot 'src' `
        -FilePatterns @('*.cc', '*.c') `
        -Regex 'NODE_BINDING_CONTEXT_AWARE_INTERNAL\(\s*(\S+)\s*,\s*(\S+)\s*\)'

    Write-Host

    $results.Values | ForEach-Object {
        $result = $_

        $result.Bindings = $result.Matches | ForEach-Object {
            @{
                "Line" = $_.LineNumber
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

    $ordered
}