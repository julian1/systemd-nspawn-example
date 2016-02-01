#!/bin/bash -x
NAME=$1


# systemctl list-units -a | grep $NAME

systemctl stop machine-$NAME.scope
systemctl reset-failed machine-$NAME.scope

brctl delif br0  vb-$NAME

/sbin/ifconfig vb-$NAME down
/sbin/ifdown vb-$NAME

# machinectl list -a | grep $NAME
# machinectl kill $NAME

# systemctl disable machine-$NAME.scope


