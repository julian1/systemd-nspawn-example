#!/bin/bash -x

NAME=wily
VERSION=wily
MIRROR=http://mirror.aarnet.edu.au/ubuntu/
MAC='00:01:04:1b:2C:1A'
KEYFILE=/home/meteo/.ssh/id_rsa.pub


if [ ! -d "$NAME" ]; then
  echo "$NAME doesnt exist - bootstrapping"
  /usr/sbin/debootstrap --verbose $VERSION ./$NAME $MIRROR || exit
fi

# ssh and python2.7 to support ansible
systemd-nspawn -D./$NAME apt-get -y update
systemd-nspawn -D./$NAME apt-get -y install ssh python2.7
systemd-nspawn -D./$NAME ln -s /usr/bin/python2.7 /usr/bin/python


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


