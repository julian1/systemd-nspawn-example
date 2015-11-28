#!/bin/bash -x

NAME=wily2
VERSION=wily
MAC='00:01:04:1b:2C:1A'


# deb testing  - 4.2, systemd 228-2 
# jessie 8 - 3.16.0-4-amd64, systemd 215-17  

# wily 15.10  - kernel 3.19, systemd 225-lubuntu9 
# vivid 15.04  - problem with journal when booting and won't network the bridge. (maybe because host is old)
# trusty 14.04
# precise 12.04  - can run commands, but won't boot even after setting os-release 

if [ ! -d "$NAME" ]; then
  echo "$NAME doesnt exist - bootstrapping"
  /usr/sbin/debootstrap --verbose $VERSION ./$NAME http://mirror.aarnet.edu.au/ubuntu/ || exit
fi 

# systemd-nspawn -D$NAME  /bin/bash

# WARN set console-login passwd
# systemd-nspawn -D ./$NAME /bin/sh -c 'echo root:root | chpasswd'

# better to use /bin/hostname , as something else is going on.
# systemd-nspawn -D ./$NAME hostname $NAME 

# shouldn't need all this
cat > ./$NAME/etc/apt/sources.list <<- EOM
deb http://mirror.aarnet.edu.au/ubuntu/ $VERSION main
deb http://mirror.aarnet.edu.au/ubuntu/ $VERSION-updates main
deb http://mirror.aarnet.edu.au/ubuntu/ $VERSION universe
deb http://mirror.aarnet.edu.au/ubuntu/ $VERSION-updates universe
deb http://security.ubuntu.com/ubuntu $VERSION-security main
deb http://security.ubuntu.com/ubuntu $VERSION-security universe
EOM


## on host generate keypair - eg.  ssh-keygen -t rsa
if [ ! -f /home/meteo/.ssh/id_rsa.pub ]; then
  echo "no keys!"
  exit
else
  sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' ./$NAME/etc/ssh/sshd_config
  mkdir ./$NAME/root/.ssh
  cat /home/meteo/.ssh/id_rsa.pub > ./$NAME/root/.ssh/authorized_keys
  chmod 400 ./$NAME/root/.ssh/authorized_keys
fi

# assume br0 has dnsmasq running dhcP
cat > ./$NAME/etc/network/interfaces <<- EOM
# The loopback interface
auto lo
iface lo inet loopback

# bridge
auto host0
iface host0 inet dhcp

hwaddress ether $MAC
EOM


# BY Default networking is not containerized so it's actually easy to use apt-get to install ssh
# not with the bridged networking
systemd-nspawn -D./$NAME apt-get -y update
# systemd-nspawn -D./$NAME apt-get -y upgrade
# systemd-nspawn -D./$NAME apt-get -y dist-upgrade
systemd-nspawn -D./$NAME apt-get -y install ssh

# don't know that we need this
# systemctl enable machines.target

# enable and disable have nothing to do with starting and stopping
# 
# cat > /lib/systemd/system/$NAME.service <<- EOM
# [Unit]
# Description=Container %I
# Documentation=man:systemd-nspawn(1)
# PartOf=machines.target
# Before=machines.target
# 
# [Service]
# ExecStart=/usr/bin/systemd-nspawn -D$(pwd)/$NAME -b --network-bridge=br0 -n
# KillMode=mixed
# Type=notify
# RestartForceExitStatus=133
# SuccessExitStatus=133
# Delegate=yes
# 
# [Install]
# WantedBy=machines.target
# EOM
# 
