function Get-SecretCertificate {
    
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Name = $null,

        [Parameter()]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string] $CertificateStore = 'CurrentUser'
    )
    
    begin {
        $Constants = Get-SecretConstants
        if ($null -eq $Name) { $Name = 'Default' }
        $CertificateName = [string]::Format('{0} - {1}', $Constants.CertificateNamePrefix, $Name)
    }
    
    process {
        $Certificate = Get-ChildItem -Path "Cert:\$CertificateStore\My" | Where-Object -Property FriendlyName -EQ -Value $CertificateName
        if (-not $Certificate) {
            $CertificateParams = @{
                CertStoreLocation = "Cert:\$CertificateStore\My"
                Type = 'Custom'
                Subject = $CertificateName
                FriendlyName = $CertificateName
                KeyFriendlyName = $CertificateName
                KeyAlgorithm = 'RSA'
                KeyLength = 2048
                KeyExportPolicy = 'Exportable'
                NotAfter = (Get-Date).AddYears(5)
            }
            $Certificate = New-SelfSignedCertificate @CertificateParams
        }
        return $Certificate
    }
    
    end {
        
    }
}