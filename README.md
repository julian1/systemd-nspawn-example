
## Example of bridged networking, dhcp/dns setup using dnsmasq, container creation using debootstrap, and nspawn to run the container

### Create bridge
```
apt-get install bridge-utils

vim /etc/network/interfaces
with resources/interfaces

sudo systemctl restart networking
```

### Install and configure dnsmasq
```
apt-get install dnsmasq
cp resources/container-dns  /etc/dnsmasq.d/
sudo systemctl restart dnsmasq
```

### Build and run container
```
# edit build parameters
sudo ./build.sh
sudo ./start.sh wily

ssh root@wily
```

### clear errors on machine load failure 
```
sudo systemctl reset-failed machine-wily.scope
```

