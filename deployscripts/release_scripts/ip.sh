#!/bin/bash


/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-eth1 &>/dev/null
if [ $? -eq 0 ];then
	IP=$(/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-eth1|/bin/cut -d"=" -f2)
fi

/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-eth2 &>/dev/null
if [ $? -eq 0 ];then
	IP=$(/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-eth2|/bin/cut -d"=" -f2)
fi


/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-eth0 &>/dev/null
if [ $? -eq 0 ];then
	IP=`/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-eth0|/bin/cut -d"=" -f2`
fi

/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond0 &>/dev/null
if [ $? -eq 0 ];then
	IP=`/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond0|/bin/cut -d"=" -f2`
fi

/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond1 &>/dev/null
if [ $? -eq 0 ];then
	IP=`/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond1|/bin/cut -d"=" -f2`
fi

/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond2 &>/dev/null
if [ $? -eq 0 ];then
	IP=`/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond2|/bin/cut -d"=" -f2`
fi

/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond3 &>/dev/null
if [ $? -eq 0 ];then
	IP=`/bin/grep -o "IPADDR=192[0-9,.]*" /etc/sysconfig/network-scripts/ifcfg-bond3|/bin/cut -d"=" -f2`
fi
echo $IP

