---
title: "[柳比歇夫时间管理] 运维篇"
date: 2020-09-29T02:51:19+08:00
draft: true
tags: ["linux", "nginx", "centos"]
---

## 目录
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [后端篇](/post/time-mgt/back-end/)  
> [运维篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  

## 环境信息
``` bash
[root@furan ~]# cat /etc/centos-release
CentOS Linux release 7.8.2003 (Core)
[root@furan ~]# nginx -v
nginx version: nginx/1.18.0
```

## nginx 安装配置 

### nginx安装 [官方文档](https://nginx.org/en/linux_packages.html#RHEL-CentOS)
1. 先要安装`yum-utils`
```bash
sudo yum install yum-utils
```
2. 然后在`/etc/yum.repos.d/`路径下新建`nginx.repo`文件。直接
```bash
vim /etc/yum.repos.d/nginx.repo
```
> vim没有安装就先安装
> ```bash
> yum install vim
> ```
3. 在`/etc/yum.repos.d/nginx.repo`里写入以下内容，并保存。
```
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```
4. 运行以下命令
```bash
yum install nginx
```
5. 配置开机启动
```bash
systemctl enable nginx
```
6. 启动
```bash
systemctl start nginx
```

#### 附录 常用命令

> 启动 Nginx
> ```bash
> systemctl start nginx
> ```
> 停止 Nginx
> ```bash
> systemctl stop nginx
> ```
> 重启 Nginx
> ```bash
> systemctl restart nginx
> ```
> 修改 Nginx 配置后，重新加载
> ```bash
> systemctl reload nginx
> ```
> 设置开机启动 Nginx
> ```bash
> systemctl enable nginx
> ```
> 关闭开机启动 Nginx
> ```bash
> systemctl disable nginx
> ```

### nginx配置