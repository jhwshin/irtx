#!/bin/sh

# check for args
if [ -z "$1" ]; then
    echo "usage: splunk-server.sh <SPLUNK_SERVER_IP>"
    exit 1
fi

SPLUNK_SERVER_IP=$1
SPLUNK_SERVER_PATH=/opt/splunk/etc/system/local

cd ${SPLUNK_SERVER_PATH}

# create backup if it doesn't exist
if [ ! -e "inputs.conf" ]; then
    mv inputs.conf inputs.conf.bak
fi

cat << EOF > inputs.conf
[splunktcp://${SPLUNK_SERVER_IP}:9997]
disabled = 0
sourcetype = suricata
connection_host = none
compressed = true
EOF

# restart
/opt/splunk/bin/splunk restart
