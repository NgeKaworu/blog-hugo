---
date: 2022-10-11T10:39:29+08:00
title: "记一次Centos 8 Network Network Is Unreachable 报错"
draft: false
tags: ["环境搭建"]
keywords:
- "centos8"
- "docker"
- "network"
- "nmcli"
- "ip"
description : "centos8及内部docker无法访问外网问题"
---

今天早上，我的梯子断了，我用快照新作了一个梯子，但是梯子却访问不了外网
```sh 
$ ping 123.456.789.0
connect: network is unreachable
```

<!--more-->

通过`systemctl status network`排查发现是旧网卡和新网不一致造成的

用`ip link show` 查看你当前网上
```sh
$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq state UP mode DEFAULT group default qlen 1000
    link/ether 56:00:04:2a:ed:84 brd ff:ff:ff:ff:ff:ff
```

一般`ens3`这种`en`开头的就是你的设备，
然后到`/etc/sysconfig/network-scripts`路径下找到类似的文件
```sh
ls -l /etc/sysconfig/network-scripts
total 220
-rw-r--r--. 1 root root    95 Oct 11 03:36 ifcfg-enp1s0
-rwxr-xr-x. 1 root root  2123 Feb 15  2021 ifdown
-rwxr-xr-x. 1 root root  1621 Jul 26  2020 ifdown-Team
-rwxr-xr-x. 1 root root  1556 Jul 26  2020 ifdown-TeamPort
```
可以看到我旧网上是`ifcfg-enp1s0`，现在的是ens3，用`vi`编辑这个文件
```
TYPE="Ethernet"
DEVICE="enp1s0"  // 替换成 ens3
ONBOOT="yes"
BOOTPROTO="dhcp"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"

```

然后`systemctl restart network`重启网络服务，就能访问外网了。


#### docker 访问不了外网

改了网上后需要重置一下docker网卡
1. 停止所有容器
```sh
docker stop $(docker ps -a -q)
```

2. 停止service
```sh
systemctl stop docker
```

3. 关闭 docker 相关的虚拟网卡设备
```sh
ip link set docker0 down
```
4. 查看所有网桥
```sh
$ nmcli

br-2f642dfe9595: connected (externally) to br-2f642dfe9595
        "br-2f642dfe9595"
        bridge, 02:42:9B:CA:5B:47, sw, mtu 1500
        inet4 172.19.0.1/16
        route4 172.19.0.0/16
        route6 ff00::/8

br-e04cb26dd95a: connected (externally) to br-e04cb26dd95a
        "br-e04cb26dd95a"
        bridge, 02:42:BC:B4:DF:93, sw, mtu 1500
        inet4 172.18.0.1/16
        route4 172.18.0.0/16
        route6 ff00::/8

docker0: connected (externally) to docker0
        "docker0"
        bridge, 02:42:68:21:0D:24, sw, mtu 1500
        inet4 172.17.0.1/16
        route4 172.17.0.0/16
```
5. 删除 docker0 等桥接设备（必须删除 docker0 ，否则没有用）
```sh
nmcli con del docker0

nmcli con del br-2f642dfe9595
nmcli con del br-e04cb26dd95a

```
6. 重启nmcli配置
```sh
nmcli con reload
```
7. 重启docker
```sh
systemctl restart docker
```