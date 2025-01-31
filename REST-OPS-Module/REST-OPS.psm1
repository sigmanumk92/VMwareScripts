using namespace System.Collections.Generic

[List[string]]$PublicFunctions = @()

[array]$WindowsPowerShellOnly = @(
    'Set-TrustAllCertsPolicy'
)

"$PSScriptRoot\public", "$PSScriptRoot\private" | ForEach-Object {
    if (Test-Path -Path $_) {
        Get-ChildItem -Path $_ -Filter "*.ps1" -Recurse | ForEach-Object {
            if (($_.BaseName -in $WindowsPowerShellOnly) -and ($PSEdition -ne 'Desktop')) { return }
            if ($_.FullName -match 'public') {$PublicFunctions.Add($_.BaseName)}
            . $_.FullName
        }
    }
}

Export-ModuleMember -Function $PublicFunctions