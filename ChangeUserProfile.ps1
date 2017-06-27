function New-Symlink {
    <#
    .SYNOPSIS
        Creates a symbolic link.
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target
    )

    Invoke-MKLINK -Link $Link -Target $Target -Symlink
}


function New-Hardlink {
    <#
    .SYNOPSIS
        Creates a hard link.
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target
    )

    Invoke-MKLINK -Link $Link -Target $Target -HardLink
}


function New-Junction {
    <#
    .SYNOPSIS
        Creates a directory junction.
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target
    )

    Invoke-MKLINK -Link $Link -Target $Target -Junction
}


function Invoke-MKLINK {
    <#
    .SYNOPSIS
        Creates a symbolic link, hard link, or directory junction.
    #>
    [CmdletBinding(DefaultParameterSetName = "Symlink")]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target,

        [Parameter(ParameterSetName = "Symlink")]
        [switch] $Symlink = $true,
        [Parameter(ParameterSetName = "HardLink")]
        [switch] $HardLink,
        [Parameter(ParameterSetName = "Junction")]
        [switch] $Junction
    )

    # Ensure target exists.
    if (-not(Test-Path $Target)) {
        throw "Target does not exist.`nTarget: $Target"
    }

    # Ensure link does not exist.
    if (Test-Path $Link) {
        throw "A file or directory already exists at the link path.`nLink: $Link"
    }

    $isDirectory = (Get-Item $Target).PSIsContainer
    $mklinkArg = ""

    if ($Symlink -and $isDirectory) {
        $mkLinkArg = "/D"
    }

    if ($Junction) {
        # Ensure we are linking a directory. (Junctions don't work for files.)
        if (-not($isDirectory)) {
            throw "The target is a file. Junctions cannot be created for files.`nTarget: $Target"
        }

        $mklinkArg = "/J"
    }

    if ($HardLink) {
        # Ensure we are linking a file. (Hard links don't work for directories.)
        if ($isDirectory) {
            throw "The target is a directory. Hard links cannot be created for directories.`nTarget: $Target"
        }

        $mkLinkArg = "/H"
    }

    # Capture the MKLINK output so we can return it properly.
    # Includes a redirect of STDERR to STDOUT so we can capture it as well.
    $output = cmd /c mklink $mkLinkArg `"$Link`" `"$Target`" 2>&1

    if ($lastExitCode -ne 0) {
        throw "MKLINK failed. Exit code: $lastExitCode`n$output"
    }
    else {
        Write-Output $output
    }
}



$flag=$true

while($flag){


    $oldName=read-host "Please input the old user name"

    write-host 'Searching user profile..' -ForegroundColor Cyan


    if (Test-Path "c:\users\$oldName"){

        write-host "User Profile c:\users\$oldName found." -ForegroundColor Cyan

        #Check if the user is currently logged In

        $quser = (quser) -replace '\s{2,17}', ',' | ConvertFrom-Csv

        $sessionId = $quser | Where-Object { $_.Username -eq $newName } | select -ExpandProperty id

        

        foreach($id in $sessionId){
            if($id -ne $null){
                write-host "Detected User $newName still login" -ForegroundColor red
                Write-Host "Force logoff the user" -ForegroundColor red
                logoff $id
            }
        
        }
       




        $newName=read-host "Please input the new name"


        $oldpath="c:\users\$oldName"
        $newpath="c:\users\$newName"

        rename-item $oldpath $newpath -Confirm -ErrorAction Stop

        write-host "Searching Registry Information " -ForegroundColor Cyan

        Get-ChildItem "hklm:\software\microsoft\windows nt\currentversion\profilelist" | foreach{
            #Get the username from SID
            $sid=$_.Name.Split('\')[-1];
            try{
            $objSID = New-Object System.Security.Principal.SecurityIdentifier ($sid)
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount]) 
            $username=$objUser.Value
            }
            catch{}

            #change registry keys
            if(($username -eq "omnicom\$oldName") -or ($username -eq "omnicom\$newName")){
                write-host "Found Registry Information of user profile $newName" -ForegroundColor Cyan

                $keys=Get-ItemProperty "hklm:\software\microsoft\windows nt\currentversion\profilelist\$sid" 
                $keys.ProfileImagePath=$newpath

                write-host "Registry key profile list is changed to $newpath" -ForegroundColor Cyan
                
                
                #Create new symbolink
                #New-Item -Path $oldpath -ItemType Junction -Value $newpath
                New-Symlink -Link $oldpath -Target $newpath

                
                break;

            }
            else{
                write-host "$username Name not match...skip" -ForegroundColor Yellow
            
            }



        
        }




        $flag=$false
        
    }

    else {

        write-host "Profile is not found. Please try again" -ForegroundColor red
    }

} 
