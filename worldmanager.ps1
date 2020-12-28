$path0='C:\temp\worldmanager\Employee Uploader (Blank).xlsx'
$path='C:\temp\worldmanager\Employee Uploader-Toowoomba Veterinary Hospital.xlsx'

#$path='C:\users\yuan.li\Downloads\tt.xlsx'
Copy-Item $path0 $path

$areas=Import-Excel $path0 -WorksheetName 'Areas and Locations'

$users=Import-Excel 'C:\Temp\Toowoomba Veterinary Hospital - Email Choice\Toowoomba Veterinary Hospital - Email Choice.xlsx' -WorksheetName 'Toowoomba Veterinary Hospital'
foreach($user in $users){
    
    if($user.Preference -like '*Ignore*'){
    
        continue
    }
        $user


    $Clinic=$user.Clinic
    $clinic

    foreach($area in $areas){
    
        if($Clinic -eq $area.'location Name'){
            $countryname=$area.'country name'
            $areaname=$area.'area name'
            $locationame=$area.'location name'
            
            #$countryname
            #$areaname
            #$locationame

            
            $fistname=$user.Firstname
            $lastname=$user.Proper

            $emailaddress=$user.Companyemail
            $username=$user.Companyemail



            $result=[pscustomobject]@{'Country Name'=$countryname;'Area Name'=$areaname;'Location Name'=$locationame;'First Name'=$fistname;'Middle name'='';'Last Name'=$lastname;'Email Address'=$emailaddress;'Position (Fulltime, Part-time, Casual)'='';'Title'='';'Nickname'='';'Start Date (DD/MM/YYYY)'='';'username'=$username;'Password'=''}







            if(($user.'Is this person the PM/HD?' -like '*HD*') -or ($user.'Are you the PM or HD?' -like '*HD*')){
                 $result | Export-Excel $path -WorksheetName 'Practice Manager  Hospital Dire' -Append
                 "HD"
            }
            if(($user.'Is this person the PM/HD?' -like '*PM*') -or ($user.'Are you the PM or HD?' -like '*PM*')){
                  $result | Export-Excel $path -WorksheetName 'Practice Manager  Hospital Dire' -Append
                  "PM"
            }




            if($user.Classification -like '*Nurse*'){
                $result | Export-Excel $path -WorksheetName 'Veterinary Nurse' -Append
                "Nurse"
                
            }

            elseif($user.Classification -like '*vet*'){
            
                 $result | Export-Excel $path -WorksheetName 'Veterinarian' -Append
                 "Vet"

            }


            else {
                $result | Export-Excel $path -WorksheetName 'Vet Clinic Team Member' -Append
                "Team"
            }









        }



    
    }

}