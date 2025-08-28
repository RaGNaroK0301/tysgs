$patchPath = "$home\desktop\修订7"
cd $patchPath

$projectPath = "D:\Repository\MyProject\tysgs"

$assetsPath = Join-Path $projectPath "docs\assets"
$pagesPath = Join-Path $projectPath "docs\pages"

foreach ($file in Get-ChildItem -Path $patchPath) {
    if ($file.Name -match "^技标") {
        $jiBiao = $true
        $newName = $file.Name.replace("技标-","").replace("技标-","").replace("】【","-").replace("】","-").replace("【","-").trimend("-")
        $file | Rename-Item -NewName $newName
        echo "Renamed $($file.Name) to $newName"

        $fileBaseName = $newName.split(".")[0]
        $fileExt = ".jpg"
        $fileName = $newName
    } else {
        $jiBiao = $false
        $fileBaseName = $file.BaseName
        $fileExt = ".jpg"
        $fileName = $file.Name
    }

    # 如果jfif在assets里已存在
    if ((Test-Path $(Join-Path $assetsPath $fileName)) -eq $true) {
        echo "$fileName already exists in $assetsPath, overwriting..."
        Copy-Item -Path $fileName -Destination $assetsPath -Force
    }

    # 如果jfif在assets里不存在但jpg存在
    if (((Test-Path $(Join-Path $assetsPath $fileName)) -eq $false) -and ((Test-Path $(Join-Path $assetsPath $fileBaseName$fileExt)) -eq $true)) {
        echo "$fileBaseName$fileExt exists, remove and copy jfif"
        Copy-Item -Path $fileName -Destination $assetsPath -Force
        Remove-Item -Path $(Join-Path $assetsPath $fileBaseName$fileExt) -Force

        #修改md文件
        Get-Content $("$pagesPath\$fileBaseName" + ".md") | ForEach-Object { $_ -replace ".jpg",".jfif" } | Set-Content $("$pagesPath\$fileBaseName" + ".md")
        echo "Updated $fileBaseName md to reference jfif"
    }

    # 如果jfif在assets里不存在jpg也不存在
    if (((Test-Path $(Join-Path $assetsPath $fileName)) -eq $false) -and ((Test-Path $(Join-Path $assetsPath $fileBaseName$fileExt)) -eq $false)) {
        echo "$fileName does not exist, copying..."
        Copy-Item -Path $fileName -Destination $assetsPath -Force

        if ($jiBiao -eq $true) {
            echo "手动加技标到md里"
            continue
        }

        #增加md文件
        New-Item -Path $("$pagesPath\$fileBaseName" + ".md") -ItemType File -Force

        $mdContent = @"
# $fileBaseName

![$fileBaseName](../assets/$($fileBaseName + ".jfif"))
    
"@
        $mdContent | Set-Content -Path $("$pagesPath\$fileBaseName" + ".md")
        echo "Created new md file for $fileBaseName"
        echo "手动加到_sidebar里"
    }
}


# cd "D:\Repository\MyProject\tysgs"; $comment = "update "; cd $projectPath; git add .; git commit -m $comment; git push origin main

