

$Url = "https://10.2.1.18/admin/login.jsp”
$Username=”admin”
$Password=”Adv#rtis3th!S”


$IE = New-Object -com internetexplorer.application;
$IE.visible = $true;
$IE.navigate($url);

# Wait a few seconds and then launch the executable.

while ($IE.Busy -eq $true)
{
    Start-Sleep -s 2;
}

#
if($IE.Document.url -match "invalidcert"){
    Write-Host "Bypass SSL Error Page" -ForegroundColor Cyan
    $link=$IE.Document.getElementsByTagName('A') | Where-Object{$_.id -eq 'overridelink'} 
    Write-Host "Loading Login page "
    $link.click()
    Start-Sleep -s 10
}

$IE.Document.getElementById(“dijit_form_TextBox_0”).value = $Username
$IE.Document.getElementByID(“dijit_form_TextBox_1”).value=$Password
$IE.Document.getElementById(“loginPage_loginSubmit_label”).Click()


while ($IE.Busy -eq $true)

{
Start-Sleep -s 2;
}

