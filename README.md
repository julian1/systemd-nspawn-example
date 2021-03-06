
## Example of bridged networking, dhcp/dns setup using dnsmasq, container creation using debootstrap, and nspawn to run the container

### Create bridge br0 and configure dnsmasq
```
apt-get install bridge-utils

vim /etc/network/interfaces
with resources/interfaces

sudo systemctl restart networking


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

# discovery
sudo arp-scan -I br0  --localnet

```

### To clear possible errors on machine load failure 
```

sudo systemctl list-units -a

sudo systemctl stop machine-jessie.scope
sudo systemctl reset-failed machine-jessie.scope

sudo /sbin/ifconfig vb-jessie2 down

sudo machinectl list -a
sudo machinectl kill jessie

sudo systemctl disable machine-jessie.scope
```


### Chef Provisioning
```
 cd systemd-nspawn-example/
 sudo ./build.sh 
 sudo ./start.sh 
 sudo systemctl  start wily 
 ssh-keygen -f "/home/user/.ssh/known_hosts" -R wily
 ssh root@wily
 cd chef
 knife solo prepare root@wily
 knife solo cook root@wily  -N wily  ./nodes/node.json 2>&1 | tee log.txt
 ssh root@wily
```

