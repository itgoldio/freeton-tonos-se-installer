# Freeton tonos-se installer
Scripts to download, install, run and control local blockchain for development and testing.

### What components does it support?
- tonos-se
- ton-q-server
- arango db

Get support in our telegram channel:
- RU: https://t.me/itgoldio_support_ru
- EN: https://t.me/itgoldio_support_en

# Supported OS versions:
Ubuntu: 20.04\
Debian: 10\
CentOS: 8\
Windows: 10 (need enabled WSL 2 with one of OS above)
## Installation
##### For Windows users: get WSL2 https://docs.microsoft.com/en-us/windows/wsl/install-win10 and install one of supported linuxes from Microsoft Store, open it's terminal (get Windows Terminaa app from Windows store) and move further

1. Download or clone this repository

`git clone https://github.com/itgoldio/freeton-tonos-se-installer.git`

2. Go to the git directory

`cd freeton-tonos-se-installer/`

3. Run [install.sh](./install.sh)

`./install.sh`

It will install all necessary packages and download precompiled binaries.

## Management
Application to run and control local blockchain created as single shell script. The script works like a menu.
 
Run  [control.sh](./control.sh)

`./control.sh`

You will see the menu page

![menu](imgs/menu1.png?raw=true "menu-1")

Using application you can:
- Start\Stop\Restart local blockchain
- Change default ports
- Reset local blockchain to zerostate

# Build your own binaries

Ansible playbook contains in [ansible](ansible/) folder:\
`git clone https://github.com/itgoldio/freeton-tonos-se-installer.git`\
`cd ansible`

To create your own releases, first - change variables in [ansible/vars/deployment.yml](absible/vars/deployment.yml) with needed versions of all components, then fill the linux group [ansible/inventory](ansible/inventory) file - put the IP’s of hosts with supported linux distributions.
Feel free to change installation scripts and configs templates with your needs, they are located in [ansible/roles/prepare_configs_and_scripts/](ansible/roles/prepare_configs_and_scripts/)

Run the playbook with:\
`ansible-playbook -i inventory build_tonos-se-binaries.yml`\
You will get compiled binaries and other filled files in artifacts folder.
