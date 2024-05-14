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
        if ($null -eq $GroupName) { $GroupName = $Constants.DefaultGroupName }

        $PrivateKey = Get-SecretPrivateKey -Name $GroupName -CertificateStore $KeyStorage

        $FilePath = Get-SecretFile -Name $GroupName
        $Secrets = Get-Content -Path $FilePath | ConvertFrom-Json
        if ($null -eq $Secrets) { $Secrets = [pscustomobject]@{} }

        $Output = @()
    }
    
    process {
        if ($Secrets | Get-Member -Name $Name -MemberType NoteProperty) {
            $ValueEncB64 = $Secrets.$Name
            $ValueByteChunks = $ValueEncB64 | ForEach-Object -Process {
                $ChunkEncB64 = $_
                $ChunkEncBytes = [System.Convert]::FromBase64String($ChunkEncB64)
                $ChunkBytes = $PrivateKey.Decrypt($ChunkEncBytes, $Constants.EncryptionPadding)
                $ChunkBytes
            }
            $Value = [System.Text.Encoding]::UTF8.GetString($ValueByteChunks)
        } else {
            $Value = Read-Host -AsSecureString -Prompt "Please enter a new value for $Name" | ConvertFrom-SecureString
            Set-Secret -GroupName $GroupName -KeyStorage $KeyStorage -Name $Name -Value $Value
        }
        $Output += $Value
    }
    
    end {
        $Output
    }
}