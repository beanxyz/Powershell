


#$allusers=Import-Excel 'C:\temp\todolist\Epping - Email Choice_samplefor Yuan test script.xlsx' -WorksheetName 'Epping Veterinary Clinic'
#$allusers=import-excel 'C:\temp\Indooroopilly Veterinary Clinic.xlsx' -WorksheetName 'Indooroopilly Veterinary Clinic'
#$allusers=import-excel 'C:\temp\Mount Pleasant.xlsx' -WorksheetName 'Mackay Veterinary Surgery'
$all=import-excel 'C:\Temp\Vetcare Tauranga\Vetcare Tauranga.xlsx' -WorksheetName 'Email Choice'
#$allusers= import-excel 'C:\share\The Gables - Email Choice.xlsx' -WorksheetName 'the gables'
#$allusers=import-excel 'C:\Temp\Pittsworth Veterinary Surgery\Pittsworth Veterinary Surgery.xlsx' -WorksheetName 'Pittsworth Veterinary Surgery'
$masterlist=Import-Excel 'C:\temp\Master list.xlsx' -WorksheetName 'group and ad'

$all[0].Clinic

$name=$all[0].Clinic


foreach($clinic in $masterlist){

    if( $clinic.hospital -eq $name){
        $teamgroup=$clinic.TeamGroupName
        $hdgroup=$clinic.HDGroupName
        $vetgroup=$clinic.VetsGroupName
        $nursegroup=$clinic.NurseGroupName
        $pmgroup=$clinic.PMGroupName

    }

}


#Grant Manager Permission

#$manager=Get-DistributionGroup -Identity $teamgroup | select -ExpandProperty Managedby 

#if($manager -ne $null){

    #Set-DistributionGroup -Identity $hdgroup -ManagedBy @{add='X Yuan Li'} -BypassSecurityGroupManagerCheck

#}





foreach($one in $all){


    if($one.Preference -like '*ignore*'){
    
        continue
    
    }

    $companyemail=$one.CompanyEmail
    $companyemail
        
    if($companyemail -eq $null){
    
        $companyemail =''
    }


    if($companyemail -ne ''){


        if($one.Classification -like "*locum*"){ continue}
        

        
        if($one.Classification -like '*vet*'){  
        
            $names=Get-DistributionGroupMember -Identity $vetgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Host "$companyemail already exists in the $vetgroup"
            }
            else{
                Add-DistributionGroupMember -Identity $vetgroup -Member $companyemail
                }
        }

        elseif($one.Classification -like "*nurse*"){
            $names=Get-DistributionGroupMember -Identity $nursegroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Host "$companyemail already exists in the $nursegroup"
            }
            else{
                Add-DistributionGroupMember -Identity $nursegroup -Member $companyemail
                }
        }
    
        elseif($one.'Is this person the PM/HD?' -like "*PM*"){
        
            $names=Get-DistributionGroupMember -Identity $pmgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Host "$companyemail already exists in the $pmgroup"
            }
            else{

                Write-Host "Add $companyemail into $pmgroup"
                Add-DistributionGroupMember -Identity $pmgroup -Member $companyemail
                }
        }
    
        elseif($one.'Is this person the PM/HD?' -like "*HD*"){

        
            $names=Get-DistributionGroupMember -Identity $hdgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Host "$companyemail already exists in the $hdgroup"
            }
            else{

                Write-Host "Add user into hd group"
                Add-DistributionGroupMember -Identity $hdgroup -Member $companyemail
                }
        
        }
    
        else{
        
            $names=Get-DistributionGroupMember -Identity $teamgroup | select name, windowsliveid

            if ($names.windowsliveid -contains $companyemail){
            
                Write-Host "$companyemail already exists in the $teamgroup"
            }
            else{
                 Write-Host "Add $companyemail into $teamgroup"
                Add-DistributionGroupMember -Identity $teamgroup -Member $companyemail
                }
        
        
        }    
    
    }

    else{
        $name=$one.Name
        write-host "Locum users $name , ignore" -ForegroundColor Yellow
    }

}









####### Verification ###############


Get-DistributionGroupMember -Identity $nursegroup 

Get-DistributionGroupMember -Identity $pmgroup


Get-DistributionGroupMember -Identity $hdgroup


Get-DistributionGroupMember -Identity $teamgroup 

Get-DistributionGroupMember -Identity $vetgroup