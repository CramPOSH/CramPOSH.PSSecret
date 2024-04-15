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
        $Secrets = Get-Content -Path $FilePath | ConvertFrom-Json -AsHashtable -Depth 100
        if ($null -eq $Secrets) { $Secrets = @{} }
    }
    
    process {
        $ValueBytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $Counter = @{ Value = 0 }
        $ValueByteChunks = $ValueBytes | Group-Object -Property { [System.Math]::Floor($Counter.Value++ / $Constants.MaxMessageLength) }
        $ValueEncChunks = $ValueByteChunks | ForEach-Object -Process {
            $ChunkBytes = $_.Group
            Write-Host $ChunkBytes.Count
            $ChunkEncBytes = $PublicKey.Encrypt($ChunkBytes, $Constants.EncryptionPadding)
            $ChunkEncB64 = [System.Convert]::ToBase64String($ChunkEncBytes)
            $ChunkEncB64
        }
        $Secrets[$Name] = $ValueEncChunks
    }
    
    end {
        Set-Content -Path $FilePath -Value ($Secrets | ConvertTo-Json -Depth 1) -Force
    }
}