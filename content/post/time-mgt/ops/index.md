---
title: "[柳比歇夫时间管理] 部署篇"
date: 2020-09-29T02:51:19+08:00
draft: true
tags: ["linux", "nginx", "centos"]
---

## 目录
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [后端篇](/post/time-mgt/back-end/)  
> [部署篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  

## 环境信息
``` bash
[root@furan ~]# cat /etc/centos-release
CentOS Linux release 8.2.2004 (Core)
[root@furan ~]# nginx -v
nginx version: nginx/1.18.0
[root@furan ~]# deno -V
deno 1.3.0
[root@furan ~]# git --version
git version 2.18.4
```

## 写在最前
 请先确保安装了GLIBC_2.18， 确认方法如下，如输出列表没有匹配，则应先升级。  
 <font color="red">升级务必慎重</font>  
 <font color="red">升级务必慎重</font>  
 <font color="red">升级务必慎重</font>  
 这是linux系统中最底层的api，同时是deno的依赖，我之前centos7就是因为升级这个，导致系统崩了，现在换成centos8了。=- =、
```bash
strings /usr/lib64/libc.so.6 | grep GLIBC_2.1
```

如果报`strings: command not found`，用以下命令安装
```bash
yum install binutils
```

## Nginx 安装配置 

### 安装 [官方文档](https://nginx.org/en/linux_packages.html#RHEL-CentOS)
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
4. 运行以下命令安装
```bash
yum install nginx
```
5. 启动
```bash
systemctl start nginx
```

### 配置开机启动
```bash
systemctl enable nginx
```

### 常用命令

启动 Nginx
```bash
systemctl start nginx
```
停止 Nginx
```bash
systemctl stop nginx
```
重启 Nginx
```bash
systemctl restart nginx
```
修改 Nginx 配置后，重新加载
```bash
systemctl reload nginx
```
设置开机启动 Nginx
```bash
systemctl enable nginx
```
关闭开机启动 Nginx
```bash
systemctl disable nginx
```

### 配置
先编辑`vim /etc/nginx/nginx.conf`文件, 这是主配置文件。在`http`里加入以下内容，开启gzip。
```conf
# 开启gzip
gzip  on;
# 进行压缩的文件类型。javascript有多种形式。其中的值可以在 mime.types 文件中找到。
gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png application/vnd.ms-fontobject font/ttf font/opentype font/x-woff image/svg+xml;
```
然后不同端的详细配置会在之后的章节分别详述，这里暂不提及。

## MongoDB

### 安装 [官方文档](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/)
1. 设置yum源，`vim /etc/yum.repos.d/mongodb-org-4.4.repo`
```
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
```
2. 安装
```bash
yum install -y mongodb-org
```

3. 配置 [全部配置](https://docs.mongodb.com/manual/reference/program/mongod/#bin.mongod)  
编辑`vim /etc/mongod.conf`，找到并修改： （没有请新增）
```bash
    # 外网访问
    net:
        bind_ip: 0.0.0.0 
    # 身份认证
    security:
        authorization: enabled
```

4. 启动
```bash
systemctl start mongod
```

5. 输入`mongo`，进入mongo shell模式，并新增个admin用户
```javascript
use admin
db.createUser(
      {
          user: "username",
          pwd: "password",
          roles: [ "root" ]
      }
  )
```
成功后 ctrl + d 退出

## Firewalld 防火墙
### 常用命令
```bash
firewall-cmd --zone=public --add-port=5672/tcp --permanent   # 开放5672端口
firewall-cmd --zone=public --remove-port=5672/tcp --permanent  #关闭5672端口
firewall-cmd --reload   # 配置立即生效
firewall-cmd --zone=public --list-ports #查看防火墙所有开放的端口
firewall-cmd --state #查看防火墙状态

netstat -lnpt # 查看监听的端口
# S:centos7默认没有 netstat 命令，需要安装 net-tools 工具，yum install -y net-tools

netstat -lnpt |grep 5672 #检查端口被哪个进程占用

ps 6832 #查看进程的详细信息
kill -9 6832 #中止进程
```

### 本文涉及端口
| 端口  | 作用  |
| ----- | ----- |
| 80    | http  |
| 443   | https |
| 27017 | mongo |
| 22    | ssh   |

## Deno
### 安装 [官方文档](https://deno.land/)
1. 下载
```bash
curl -fsSL https://deno.land/x/install/install.sh | sh -s v1.3.0
```
<font color="red">请用1.3版本</font>  
<font color="red">请用1.3版本</font>  
<font color="red">请用1.3版本</font>  
重要的事说三遍，1.4版本强制使用了import type导入type，很多依赖都未支持。

2. 按提示把下面内容加到`vim ~/.bashrc`
```bash
export DENO_INSTALL="/root/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
```

3. 刷新终端
```bash
source ~/.bashrc
```

4. 查看安装状态
```bash
[root@furan ~]# deno -V
deno 1.3.0
```

### 部署项目
deno现今还不能编译可执行文件。所以只能用git拉到本地
1. clone 项目
```shell
cd /home/
mkdir www
cd www
git clone https://github.com/NgeKaworu/time-mgt-deno.git
```
2. shell 执行一遍进行初始化 
> 因为deno mongo驱动原因，索引建立是通过js脚本实现的，但开了身份验证后，会无法执行成功，尚未找到原因。请先关闭mongo身份验证。
```bash
deno run -A --unstable /home/www/time-mgt-deno/main.ts -m=mongodb://localhost:27017 -i=true --db='time-mgt' -k=[your secert]
```

3. 编写systemctl脚本，`vim /etc/systemd/system/time-mgt-denod.service`
```
[Unit]
Description=time mgt deno 
Documentation=http://deno.land
After=network.target

[Service]
Type=simple
PIDFile=/home/www/time-mgt-deno/deno.pid
WorkingDirectory=/home/www/time-mgt-deno
ExecStart=/root/.deno/bin/deno run -A --unstable main.ts -m=mongodb://localhost:27017 -i=false --db='time-mgt' -k=[your secert]
# On failer, wait 60 seconds before auto-restarting.
RestartSec=60
# Auto-restart on failure.
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

4. 启动并添加开机启动
```bash
systemctl start time-mgt-denod
systemctl enable time-mgt-denod
```

