$patchPath = "$home\desktop\修订8"
cd $patchPath

$projectPath = "D:\Repository\MyProject\tysgs"

$assetsPath = Join-Path $projectPath "docs\assets"
$pagesPath = Join-Path $projectPath "docs\pages"

foreach ($file in Get-ChildItem -Path $patchPath) {
    if ($file.Name -match "^技标") {
        $jiBiao = $true
        $newName = $file.Name.replace("技标-","").replace("技标-","").replace("】【","-").replace("】","-").replace("【","-").replace("-.",".")
        $file | Rename-Item -NewName $newName
        Write-Host "Renamed $($file.Name) to $newName" -ForegroundColor Green

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
        Write-Host "$fileName already exists in $assetsPath, overwriting..." -ForegroundColor Green
        Copy-Item -Path $fileName -Destination $assetsPath -Force
    }

    # 如果jfif在assets里不存在但jpg存在
    if (((Test-Path $(Join-Path $assetsPath $fileName)) -eq $false) -and ((Test-Path $(Join-Path $assetsPath $fileBaseName$fileExt)) -eq $true)) {
        Write-Host "$fileBaseName$fileExt exists, remove and copy jfif" -ForegroundColor Green
        Copy-Item -Path $fileName -Destination $assetsPath -Force
        Remove-Item -Path $(Join-Path $assetsPath $fileBaseName$fileExt) -Force

        #修改md文件
        Get-Content $("$pagesPath\$fileBaseName" + ".md") | ForEach-Object { $_ -replace ".jpg",".jfif" } | Set-Content $("$pagesPath\$fileBaseName" + ".md")
        Write-Host "Updated $fileBaseName md to reference jfif" -ForegroundColor Green
    }

    # 如果jfif在assets里不存在jpg也不存在
    if (((Test-Path $(Join-Path $assetsPath $fileName)) -eq $false) -and ((Test-Path $(Join-Path $assetsPath $fileBaseName$fileExt)) -eq $false)) {
        Write-Host "$fileName does not exist, copying..." -ForegroundColor Green
        Copy-Item -Path $fileName -Destination $assetsPath -Force

        if ($jiBiao -eq $true) {
            Write-Host "手动加技标到md里" -ForegroundColor Magenta
            continue
        }

        #增加md文件
        New-Item -Path $("$pagesPath\$fileBaseName" + ".md") -ItemType File -Force | Out-Null

        $mdContent = @"
# $fileBaseName

![$fileBaseName](../assets/$($fileBaseName + ".jfif"))
    
"@
        $mdContent | Set-Content -Path $("$pagesPath\$fileBaseName" + ".md")
        Write-Host "Created new md file for $fileBaseName" -ForegroundColor Green
        Write-Host "手动加到_sidebar里" -ForegroundColor Magenta
    }
}


# cd "D:\Repository\MyProject\tysgs"; $comment = "update "; cd $projectPath; git add .; git commit -m $comment; git push origin master

