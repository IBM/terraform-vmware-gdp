param(
    [string]$VCenterServer,
    [string]$Username,
    [string]$Password,
    [string]$VMName,
    [string]$TerraformVarsPath = "terraform.tfvars"
)

Write-Host "📂 Loading Terraform vars from: $TerraformVarsPath"

Import-Module VMware.PowerCLI -Force
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
Set-PowerCLIConfiguration -Scope Session -ParticipateInCEIP $false -Confirm:$false | Out-Null
Connect-VIServer -Server $VCenterServer -User $Username -Password $Password -Force | Out-Null

Write-Host "🔗 Connected to vCenter. Target VM: $VMName"

# Read values from terraform.tfvars
$vars = Get-Content $TerraformVarsPath | ForEach-Object {
    if ($_ -match '^(?<key>[a-zA-Z0-9_]+)\s*=\s*\"(?<value>[^\"]+)\"') {
        [PSCustomObject]@{ Key = $Matches['key']; Value = $Matches['value'] }
    }
} | Group-Object -AsHashTable -AsString -Property Key

$newPassword = $vars['guardium_cli_password'].Value
$hostname = $vars['system_hostname'].Value
$domain = $vars['system_domain'].Value
$ip = $vars['network_interface_ip'].Value
$mask = $vars['network_interface_mask'].Value
$gateway = $vars['network_routes_defaultroute'].Value
$dns1 = $vars['network_resolvers1'].Value
$dns2 = $vars['network_resolvers2'].Value
$timezone = $vars['system_clock_timezone'].Value

Write-Host "✅ Parsed variables:"
Write-Host "   IP: $ip$mask"
Write-Host "   Hostname: $hostname, Domain: $domain"
Write-Host "   DNS: $dns1, $dns2, Gateway: $gateway"
Write-Host "   Timezone: $timezone"

