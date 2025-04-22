## R2S 基于原生 OpenWRT 的固件编译脚本 (AS IS, NO WARRANTY!!!)
### 请勿用于商业用途!!!
**同时也包含了 x86_64 版本**

### 发布地址：
（可能会翻车，风险自担，需要登录 GitHub 账号后才能下载，不提供任何形式的技术支持）  
https://github.com/KaneGreen/OpenWrt-Builder/actions  
![OpenWrt for R2S](https://github.com/KaneGreen/OpenWrt-Builder/actions/workflows/R2S-OpenWrt.yml/badge.svg?branch=master)
![OpenWrt for x86](https://github.com/KaneGreen/OpenWrt-Builder/actions/workflows/x86-OpenWrt.yml/badge.svg?branch=master)

建议对照 [变更日志](./CHANGELOG.md) 确认版本之间的变化。

### 注意事项：
1. 登陆 IP：`192.168.1.1`，密码：无。

2. R2S 版 OpenWrt 内置升级可用。

3. R2S 版不再交换 LAN WAN 网口，和上游定义一致。

4. 遇到上不了网的，请自行排查自己的 IPv6 连接情况，或禁用 IPv6（同时禁用 WAN 和 LAN 的 IPv6）（默认已关闭ipv6的dns解析，手动可以在DHCP/DNS里的高级设置中调整）

5. R2S 版 sys 灯引导时闪烁，启动后常亮，也是上游的设定，有疑问请联系 OpenWrt 官方社区。

### 版本信息：
LUCI版本：OpenWrt-24.10

其他模块版本：OpenWrt-24.10

### 特性及功能：
1. O2 优化级别。R2S 版核心频率 1.5GHz，SquashFS 格式。x86 版 EXT4 格式，非 UEFI 版本。

2. 内置一款主题，包含 SSRP，OpenClash，SQM，网络唤醒，DDNS，UPNP，FullCone（默认开启），流量分载（防火墙中手动开启），BBR v3（默认开启）。  
[完整功能列表](./featurelist.md)

3. Github Actions 里面的编译结果包含 SHA256 哈希校验和 MD5 哈希校验文件。同样的内容也会显示在 Actions 的编译日志的 `Cleaning and hashing` 步骤（倒数第四步）里。**请注意核对和校验固件文件的完整性！**

4. [清盘刷机教程](./howto_cleanflash.md)  [变更日志](./CHANGELOG.md)

### 三代壳 OLED 相关
R2S 版未编译安装 OLED 的 luci-app，有需要者自行寻找软件包安装。
x86 版不支持此功能。

### 本地一键编译脚本（实验性）
1. 首先自行配置环境， Ubuntu 22.04 可以参考 [Actions 脚本的第 56 行](.github/workflows/R2S-OpenWrt.yml)。
2. 获取一键编译脚本：[onekeybuild.sh](./onekeybuild.sh)。根据具体情况修改脚本，例如第 32 行的编译工具链的并行数。
3. 确保工作目录下没有同名目录或文件：`OpenWrt-Builder`、`buildtime.txt`。
4. 通过环境变量 `MYOPENWRTTARGET` 指定编译的固件：`R2S`、`x86`；注意区分大小写，默认编译 R2S 的固件。
5. 通过环境变量 `MYMAKENUMBER` 指定编译的并行数，默认 4 并行。
6. 用 bash 执行脚本，开始编译。

### 感谢
* [QiuSimons](https://github.com/QiuSimons/)
* [quintus-lab](https://github.com/quintus-lab/)
* [CTCGFW](https://github.com/immortalwrt/immortalwrt)
* [coolsnowwolf](https://github.com/coolsnowwolf)
* [Lienol](https://github.com/Lienol)
* [NoTengoBattery](https://github.com/NoTengoBattery)
* 以及其他所有曾为 R2S 做出努力的贡献者们。
