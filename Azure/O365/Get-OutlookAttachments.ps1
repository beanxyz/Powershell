Add-Type -assembly "Microsoft.Office.Interop.Outlook"
$o = New-Object -comobject outlook.application
$namespace = $o.GetNamespace("MAPI")
$inbox = $namespace.Folders[1].Folders.Item("TEST")

#$inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderTEST)
$filepath = "c:\test\"
$inbox.Items| foreach {
 $SendName = $_.SenderName
   $_.attachments|foreach {
    Write-Host $_.filename
    $a = $_.filename
    If ($a.Contains("pdf")) {
    $_.saveasfile((Join-Path $filepath "$a"))
   }
  }
}