#!/usr/bin/env bash

SPLUNK_SERVER=$1

# ----------------------------------------------------------
#   SERVER VARIABLES
# ----------------------------------------------------------

# inputs.conf
SPLUNK_SERVER_INPUT_PATH="/opt/splunk/etc/system/local/inputs.conf"
SPLUNK_SERVER_INPUT="[splunktcp://${SPLUNK_SERVER}:9997]
disabled = 0
sourcetype = suricata
connection_host = none
compressed = true
"

# ----------------------------------------------------------
#   FORWARDER VARIABLES
# ----------------------------------------------------------

PFSENSE_SERVER="192.168.0.1"
PFSENSE_USER="admin"
PFSENSE_PASS="labadmin"

# config.xml
PFSENSE_CONF_PATH="/cf/conf/config.xml"

# inputs.conf
FORWARDER_INPUT_PATH="/opt/splunkforwarder/etc/system/local/inputs.conf"
FORWARDER_INPUT="[monitor:///var/log/suricata/suricata_em331133/eve.json]
sourcetype = suricata
disabled = 0
"

# outputs.conf
FORWARDER_OUTPUT_PATH="/opt/splunkforwarder/etc/system/local/outputs.conf"
FORWARDER_OUTPUT="[tcpout]
defaultGroup=my_indexers

[tcpout:my_indexers]
server=${SPLUNK_SERVER}:9997
"

setup_splunk_forwarder() {
    echo -e "> Setting up Forwarder...\n"

    REMOTE_SCRIPT=$(cat <<EOF
set -e

# generate pfsense config
curl http://localhost > /dev/null

# Backup
cp "${FORWARDER_INPUT_PATH}" "${FORWARDER_INPUT_PATH}.bak"
cp "${FORWARDER_OUTPUT_PATH}" "${FORWARDER_OUTPUT_PATH}.bak"
cp "${PFSENSE_CONF_PATH}" "${PFSENSE_CONF_PATH}.bak"

# Write configs
cat > "${FORWARDER_INPUT_PATH}" << 'INPUT_EOF'
${FORWARDER_INPUT}
INPUT_EOF

cat > "${FORWARDER_OUTPUT_PATH}" << 'OUTPUT_EOF'
${FORWARDER_OUTPUT}
OUTPUT_EOF

# Modify config
sed -i '' "s|<remoteserver>.*</remoteserver>|<remoteserver>${SPLUNK_SERVER}:9997</remoteserver>|" "${PFSENSE_CONF_PATH}"

# Restart services (suricata, pfsense and splunk forwarder)
/usr/local/etc/rc.d/suricata onerestart
/etc/rc.reload_all
/opt/splunkforwarder/bin/splunk restart
EOF
    )

    sshpass -p "${PFSENSE_PASS}" \
    ssh -o StrictHostKeyChecking=no "${PFSENSE_USER}@${PFSENSE_SERVER}" /bin/sh <<< "${REMOTE_SCRIPT}"

    echo -e "> Forwarder Setup Complete!\n"
}

setup_server() {
    echo -e "> Setting up Server...\n"

    # usage
    if [ -z "$1" ]; then
        echo "usage: $0 <SPLUNK_SERVER_IP>"
        exit 1
    fi

    # backup
    cp "${SPLUNK_SERVER_INPUT_PATH}" "${SPLUNK_SERVER_INPUT_PATH}.bak"

    echo "${SPLUNK_SERVER_INPUT}" > ${SPLUNK_SERVER_INPUT_PATH}

    # restart server
    /opt/splunk/bin/splunk restart

    echo -e "> Server Setup Complete!\n"
}

setup_machine() {

    echo -e "> Installing Applications ...\n"

    sudo apt update && sudo apt install -y sshpass && sync && wait

    echo -e "> Applications Installed!\n"
}

echo -e "> Setting up Blue Team...\n"

setup_splunk_server $1
setup_splunk_forwarder

echo -e "> Blue Team Setup Complete!\n"