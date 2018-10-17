#!/bin/bash
# ----------------------------------------------------------------------------
#本脚本为总启动脚本，执行顺序：
#先判断系统，根据是CentOS还是Debian执行不同的升级命令（更新系统），然后执行对应的子任务，如果
#无法获取到用户系统，则让用户手动选择
# ----------------------------------------------------------------------------

#判断是否Root运行#
if [ `id -u` -ne 0 ]
then
  echo "Need root, try with sudo"
  exit 0
fi

#Debian或CentOS，自动进行下一步
function autosetup(){
  echo -e "\033[36m ##################################### \033[0m"
  echo -e "\033[36m CentOS/Debian 安装菜单 \033[0m"
  echo -e "\033[36m ##################################### \033[0m"
  echo -e "\033[36m 安装 ShadowSocks 2.8.3            按 1 \033[0m"
  echo -e "\033[36m 安装 BBR ForOpenVZ（推荐加速442） 按 2 \033[0m"
  echo -e "\033[36m 安装 kcptun（441转成8379）        按 3 \033[0m"
  echo -e "\033[36m 安装 v2Ray(端口440)                     按 4 \033[0m"
  echo -e "\033[36m 设置 定时签到文本                 按 5 \033[0m"
  echo -e "\033[36m 退出请按其他键                          \033[0m"
  echo -e "\033[36m ##################################### \033[0m"
  echo -n "请输入数字:"

  read aNum
  if [[ $os=="CentOS" ]]; then
    # yum -y update #升级所有包同时也升级软件和系统内核#
    yum -y install epel-release #添加源，防止有些软件找不到#
  elif [[ $os=="Debian" ]]; then
    apt-get update && apt-get upgrade -y #更新软件包列表并升级系统中的所有软件包
  fi
  case $aNum in
    1)  echo '安装ShadowSocks...'
    rm -f ss-server.sh
    wget -N https://github.com/36bian/OneKeyScriptForLinux/raw/master/ss/ss-server.sh
    chmod +x ss-server.sh &&  ./ss-server.sh
    ;;
    2)  echo '安装BBR for OpenVZ...'
    wget https://raw.githubusercontent.com/kuoruan/shell-scripts/master/ovz-bbr/ovz-bbr-installer.sh
    chmod +x ovz-bbr-installer.sh && ./ovz-bbr-installer.sh
    ;;
    3)  echo '安装Kcptun...'
    rm -f kcptun.sh
    wget -N https://github.com/36bian/OneKeyScriptForLinux/raw/master/kcptun/kcptun.sh
    chmod +x kcptun.sh &&  ./kcptun.sh
    ;;
    4)  echo '安装V2ray...'
    rm -f go.sh
    bash <(curl -L -s https://install.direct/go.sh)
    wget https://github.com/36bian/OneKeyScriptForLinux/raw/master/v2ray/config.json -O config.json
    mv -f config.json /etc/v2ray/
    # 开启bbr支持
    echo 440 >> /usr/local/haproxy-lkl/etc/port-rules
    service haproxy-lkl restart
    service v2ray restart
    ;;
    5)  echo '设置189签到定时脚本'
    wget -N https://github.com/36bian/OneKeyScriptForLinux/raw/master/189qiandao/189qiandao.sh
    echo "0 12 * * * bash /root/189qiandao.sh" >> /etc/crontab
    crontab /etc/crontab
    # 启动crontab服务
    service crond start
	;;
    # 其他键则执行
    *)  echo '退出并清除自身文件'
    rm $0
    ;;
  esac
}

#无法识别Debian或CentOS，让手动判断
function otherOS(){
  echo -e "\033[36m can not find system type,please choose: \033[0m"
  echo -e "\033[36m 1.CentOS  \033[0m"
  echo -e "\033[36m 2.Debian/Ubuntu  \033[0m"
  echo -e "\033[36m Other number,exit  \033[0m"
  read Num
  case $Num in
    1)  os="CentOS"
    autosetup
    ;;
    2)  os="Debian"
    autosetup
    ;;
    *)  echo '退出并清除自身文件'
    rm $0
    ;;
  esac
}

#判断操作系统
function main(){
  if (grep -q -i 'red hat' /proc/version); then
    os="CentOS"
    autosetup
  elif (grep -q -i Debian /etc/issue); then
    os="Debian"
    autosetup
  else
    otherOS
  fi
}

#程序入口
main
