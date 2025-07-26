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
    $generalList = (ls $folderPath).BaseName
    $fileList = (ls $folderPath).Name

    $sidebarmd += "---`r`n"
    $sidebarmd += "  * $folder"

    for ($i = 0; $i -lt $generalList.Count; $i++) {
        $fileName = $fileList[$i]   #晋-杜预001.jfif
        $generalName = $generalList[$i].Split('-')[1]     #杜预001
        $mdName = $generalName + ".md"
        $sidebarmd += "    * [$generalName](pages/$mdName)"

        $generalMd = @()
        $generalMd += "# $generalName`r`n"
        $generalMd += "![$generalName](../assets/$fileName)`r`n"
        $generalMd | Out-File -FilePath ".\docs\pages\$mdName" -Encoding utf8 -Force -Confirm:$false
    }

   # $sidebarmd += "`r"
}

$sidebarmd += "---"

$sidebarmd | Out-File -FilePath ".\docs\_sidebar.md" -Encoding utf8 -Force -Confirm:$false

# $comment = "update "; cd $projectPath; git add .; git commit -m $comment; git push origin master
