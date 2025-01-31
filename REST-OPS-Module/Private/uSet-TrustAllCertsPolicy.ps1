using namespace System.Net
using namespace System.Security.Cryptography.X509Certificates
using namespace System.Management.Automation

#Requires -PSEdition Desktop

function Set-TrustAllCertsPolicy {
    if (-not ([PSTypeName]'TrustAllCertsPolicy').Type) {
        class TrustAllCertsPolicy : ICertificatePolicy {
            [bool] CheckValidationResult(
                [ServicePoint]$srvPoint,
                [X509Certificate]$certificate,
                [WebRequest]$request,
                [int]$certificateProblem
            ) {
                return $true
            }
        }
    }

    [ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}