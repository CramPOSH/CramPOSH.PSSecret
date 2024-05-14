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
        if ($null -eq $GroupName) { $GroupName = $Constants.DefaultGroupName }

        $Certificate = Get-SecretCertificate -Name $GroupName -CertificateStore $KeyStorage
        $PublicKey = $Certificate.PublicKey.Key

        $FilePath = Get-SecretFile -Name $GroupName
        $Secrets = Get-Content -Path $FilePath | ConvertFrom-Json
        if ($null -eq $Secrets) { $Secrets = [pscustomobject]@{} }
    }
    
    process {
        $ValueBytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $Counter = @{ Value = 0 }
        $ValueByteChunks = $ValueBytes | Group-Object -Property { [System.Math]::Floor($Counter.Value++ / $Constants.MaxMessageLength) }
        $ValueEncChunks = $ValueByteChunks | ForEach-Object -Process {
            $ChunkBytes = $_.Group
            $ChunkEncBytes = $PublicKey.Encrypt($ChunkBytes, $Constants.EncryptionPadding)
            $ChunkEncB64 = [System.Convert]::ToBase64String($ChunkEncBytes)
            $ChunkEncB64
        }
        if ($Secrets | Get-Member -Name $Name -MemberType NoteProperty) {
            $Secrets.$Name = $ValueEncChunks
        } else {
            $Secrets = $Secrets | Add-Member -Name $Name -MemberType NoteProperty -Value $ValueEncChunks -PassThru
        }
    }
    
    end {
        Set-Content -Path $FilePath -Value ($Secrets | ConvertTo-Json) -Force
    }
}