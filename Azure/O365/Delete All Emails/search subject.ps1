
Get-MessageTrace -StartDate $dateStart -EndDate $dateEnd -Page $c | Where {$_.Subject -like "*example*"} | ft -Wrap

Get-MessageTrace -StartDate 03/09/2018 -EndDate 03/09/2018 | Where {$_.Subject -like "*New Contract James Wright*"} | ft -Wrap