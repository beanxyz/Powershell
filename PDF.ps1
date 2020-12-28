$pdffiles = Get-ChildItem c:\test\*.pdf

foreach ($file in $pdffiles) {
    
    Write-Host $file.Name
    pdftk $file.Name burst output $file"page-%02d.pdf"
    
}

