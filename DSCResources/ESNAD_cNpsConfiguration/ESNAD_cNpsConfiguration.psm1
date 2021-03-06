# Load the Helper Module
Import-Module -Name "$PSScriptRoot\..\Helper.psm1" -Verbose:$false

data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
VerboseTestTargetConfigurationNoMatch = Reference configuration does not match the current configuration.
VerboseTestTargetTrueResult = The target resource is already in the desired state. No action is required. 
VerboseTestTargetFalseResult = The target resource is not in the desired state. 
VerboseSetTargetNpsConfiguration = Imported reference configuration.
'@

}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigurationFile
    )

    $returnValue = @{
        ConfigurationFile = [System.String](Compare-NpsConfiguration -NpsConfigurationFile $ConfigurationFile)
    }
    
    return $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigurationFile
    )

    Import-NpsConfiguration -Path $ConfigurationFile
    Write-Verbose -Message ($LocalizedData.VerboseSetTargetNpsConfiguration)
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigurationFile
    )

    $InDesiredState = $true
    $targetResource = Get-TargetResource @PSBoundParameters
    
    if($targetResource.ConfigurationFile -eq $false)
    {
        $InDesiredState = $false
    }

    if ($InDesiredState -eq $true) 
    { 
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetTrueResult) 
    } 
    else 
    { 
        Write-Verbose -Message ($LocalizedData.VerboseTestTargetFalseResult) 
    } 
    return $InDesiredState 
}

Function Compare-NpsConfiguration
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $NpsConfigurationFile
    )
    
    $path = $env:windir + '\temp'
    $currentNpsConfig = $path + "\" + "current.xml"
    Export-NpsConfiguration -Path $currentNpsConfig
    $compare = Compare-Object -ReferenceObject (Get-Content -Path $NpsConfigurationFile) `
                              -DifferenceObject (Get-Content -Path $currentNpsConfig)
    Remove-Item -path $currentNpsConfig -Force -Confirm:$false -ErrorAction SilentlyContinue
    if (($compare | ?{$_ -notmatch '<SystemInfo ProcessorArchitecture=*'}) -eq $null)
    {
        return $true
    }
    else
    {
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource

