$DirectorySeparator = [System.IO.Path]::DirectorySeparatorChar

$PrivatePath = $PSScriptRoot + $DirectorySeparator + 'Private'
$PrivateFiles = Get-ChildItem -Path $PrivatePath | Where-Object -Property Extension -EQ -Value '.ps1'
$PrivateFiles | ForEach-Object -Process { . $_.FullName }

$PublicPath = $PSScriptRoot + $DirectorySeparator + 'Public'
$PublicFiles = Get-ChildItem -Path $PublicPath | Where-Object -Property Extension -EQ -Value '.ps1'
$PublicFiles | ForEach-Object -Process {
    . $_.FullName
    $Alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
    if ($Alias) {
        Export-ModuleMember -Function $_.BaseName -Alias $Alias
    } else {
        Export-ModuleMember -Function $_.BaseName
    }
}