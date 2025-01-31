using namespace System.Net

function Set-BypassCertificatePolicy {
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        Set-TrustAllCertsPolicy
    }

    [ServicePointManager]::SecurityProtocol = [SecurityProtocolType]::Tls12
}