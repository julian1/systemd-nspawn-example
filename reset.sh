#!/bin/bash -x
NAME=$1


# sudo systemctl list-units -a | grep $NAME

sudo systemctl stop machine-$NAME.scope
sudo systemctl reset-failed machine-$NAME.scope

sudo /sbin/ifconfig vb-$NAME down
sudo /sbin/ifdown vb-$NAME

# sudo machinectl list -a | grep $NAME
# sudo machinectl kill $NAME

# sudo systemctl disable machine-$NAME.scope


