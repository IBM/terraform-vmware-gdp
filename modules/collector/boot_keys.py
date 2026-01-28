#!/usr/bin/env python3
import subprocess
import os
import hcl2
import time
import sys

# Flush all print statements immediately
sys.stdout.reconfigure(line_buffering=True)

class PowerCLIKeystrokeSender:
    def __init__(self, vcenter_server, username, password):
        self.vcenter_server = vcenter_server
        self.username = username
        self.password = password

    def send_keystroke(self, vm_name, keystrokes, retries=3):
        powershell_cmd = self._find_powershell()
        if not powershell_cmd:
            print("❌ PowerShell not found!")
            return False

        script_path = os.path.join(os.path.dirname(__file__), "vm_keystrokes.ps1")
        for attempt in range(retries):
            try:
                result = subprocess.run([
                    powershell_cmd, "-ExecutionPolicy", "Bypass", "-File", script_path,
                    "-VCenterServer", self.vcenter_server,
                    "-Username", self.username,
                    "-Password", self.password,
                    "-VMName", vm_name,
                    "-HidCodes"
                ] + keystrokes, capture_output=True, text=True)

                print(result.stdout)
                if result.returncode == 0:
                    return True
                else:
                    print(f"❌ Attempt {attempt+1} failed:\n{result.stderr}")
                    time.sleep(5)
            except Exception as e:
                print(f"⚠️ Error: {e}")
        return False

    def _find_powershell(self):
        for cmd in ["pwsh", "powershell"]:
            try:
                subprocess.run([cmd, "-v"], capture_output=True)
                return cmd
            except FileNotFoundError:
                continue
        return None

def load_tfvars(path):
    if not os.path.isfile(path):
        print(f"⚠️ TFVARS file not found: {path}")
        return {}
    with open(path, 'r') as f:
        return hcl2.load(f)

def main():
    tfvars_file = sys.argv[1] if len(sys.argv) > 1 else "terraform.tfvars"
    shared_tfvars_file = "terraform.tfvars"

    print(f"🔍 Loading instance vars from: {tfvars_file}")
    tfvars = load_tfvars(tfvars_file)

    print(f"🔍 Loading shared vars from: {shared_tfvars_file}")
    shared_vars = load_tfvars(shared_tfvars_file)
    tfvars.update(shared_vars)

    # DEBUG: Show all keys for confirmation
    print(f"✅ Combined tfvars keys: {list(tfvars.keys())}")

    sender = PowerCLIKeystrokeSender(
        tfvars["vcenter_server"],
        tfvars["vcenter_username"],
        tfvars["vcenter_password"]
    )

    wait_time = tfvars.get("boot_menu_wait_seconds", 30)
    print(f"⏳ Waiting {wait_time} seconds for boot menu...")
    time.sleep(wait_time)

    vm_name = tfvars["vm_name"]


    print("⏎ Sending ENTER...")
    success = sender.send_keystroke(vm_name, ["0x28"])
    if success:
        print("✅ Keystrokes sent successfully!")
    else:
        print("❌ Failed to send keystrokes.")

if __name__ == "__main__":
    main()

