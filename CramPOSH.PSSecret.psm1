$DirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
$ModuleName = $PSScriptRoot.Split($DirectorySeparator)[-1]

$ManifestPath = $PSScriptRoot + $DirectorySeparator + $ModuleName + '.psd1'
$PrivatePath = $PSScriptRoot + $DirectorySeparator + 'Private'
$PublicPath = $PSScriptRoot + $DirectorySeparator + 'Public'

$Manifest = Test-ModuleManifest -Path $ManifestPath
$PrivateFiles = Get-ChildItem -Path $PrivatePath | Where-Object -Property Extension -EQ -Value '.ps1'
$PublicFiles = Get-ChildItem -Path $PublicPath | Where-Object -Property Extension -EQ -Value '.ps1'

$PrivateFiles | ForEach-Object -Process { . $_.FullName }
$PublicFiles | ForEach-Object -Process { . $_.FullName }

$Aliases = @()
$PublicFiles | ForEach-Object -Process {
    $Alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
    if ($Alias) {
        $Aliases += $Alias
        Export-ModuleMember -Function $_.BaseName -Alias $Alias
    } else {
        Export-ModuleMember -Function $_.BaseName
    }
}

$FunctionsAdded = $PublicFiles | Where-Object -Property BaseName -NotIn -Value $Manifest.ExportedFunctions.Keys
$FunctionsRemoved = $Manifest.ExportedFunctions.Keys | Where-Object -FilterScript { $_ -notin $PublicFiles.BaseName }
$AliasesAdded = $Aliases | Where-Object -FilterScript { $_ -notin $Manifest.ExportedAliases.Keys }
$AliasesRemoved = $Manifest.ExportedAliases.Keys | Where-Object -FilterScript { $_ -notin $Aliases }

if ($FunctionsAdded -or $FunctionsRemoved -or $AliasesAdded -or $AliasesRemoved) {
    try {

        $UpdateParams = @{}
        $UpdateParams.Add('Path', $ManifestPath)
        $UpdateParams.Add('ErrorAction', 'Stop')
        if ($Aliases.Count -gt 0) { $UpdateParams.Add('AliasesToExport', $Aliases) }
        if ($PublicFiles.Count -gt 0) { $UpdateParams.Add('FunctionsToExport', $PublicFiles.BaseName) }
        Update-ModuleManifest @UpdateParams

    } catch {
        $_ | Write-Error
    }
}