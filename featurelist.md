## 功能与特性

### 重要事项
* R2S 版采用 FriendlyWrt 的默认的 WAN/LAN 口绑定。现在 WAN 口绑定在远离电源接口的那一个 RJ45 上。

### 安全性
* 防火墙设置为默认拒绝来自 WAN 口入站数据和转发。
* 未安装 ttyd 组件（网页终端）。因为该组件默认开放端口，且不使用 HTTPS。  
* 固件默认密码为空，建议刷机后尽快更改密码。

### 常用功能
|  |  |  |  |  |  |
| :---: | :---: | :---: | :---: | :---: | :---: |
| NetData 监控 | 流量监控 | 释放内存 | 定时重启 | CPU 占用率限制 | 硬盘休眠 |
| SSRP | OpenClash | 动态 DNS | WOL 网络唤醒 | WireGuard | ZeroTier |
| Aria2 | Samba4 | uHTTPd 配置 | UPnP 配置 | socat | SQM QoS |
| BBR (1) | FullCone NAT (2) | Offloading (2) | - | - | - |

1. BBR 已默认启用。
2. FullCone NAT 已默认启用（其选项在防火墙设置页面中）；软件 Offloading 需要在防火墙设置页面中，默认没有启用。  
3. FTP 支持由 vsftpd-tls 提供。没用图形界面，须使用命令行手工配置。建议开启TLS以提高安全性。  
4. 以下组件在本固件中不包含：  
ttyd（网页终端）、Docker、单线/多线多拨、KMS 服务器、访问时间控制、WiFi 排程、beardropper（SSH 公网访问限制）、应用过滤、三代壳 OLED 程序、SmartDNS、dnsproxy、Server 酱、网易云音乐解锁、USB 打印机、迅雷快鸟、pandownload-fake-server、frpc/frps 内网穿透、OpenVPN、京东自动签到、Transmission、qBittorrent。

### 命令行特性
* `cmp`、`find`、`grep`、`gzip`、`gunzip`、`ip`、`login`、`md5sum`、`mount`、`passwd`、`sha256sum`、`tar`、`umount`、`xargs`、`zcat` 等命令替换为 GNU 实现或其他更标准的实现。
* SSH 客户端由 OpenSSH 提供（而不是 Dropbear），提供更标准的 SSH 连接体验。（服务端仍然是 Dropbear）
* F2FS、EXT4、FAT32、BTRFS 文件系统支持。EXT4 支持 acl 和 attr 。
* Python3 解释型语言支持。
* `curl` 和 `wget` 两大常用工具。
* 由 openssh-sftp-server 提供 SFTP 协议文件传输功能。由 openssh-keygen 提供 SSH 密钥对生成。
* 常用命令行工具：bc、file、htop、lsof、nohup、pv、timeout、tree、xxd、split。
* 文本编辑器：nano、vim。其中 vim 已添加一个[简单的配置文件](./PRECONFS/vimrc)。
* 终端复用工具：screen、tmux。其中 screen 已添加一个[简单的配置文件](./PRECONFS/screenrc)。
* 网络相关工具：dig、ethtool、host、ifstat、iftop、iperf3、ncat、nmap、nping、ss。
* 压缩工具：zstd、unzip、bzip2、xz。
* 文件同步工具：rsync。
* 密码学工具：GnuPG。
* 硬盘自检工具：smartmontools。
* 磁盘分区工具：cfdisk（MBR/GPT 分区表均支持）。

### OpneSSL
* 支持签发自签名证书。

### 无线网卡
* 理论上支持部分 USB 无线网卡，未测试。

### 三代壳 OLED 相关 （仅 R2S 版）
* 未安装 OLED 的 luci-app 和对应的程序。  
需要 OLED 功能的用户，自行寻找/选择适合的软件包安装即可，同时不要忘记安装依赖包 i2c-tools。

### 区别
x86 版具有 AMD 和 Intel 的 CPU 微码。  
而 R2S 版比 x86 版，添加了 CPU 频率调节。
x86 版的 UPnP 默认没有开启，有需要的请手动开启。
