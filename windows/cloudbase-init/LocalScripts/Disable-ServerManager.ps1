#ps1
# Disable Server Manager auto-start for all users (policy).
# Idempotent: does nothing after the key is present.

$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager'
$regName = 'DoNotOpenServerManagerAtLogon'

try {
    $val = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop).$regName
} catch {
    $val = $null
}

if ($val -ne 1) {
    New-Item -Path $regPath -Force | Out-Null
    New-ItemProperty -Path $regPath -Name $regName -PropertyType DWord -Value 1 -Force | Out-Null
}
