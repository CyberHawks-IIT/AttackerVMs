#!/bin/zsh

# Create directories
mkdir $HOME/test
mkdir $HOME/tools
cd $HOME/tools/

# Sublime APT dependencies
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg  --no-check-certificate| gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Software upgrade
#sudo sed -i 's/http.kali.org/mirrors.ocf.berkeley.edu/g' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
sudo dpkg-reconfigure debconf --frontend=noninteractive
sudo apt -y update
sudo apt -y upgrade

# Software (APT) packages
sudo apt -y install sublime-text krb5-user freerdp2-x11 rdate testssl.sh ipmitool python3-venv nfs-client mitm6 git seclists enum4linux-ng pipx golang rsyslog cloud-init qemu-guest-agent

# Switch default Python to Python 3 (required for some tools like PetitPotam)
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Fix path to include pipx and go directories
echo 'PATH=$HOME/.local/bin:$HOME/go/bin:$PATH' >> $HOME/.zshrc;. $HOME/.zshrc

# Python packages
pip3 install --upgrade pip --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org--trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
pipx ensurepath
PIP_NO_VERIFY="true" pipx install git+https://github.com/Pennyw0rth/NetExec
PIP_NO_VERIFY="true" pipx install git+https://github.com/garrettfoster13/pre2k
PIP_NO_VERIFY="true" pipx install impacket certipy-ad modbus_cli
PIP_NO_VERIFY="true" pipx inject impacket pyOpenSSL==24.0.0 --force # fix for ntlmrelayx.py --shadowcredentials

# Go modules
go install github.com/sensepost/gowitness@latest

# Ruby gems
echo ":ssl_verify_mode: 0" | sudo tee -a /root/.gemrc
sudo gem install evil-winrm

# Standalone Python scripts (alternatives to coercer)
sudo wget https://raw.githubusercontent.com/topotam/PetitPotam/refs/heads/main/PetitPotam.py -O /usr/local/bin/petitpotam --no-check-certificate
sudo chmod +x /usr/local/bin/petitpotam
sudo wget https://raw.githubusercontent.com/Wh04m1001/DFSCoerce/refs/heads/main/dfscoerce.py -O /usr/local/bin/dfscoerce --no-check-certificate
sudo chmod +x /usr/local/bin/dfscoerce
sudo wget https://raw.githubusercontent.com/ShutdownRepo/ShadowCoerce/refs/heads/main/shadowcoerce.py -O /usr/local/bin/shadowcoerce --no-check-certificate
sudo chmod +x /usr/local/bin/shadowcoerce
sudo wget https://raw.githubusercontent.com/dirkjanm/krbrelayx/refs/heads/master/printerbug.py -O /usr/local/bin/printerbug --no-check-certificate
sudo chmod +x /usr/local/bin/printerbug
sudo wget https://raw.githubusercontent.com/evilashz/CheeseOunce/refs/heads/main/cheese.py -O /usr/local/bin/cheeseounce --no-check-certificate
sudo chmod +x /usr/local/bin/cheeseounce

# Binaries and Standalone Scripts
sudo wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -O /usr/local/bin/kerbrute --no-check-certificate
sudo chmod +x /usr/local/bin/kerbrute
sudo wget https://raw.githubusercontent.com/CiscoCXSecurity/rdp-sec-check/master/rdp-sec-check.pl -O /usr/local/bin/rdp-sec-check.pl --no-check-certificate
sudo chmod +x /usr/local/bin/rdp-sec-check.pl
sudo wget https://raw.githubusercontent.com/RhinoSecurityLabs/Security-Research/master/tools/python/CVE-2005-1794-check.py -O /usr/local/bin/CVE-2005-1794-check.py --no-check-certificate
sudo chmod +x /usr/local/bin/CVE-2005-1794-check.py
sudo wget https://raw.githubusercontent.com/shifty0g/ultimate-nmap-parser/master/ultimate-nmap-parser.sh -O /usr/local/bin/parse-nmap --no-check-certificate
sudo chmod +x /usr/local/bin/parse-nmap

# Github packages
git -c http.sslVerify=false clone https://github.com/hsaunders1904/pyautoenv
chmod +x pyautoenv/pyautoenv.plugin.zsh
git -c http.sslVerify=false clone https://github.com/insidetrust/statistically-likely-usernames
git -c http.sslVerify=false clone https://github.com/dirkjanm/krbrelayx
git -c http.sslVerify=false clone https://github.com/ShutdownRepo/pywhisker
git -c http.sslVerify=false clone https://github.com/Ridter/noPac

# Custom userlist for GOAD
curl -s https://www.hbo.com/game-of-thrones/cast-and-crew | grep 'href="/game-of-thrones/cast-and-crew/'| grep -o 'aria-label="[^"]*"' | cut -d '"' -f 2 | awk '{if($2 == "") {print tolower($1)} else {print tolower($1) "." tolower($2);} }' > statistically-likely-usernames/goad.txt

# Installs
sudo cpan install Encoding::BER
sudo cpan install Net::Pcap

# Install each tool in its own virtual env
find $HOME/tools -type f -name 'requirements.txt' -execdir python3 -m venv .venv \; -execdir .venv/bin/pip install -r {} \;

# Custom zshrc
echo -e "# clear without clearing history\nalias clear='clear -x'\n\n# activate venv\nactivate() {\ndeactivate &>/dev/null;source ./\${1:-'venv'}/bin/activate\n}\n\n# create venv\nvenv() {\npython3 -m venv \${1:-'venv'}\nactivate \${1:-'venv'}\n}\n\n# auto activate python virtual environments\nsource $HOME/tools/pyautoenv/pyautoenv.plugin.zsh\n\n# better terminal prompt\nIP=\$(ifconfig eth0 | awk '/inet /{print \$2}')\n\nPROMPT=\$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)──}(%B%F{%(#.red.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]%F{green} [eth0: \$IP]\\\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '\nRPROMPT=\$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'" >> $HOME/.zshrc
echo -e "# clear without clearing history\nalias clear='clear -x'\n\n# activate venv\nactivate() {\ndeactivate &>/dev/null;source ./\${1:-'venv'}/bin/activate\n}\n\n# create venv\nvenv() {\npython3 -m venv \${1:-'venv'}\nactivate \${1:-'venv'}\n}\n\n# auto activate python virtual environments\nsource $HOME/tools/pyautoenv/pyautoenv.plugin.zsh" | sudo tee -a /root/.zshrc

# Configure logging
sudo sh -c "echo 'local6.*    /var/log/commands.log' >> /etc/rsyslog.d/commands.conf"
echo 'precmd() { eval RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$]: $(history | tail -n1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" }' >> $HOME/.zshrc
echo 'precmd() { eval RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$]: $(history | tail -n1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" }' | sudo tee -a /root/.zshrc
sudo systemctl restart rsyslog

# Prepare template for cloning
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/etc-machineid
sudo ln -s /etc/machine-id /var/lib/dbus/etc-machineid
sudo rm /etc/ssh/ssh_host_*
sudo systemctl enable cloud-init

. $HOME/.zshrc
echo "Installation complete!"