#!/bin/sh

SPLUNK_SERVER_IP=$1
SPLUNK_FORWARDER_PATH=/opt/splunkforwarder/etc/system/local

# 1. set pfsense
if [ ! -e "/cf/conf/config.xml.bak" ]; then
    mv /cf/conf/config.xml /cf/conf/config.xml.bak
fi

rm /tmp/config.cache

sed -i '' "s|<remoteserver>.*</remoteserver>|<remoteserver>${SPLUNK_SERVER_IP}:9997</remoteserver>|" /cf/conf/config.xml

# 2. edit inputs.conf
cd ${SPLUNK_FORWARDER_PATH}

if [ ! -e "inputs.conf" ]; then
    mv inputs.conf inputs.conf.bak
fi

cat << EOF > "inputs.conf"
[monitor:///var/log/sulsricata/suricata_em331133/eve.json]
sourcetype = suricata
disabled = 0
EOF

# 3. edit outputs.conf
if [ ! -e "outputs.conf" ]; then
    mv outputs.conf outputs.conf.bak
fi

cat << EOF > "outputs.conf"
[tcpout]
defaultGroup=my_indexers

[tcpout:my_indexers]
server=${SPLUNK_SERVER_IP}:9997
EOF

#/opt/splunkforwarder/bin/splunk restart
