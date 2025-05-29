#!/bin/sh

SPLUNK_FORWARDER_IP=$1
SPLUNK_SERVER_PATH=/opt/splunk/etc/system/local

cd ${SPLUNK_SERVER_PATH}

# create backup if it doesn't exist
if [ ! -e "inputs.conf" ]; then
    mv inputs.conf inputs.conf.bak
fi

cat << EOF > inputs.conf
[splunktcp://${SPLUNK_FORWARDER_IP}:9997]
disabled = 0
sourcetype = suricata
connection_host = none
compressed = true
EOF

# restart
/opt/splunk/bin/splunk restart
