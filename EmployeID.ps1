$files=Import-Excel '.\Employee List.xlsx' -WorksheetName "Employee List" 

$result=@()


foreach ( $line in $files){
    $line

    $firstname=$line.'First Name'.Split()[0]
    $init=$firstname[0]
    $lastname=$line.Surname
    $code=$line.Code

    $sam1="$firstname.$lastname"
    $sam2="$init$lastname"
    
    $User = Get-ADUser -Filter {sAMAccountName -eq $sam1}
    If ($User -eq $Null) {
        write-host "$sam1 does not exist in AD, try $Sam2" -ForegroundColor Yellow
        $user=Get-ADUser -Filter {Samaccountname -eq $sam2}
        if ( $user -eq $null)
        {
            write-host "$sam2 does not exist in AD either" -ForegroundColor Red
            $sam='Unknown'
        
        
        }

        else{ 
            write-host "$sam2 found in AD" -ForegroundColor Cyan
            $sam=$sam2
        }
    
    }
    Else {
        write-host "$sam1 found in AD" -ForegroundColor Cyan
        $sam=$sam1
    }


   $temp=[pscustomobject]@{SamAccount=$sam;code=$code;firstname=$line.'First Name';lastname=$line.Surname;company=$line.'Payroll Company';'startdate'=$line.'Date Hired'}
   $result+=$temp

}

$result | Export-Excel c:\temp\list.xlsx



