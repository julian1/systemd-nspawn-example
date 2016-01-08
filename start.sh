#!/bin/bash
NAME=$1

/usr/bin/systemd-nspawn -D$(pwd)/$NAME -b --network-bridge=br0   

