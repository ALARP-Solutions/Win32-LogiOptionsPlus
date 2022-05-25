
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

$installcmd = 'start /w "" "%~dp0logioptionsplus_installer.exe" /quiet /flow No /update No /sso No /analytics No'
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$PSScriptRoot\temp\Install.cmd", $installcmd, $Utf8NoBomEncoding)

$uninstallcmd = 'start /w "" "%~dp0logioptionsplus_installer.exe" /uninstall'
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$PSScriptRoot\temp\Uninstall.cmd", $uninstallcmd, $Utf8NoBomEncoding)

## ------------------------------ ##
## Download Logitech Options Plus
## ------------------------------ ##

$url = "https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.exe"
$filepath = "$temppath\logioptionsplus_installer.exe"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $filepath)

## ------------------------------ ##
## Build the Intunewin File
## ------------------------------ ##
$Testpath = "$buildpath\logioptionsplus_installer.intunewin"
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
