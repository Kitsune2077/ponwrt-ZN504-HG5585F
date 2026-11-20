#!/bin/sh
# HG5382A 2.5G (lan1) bridge mode setup per docs/FLASHING.md
# - moves lan1 out of br-lan into a pure L2 bridge br-wan with pon0
# - wan becomes proto=none on br-wan (PPPoE handled downstream)
# - adds management IP 192.168.9.1/24 on br-wan behind a tight firewall zone
set -e

ts=$(date +%Y%m%d-%H%M%S)
cp /etc/config/network "/etc/config/network.bak.$ts"
cp /etc/config/firewall "/etc/config/firewall.bak.$ts"
echo "backed up to /etc/config/{network,firewall}.bak.$ts"

# 1) shrink br-lan to the gigabit management ports (lan2-lan4)
dev=$(uci show network | sed -n "s/^network\.\(.*\)\.name='br-lan'$/\1/p" | head -n1)
uci -q delete "network.$dev.ports"
uci add_list "network.$dev.ports='lan2'"
uci add_list "network.$dev.ports='lan3'"
uci add_list "network.$dev.ports='lan4'"

# 2) new pure layer-2 bridge: pon0 + lan1 (2.5G)
uci set network.brwan='device'
uci set network.brwan.name='br-wan'
uci set network.brwan.type='bridge'
uci add_list network.brwan.ports='pon0'
uci add_list network.brwan.ports='lan1'

# 3) wan points at the bridge, no protocol / no IP; drop wan6
uci set network.wan.device='br-wan'
uci set network.wan.proto='none'
uci -q delete network.wan6

# 4) management IP on br-wan (untagged case), no default route
uci set network.mgmtwan=interface
uci set network.mgmtwan.proto='static'
uci set network.mgmtwan.device='br-wan'
uci set network.mgmtwan.ipaddr='192.168.9.1'
uci set network.mgmtwan.netmask='255.255.255.0'
uci set network.mgmtwan.defaultroute='0'

uci commit network

# 5) firewall: lock the management IP down to the router's virtual IP
uci add firewall zone
uci set firewall.@zone[-1].name='mgmtwan'
uci set firewall.@zone[-1].input='REJECT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='REJECT'
uci add_list firewall.@zone[-1].network='mgmtwan'

uci add firewall rule
uci set firewall.@rule[-1].name='Allow-mgmt-from-router'
uci set firewall.@rule[-1].src='mgmtwan'
uci set firewall.@rule[-1].src_ip='192.168.9.254/32'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='22 80 443'
uci set firewall.@rule[-1].target='ACCEPT'

uci commit firewall
echo "uci config committed"

echo "restarting network..."
/etc/init.d/network restart
/etc/init.d/firewall restart
sleep 3

echo "=== link state ==="
ip -br link
echo "=== br-wan address (expect 192.168.9.1/24) ==="
ip -4 addr show br-wan
echo "=== bridge members ==="
bridge link
