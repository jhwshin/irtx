#!/bin/sh

# check for args
if [ -z "$1" ]; then
    echo "usage: splunk_forwarder.sh <SPLUNK_SERVER_IP>"
    exit 1
fi

SPLUNK_SERVER_IP=$1
SPLUNK_FORWARDER_PATH=/opt/splunkforwarder/etc/system/local

# 1. setup pfsense

# create backup if it doesn't exist
if [ ! -e "/cf/conf/config.xml.bak" ]; then
    mv /cf/conf/config.xml /cf/conf/config.xml.bak
fi

rm /tmp/config.cache

sed -i '' "s|<remoteserver>.*</remoteserver>|<remoteserver>${SPLUNK_SERVER_IP}:9997</remoteserver>|" /cf/conf/config.xml

# 2. edit inputs.conf
cd ${SPLUNK_FORWARDER_PATH}

# create backup if it doesn't exist
if [ ! -e "inputs.conf" ]; then
    mv inputs.conf inputs.conf.bak
fi

cat << EOF > "inputs.conf"
[monitor:///var/log/suricata/suricata_em331133/eve.json]
sourcetype = suricata
disabled = 0
EOF

# 3. edit outputs.conf

# create backup if it doesn't exist
if [ ! -e "outputs.conf" ]; then
    mv outputs.conf outputs.conf.bak
fi

cat << EOF > "outputs.conf"
[tcpout]
defaultGroup=my_indexers

[tcpout:my_indexers]
server=${SPLUNK_SERVER_IP}:9997
EOF

# restart
/opt/splunkforwarder/bin/splunk restart
