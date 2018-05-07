#!/bin/bash
# Install ShadowsocksR on CentOS 7

# 下载
yum install git -y
git clone -b manyuser https://github.com/shadowsocksrr/shadowsocksr.git
# 初始化
cd ~/shadowsocksr && bash initcfg.sh
# 拷贝配置文件
wget https://github.com/36bian/OneKeyScriptForLinux/raw/master/lib/user-config.json -O user-config.json -P /root/shadowsocksr
# 启动服务
cd ~/shadowsocksr/shadowsocks
python server.py -d start
# 加入开机自启
chmod +x /etc/rc.d/rc.local
echo "python /root/shadowsocksr/shadowsocks/server.py -c /root/shadowsocksr/user-config.json -d start"  >> /etc/rc.local