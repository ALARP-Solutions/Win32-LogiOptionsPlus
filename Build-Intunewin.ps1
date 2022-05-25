
$vers = Read-Host -Prompt "Enter VSCode Version"

## ------------------------------ ##
## Create Build Folder
## ------------------------------ ##

$buildpath = "$PSScriptRoot\Builds\"

If (-Not (Test-Path $buildpath)) {
    New-Item -Path "$buildpath" -Name "" -ItemType "directory" | Out-Null
}

## ------------------------------ ##
## Create Temp Folder
## ------------------------------ ##

$temppath = "$PSScriptRoot\temp"
If (Test-Path $temppath) {
    $Items = Get-ChildItem -LiteralPath "$temppath" -Recurse
    foreach ($Item in $Items) {
        $Item.Delete()
    }
    $Items = Get-Item -LiteralPath "$temppath"
    $Items.Delete($true)
}
New-Item -Path "$PSScriptRoot" -Name "temp" -ItemType "directory" | Out-Null

## ------------------------------ ##
## Copy Inputs into Temp Folder
## ------------------------------ ##

$installcmd = 'start /w "" "%~dp0VSCodeSetup-x64-' + $vers + '.exe" /verysilent /norestart /mergetasks=!runcode'
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$PSScriptRoot\temp\Install.cmd", $installcmd, $Utf8NoBomEncoding)

$uninstallcmd = '"C:\Program Files\Microsoft VS Code\unins000.exe" /verysilent /norestart'
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$PSScriptRoot\temp\Uninstall.cmd", $uninstallcmd, $Utf8NoBomEncoding)

## ------------------------------ ##
## Download VSCode
## ------------------------------ ##

$url = "https://update.code.visualstudio.com/$vers/win32-x64/stable"
$filepath = "$temppath\VSCodeSetup-x64-$vers.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $filepath)

## ------------------------------ ##
## Build the Intunewin File
## ------------------------------ ##
$Testpath = "$buildpath\VSCodeSetup-x64-$vers.intunewin"
if (Test-Path $Testpath) {
    Remove-Item $Testpath
}

& "$PSScriptRoot\Microsoft Win32 Content Prep Tool\IntuneWinAppUtil.exe" -c "$temppath" -s "$filepath" -o "$buildpath"

## ------------------------------ ##
## Clean-Up
## ------------------------------ ##
If (Test-Path $temppath) {
    $Items = Get-ChildItem -LiteralPath "$temppath" -Recurse
    foreach ($Item in $Items) {
        $Item.Delete()
    }
    $Items = Get-Item -LiteralPath "$temppath"
    $Items.Delete($true)
}
