# Attacker VMs
Setup scripts for creating attacker VM templates in Proxmox.

## Kali Linux
1. Install base OS
2. Download contents of [kali](kali/) directory
3. Run the [setup script](kali/kali-setup.sh): `chmod +x kali-setup.sh && ./kali-setup.sh`
4. Set up Kerberos file for [GOAD](https://orange-cyberdefense.github.io/GOAD/) (optional): `sudo mv krb5.conf /etc/krb5.conf`
5. Clear logs (optional): `sudo rm -f ~/.zsh_history /root/.zsh_history /var/log/* && sudo find /var/log -type f -exec rm -f {} \;`
6. Shutdown and create template

## Windows Server 2025
Note: There's a known issue with IDE where ID 0 conflicts with 1 and 2 conflicts with 3. When adding a cloud-init drive to your Windows VM, either ensure that you've removed the other IDE drives or use SCSI.
1. Install base OS
2. Check for updates and install all updates - may need to be done multiple times
3. Modify local group policy: Start > gpedit.msc
  - Permanently disable Windows Defender: Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus - set "Turn off Windows Defender" to Enabled
  - Stop Server Manager from starting on login: Computer Configuration > Administrative Templates > System > Server Manager - set "Do not display Server Manager automatically at logon" to Enabled
6. Install VirtIO drivers and QEMU guest agent (optional): see [this link](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers) and follow steps under Installation > Using the ISO > Wizard Installation
7. Reboot
8. Download contents of [windows](windows/) directory
9. Download cloudbase-init from [here](https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi), and go through prompts
  - At the end, select the option to run sysprep but DO NOT select the option to shutdown after installation
10. Run the [setup script](windows/windows-setup.ps1) in PowerShell: `Set-ExecutionPolicy Bypass && .\windows-setup.ps1`
  - Newer versions of PingCastle need to be downloaded manually from [here](https://www.netwrix.com/active-directory-risk-assessment.html)
  - Some links in the setup script are dated, and I like to manually install additional software. View the full list of software below.
11. `move cloudbase-init/* "C:\Program Files\Cloudbase Solutions\Cloudbase-Init"`
  - You may need to change the DNS server in [DNS.bat](windows/cloudbase-init/LocalScripts/DNS.bat)
12. `move shortcuts/* "C:\Users\Public\Desktop"`
13. Shutdown and create template

### Windows Software
Eventually, I'll add updated versions of all this to the setup script.
- [Python 3](https://www.python.org/downloads/)
- [MobaXterm](https://mobaxterm.mobatek.net/download.html)
- [Notepad++](https://notepad-plus-plus.org/downloads/)
- [Visual Studio](https://visualstudio.microsoft.com/vs/community/)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [7-Zip File Manager](https://www.7-zip.org/)
- Tooling in C:\Tools: [Rubeus](https://github.com/GhostPack/Rubeus), [Certify](https://github.com/GhostPack/Certify), [Seatbelt](https://github.com/GhostPack/Seatbelt), [PrivescCheck](https://github.com/itm4n/PrivescCheck), [SharpGPOAbuse](https://github.com/FSecureLABS/SharpGPOAbuse), [SharpSCCM](https://github.com/Mayyhem/SharpSCCM), [Whisker](https://github.com/eladshamir/Whisker), [SharpDPAPI](https://github.com/GhostPack/SharpDPAPI), [PrivescCheck](https://github.com/itm4n/PrivescCheck), [winPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS), [SigmaPotato](https://github.com/tylerdotrar/SigmaPotato), [Snaffler](https://github.com/SnaffCon/Snaffler), [PingCastle](https://www.pingcastle.com/download/)
