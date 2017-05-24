#Set-UserPhoto "yuan li" -PictureData([system.io.file]::ReadAllBytes("C:\users\yli\Desktop\baby.jpg")) 
#$UserCredential = Get-Credential 

#Connect-MsolService -Credential $UserCredential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import-PSSession $Session



$objs=get-childitem C:\users\yli\Desktop\Images\Images


foreach($obj in $objs){


 $username=$obj.name.Split('.')[0]

 #get-aduser -Filter{ name -eq $username} 

 $path=$obj.FullName

 #write-host 'Upload photo to '$username "from "$path -ForegroundColor Cyan
 #Set-UserPhoto $username -PictureData([system.io.file]::ReadAllBytes($path)) -Confirm:$false 
 Write-Host 'remove photo from '$username
 Remove-UserPhoto -Identity $username -Confirm:$false
}
