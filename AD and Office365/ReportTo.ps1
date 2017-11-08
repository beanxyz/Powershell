$userlists=Import-Excel 'C:\users\yli\Desktop\DDB Org Chart.xlsx'

foreach($user in $userlists){
    
    $name = $user.'Name  Surname'
    $manager=$user.'Reports to'
    $managerSamName=get-aduser -Filter {name -like $manager} | select -ExpandProperty samaccountName
    #$manager
    get-aduser -filter { name -like $name} | set-aduser -Manager $managerSamName -PassThru | get-aduser -Properties title, manager 

}




