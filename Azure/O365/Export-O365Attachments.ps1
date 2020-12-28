Function New-OSCEXOSearchFolder
{
	#.EXTERNALHELP New-OSCEXOSearchFolder-Help.xml

	[cmdletbinding()]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$false,Position=1)]
        [ValidateSet("Inbox","SentItems","DeletedItems")]
		[string]$WellKnownFolderName="Inbox",		
		[Parameter(Mandatory=$false,Position=2)]
		[datetime]$StartDate=(Get-Date).AddDays(-30),
		[Parameter(Mandatory=$false,Position=3)]
		[datetime]$EndDate=(Get-Date),
		[Parameter(Mandatory=$false,Position=4)]
		[string]$Subject,
		[Parameter(Mandatory=$false,Position=5)]
		[string]$From,
		[Parameter(Mandatory=$false,Position=6)]
		[string]$DisplayTo,
		[Parameter(Mandatory=$false,Position=7)]
		[string]$DisplayCc,
		[Parameter(Mandatory=$false,Position=8)]
		[int]$PageSize=100,
		[Parameter(Mandatory=$false,Position=9)]
		[Microsoft.Exchange.WebServices.Data.SearchFolderTraversal]$Traversal="Shallow",
		[Parameter(Mandatory=$false,Position=10)]
		[string]$DisplayName=(Get-Date)
	)
	Begin
	{
        #Verify the existence of exchange service object
        if ($exService -eq $null) {
			$errorMsg = $Messages.RequireConnection
			$customError = New-OSCPSCustomErrorRecord `
			-ExceptionString $errorMsg `
			-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $PSCmdlet
			$PSCmdlet.ThrowTerminatingError($customError)
        }
	}
	Process
	{   
        #Define base property sets that are used as the base for custom property sets.
        $folderPropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(`
                       		 [Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly,`
                       		 [Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,`
					   		 [Microsoft.Exchange.WebServices.Data.FolderSchema]::ChildFolderCount)
							 
        $itemPropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(`
                       	   [Microsoft.Exchange.WebServices.Data.BasePropertySet]::IdOnly,`
						   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ItemClass,`
                       	   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::Subject,`
					   	   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DateTimeReceived,`
                           [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::From,`
					   	   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DisplayTo,`
						   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DisplayCc)
						   
		#Define FolderView and ItemView
		$folderView = New-Object Microsoft.Exchange.WebServices.Data.FolderView($PageSize)
		$folderView.PropertySet = $folderPropertySet
		$itemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView($PageSize)
		$itemView.PropertySet = $itemPropertySet
               
        #Prepare search filter for searching emails
        $searchFilterCollection = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+SearchFilterCollection(`
                                  [Microsoft.Exchange.WebServices.Data.LogicalOperator]::And)
		$startDateFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsGreaterThanOrEqualTo(`
						   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DateTimeCreated,$StartDate)
		$endDateFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsLessThanOrEqualTo(`
						 [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DateTimeCreated,$endDate)
		$itemClassFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo(`
						   [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::ItemClass,"IPM.Note")						 
		$searchFilterCollection.Add($startDateFilter)
		$searchFilterCollection.Add($endDateFilter)
		$searchFilterCollection.Add($itemClassFilter)
		
        if (-not [System.String]::IsNullOrEmpty($Subject)) {
            $subjectFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+ContainsSubString(`
                             [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::Subject,$Subject)  
            $searchFilterCollection.Add($subjectFilter)
        }

        if (-not [System.String]::IsNullOrEmpty($From)) {
            $fromFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+ContainsSubString(`
                             [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::From,$From)  
            $searchFilterCollection.Add($fromFilter)
        }

        if (-not [System.String]::IsNullOrEmpty($DisplayTo)) {
            $displayToFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+ContainsSubString(`
                             [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DisplayTo,$DisplayTo)  
            $searchFilterCollection.Add($displayToFilter)
        }

        if (-not [System.String]::IsNullOrEmpty($DisplayCc)) {
            $displayCcFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+ContainsSubString(`
                             [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::DisplayCc,$DisplayCc)  
            $searchFilterCollection.Add($displayCcFilter)
        }

        $folderID = New-Object Microsoft.Exchange.WebServices.Data.FolderId(`
                    [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::$WellKnownFolderName)
		
        Try
        {
            #Create a new search folder
            $searchFolder = New-Object Microsoft.Exchange.WebServices.Data.SearchFolder($exService)
            $searchFolder.SearchParameters.RootFolderIds.Add($folderID) | Out-Null
            $searchFolder.SearchParameters.Traversal = [Microsoft.Exchange.WebServices.Data.SearchFolderTraversal]::$Traversal
            $searchFolder.SearchParameters.SearchFilter = $searchFilterCollection
            $searchFolder.DisplayName = $DisplayName
            $searchFolder.Save([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::SearchFolders)

            #Return the newly created search folder
            return $searchFolder
        }
        Catch
        {
            $PSCmdlet.WriteError($_)
            return $null
        }
	}
	End {}
}

Function Get-OSCEXOSearchFolder
{
	#.EXTERNALHELP Get-OSCEXOSearchFolder-Help.xml

	[cmdletbinding()]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$true,Position=1)]
		[string]$DisplayName
	)
	Begin
	{
        #Verify the existence of exchange service object
        if ($exService -eq $null) {
			$errorMsg = $Messages.RequireConnection
			$customError = New-OSCPSCustomErrorRecord `
			-ExceptionString $errorMsg `
			-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $PSCmdlet
			$PSCmdlet.ThrowTerminatingError($customError)
        }
	}
	Process
	{   
        #Define the view settings in a folder search operation.
        $folderView = New-Object Microsoft.Exchange.WebServices.Data.FolderView(100)

        #Bind Default Search Folders
        $rootSearchFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind(`
                            $exService,[Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::SearchFolders)
        
        #Prepare search filter to find folder with specific display name
        $searchFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo(`
						[Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,$DisplayName)
        
        #Begin to find folders
        do
        {
            $findResults = $rootSearchFolder.FindFolders($searchFilter,$folderView)
        } while ($findResults.MoreAvailable)

        #Return search folder
        if ($findResults.TotalCount -ne 0) {
            $searchFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind(`
                            $exService,$findResults.Id)
            return $searchFolder
        } else {
            return $null
        }
	}
	End {}
}

Function Export-OSCEXOEmailAttachment
{
    [cmdletbinding()]
    Param
    (
        #Define parameters
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
        [Microsoft.Exchange.WebServices.Data.SearchFolder]$SearchFolder,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$Path,
        [Parameter(Mandatory=$false,Position=3)]
        [int]$PageSize=100,
        [Parameter(Mandatory=$false)]
        [switch]$AllowOverwrite,
        [Parameter(Mandatory=$false)]
        [switch]$KeepSearchFolder
    )
    Begin
    {
        #Verify the existence of exchange service object
        #This bit of code (removed) 
        #validates that variable $exService is initialised


        #Load necessary properties for email messages
        #Not certain what this is for. Does this indicate which particular properties are loaded?
        $itemPropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(`
                           [Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties,
                           [Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::MimeContent)

        #Load properties for attachments. Do we need to do this to get Mime.Content??
        $attachmentPropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(`
                           [Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties,
                           [Microsoft.Exchange.WebServices.Data.Attachment]::MimeContent)

    }
    Process
    {
        #Define the view settings in a folder search operation.
        $itemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView($PageSize)

        #Iterate each item in the search folder
        #Iterate each item in the search folder
do
{
    $findResults = $SearchFolder.FindItems($itemView)
    foreach ($findResult in $findResults) {
        #Bind each email with a small set of PropertySet
        $emailMsg = [Microsoft.Exchange.WebServices.Data.EmailMessage]::Bind($exService,$findResult.Id)
        $emailMsg.Load()

        # Iterate through attachments inside email
        foreach ($attachment in $emailMsg.Attachments) {
            $ext = [System.IO.Path]::GetExtension($attachment.Name)

            if($ext -eq ".pdf") {
              $attachment.Load()
              $exportPath=$Path + "\" + $attachment.Name
              Write-Host $exportPath

              #Export attachment
              Try
              {
                 $file = New-Object System.IO.FileStream($exportPath,[System.IO.FileMode]::Create)
                 $file.Write($attachment.Content,0,$attachment.Content.Length)
                 $file.Close()
              }
              Catch
              {
                 $PSCmdlet.WriteError($_)
              }
           }
        }


    }

    # Once we've gone through this page of items, go to the next page
    $itemView.Offset += $PageSize
} while ($findResults.MoreAvailable)
    }
    

    }