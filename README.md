# Freeton tonos-se installer
Scripts for download, install, run and control local blockchain for development and testing.\

### What components does it support?
- tonos-se
- ton-q-server
- arango db

support in our telegram channel:
- RU: https://t.me/itgoldio_support_ru
- EN: https://t.me/itgoldio_support_en


# UBUNTU 20.4
## Installation

1. Download or clone this repository

`git clone https://github.com/itgoldio/freeton-tonos-se-installer.git`

2. Go to the git directory

`cd freeton-tonos-se-installer/`

3. Run [install.sh](./install.sh)

`./install.sh`

It will install all necessary packages and download precompiled binaries.

## Management
Application for run and control local blockchain create as single shell script. The script work in menu stile.
 
Run  [control.sh](./control.sh)

`./control.sh`

You will see menu page

![menu](imgs/menu1.png?raw=true "menu-1")

Use application you can:
- Start\Stop\Restart local blockchain
- Change default ports
- Reset local blockchain to zerostate
