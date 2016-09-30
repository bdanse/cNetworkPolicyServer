# cNetworkPolicyServer
This repository contains the **cNetworkPolicyServer** Powershell module, containing Microsoft Windows PowerShell Desired State Configuration (DSC) resources to monitor and import a Network Policy Server (NPS) configuration file.

## Resources
* **ESNAD_cNpsConfiguration** Works best in conjunction with xRemoteFile to monitor a NPS configuration. (For example if you use RDG/MFA)

### ESNAD_cNpsConfiguration
* **ConfigurationFile** Location of the 'baseline' file.

## Examples
```powershell
xRemoteFile GetRdgConfig
{
	Uri = 'https://storageaccountname.blob.core.windows.net/scripts/rdgconfig.xml'
        DestinationPath = 'c:\windows\temp\reference.xml'
        MatchSource = $true
}

ESNAD_cCapStore SetCentralCAP
       {
        CentralCAPEnabled = 1
        RequestSOH = 1
        NpsConfigurationFile = 'C:\windows\temp\reference.xml'
        #DependsOn = '[xRemoteFile]GetRdgConfig'
}

ESNAD_cNpsConfiguration SetNPSConfiguration
{
        ConfigurationFile = 'c:\windows\temp\reference.xml'
        DependsOn = '[xRemoteFile]GetRdgConfig'
}
Sample_Set_NPS_Configuration
```