# Building the Splunk and Zeek Debian containers

The monitoring stack (setup 2) runs on two Debian 12 boxes: a **Splunk indexer**
and a **Zeek sensor**. This guide creates the two empty containers. Installing
Splunk and Zeek onto them is handled separately by
[defense-tooling](https://github.com/CyberHawks-IIT/defense-tooling), which you
run after the containers exist.

Both are LXC containers here, but a VM works just as well if you prefer. Run
every command below **on the Proxmox host**.

The two differ in one important way:

- The **Splunk indexer** is an ordinary container. Unprivileged is fine.
- The **Zeek sensor** must be a **privileged** container with a **second,
  dedicated capture NIC**, because raw packet capture needs both. Getting either
  wrong fails silently, not loudly. See
  [defense-tooling/docs/manual-prerequisites.md](https://github.com/CyberHawks-IIT/defense-tooling/blob/main/docs/manual-prerequisites.md)
  for the full reasoning.

The addresses below match this project's `defense` network (`10.0.10.0/24`).
Change them to fit your own layout.

## 0. Get a Debian 12 template

If you don't already have a Debian 12 LXC template on the host:

```bash
pveam update
pveam available --section system | grep debian-12
pveam download local debian-12-standard_12.7-1_amd64.tar.zst   # use the current filename from the line above
```

## 1. Splunk indexer (ordinary container)

```bash
pct create 510 local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --hostname splunk \
  --cores 2 --memory 4096 --swap 512 \
  --rootfs local-zfs:32 \
  --net0 name=eth0,bridge=defense,firewall=1,ip=10.0.10.2/24,gw=10.0.10.1 \
  --nameserver 10.0.10.1 \
  --features nesting=1 \
  --unprivileged 1 \
  --start 1
```

Size `--rootfs`, `--cores`, and `--memory` for how much data you'll retain. 32 GB
is fine for a lab on Splunk's free tier (500 MB/day). Then set up the admin
account defense-tooling connects as (see [step 3](#3-give-both-containers-your-ssh-key-and-a-sudo-user)).

**Check:** `pct config 510` shows `unprivileged: 1`, and `pct exec 510 -- ip a`
shows `eth0` at `10.0.10.2`.

## 2. Zeek sensor (privileged, two NICs)

Because a privileged flag can't be added to an existing container or set by
cloning, build the Zeek container fresh with defense-tooling's helper script,
which passes `--unprivileged 0`:

```bash
# from a checkout of defense-tooling on the Proxmox host:
scripts/proxmox/create-privileged-lxc.sh --vmid 511 --hostname zeek \
  --template local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --bridge defense --ip 10.0.10.3/24 --gw 10.0.10.1 \
  --nameserver 10.0.10.1 --cores 1 --memory 4096 \
  --rootfs-storage local-zfs --rootfs-size 16
```

That gives you `eth0`, the management and log-forwarding NIC. Now add the
**second NIC**, the one Zeek actually sniffs on. It must have **`firewall=0`**
and **no IP**, and it goes on the bridge your traffic mirror delivers to:

```bash
pct set 511 --net1 name=eth1,bridge=<mirror-bridge>,firewall=0
pct start 511
```

Replace `<mirror-bridge>` with the bridge you mirror traffic onto.
defense-tooling's `scripts/proxmox/setup-mirror.sh` wires the mirror to this
interface, and the `zeek_sensor` role brings `eth1` up in promiscuous mode
inside the guest. You don't give `eth1` an IP, and you must keep `firewall=0`,
or Proxmox's per-guest firewall silently drops the mirrored frames.

**Check:** `pct config 511` has no `unprivileged:` line (which means it's
privileged), and shows both `net0` and a `net1` with `firewall=0` and no `ip=`.

## 3. Give both containers your SSH key and a sudo user

defense-tooling connects over SSH as a sudo user (its inventory uses `sysadmin`).
Create that account in each container and install your control node's public key:

```bash
for CT in 510 511; do
  pct exec $CT -- bash -c '
    id sysadmin >/dev/null 2>&1 || useradd -m -s /bin/bash sysadmin
    usermod -aG sudo sysadmin
    echo "sysadmin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sysadmin
    install -d -m 700 -o sysadmin -g sysadmin /home/sysadmin/.ssh
  '
  pct push $CT /root/id_ed25519_defense_tooling.pub /home/sysadmin/.ssh/authorized_keys \
    --user 1000 --group 1000 --perms 600
done
```

Copy your control node's public key to `/root/id_ed25519_defense_tooling.pub` on
the Proxmox host first, or adjust the `pct push` source path.

**Check:** from your control node,
`ssh sysadmin@10.0.10.2 sudo id` and `ssh sysadmin@10.0.10.3 sudo id` both
return `uid=0(root)`.

## Next

The containers are ready. Install the software from
[defense-tooling](https://github.com/CyberHawks-IIT/defense-tooling), following
its [setup guide](https://github.com/CyberHawks-IIT/cyber-range/blob/master/docs/setup/range-with-monitoring.md).
It installs Splunk on `510`, Zeek on `511`, brings up the capture interface, and
wires the traffic mirror.
