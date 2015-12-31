#!/bin/bash -x

NAME=jessie
VERSION=jessie
MIRROR=http://mirror.aarnet.edu.au/debian/
MAC='00:01:04:1b:2C:1A'
KEYFILE=/home/meteo/.ssh/id_rsa.pub


if [ ! -d "$NAME" ]; then
  echo "$NAME doesnt exist - bootstrapping"
  /usr/sbin/debootstrap --verbose $VERSION ./$NAME $MIRROR || exit
fi

# upgrade
systemd-nspawn -D./$NAME apt-get -y update
systemd-nspawn -D./$NAME apt-get -y upgrade

# ssh and python2.7 to support ansible
systemd-nspawn -D./$NAME apt-get -y install ssh python2.7
systemd-nspawn -D./$NAME ln -s /usr/bin/python2.7 /usr/bin/python

# Helpful to debug
# systemd-nspawn -D ./$NAME /bin/sh -c 'echo root:root | chpasswd'
# systemd-nspawn -D./$NAME apt-get -y install tcpdump dhcpdump screen aptitude arping

# allow dhcp to set hostname
# actually don't even need if use ansible
# systemd-nspawn -D./$NAME echo > ./$NAME/etc/hostname

## on host generate keypair - eg.  ssh-keygen -t rsa
if [ ! -f "$KEYFILE" ]; then
  echo "no keys!"
  exit
else
  sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' ./$NAME/etc/ssh/sshd_config
  mkdir ./$NAME/root/.ssh
  cat "$KEYFILE" >> ./$NAME/root/.ssh/authorized_keys
  chmod 400 ./$NAME/root/.ssh/authorized_keys
fi

# assume br0 has dnsmasq running dhcP
cat > ./$NAME/etc/network/interfaces <<- EOM
# The loopback interface
auto lo
iface lo inet loopback

# Bridge
auto host0
iface host0 inet dhcp
hwaddress ether $MAC
EOM

# OK Debian has same problem - works, but must set hostname to localhost first

# make debian or ubuntu honor dhcp
# http://askubuntu.com/questions/104918/how-to-get-the-hostname-from-a-dhcp-server
# http://blog.schlomo.schapiro.org/2013/11/setting-hostname-from-dhcp-in-debian.html

# may be a further issue of nspawn overiding hostname 

echo unset old_host_name > ./$NAME/etc/dhcp/dhclient-enter-hooks.d/unset_old_hostname

# systemd-nspawn -D./$NAME hostname localhost

echo localhost > ./$NAME/etc/hostname

