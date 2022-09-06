---
date: 2022-09-06T14:38:22+08:00
title: "记一次迁移docker data root问题"
draft: false
tags: ["环境搭建"]
keywords:
- "docker"
- "data-root"
description : "迁移docker data root"
---
书接[上回](/post/env/gitlab-ci/),公司搭了web的gitlab-ci。现在要搭android环境的ci，我选了reactnativecommunity/react-native-android作基本镜像，有10G之大，然后pull不下来，排查之后发现是docker的安装盘满了。所以就有了这次的docker data root迁移体验。

<!--more-->
## 写在前面
### 如果你是centos7，请先确认SElinuxe状况。  
> 查看SELinux状态：
> 1、/usr/sbin/sestatus -v##如果SELinux status参数为enabled即为开启状态
> SELinux status: enabled
> 2、getenforce ##也可以用这个命令检查
> 关闭SELinux：
> 
> 1、临时关闭（不用重启机器）：
> setenforce 0##设置SELinux 成为permissive模式
> ##setenforce 1 设置SELinux 成为enforcing模式
> 
> 2、修改配置文件需要重启机器：
> 修改/etc/selinux/config 文件
> 将SELINUX=enforcing改为SELINUX=disabled
**如果你不确定可以关闭戓配置SElinux白名单，请尝试其它文章。因为迁移后会导致原容器访问卷失败**

### 确认你的docker版本
``` 
docker -v
```
如果你的docker是默认安装的1.13，那么请选择方案2


1. docker info 查看你的docker root dir，
```bash
    docker info | grep 'Dir'
    Docker Root Dir: /var/lib/docker
```
2. 查看你docker root dir磁盘占用情况
```
    df -lh /var/lib
```
这个时候通常会是快满的状况，你可以选择两种解决方案。

#### 一：
1. `systemctl stop docker` 停止docker
2. `mkdir -p /home/lib/docker` 创建一个新目录，这个目录你可以自定义
3. `mv /var/lib/docker /home/lib/docker` 移动旧目录过去
4. `vim /etc/docker/daemon.json` 添加 { "data-root": "/home/lib/docker" }到原json
5. `systemctl daemon-reload` 加载配置项
6. `systemctl restart docker` 重启docker

如果报错`unable to configure the Docker daemon with file /etc/docker/daemon.js`说明你docker版本太低。 要么换方案2，要么升级docker吧。

#### 二：
跟上述步骤一样，只是把第4步换成。
4. ln -s /home/lib/docker /var/lib/docker

重启docker

如果是centos7且发现旧容器访问volume报permission denied。就临时关闭SElinux
```bash
setenforce 0
```