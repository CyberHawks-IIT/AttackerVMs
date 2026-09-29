# Building the base VM templates

These are the Proxmox templates every lab VM is cloned from. You build each one
once, convert it to a template, and then the clone scripts in cyber-range stamp
out real VMs from it (`create_range_vms.sh` for the range hosts,
`create_testing_vms.sh` for per-student attacker boxes).

Steps tagged **[Attacker only]** apply only to the attacker templates (Kali and
Windows Server 2025). Skip those steps when you build the plain range templates.

## Which templates you need

| Template | OS | Cloned into | Attacker tooling |
|---|---|---|---|
| Windows Server 2016 | Server 2016 | dc1, sql1 | No |
| Windows Server 2019 | Server 2019 | dc2, ca | No |
| Windows Server 2022 | Server 2022 | web, sql2 | No |
| Windows 11 | Windows 11 Pro N | workstation | No |
| Windows Server 2025 | Server 2025 | per-student attacker Windows box | **Yes** |
| Kali Linux | Kali rolling | per-student attacker Kali box | **Yes** |

The Windows templates all follow the same procedure below. They only differ in
which OS you install and whether you run the attacker-tooling step.

You only need the OS versions your setup uses. For setup 1 (range only) that's
the four range Windows templates. Add Windows Server 2025 and Kali if you also
want attacker boxes.

## Windows templates

> **Cloud-init drive gotcha.** There's a known issue where IDE drive IDs
> conflict (0 with 1, and 2 with 3). When you add a cloud-init drive to the VM,
> either remove the other IDE drives or attach the cloud-init drive as SCSI.

1. **Create the VM and install the OS.** Use the Windows version from the table
   above.
2. **Install all Windows Updates.** Check more than once. New updates often
   appear after the first round installs and reboots.
3. **[Attacker only] Set local group policy** (Start, then `gpedit.msc`).
   - **Turn off Windows Defender.** Under Computer Configuration, Administrative
     Templates, Windows Components, Microsoft Defender Antivirus, set "Turn off
     Windows Defender" to Enabled.
   - **Stop Server Manager opening on login.** Under Computer Configuration,
     Administrative Templates, System, Server Manager, set "Do not display Server
     Manager automatically at logon" to Enabled.
4. **[Windows 11 only] Turn off Tamper Protection.** Open Windows Security, then
   Virus & threat protection, then Manage settings, and set Tamper Protection to
   Off. The range disables Defender on workstation, and Tamper Protection blocks
   that. It can't be turned off by script (the setting is protected even for
   SYSTEM), so it has to be done here, once. Leave Defender itself on. Ansible
   turns it off on workstation after cloning. Every other template keeps Defender
   on and skips this step.
