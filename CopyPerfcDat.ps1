$computers=Get-ADComputer -Filter {operatingsystem -like "*windows*"}

foreach($computer in $computers){
    $name=$computer.name
    $url="\\$name\c$\windows"
    $file="$url\perfc.dat"

    if(Test-Connection $computer.name -Quiet -Count 1){
    
    }
    else{
        write-host "$name is disconnected" -ForegroundColor red 
        continue;
    }

    if (Test-Path $file){
        Write-Host "$file is already copied" -ForegroundColor Cyan
    }
    else{
        copy C:\temp\perfc.dat $url -ErrorAction SilentlyContinue -ErrorVariable aa

    }
    
    

}

Write-Host $aa.targetObject