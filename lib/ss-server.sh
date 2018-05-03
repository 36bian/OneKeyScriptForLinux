#!/bin/bash
# Install Shadowsocks on CentOS 7

echo "Installing Shadowsocks..."

CONFIG_FILE=/etc/shadowsocks.json
SERVICE_FILE=/etc/systemd/system/shadowsocks.service
SS_IP=`ip route get 1 | awk '{print $NF;exit}'`
GET_PIP_FILE=/tmp/get-pip.py

# install pip
curl "https://bootstrap.pypa.io/get-pip.py" -o "${GET_PIP_FILE}"
python ${GET_PIP_FILE}

# install shadowsocks
pip install --upgrade pip
pip install shadowsocks

# create shadowsocls config
cat <<EOF | sudo tee ${CONFIG_FILE}
{
  "server": "0.0.0.0",
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "port_password": {
    "441": "ShadowSocks",
    "442": "ShadowSocks"
  },
  "timeout": 600,
  "method": "aes-256-cfb"
}
EOF

# create service
cat <<EOF | sudo tee ${SERVICE_FILE}
[Unit]
Description=Shadowsocks

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/ssserver -c ${CONFIG_FILE}

[Install]
WantedBy=multi-user.target
EOF

# start service
systemctl enable shadowsocks
systemctl start shadowsocks

# view service status
sleep 5
systemctl status shadowsocks -l

echo "================================"
echo ""
echo "Congratulations! Shadowsocks has been installed on your system."
echo "You shadowsocks connection info:"
echo "--------------------------------"
echo "server:      ${SS_IP}"
echo "server_port: 441(可能转换为Kcp8379) & 442"
echo "password:    ShadowSocks"
echo "method:      aes-256-cfb"
echo "--------------------------------"