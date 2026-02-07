$scriptRoot = $PSScriptRoot
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..')
$pagesDir = Join-Path $repoRoot 'docs\\pages'
$assetsDir = Join-Path $repoRoot 'docs\\assets'

$pages = Get-ChildItem -Path $pagesDir -Filter *.md -Recurse -ErrorAction SilentlyContinue
$missing = @()
foreach ($f in $pages) {
    $lines = Get-Content -Path $f.FullName -TotalCount 3 -ErrorAction SilentlyContinue
    if ($null -eq $lines -or $lines.Count -lt 3) {
        $missing += "{0} -> FILE_TOO_SHORT" -f $f.FullName; continue
    }
    $line3 = $lines[2].Trim()
    if ($line3 -match 'assets[\\/](.+?\.(jfif|jpe?g|png|gif|webp|svg))') {
        $assetName = $matches[1]
        $found = Get-ChildItem -Path $assetsDir -Recurse -Filter $assetName -ErrorAction SilentlyContinue
        if (-not $found) { $missing += "{0} -> {1}" -f $f.FullName, $assetName }
    } else {
        $missing += "{0} -> NO_ASSET_PATH_FOUND_IN_LINE3: {1}" -f $f.FullName, $line3
    }
}
if ($missing.Count -eq 0) { Write-Output "ALL_OK" } else { $missing | Sort-Object }
