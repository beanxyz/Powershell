new-item \\sydittest\temp\jre8.exe -force
copy-item C:\test\jre8.exe \\sydittest\c$\temp\jre8.exe | out-null
invoke-Command -ComputerName sydittest -ScriptBlock { Start-Process -filepath "c:\temp\jre8.exe" -argumentlist "/s /L c:\temp\install.txt" -Verb runas -PassThru -Wait }


#Configure LCM in the Client 
[DSCLocalConfigurationManager()]
Configuration LCM_Push 
{
	Node s1
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Push'
                        	
		}
	}
}

LCM_Push -ComputerName s1 -OutputPath C:\DSC\Mod5Config

Set-DSCLocalConfigurationManager -ComputerName s1 -Path c:\DSC\mod5Config –Verbose

#Copy Java.msi and install
configuration Testmsi {

    Node sydittest {

     File MSIFile {
            Ensure = "Present" 
            Type = "Directory“ # Default is “File”
            Force = $True
            Recurse = $True
            SourcePath = '\\sydit01\test2'
            DestinationPath = 'C:\Downloads'  # On Sydittest
        }


     Package InstallJava {
            Ensure = "Present" 
            Name='Java 8 Update 71 (64-bit)'
            path='c:\downloads\jre1.8.0_71.msi'
            productid="26A24AE4-039D-4CA4-87B4-2F86418071F0"
            dependson='[file]msifile'
        }



    }




}

Testmsi -OutputPath c:\temp\nscpconfig
Start-DscConfiguration -computername sydittest -Path c:\temp\nscpConfig -Wait -Verbose -force



