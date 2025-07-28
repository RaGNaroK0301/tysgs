$projectPath = "$home\desktop\tysgs"
cd $projectPath

$sidebarmd = @()
$sidebarmd += "* [首页](README.md)"

$assetsPath = "E:\115\tysgs_assets"
echo "tysgs assets path: $assetsPath"
#ls $assetsPath -Recurse | ? {!$_.PSIsContainer} | Copy-Item -Destination .\docs\assets\ -Force -Confirm:$false

$folderList = (ls $assetsPath | ? { $_.PSIsContainer }).Name    #晋
foreach ($folder in $folderList) {
    $folderPath = Join-Path -Path $assetsPath $folder
    $baseList = (ls $folderPath).BaseName
    $fileList = (ls $folderPath).Name

    $sidebarmd += "---`r`n"
    $sidebarmd += "  * $folder"

    for ($i = 0; $i -lt $baseList.Count; $i++) {
        $fileName = $fileList[$i]   #晋-杜预001.jfif
        $baseName = $baseList[$i]     #晋-杜预001
        $mdName = $baseName + ".md"
        $sidebarmd += "    * [$baseName](pages/$mdName)"

        $baseMd = @()
        $baseMd += "# $baseName`r`n"
        $baseMd += "![$baseName](../assets/$fileName)`r`n"
        $baseMd | Out-File -FilePath ".\docs\pages\$mdName" -Encoding utf8 -Force -Confirm:$false
    }

   # $sidebarmd += "`r"
}

$sidebarmd += "---"

$sidebarmd | Out-File -FilePath ".\docs\_sidebar.md" -Encoding utf8 -Force -Confirm:$false

# $comment = "update "; cd $projectPath; git add .; git commit -m $comment; git push origin main