5. **Install the VirtIO drivers and the QEMU guest agent.** In Proxmox, attach
   the VirtIO driver ISO to the VM: add a CD/DVD drive and select
   `virtio-win.iso` (download it per the
   [Proxmox VirtIO guide](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers) if
   the host doesn't already have it). Then, in Windows, open the mounted ISO
   drive (usually `D:` or `E:`) and:
   - Double-click **`virtio-win-guest-tools.exe`** and click through the
     installer. This installs all the VirtIO drivers and the QEMU guest agent
     together.
   - To install them separately instead, run **`virtio-win-gt-x64.msi`** for the
     drivers and **`guest-agent\qemu-ga-x86_64.msi`** for the guest agent.

   Afterward, confirm the **QEMU Guest Agent** service is running (`services.msc`).
6. **Reboot.**
7. **Download the contents of the [windows](../windows/) directory** onto the VM.
8. **Install cloudbase-init** from
   [cloudbase.it](https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi) and
   go through the prompts. At the end, choose to run sysprep, but **do not**
   choose to shut down after installation.
9. **[Attacker only] Install the offensive tooling.** In PowerShell, run the
   [setup script](../windows/windows-setup.ps1):
   `Set-ExecutionPolicy Bypass && .\windows-setup.ps1`. Notes:
   - Newer versions of PingCastle must be downloaded by hand from
     [Netwrix](https://www.netwrix.com/active-directory-risk-assessment.html).
   - Some links in the script are dated. See the [software list](#attacker-software-list)
     at the bottom for what should end up installed, and add any extras by hand.
10. **Place the cloudbase-init config.** Run
    `move cloudbase-init/* "C:\Program Files\Cloudbase Solutions\Cloudbase-Init"`.
11. **Set the DNS server manually.** cloudbase-init can't read the DNS server
    from Proxmox's cloud-init drive, so clones come up without one. The simplest
    fix is to assume every clone from this template uses the same DNS server and
    set it here, once, before templating. For the range templates that's the
    gateway, `10.0.2.1`. In an administrator command prompt:

    ```
    netsh interface ip set dns "Ethernet Interface 0" static 10.0.2.1
    netsh interface ip set dns "Ethernet Interface 0" suffix cyberhawks.lab
    ```

    Use the DNS server for whatever network the template's clones live on (for
    example `192.168.1.1` for the attacker template). If the adapter isn't named
    `Ethernet Interface 0`, list the names with `netsh interface show interface`.
    The range's Ansible sets each host's final DNS later, so this is just a
    working baseline for first boot.
12. **[Attacker only] Place the desktop shortcuts.** Run
    `move shortcuts/* "C:\Users\Public\Desktop"`.
13. **Shut down and convert to a template** (see [below](#convert-to-a-template)).

## Kali template (attacker)

1. **Install the base OS.**
2. **Download the contents of the [kali](../kali/) directory** onto the VM.
3. **Run the [setup script](../kali/kali-setup.sh):**
   `chmod +x kali-setup.sh && ./kali-setup.sh`.
4. **[Optional] Set up the Kerberos file for [GOAD](https://orange-cyberdefense.github.io/GOAD/):**
   `sudo mv krb5.conf /etc/krb5.conf`.
5. **[Optional] Clear logs:**
   `sudo rm -f ~/.zsh_history /root/.zsh_history /var/log/* && sudo find /var/log -type f -exec rm -f {} \;`.
6. **Shut down and convert to a template** (see below).

## Convert to a template

On the Proxmox host, with the VM shut down:

```bash
qm template <vmid>
```

Then note the template's VMID. The clone scripts take these VMIDs as inputs:

- `create_range_vms.sh` uses the four range Windows templates through its
  `--tmpl-2016`, `--tmpl-2019`, `--tmpl-2022`, and `--tmpl-win11` options.
- `create_testing_vms.sh` uses the attacker Windows and Kali templates through
  its `--templates` option.

## Attacker software list

The Windows attacker template should end up with this software. The setup script
installs most of it. Add anything missing by hand.

- [Python 3](https://www.python.org/downloads/)
- [MobaXterm](https://mobaxterm.mobatek.net/download.html)
- [Notepad++](https://notepad-plus-plus.org/downloads/)
- [Visual Studio](https://visualstudio.microsoft.com/vs/community/)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [7-Zip File Manager](https://www.7-zip.org/)
- Tooling in `C:\Tools`: [Rubeus](https://github.com/GhostPack/Rubeus),
  [Certify](https://github.com/GhostPack/Certify),
  [Seatbelt](https://github.com/GhostPack/Seatbelt),
  [PrivescCheck](https://github.com/itm4n/PrivescCheck),
  [SharpGPOAbuse](https://github.com/FSecureLABS/SharpGPOAbuse),
  [SharpSCCM](https://github.com/Mayyhem/SharpSCCM),
  [Whisker](https://github.com/eladshamir/Whisker),
  [SharpDPAPI](https://github.com/GhostPack/SharpDPAPI),
  [winPEAS](https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS),
  [SigmaPotato](https://github.com/tylerdotrar/SigmaPotato),
  [Snaffler](https://github.com/SnaffCon/Snaffler),
  [PingCastle](https://www.pingcastle.com/download/)
