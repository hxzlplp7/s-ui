#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

SUI_GITHUB_PROXY=${SUI_GITHUB_PROXY:-}
if [[ -n "$SUI_GITHUB_PROXY" && "${SUI_GITHUB_PROXY: -1}" != "/" ]]; then
    SUI_GITHUB_PROXY="${SUI_GITHUB_PROXY}/"
fi

GITHUB_REPO_URL="https://github.com/alireza0/s-ui"
GITHUB_API_URL="https://api.github.com/repos/alireza0/s-ui"

build_download_url() {
    local url="$1"
    if [[ -n "$SUI_GITHUB_PROXY" ]]; then
        echo "${SUI_GITHUB_PROXY}${url}"
    else
        echo "$url"
    fi
}

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}致命错误：${plain} 请使用 root 权限运行此脚本\n " && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "无法识别系统发行版，请联系作者！" >&2
    exit 1
fi
echo "系统发行版：$release"

arch() {
    case "$(uname -m)" in
    x86_64 | x64 | amd64) echo 'amd64' ;;
    i*86 | x86) echo '386' ;;
    armv8* | armv8 | arm64 | aarch64) echo 'arm64' ;;
    armv7* | armv7 | arm) echo 'armv7' ;;
    armv6* | armv6) echo 'armv6' ;;
    armv5* | armv5) echo 'armv5' ;;
    s390x) echo 's390x' ;;
    *) echo -e "${green}不支持的 CPU 架构！${plain}" && rm -f install.sh && exit 1 ;;
    esac
}

echo "系统架构：$(arch)"

install_base() {
    case "${release}" in
    centos | almalinux | rocky | oracle)
        yum -y update && yum install -y -q wget curl tar tzdata
        ;;
    fedora)
        dnf -y update && dnf install -y -q wget curl tar tzdata
        ;;
    arch | manjaro | parch)
        pacman -Syu && pacman -Syu --noconfirm wget curl tar tzdata
        ;;
    opensuse-tumbleweed)
        zypper refresh && zypper -q install -y wget curl tar timezone
        ;;
    *)
        apt-get update && apt-get install -y -q wget curl tar tzdata
        ;;
    esac
}

config_after_install() {
    echo -e "${yellow}正在迁移数据...${plain}"
    /usr/local/s-ui/sui migrate
    
    echo -e "${yellow}安装/升级完成！为安全起见，建议立即修改面板设置。${plain}"
    read -p "是否继续修改设置 [y/n]? ": config_confirm
    if [[ "${config_confirm}" == "y" || "${config_confirm}" == "Y" ]]; then
        echo -e "请输入${yellow}面板端口${plain}（留空表示使用当前/默认值）："
        read config_port
        echo -e "请输入${yellow}面板路径${plain}（留空表示使用当前/默认值）："
        read config_path

        # Sub configuration
        echo -e "请输入${yellow}订阅端口${plain}（留空表示使用当前/默认值）："
        read config_subPort
        echo -e "请输入${yellow}订阅路径${plain}（留空表示使用当前/默认值）：" 
        read config_subPath

        # Set configs
        echo -e "${yellow}正在初始化，请稍候...${plain}"
        params=""
        [ -z "$config_port" ] || params="$params -port $config_port"
        [ -z "$config_path" ] || params="$params -path $config_path"
        [ -z "$config_subPort" ] || params="$params -subPort $config_subPort"
        [ -z "$config_subPath" ] || params="$params -subPath $config_subPath"
        /usr/local/s-ui/sui setting ${params}

        read -p "是否修改管理员账号密码 [y/n]? ": admin_confirm
        if [[ "${admin_confirm}" == "y" || "${admin_confirm}" == "Y" ]]; then
            # First admin credentials
            read -p "请设置用户名：" config_account
            read -p "请设置密码：" config_password

            # Set credentials
            echo -e "${yellow}正在初始化，请稍候...${plain}"
            /usr/local/s-ui/sui admin -username ${config_account} -password ${config_password}
        else
            echo -e "${yellow}当前管理员账号信息：${plain}"
            /usr/local/s-ui/sui admin -show
        fi
    else
        echo -e "${red}已取消配置...${plain}"
        if [[ ! -f "/usr/local/s-ui/db/s-ui.db" ]]; then
            local usernameTemp=$(head -c 6 /dev/urandom | base64)
            local passwordTemp=$(head -c 6 /dev/urandom | base64)
            echo -e "检测到全新安装，将随机生成登录信息以提升安全性："
            echo -e "###############################################"
            echo -e "${green}用户名：${usernameTemp}${plain}"
            echo -e "${green}密码：${passwordTemp}${plain}"
            echo -e "###############################################"
            echo -e "${red}如果忘记登录信息，可输入 ${green}s-ui${red} 打开配置菜单。${plain}"
            /usr/local/s-ui/sui admin -username ${usernameTemp} -password ${passwordTemp}
        else
            echo -e "${red}检测到升级安装，将保留旧设置；若忘记登录信息，可输入 ${green}s-ui${red} 打开配置菜单。${plain}"
        fi
    fi
}

prepare_services() {
    if [[ -f "/etc/systemd/system/sing-box.service" ]]; then
        echo -e "${yellow}正在停止 sing-box 服务...${plain}"
        systemctl stop sing-box
        rm -f /usr/local/s-ui/bin/sing-box /usr/local/s-ui/bin/runSingbox.sh /usr/local/s-ui/bin/signal
    fi
    if [[ -e "/usr/local/s-ui/bin" ]]; then
        echo -e "###############################################################"
        echo -e "${green}/usr/local/s-ui/bin${red} 目录已存在！"
        echo -e "请检查目录内容，并在迁移完成后手动删除。${plain}"
        echo -e "###############################################################"
    fi
    systemctl daemon-reload
}

install_s-ui() {
    cd /tmp/

    local arch_name
    arch_name=$(arch)

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "$(build_download_url "${GITHUB_API_URL}/releases/latest")" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            last_version="latest"
        fi
        echo -e "获取到 s-ui 最新版本：${last_version}，开始安装..."
        url="$(build_download_url "${GITHUB_REPO_URL}/releases/latest/download/s-ui-linux-${arch_name}.tar.gz")"
        wget -N --no-check-certificate -O /tmp/s-ui-linux-${arch_name}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}下载 s-ui 失败，请确认服务器可访问 GitHub（或设置 SUI_GITHUB_PROXY）。${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="$(build_download_url "${GITHUB_REPO_URL}/releases/download/${last_version}/s-ui-linux-${arch_name}.tar.gz")"
        echo -e "开始安装 s-ui v$1"
        wget -N --no-check-certificate -O /tmp/s-ui-linux-${arch_name}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}下载 s-ui v$1 失败，请检查该版本是否存在。${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/s-ui/ ]]; then
        systemctl stop s-ui
    fi

    tar zxvf s-ui-linux-${arch_name}.tar.gz
    rm s-ui-linux-${arch_name}.tar.gz -f

    chmod +x s-ui/sui s-ui/s-ui.sh
    cp s-ui/s-ui.sh /usr/bin/s-ui
    cp -rf s-ui /usr/local/
    cp -f s-ui/*.service /etc/systemd/system/
    rm -rf s-ui

    config_after_install
    prepare_services

    systemctl enable s-ui --now

    echo -e "${green}s-ui v${last_version}${plain} 安装完成，服务已启动。"
    echo -e "可通过以下地址访问面板：${green}"
    /usr/local/s-ui/sui uri
    echo -e "${plain}"
    echo -e ""
    s-ui help
}

echo -e "${green}开始执行安装...${plain}"
install_base
install_s-ui $1
