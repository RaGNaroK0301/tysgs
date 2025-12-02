$patchPath = "$home\desktop\修订9"
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


<#

cd "D:\Repository\MyProject\tysgs"

$jin_count = (gci .\assets\ | ? {($_.BaseName -notmatch "晋-.*?-.*") -and ($_.BaseName -match "晋-.*?\d{3}") -and ($_.BaseName -notmatch "晋-神.*?\d{3}")}).count
$qun_count = (gci .\assets\ | ? {($_.BaseName -notmatch "群-.*?-.*") -and ($_.BaseName -match "群-.*?\d{3}") -and ($_.BaseName -notmatch "群-神.*?\d{3}")}).count
$shu_count = (gci .\assets\ | ? {($_.BaseName -notmatch "蜀-.*?-.*") -and ($_.BaseName -match "蜀-.*?\d{3}") -and ($_.BaseName -notmatch "蜀-神.*?\d{3}")}).count
$wei_count = (gci .\assets\ | ? {($_.BaseName -notmatch "魏-.*?-.*") -and ($_.BaseName -match "魏-.*?\d{3}") -and ($_.BaseName -notmatch "魏-神.*?\d{3}")}).count
$wu_count = (gci .\assets\ | ? {($_.BaseName -notmatch "吴-.*?-.*") -and ($_.BaseName -match "吴-.*?\d{3}") -and ($_.BaseName -notmatch "吴-神.*?\d{3}")}).count
$shen_count = (gci .\assets\ | ? {($_.BaseName -match "^*-神.*?\d{3}") -and ($_.BaseName -notmatch "^*-神.*?-.*")}).count
Write-Host "晋 count: $jin_count"
Write-Host "群 count: $qun_count"
Write-Host "蜀 count: $shu_count"
Write-Host "魏 count: $wei_count"
Write-Host "吴 count: $wu_count"
Write-Host "神 count: $shen_count"

$sidebarContent = Get-Content .\docs\_sidebar.md -Raw
$jin_pattern = "  \* 晋 \(\d+\)"
$qun_pattern = "  \* 群 \(\d+\)"
$shu_pattern = "  \* 蜀 \(\d+\)"
$wei_pattern = "  \* 魏 \(\d+\)"
$wu_pattern = "  \* 吴 \(\d+\)"
$shen_pattern = "  \* 神 \(\d+\)"
$sidebarContent = $sidebarContent -replace $jin_pattern, "  * 晋 ($jin_count)"
$sidebarContent = $sidebarContent -replace $qun_pattern, "  * 群 ($qun_count)"
$sidebarContent = $sidebarContent -replace $shu_pattern, "  * 蜀 ($shu_count)"
$sidebarContent = $sidebarContent -replace $wei_pattern, "  * 魏 ($wei_count)"
$sidebarContent = $sidebarContent -replace $wu_pattern, "  * 吴 ($wu_count)"
$sidebarContent = $sidebarContent -replace $shen_pattern, "  * 神 ($shen_count)"
$sidebarContent | Set-Content .\docs\_sidebar.md -Encoding UTF8


$comment = "update "; git add .; git commit -m $comment; git push origin master

#>