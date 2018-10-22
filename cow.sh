#!/bin/bash

version=0.9.8

arch=`uname -m`
case $arch in
    "x86_64")
        arch="64"
        ;;
    "i386" | "i586" | "i486" | "i686")
        arch="32"
        ;;
    "armv5tel" | "armv6l" | "armv7l")
        features=`cat /proc/cpuinfo | grep Features`
        if [[ ! "$features" =~ "vfp" ]]; then
            #arm without vfp must use GOARM=5 binary
            #see https://github.com/golang/go/wiki/GoArm
            arch="-armv5tel"
        else
            arch="-$arch"
        fi
        ;;
    *)
        echo "$arch currently has no precompiled binary"
        ;;
esac

os=`uname -s`
case $os in
    "Darwin")
        os="mac"
        ;;
    "Linux")
        os="linux"
        ;;
    *)
        echo "$os currently has no precompiled binary"
        exit 1
esac

exit_on_fail() {
    if [ $? != 0 ]; then
        echo $1
        exit 1
    fi
}

while true; do
    # Get install directory from environment variable.
    if [[ -n $COW_INSTALLDIR && -d $COW_INSTALLDIR ]]; then
        install_dir=$COW_INSTALLDIR
        break
    fi

    # Get installation directory from user
    echo -n "Install cow binary to which directory (absolute path, defaults to current dir): "
    read install_dir </dev/tty
    if [ -z $install_dir ]; then
        echo "No installation directory given, assuming Home directory"
        install_dir=/users/`whoami`
        break
    fi
    if [ ! -d $install_dir ]; then
        echo "Directory $install_dir does not exists"
    else
        break
    fi
done

# Ask OS X user whehter to start COW upon login
start_on_login="n"
if [ $os == "mac" ]; then
    while true; do
        echo -n "Start COW upon login? (If yes, download a plist file to ~/Library/LaunchAgents) [Y/n] "
        read start_on_login </dev/tty
        case $start_on_login in
        "Y" | "y" | "")
            start_on_login="y"
            break
            ;;
        "N" | "n")
            start_on_login="n"
            break
            ;;
        esac
    done
fi

# Download COW binary
binary_url="https://github.com/OMGZui/go/raw/master/cow.zip" # 修改下载地址
curl -L "$binary_url" -o ${install_dir}/cow.zip || \
    exit_on_fail "Downloading cow binary failed"
unzip -o ${install_dir}/cow.zip -d ${install_dir}/ || exit_on_fail "unzip $tmpbin.zip failed"
rm ${install_dir}/cow.zip

# Download sample config file if no configuration directory present
doc_base="https://raw.github.com/cyfdecyf/cow/$version/doc"
config_dir="$HOME/.cow"
is_update=true
if [ ! -e $config_dir ]; then
    is_update=false
    sample_config_base="${doc_base}/sample-config"
    echo "Downloading sample config file to $config_dir"
    mkdir -p $config_dir || exit_on_fail "Can't create $config_dir directory"
    for f in rc; do
        echo "Downloading $sample_config_base/$f to $config_dir/$f"
        curl -L "$sample_config_base/$f" -o $config_dir/$f || \
            exit_on_fail "Downloading sample config file $f failed"
    done
fi

# Download startup plist file
if [ $start_on_login == "y" ]; then
    la_dir="$HOME/Library/LaunchAgents"
    plist="info.chenyufei.cow.plist"
    plist_url="$doc_base/osx/$plist"
    mkdir -p $la_dir && exit_on_fail "Can't create directory $la_dir"
    echo "Downloading $plist_url to $la_dir/$plist"
    curl -L "$plist_url" | \
        sed -e "s,COWBINARY,$install_dir/cow," > $la_dir/$plist || \
        exit_on_fail "Download startup plist file to $la_dir failed"
fi

# 配置rc
echo "正在配置代理地址，请输入主机ip："
read hostip
echo "请输入主机端口："
read hostport
echo "proxy = ss://aes-256-cfb:ShadowSocks@${hostip}:${hostport}" >> ${HOME}/.cow/rc

# 后台启动cow
${install_dir}/cow &

# 设置代理
networksetup -setautoproxyurl "Wi-Fi" http://127.0.0.1:7777/pac
networksetup -setproxybypassdomains Wi-Fi 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

# Done
echo
if $is_update; then
    echo "Update finished."
else
    echo "Installation finished."
    echo "Please edit $config_dir/rc according to your own settings."
    echo 'After that, execute "cow &" to start cow and run in background.'
fi
