[System.IO.File]::WriteAllText(
        'C:\scripts\groups.txt',
        ([System.IO.File]::ReadAllText('C:\scripts\groups.txt') -replace '\s')
    )