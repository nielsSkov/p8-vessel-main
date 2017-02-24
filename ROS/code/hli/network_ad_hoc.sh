#!/bin/sh
# /etc/init.d/network_ad_hoc
# This script sets up an ad-hoc network
ifconfig wlan0 down
iwconfig wlan0 mode ad-hoc
ifconfig wlan0 up
iwconfig wlan0 essid "aauship"
ifconfig wlan0 192.168.42.1 netmask 255.255.255.0
esac
exit 0

