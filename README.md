# AttackerVMs
Setup scripts for creating attacker VM templates in Proxmox.

## Kali Linux
1. Install base OS
2. Download contents of [kali](kali/) directory
3. Run the [setup script](kali/kali-setup.sh): `chmod +x kali-setup.sh && ./kali-setup.sh`
4. Set up Kerberos file for [GOAD](https://orange-cyberdefense.github.io/GOAD/) (optional): `sudo mv krb5.conf /etc/krb5.conf`
5. Clear logs (optional): `sudo rm -f ~/.zsh_history /root/.zsh_history /var/log/* && sudo find /var/log -type f -exec rm -f {} \;`
6. Shutdown and create template

## Windows Server 2022
Note: When adding a cloud-init drive to your Windows VM, use SCSI. There's a known issue with IDE where ID 0 conflicts with 1 and 2 conflicts with 3, and you're probably already using 0 and 2.
1. Install base OS
2. Check for updates and install all updates - may need to be done multiple times
3. Permanently disable Windows Defender: Start > gpedit.msc > Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus - set "Turn off Windows Defender" to Enabled
4. Install VirtIO drivers and QEMU guest agent (optional): see [this link](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers) and follow steps under Installation > Using the ISO > Wizard Installation
5. Reboot
6. Download contents of [windows](windows/) directory
7. Download cloudbase-init from [here](https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi), and go through prompts
   - At the end, select the option to run sysprep but DO NOT select the option to shutdown after installation
8. Run the [setup script](windows/windows-setup.ps1) in PowerShell: `Set-ExecutionPolicy Bypass && .\windows-setup.ps1`
9. `mov cloudbase-init/* "C:\Program Files\Cloudbase Solutions\Cloudbase-Init"`
   - You may need to change the DNS server in [DNS.bat](windows/cloudbase-init/LocalScripts/DNS.bat)
10. `mov shortcuts/* "C:\Users\Public\Desktop"`
11. Shutdown and create template
