function Get-SecretPrivateKey {
    
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Name = $null,

        [Parameter()]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string] $CertificateStore = 'CurrentUser'
    )
    
    begin {
        if ($null -eq $Name) { $Name = 'Default' }
        $Certificate = Get-SecretCertificate -Name $Name -CertificateStore $CertificateStore
    }
    
    process {
        if ($Certificate.HasPrivateKey -and $Certificate.PrivateKey) {
            return $Certificate.PrivateKey
        }

        $RSAPrivateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate)
        return $RSAPrivateKey
    }
    
    end {
        
    }
}