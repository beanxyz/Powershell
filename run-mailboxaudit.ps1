$password = "3351976Zy" | ConvertTo-SecureString -asPlainText -Force
$username = "eddie.zhang@vet.partners"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)


$session=Get-PSSession

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session

function run(){
param ([PARAMETER(Mandatory=$TRUE,ValueFromPipeline=$FALSE)]
[string]$Mailbox,
[PARAMETER(Mandatory=$TRUE,ValueFromPipeline=$FALSE)]
[string]$StartDate,
[PARAMETER(Mandatory=$TRUE,ValueFromPipeline=$FALSE)]
[string]$EndDate,
[PARAMETER(Mandatory=$FALSE,ValueFromPipeline=$FALSE)]
[string]$Subject,
[PARAMETER(Mandatory=$False,ValueFromPipeline=$FALSE)]
[switch]$IncludeFolderBind,
[PARAMETER(Mandatory=$False,ValueFromPipeline=$FALSE)]
[switch]$ReturnObject)
BEGIN {
  [string[]]$LogParameters = @('Operation', 'LogonUserDisplayName', 'LastAccessed', 'DestFolderPathName', 'FolderPathName', 'ClientInfoString', 'ClientIPAddress', 'ClientMachineName', 'ClientProcessName', 'ClientVersion', 'LogonType', 'MailboxResolvedOwnerName', 'OperationResult')
  }
  END {
    if ($ReturnObject)
    {return $SearchResults}
    elseif ($SearchResults.count -gt 0)
    {
    $Date = get-date -Format yyMMdd_HHmmss
    $OutFileName = "AuditLogResults$Date.csv"
    write-host
    write-host -fore green 'Posting results to file: $OutfileName'
    $SearchResults | export-csv $OutFileName -notypeinformation -encoding UTF8
    }
    }
    PROCESS
    {
    write-host -fore green 'Searching Mailbox Audit Logs...'
    $SearchResults = @(search-mailboxAuditLog $Mailbox -StartDate $StartDate -EndDate $EndDate -LogonTypes Owner, Admin, Delegate -ShowDetails -resultsize 50000)
    write-host -fore green '$($SearchREsults.Count) Total entries Found'
    if (-not $IncludeFolderBind)
    {
    write-host -fore green 'Removing FolderBind operations.'
    $SearchResults = @($SearchResults | ? {$_.Operation -notlike 'FolderBind'})
    write-host -fore green 'Filtered to $($SearchREsults.Count) Entries'
    }
    $SearchResults = @($SearchResults | select ($LogParameters + @{Name='Subject';e={if (($_.SourceItems.Count -eq 0) -or ($_.SourceItems.Count -eq $null)){$_.ItemSubject} else {($_.SourceItems[0].SourceItemSubject).TrimStart(' ')}}},
    @{Name='CrossMailboxOp';e={if (@('SendAs','Create','Update') -contains $_.Operation) {'N/A'} else {$_.CrossMailboxOperation}}}))
    $LogParameters = @('Subject') + $LogParameters + @('CrossMailboxOp')
    If ($Subject -ne '' -and $Subject -ne $null)
    {
    write-host -fore green 'Searching for Subject: $Subject'
    $SearchResults = @($SearchResults | ? {$_.Subject -match $Subject -or $_.Subject -eq $Subject})
    write-host -fore green 'Filtered to $($SearchREsults.Count) Entries'
    }
    $SearchResults = @($SearchResults | select $LogParameters)
    }

    }



    run -IncludeFolderBind -StartDate 04/14/2020 -EndDate 04/24/2020 -Mailbox jessy.lukose@vetpartners.com.au