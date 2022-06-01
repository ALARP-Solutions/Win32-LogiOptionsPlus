$vers = '1.0.5155'
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
$tempfolder = "temp"
$temppath = "$PSScriptRoot\$tempfolder"
If (Test-Path $temppath) {
    $relocation = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    Move-Item $temppath $relocation
    Remove-Item -LiteralPath "$relocation\$tempfolder" -Recurse -Force -Confirm:$false
}
New-Item $temppath -ItemType "directory" | Out-Null

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
$Testpath = "$buildpath\LogiOptionsPlus.$vers.intunewin"
if (Test-Path $Testpath) {
    Remove-Item $Testpath
}

& "$PSScriptRoot\Microsoft Win32 Content Prep Tool\IntuneWinAppUtil.exe" -c "$temppath" -s "$filepath" -o "$buildpath"
Rename-Item -Path "$buildpath\logioptionsplus_installer.intunewin" -NewName "LogiOptionsPlus.$vers.intunewin"

## ------------------------------ ##
## Build the Detection Script
## ------------------------------ ##
$DSpath = "$buildpath\DetectionScript.$vers.ps1"
if (Test-Path $DSpath) {
    Remove-Item $DSpath
}

$detectionScript = @"
`$FileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\Program Files\LogiOptionsPlus\logioptionsplus.exe").FileVersion
#The below line trims the spaces before and after the version name
`$FileVersion = `$FileVersion.Trim();
if ([System.Version]`$FileVersion -ge [System.Version]'$vers') {
    #Write the version to STDOUT by default
    `$FileVersion
    exit 0
}
else {
    #Exit with non-zero failure code
    exit 1
}
"@
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($DSpath, $detectionScript, $Utf8NoBomEncoding)

# ## ------------------------------ ##
# ## Clean-Up
# ## ------------------------------ ##
# If (Test-Path $temppath) {
#     $Items = Get-ChildItem -LiteralPath "$temppath" -Recurse
#     foreach ($Item in $Items) {
#         $Item.Delete()
#     }
#     $Items = Get-Item -LiteralPath "$temppath"
#     $Items.Delete($true)
# }

## ------------------------------ ##
## Clean-Up - Pause here for debug
## ------------------------------ ##
If (Test-Path $temppath) {
    $relocation = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    Move-Item $temppath $relocation
    Remove-Item -LiteralPath "$relocation\$tempfolder" -Recurse -Force -Confirm:$false
}