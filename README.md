# irtx


## Blue Team

### Setup

Script will setup:
 - `Splunk` Server
 - `Splunk Forwarder` on `pFSense`
 - Forward `syslogs` on `Metasploitable` to `Splunk`
 - Forward `syslogs` on `Blackbox` to `Splunk`

1. Clone repo from __Splunk Server Machine__
```bash
# install git
sudo apt install git

# clone repo
git clone https://github.com/jhwshin/irtx

# run script and input splunk creds when prompted
cd irtx/shared
sudo blue_setup.sh <SPLUNK_IP>
```

2. Enable Splunk to receive syslogs:

`Settings > Data Inputs > UDP > New Local UDP`

`Port > 514 (UDP) > Next`

`Select Source Type > Operating System > syslog > Review > Submit`