#!/bin/sh

echo "Stopping firewall and allowing everyone..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT


# route outgoing
# iptables  -t nat -A POSTROUTING   -s 10.1.1.0/24   -j MASQUERADE
iptables  -t nat -A POSTROUTING   -s 10.10.1.0/24   -j MASQUERADE


# route to container
#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.1.1.18 
#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 10.1.1.18 
#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j DNAT --to-destination 10.1.1.18 



