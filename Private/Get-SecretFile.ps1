function Get-SecretFile {
    
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Name = $null
    )
    
    begin {
        $DirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
        if ($null -eq $Name) { $Name = 'Default' }
        
        $RootPath = $env:LOCALAPPDATA + $DirectorySeparator + 'PSSecrets'
        if (-not (Test-Path -Path $RootPath -PathType Container)) { New-Item -Path $RootPath -ItemType Directory -Force | Out-Null }

        $FilePath = $RootPath + $DirectorySeparator + $Name + '.json'
        if (-not (Test-Path -Path $FilePath -PathType Leaf)) { [PSCustomObject]@{} | ConvertTo-Json -Depth 100 | Out-File -FilePath $FilePath -Force }
    }
    
    process {
        
    }
    
    end {
        return $FilePath
    }
}