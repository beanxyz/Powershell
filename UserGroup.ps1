
Write-Host "Delete old record..."

Remove-Item c:\temp\user1.txt -ErrorAction SilentlyContinue
Remove-Item c:\temp\user2.txt -ErrorAction SilentlyContinue
remove-item C:\temp\result.xlsx -ErrorAction SilentlyContinue

Write-Host "Import Excel file.." -ForegroundColor Cyan
$all=Import-Excel 'C:\temp\Nurses and Other.xlsx'


Write-Host "Connect to Office365..." -ForegroundColor Cyan
#Connect to Office365

$session=Get-PSSession

if($session.ComputerName -like "outlook.office365*"){
    Write-Host "Outlook.Office365.com session is connected" -ForegroundColor Cyan
}
else{

#    Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
#    $EXOSession = New-ExoPSSession
#    Import-PSSession $EXOSession

#    Connect-MsolService


    $CreateEXOPSSession = (Get-ChildItem -Path $env:userprofile -Filter CreateExoPSSession.ps1 -Recurse -ErrorAction SilentlyContinue -Force | Select -Last 1).DirectoryName
. "$CreateEXOPSSession\CreateExoPSSession.ps1"
    Connect-EXOPSSession
}



foreach($user in $all){

    $firstname=$user."preferred name"
    $lastname=$user.surname
    $name=$firstname+" "+$lastname
    #$name



    $group=$user.group

    $result=Get-ADUser -Filter {name -eq $name}

if($result -eq $null){

    Write-Host "$name is not found in AD" -ForegroundColor Red
    "$name" | out-file c:\temp\user1.txt -Append 

    $user | Export-Excel -WorksheetName "NotInAD" -Path c:\temp\result.xlsx -Append

}
else
{
    
    
 

    #Write-Host "Check membership.."
    if($group -ne $null){
        $members=Get-DistributionGroupMember -Identity $group | select -ExpandProperty name
      }
    else{
            write-host "$name has empty group colume" -ForegroundColor Green
          $user | Export-Excel -WorksheetName "Empty Group" -Path c:\temp\result.xlsx -Append
            continue
    }


    if($members -like "$name*")
    {
        write-host "$name is already added to $group" -ForegroundColor Yellow
        $user | Export-Excel -WorksheetName "Added" -Path c:\temp\result.xlsx -Append
    }

    else

    {
        $group=$user.Group
       
        Write-Host "Adding $name to group $group"


  
    try{
                
        Add-DistributionGroupMember -identity $group -member $name -ErrorAction stop
        Write-Host "$name is added into $group" -ForegroundColor Cyan
            $user | Export-Excel -WorksheetName "Added" -Path c:\temp\result.xlsx -Append
    }catch{

    #$error[0]
        "$name --------> $group"| Out-File c:\temp\user2.txt -Append
        $user | Export-Excel -WorksheetName "Otherfailure" -Path c:\temp\result.xlsx -Append
        
    }
        
        
        
        
       
    }

   
}

}

"-------------Summary------------- "
$total=$all | measure | select -ExpandProperty count

"Total user number: "+$total

$noinad=gc C:\temp\user1.txt | measure | select -ExpandProperty count
$noadd=gc C:\temp\user2.txt | measure | select -ExpandProperty count

"Not in AD number: "+$noinad
"Other failure number: "+$noadd