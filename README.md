# S-UI
**高级 Web 面板 • 基于 SagerNet/Sing-Box 构建**

![](https://img.shields.io/github/v/release/alireza0/s-ui.svg)
![S-UI Docker pull](https://img.shields.io/docker/pulls/alireza7/s-ui.svg)
[![Go Report Card](https://goreportcard.com/badge/github.com/alireza0/s-ui)](https://goreportcard.com/report/github.com/alireza0/s-ui)
[![Downloads](https://img.shields.io/github/downloads/alireza0/s-ui/total.svg)](https://img.shields.io/github/downloads/alireza0/s-ui/total.svg)
[![License](https://img.shields.io/badge/license-GPL%20V3-blue.svg?longCache=true)](https://www.gnu.org/licenses/gpl-3.0.en.html)

> **免责声明：** 本项目仅用于个人学习与交流，请勿用于非法用途，也请勿在生产环境中直接使用。

**如果你觉得这个项目对你有帮助，欢迎点一个** :star2:

**想参与贡献？** 请查看 [CONTRIBUTING.md](CONTRIBUTING.md)，其中包含开发环境、编码规范、测试与 PR 流程。

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/alireza7)

<a href="https://nowpayments.io/donation/alireza7" target="_blank" rel="noreferrer noopener">
   <img src="https://nowpayments.io/images/embeds/donation-button-white.svg" alt="Crypto donation button by NOWPayments">
</a>

## 快速概览
| 功能 | 是否支持 |
| -------------------------------------- | :----------------: |
| 多协议 | :heavy_check_mark: |
| 多语言 | :heavy_check_mark: |
| 多客户端/多入站 | :heavy_check_mark: |
| 高级流量路由界面 | :heavy_check_mark: |
| 客户端/流量/系统状态监控 | :heavy_check_mark: |
| 订阅链接（link/json/clash + info） | :heavy_check_mark: |
| 深色/浅色主题 | :heavy_check_mark: |
| API 接口 | :heavy_check_mark: |

## 支持平台
| 平台 | 架构 | 状态 |
|----------|--------------|---------|
| Linux    | amd64, arm64, armv7, armv6, armv5, 386, s390x | ✅ 已支持 |
| Windows  | amd64, 386, arm64 | ✅ 已支持 |
| macOS    | amd64, arm64 | 🚧 实验性支持 |

## 截图

!["Main"](https://github.com/alireza0/s-ui-frontend/raw/main/media/main.png)

[更多界面截图](https://github.com/alireza0/s-ui-frontend/blob/main/screenshots.md)

## API 文档

[API-Documentation Wiki](https://github.com/alireza0/s-ui/wiki/API-Documentation)

## 默认安装信息
- 面板端口：2095
- 面板路径：/app/
- 订阅端口：2096
- 订阅路径：/sub/
- 用户名/密码：admin

## 安装与升级到最新版本

### Linux/macOS
```sh
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)
```

### Windows
1. 从 [GitHub Releases](https://github.com/alireza0/s-ui/releases/latest) 下载最新 Windows 版本
2. 解压 ZIP 文件
3. 以管理员身份运行 `install-windows.bat`
4. 按安装向导完成安装

## 安装旧版本

**步骤 1：** 在安装命令末尾追加版本号即可安装指定旧版本，例如 `1.0.0`：

```sh
VERSION=1.0.0 && bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/$VERSION/install.sh) $VERSION
```

## 手动安装

### Linux/macOS
1. 在 GitHub 获取与你系统/架构匹配的最新版 S-UI：[https://github.com/alireza0/s-ui/releases/latest](https://github.com/alireza0/s-ui/releases/latest)
2. **可选**：获取最新 `s-ui.sh`：[https://raw.githubusercontent.com/alireza0/s-ui/master/s-ui.sh](https://raw.githubusercontent.com/alireza0/s-ui/master/s-ui.sh)
3. **可选**：将 `s-ui.sh` 复制到 /usr/bin/ 并执行 `chmod +x /usr/bin/s-ui`
4. 将 s-ui 的 tar.gz 解压到你选择的目录，并进入解压目录
5. 将 *.service 文件复制到 /etc/systemd/system/，然后执行 `systemctl daemon-reload`
6. 执行 `systemctl enable s-ui --now` 启用并启动 S-UI 服务
7. 执行 `systemctl enable sing-box --now` 启动 sing-box 服务

### Windows
1. 在 GitHub 获取最新 Windows 版本：[https://github.com/alireza0/s-ui/releases/latest](https://github.com/alireza0/s-ui/releases/latest)
2. 下载对应架构的 Windows 安装包（例如 `s-ui-windows-amd64.zip`）
3. 将 ZIP 解压到你选择的目录
4. 以管理员身份运行 `install-windows.bat`
5. 按安装向导完成安装
6. 在 http://localhost:2095/app 访问面板

## 卸载 S-UI

```sh
sudo -i

systemctl disable s-ui  --now

rm -f /etc/systemd/system/sing-box.service
systemctl daemon-reload

rm -fr /usr/local/s-ui
rm /usr/bin/s-ui
```

## 使用 Docker 安装

<details>
   <summary>点击展开</summary>

### 用法

**步骤 1：** 安装 Docker

```shell
curl -fsSL https://get.docker.com | sh
```

**步骤 2：** 安装 S-UI

> 使用 Docker compose

```shell
mkdir s-ui && cd s-ui
wget -q https://raw.githubusercontent.com/alireza0/s-ui/master/docker-compose.yml
docker compose up -d
```

> 使用 docker

```shell
mkdir s-ui && cd s-ui
docker run -itd \
    -p 2095:2095 -p 2096:2096 -p 443:443 -p 80:80 \
    -v $PWD/db/:/app/db/ \
    -v $PWD/cert/:/root/cert/ \
    --name s-ui --restart=unless-stopped \
    alireza7/s-ui:latest
```

> 自行构建镜像

```shell
git clone https://github.com/alireza0/s-ui
git submodule update --init --recursive
docker build -t s-ui .
```

</details>

## 手动运行（贡献开发）

<details>
   <summary>点击展开</summary>

### 构建并运行整个项目
```shell
./runSUI.sh
```

### 克隆仓库
```shell
# 克隆主仓库
git clone https://github.com/alireza0/s-ui
# 拉取子模块
git submodule update --init --recursive
```

### - 前端

前端代码请访问 [s-ui-frontend](https://github.com/alireza0/s-ui-frontend)

### - 后端
> 请先至少构建一次前端！

构建后端：
```shell
# 删除旧的前端编译文件
rm -fr web/html/*
# 复制新的前端编译产物
cp -R frontend/dist/ web/html/
# 构建
go build -o sui main.go
```

运行后端（在仓库根目录）：
```shell
./sui
```

</details>

## 语言

- 英语
- 波斯语
- 越南语
- 中文（简体）
- 中文（繁体）
- 俄语

## 功能

- 支持协议：
  - 通用：Mixed、SOCKS、HTTP、HTTPS、Direct、Redirect、TProxy
  - 基于 V2Ray：VLESS、VMess、Trojan、Shadowsocks
  - 其他协议：ShadowTLS、Hysteria、Hysteria2、Naive、TUIC
- 支持 XTLS 协议
- 高级流量路由配置界面，支持 PROXY Protocol、External、Transparent Proxy、SSL 证书与端口配置
- 高级入站/出站配置界面
- 客户端流量限额与到期时间管理
- 展示在线客户端、入站/出站流量统计与系统状态监控
- 订阅服务支持添加外部链接与订阅
- 支持 HTTPS 安全访问面板与订阅服务（需自备域名与 SSL 证书）
- 深色/浅色主题

## 环境变量

<details>
  <summary>点击展开</summary>

### 用法

| 变量 | 类型 | 默认值 |
| -------------- | :--------------------------------------------: | :------------ |
| SUI_LOG_LEVEL  | `"debug"` \| `"info"` \| `"warn"` \| `"error"` | `"info"` |
| SUI_DEBUG      | `boolean` | `false` |
| SUI_BIN_FOLDER | `string` | `"bin"` |
| SUI_DB_FOLDER  | `string` | `"db"` |
| SINGBOX_API    | `string` | - |

</details>

## SSL 证书

<details>
  <summary>点击展开</summary>

### Certbot

```bash
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

certbot certonly --standalone --register-unsafely-without-email --non-interactive --agree-tos -d <Your Domain Name>
```

</details>

## Stargazers over Time
[![Stargazers over time](https://starchart.cc/alireza0/s-ui.svg)](https://starchart.cc/alireza0/s-ui)