# HID map (lowercase, uppercase, and special characters)
$hidCharacterMap = @{}
$hidCharacterMap['a'] = '0x04'
$hidCharacterMap['A'] = '0x04'
$hidCharacterMap['b'] = '0x05'
$hidCharacterMap['B'] = '0x05'
$hidCharacterMap['c'] = '0x06'
$hidCharacterMap['C'] = '0x06'
$hidCharacterMap['d'] = '0x07'
$hidCharacterMap['D'] = '0x07'
$hidCharacterMap['e'] = '0x08'
$hidCharacterMap['E'] = '0x08'
$hidCharacterMap['f'] = '0x09'
$hidCharacterMap['F'] = '0x09'
$hidCharacterMap['g'] = '0x0a'
$hidCharacterMap['G'] = '0x0a'
$hidCharacterMap['h'] = '0x0b'
$hidCharacterMap['H'] = '0x0b'
$hidCharacterMap['i'] = '0x0c'
$hidCharacterMap['I'] = '0x0c'
$hidCharacterMap['j'] = '0x0d'
$hidCharacterMap['J'] = '0x0d'
$hidCharacterMap['k'] = '0x0e'
$hidCharacterMap['K'] = '0x0e'
$hidCharacterMap['l'] = '0x0f'
$hidCharacterMap['L'] = '0x0f'
$hidCharacterMap['m'] = '0x10'
$hidCharacterMap['M'] = '0x10'
$hidCharacterMap['n'] = '0x11'
$hidCharacterMap['N'] = '0x11'
$hidCharacterMap['o'] = '0x12'
$hidCharacterMap['O'] = '0x12'
$hidCharacterMap['p'] = '0x13'
$hidCharacterMap['P'] = '0x13'
$hidCharacterMap['q'] = '0x14'
$hidCharacterMap['Q'] = '0x14'
$hidCharacterMap['r'] = '0x15'
$hidCharacterMap['R'] = '0x15'
$hidCharacterMap['s'] = '0x16'
$hidCharacterMap['S'] = '0x16'
$hidCharacterMap['t'] = '0x17'
$hidCharacterMap['T'] = '0x17'
$hidCharacterMap['u'] = '0x18'
$hidCharacterMap['U'] = '0x18'
$hidCharacterMap['v'] = '0x19'
$hidCharacterMap['V'] = '0x19'
$hidCharacterMap['w'] = '0x1a'
$hidCharacterMap['W'] = '0x1a'
$hidCharacterMap['x'] = '0x1b'
$hidCharacterMap['X'] = '0x1b'
$hidCharacterMap['y'] = '0x1c'
$hidCharacterMap['Y'] = '0x1c'
$hidCharacterMap['z'] = '0x1d'
$hidCharacterMap['Z'] = '0x1d'
$hidCharacterMap['1'] = '0x1e'
$hidCharacterMap['!'] = '0x1e'
$hidCharacterMap['2'] = '0x1f'
$hidCharacterMap['@'] = '0x1f'
$hidCharacterMap['3'] = '0x20'
$hidCharacterMap['#'] = '0x20'
$hidCharacterMap['4'] = '0x21'
$hidCharacterMap['$'] = '0x21'
$hidCharacterMap['5'] = '0x22'
$hidCharacterMap['%'] = '0x22'
$hidCharacterMap['6'] = '0x23'
$hidCharacterMap['^'] = '0x23'
$hidCharacterMap['7'] = '0x24'
$hidCharacterMap['&'] = '0x24'
$hidCharacterMap['8'] = '0x25'
$hidCharacterMap['*'] = '0x25'
$hidCharacterMap['9'] = '0x26'
$hidCharacterMap['('] = '0x26'
$hidCharacterMap['0'] = '0x27'
$hidCharacterMap[')'] = '0x27'
$hidCharacterMap['-'] = '0x2d'
$hidCharacterMap['_'] = '0x2d'
$hidCharacterMap['='] = '0x2e'
$hidCharacterMap['+'] = '0x2e'
$hidCharacterMap['['] = '0x2f'
$hidCharacterMap[']'] = '0x30'
$hidCharacterMap['\'] = '0x31'
$hidCharacterMap[';'] = '0x33'
$hidCharacterMap[','] = '0x36'
$hidCharacterMap['.'] = '0x37'
$hidCharacterMap['/'] = '0x38'
$hidCharacterMap[' '] = '0x2c'

function Send-StringAsKeystrokes {
    param (
        [string]$Text
    )
    $vm = Get-View -ViewType VirtualMachine -Filter @{ "Name" = "^$($VMName)$" }
    if (!$vm) { Write-Error "VM '$VMName' not found"; return }

    foreach ($char in $Text.ToCharArray()) {
        $hidCodes = @()
        if ($null -ne $char) {
            $key = $char.ToString()
            if ($hidCharacterMap.ContainsKey($key)) {
                $hidCode = $hidCharacterMap[$key]
                $hidInt = [Convert]::ToInt64($hidCode, 16)
                $hidCodeValue = ($hidInt -shl 16) -bor 0x07

                # Key down event
                $keyDown = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
                $keyDown.UsbHidCode = $hidCodeValue
                if ($key -cmatch '[A-Z]' -or $key -in '!','@','#','$','%','^','&','*','(',')','_','+') {
                    $modifier = New-Object VMware.Vim.UsbScanCodeSpecModifierType
                    $modifier.LeftShift = $true
                    $keyDown.Modifiers = $modifier
                }
                $hidCodes += $keyDown

                # Key up event
                $keyUp = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
                $keyUp.UsbHidCode = ($hidInt -shl 16) -bor 0x80000007
                $hidCodes += $keyUp

                $spec = New-Object VMware.Vim.UsbScanCodeSpec
                $spec.KeyEvents = $hidCodes
                $vm.PutUsbScanCodes($spec)
                Start-Sleep -Milliseconds 100
            } else {
                Write-Host "Character '$char' not in HID map"
                continue
            }
        }
    }

    $enterCodes = @()
    $enter = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
    $enter.UsbHidCode = ([Convert]::ToInt64("0x28", 16) -shl 16) -bor 0x07
    $enterUp = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
    $enterUp.UsbHidCode = ([Convert]::ToInt64("0x28", 16) -shl 16) -bor 0x80000007
    $enterCodes += $enter
    $enterCodes += $enterUp

    $enterSpec = New-Object VMware.Vim.UsbScanCodeSpec
    $enterSpec.KeyEvents = $enterCodes
    $vm.PutUsbScanCodes($enterSpec)
    Start-Sleep -Milliseconds 100
}

Write-Host "⌨️ Sending login: cli"
Send-StringAsKeystrokes -Text "cli"
Start-Sleep -Seconds 5

Write-Host "⌨️ Sending password: guardium"
Send-StringAsKeystrokes -Text "guardium"
Start-Sleep -Seconds 5

Write-Host "⌨️ Sending password: guardium"
Send-StringAsKeystrokes -Text "guardium"
Start-Sleep -Seconds 5

Write-Host "⌨️ Sending new password via keystrokes..."
Send-StringAsKeystrokes -Text $newPassword
Start-Sleep -Seconds 5

Write-Host "⌨️ Sending new password via keystrokes..."
Send-StringAsKeystrokes -Text $newPassword
Start-Sleep -Seconds 5

$cliCommands = @(
    @{ cmd = "store network interface ip $ip$mask"; wait = 15 },
    @{ cmd = "store network routes defaultroute $gateway"; wait = 15 },
    @{ cmd = "store network resolvers $dns1 $dns2"; wait = 15 },
    @{ cmd = "store system domain $domain"; wait = 40 },
    @{ cmd = "store system hostname $hostname"; wait = 25 },
    @{ cmd = "n"; wait = 25 },
    @{ cmd = "store system clock timezone $timezone"; wait = 45 },
    @{ cmd = "y"; wait = 55 },
    @{ cmd = "restart network"; wait = 25 },
    @{ cmd = "yes"; wait = 600 }
)

foreach ($c in $cliCommands) {
    Write-Host "⌨️ Sending CLI command: $($c.cmd)"
    Send-StringAsKeystrokes -Text $c.cmd
    Start-Sleep -Seconds $c.wait
}

Write-Host "🔌 Disconnected from vCenter"
Disconnect-VIServer -Server $VCenterServer -Confirm:$false
