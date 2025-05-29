# irtx

If `git` is not installed, use `curl`:
```bash
curl -L -O irtx.zip https://github.com/jhwshin/irtx/archive/refs/heads/main.zip

# unzip repo
unzip main.zip
```

Splunk Forwarder:
```bash
cd irtx-main/shared

./splunk-forwarder.sh <SPLUNK_SERVER_IP>
```

Splunk Server:
```bash
cd irtx-main/shared

sudo ./splunk-server.sh <SPLUNK_FORWARDER_IP>
```