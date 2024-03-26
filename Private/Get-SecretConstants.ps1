function Get-SecretConstants {
    return [PSCustomObject]@{
        CertificateNamePrefix = 'Secret Storage'
        EncryptionPadding = [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA512
    }
}