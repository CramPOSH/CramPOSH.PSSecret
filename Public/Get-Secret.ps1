function Get-Secret {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position=1)]
        [string] $Name,

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
        $PrivateKey = $Certificate.PrivateKey

        $FilePath = Get-SecretFile -Name $GroupName
        $Secrets = Get-Content -Path $FilePath | ConvertFrom-Json -AsHashtable -Depth 1
        if ($null -eq $Secrets) { $Secrets = @{} }

        $Output = @{}
    }
    
    process {
        $ValueEncB64 = $Secrets[$Name]
        if ($ValueEncB64) {
            $ValueEncBytes = [System.Convert]::FromBase64String($ValueEncB64)
            $ValueBytes = $PrivateKey.Decrypt($ValueEncBytes, $Constants.EncryptionPadding)
            $Value = [System.Text.Encoding]::UTF8.GetString($ValueBytes)
        } else {
            $Value = Read-Host -AsSecureString -Prompt "Please enter a new value for $Name" | ConvertFrom-SecureString -AsPlainText
            Set-Secret -GroupName $GroupName -KeyStorage $KeyStorage -Name $Name -Value $Value
        }
        $Output[$Name] = $Value
    }
    
    end {
        $Output
    }
}