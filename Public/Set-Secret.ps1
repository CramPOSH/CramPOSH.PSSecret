function Set-Secret {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Value,

        [Parameter()]
        [string] $GroupName = $null,

        [Parameter()]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string] $KeyStorage = 'CurrentUser'
    )
    
    begin {
        $Constants = Get-SecretConstants
        $GroupName = $GroupName ? $GroupName : $Constants.DefaultGroupName

        $Certificate = Get-SecretCertificate -Name $GroupName -CertificateStore $KeyStorage
        $PublicKey = $Certificate.PublicKey.GetRSAPublicKey()

        $FilePath = Get-SecretFile -Name $GroupName
        $Secrets = Get-Content -Path $FilePath | ConvertFrom-Json -AsHashtable -Depth 1
        if ($null -eq $Secrets) { $Secrets = @{} }
    }
    
    process {
        $ValueBytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $ValueEncBytes = $PublicKey.Encrypt($ValueBytes, $Constants.EncryptionPadding)
        $ValueEncB64 = [System.Convert]::ToBase64String($ValueEncBytes)
        $Secrets[$Name] = $ValueEncB64
    }
    
    end {
        Set-Content -Path $FilePath -Value ($Secrets | ConvertTo-Json -Depth 1) -Force
    }
}