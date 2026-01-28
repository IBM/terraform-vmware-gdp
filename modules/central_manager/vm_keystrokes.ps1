param(
    [string]$VCenterServer,
    [string]$Username,
    [string]$Password,
    [string]$VMName,
    [string[]]$HidCodes
)

Import-Module VMware.PowerCLI -Force
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
Set-PowerCLIConfiguration -Scope Session -ParticipateInCEIP $false -Confirm:$false | Out-Null
Connect-VIServer -Server $VCenterServer -User $Username -Password $Password -Force | Out-Null
$vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = "^$($VMName)$"}

foreach ($code in $HidCodes) {
    $hidInt = [Convert]::ToInt64($code, 16)
    $value = ($hidInt -shl 16) -bor 0x07

    $keyDown = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
    $keyDown.UsbHidCode = $value

    $keyUp = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
    $keyUp.UsbHidCode = ($value -bor 0x80000000)

    $spec = New-Object VMware.Vim.UsbScanCodeSpec
    $spec.KeyEvents = @($keyDown, $keyUp)

    $vm.PutUsbScanCodes($spec)

    Start-Sleep -Milliseconds 1000
}

Disconnect-VIServer -Server $VCenterServer -Confirm:$false
