#!/bin/sh
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -N KNOCKING
iptables -N GATE1
iptables -N GATE2
iptables -N GATE3
iptables -N PASSED
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -j KNOCKING
iptables -A GATE1 -p tcp --dport 1111 -m recent --name AUTH1 --set -j DROP
iptables -A GATE1 -j DROP
iptables -A GATE2 -m recent --name AUTH1 --remove
iptables -A GATE2 -p tcp --dport 2222 -m recent --name AUTH2 --set -j DROP
iptables -A GATE2 -j GATE1
iptables -A GATE3 -m recent --name AUTH2 --remove
iptables -A GATE3 -p tcp --dport 3333 -m recent --name AUTH3 --set -j DROP
iptables -A GATE3 -j GATE1
iptables -A PASSED -m recent --name AUTH3 --remove
iptables -A PASSED -p tcp --dport 22 -j ACCEPT
iptables -A PASSED -j GATE1
iptables -A KNOCKING -m recent --rcheck --seconds 60 --name AUTH3 -j PASSED
iptables -A KNOCKING -m recent --rcheck --seconds 30 --name AUTH2 -j GATE3
iptables -A KNOCKING -m recent --rcheck --seconds 30 --name AUTH1 -j GATE2
iptables -A KNOCKING -j GATE1