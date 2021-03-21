Write-host $PSScriptRoot
Echo "v5"

function DownloadFilesFromRepo {
#Param(
    $Owner= 'nmpereira'
    $Repository='PowerShellTest'
    $Path= 'Test1.ps1'
    $DestinationPath= 'C:\Gitpersonal\testcode'
    $script:scriptpath = join-path $DestinationPath -childpath $Path
    $script:DestinationPathexe = join-path $DestinationPath -childpath 'Test1.exe'
    #)

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args+'?access_token=b498b0407dde53d232f344d5a37b09f3a971b1c2')
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        } catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}

(DownloadFilesFromRepo)
start-sleep 5
taskkill /IM Test1.EXE /F
& "$PSScriptRoot\ps2execonvert.ps1"
#invoke-ps2exe -inputfile $scriptpath -outputfile $DestinationPathexe
#Start-Process -FilePath "Test1.exe"

pause
