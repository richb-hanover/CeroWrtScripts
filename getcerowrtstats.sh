#! /bin/sh
# a collection of diagnostics to take when wifi troubles arise:

out_fqn=/tmp/wifi_debug_output.txt
radio=phy0
wlan_if=sw00
#ath9k_sub_dis=(interrupt queues xmit recv reset)


echo -e "date" >> ${out_fqn}
date > ${out_fqn}
echo -e "\n" >> ${out_fqn}

echo -e "uname -a" >> ${out_fqn}
echo $( uname -a ) >> ${out_fqn}
echo -e "\n" >> ${out_fqn}

echo -e "uptime" >> ${out_fqn}
echo $( uptime ) >> ${out_fqn}
echo -e "\n" >> ${out_fqn}

echo -e "tc -s qdisc show dev ${wlan_if}" >> ${out_fqn}
tc -s qdisc show dev ${wlan_if} >> ${out_fqn}
echo -e "\n" >> ${out_fqn}

echo -e "iw dev ${wlan_if} station dump" >> ${out_fqn}
iw dev ${wlan_if} station dump >> ${out_fqn}
echo -e "\n" >> ${out_fqn}

echo -e "cat /sys/kernel/debug/ieee80211/${radio}/ath9k/ani" >> ${out_fqn}
cat /sys/kernel/debug/ieee80211/${radio}/ath9k/ani >> ${out_fqn}
echo -e "" >> ${out_fqn}

echo -e "cat /sys/kernel/debug/ieee80211/${radio}/ath9k/interrupt" >> ${out_fqn}
cat /sys/kernel/debug/ieee80211/${radio}/ath9k/interrupt >> ${out_fqn}
echo -e "" >> ${out_fqn}

echo -e "cat /sys/kernel/debug/ieee80211/${radio}/ath9k/queues" >> ${out_fqn}
cat /sys/kernel/debug/ieee80211/${radio}/ath9k/queues >> ${out_fqn}
echo -e "" >> ${out_fqn}

echo -e "cat /sys/kernel/debug/ieee80211/${radio}/ath9k/xmit" >> ${out_fqn}
cat /sys/kernel/debug/ieee80211/${radio}/ath9k/xmit >> ${out_fqn}
echo -e "" >> ${out_fqn}

echo -e "cat /sys/kernel/debug/ieee80211/${radio}/ath9k/recv" >> ${out_fqn}
cat /sys/kernel/debug/ieee80211/${radio}/ath9k/recv >> ${out_fqn}
echo -e "" >> ${out_fqn}

echo -e "cat /sys/kernel/debug/ieee80211/${radio}/ath9k/reset" >> ${out_fqn}
cat /sys/kernel/debug/ieee80211/${radio}/ath9k/reset >> ${out_fqn}
echo -e "" >> ${out_fqn}

echo -e "logread" >> ${out_fqn}
logread >> ${out_fqn}
echo -e "\n" >> ${out_fqn}

echo -e "dmesg" >> ${out_fqn}
dmesg >> ${out_fqn}
echo -e "" >> ${out_fqn}


echo "Done... (${0})"
