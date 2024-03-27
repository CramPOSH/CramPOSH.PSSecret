function Clear-Secret {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Single', ValueFromPipeline)]
        [string] $Name,

        [Parameter(ParameterSetName = 'Group')]
        [switch] $File,

        [Parameter(ParameterSetName = 'Group')]
        [switch] $Certificate,

        [Parameter(ParameterSetName = 'Single')]
        [Parameter(ParameterSetName = 'Group')]
        [string] $GroupName = $null,

        [Parameter(ParameterSetName = 'Single')]
        [Parameter(ParameterSetName = 'Group')]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string] $KeyStorage = 'CurrentUser'
    )
    
    begin {
        $Constants = Get-SecretConstants
        $GroupName = $GroupName ? $GroupName : $Constants.DefaultGroupName
        
        $TheCertificate = Get-SecretCertificate -Name $GroupName -CertificateStore $KeyStorage
        $FilePath = Get-SecretFile -Name $GroupName
        $Secrets = Get-Content -Path $FilePath | ConvertFrom-Json -AsHashtable -Depth 1
        if ($null -eq $Secrets) { $Secrets = @{} }
    }
    
    process {
        if ($Name) {
            $Secrets.Remove($Name)
        }
    }
    
    end {
        if ($Name) {
            Set-Content -Path $FilePath -Value ($Secrets | ConvertTo-Json -Depth 1) -Force
        }
        if ($File) {
            Remove-Item -Path $FilePath -Force -Confirm:$false
        }
        if ($Certificate) {
            Remove-Item -Path $TheCertificate.PSPath -Force -Confirm:$false
        }
    }
}