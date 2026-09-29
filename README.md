# VM Templates

Scripts and guides for building the base VMs and containers the CyberHawks lab
runs on. Everything else in the project clones or configures what this repo
creates.

## What this repo builds

- **Base OS templates** for Proxmox. These are the images every lab VM is cloned
  from. Two families:
  - The **Windows Server and Windows 11 templates** the vulnerable range is
    cloned from (dc1, dc2, ca, web, sql1, sql2, workstation).
  - The **Kali and Windows Server 2025 attacker templates** students clone to
    attack the range.
- **The Splunk and Zeek Debian containers** the monitoring stack runs on (setup
  2 only).

## Guides

- **[Building the base VM templates](docs/building-templates.md)** covers the
  Windows and Kali templates step by step. Steps that only apply to the attacker
  templates are marked **[Attacker only]**, so the same guide builds the plain
  range templates too.
- **[Building the Splunk and Zeek Debian containers](docs/debian-containers.md)**
  covers creating the two monitoring containers, including the privileged Zeek
  sensor and its dedicated capture NIC.

## Part of a bigger project

This sits alongside [cyber-range](https://github.com/CyberHawks-IIT/cyber-range)
(the AD range, and where you **start** for the full
[setup guides](https://github.com/CyberHawks-IIT/cyber-range/blob/main/docs/setup/README.md)),
[defense-tooling](https://github.com/CyberHawks-IIT/defense-tooling) (the Splunk
and Zeek stack), and
[splunk-detections](https://github.com/CyberHawks-IIT/splunk-detections) (the
detections). Each one stands alone.

> **Tip:** note the VMID of each template and container you build. cyber-range's
> `create_range_vms.sh` and `create_testing_vms.sh` take the template VMIDs as
> inputs (`--tmpl-2016`, `--templates`, and so on).
