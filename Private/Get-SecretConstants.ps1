function Get-SecretConstants {
    return [PSCustomObject]@{
        CertificateNamePrefix = 'Secret Storage'
        DefaultGroupName = 'Default'
        EncryptionPadding = [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1
        MaxMessageLength = 64
    }
}