---
title: "[柳比歇夫时间管理] 部署篇"
date: 2020-09-29T02:51:19+08:00
draft: false
tags: ["linux", "nginx", "centos", "mongo", "systemctl", "firewall"]
---

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
<!--more-->
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

### 常用规则
```bash
location  = / {
  # 精确匹配 / ，主机名后面不能带任何字符串
  [ configuration A ]
}
location  / {
  # 因为所有的地址都以 / 开头，所以这条规则将匹配到所有请求
  # 但是正则和最长字符串会优先匹配
  [ configuration B ]
}
location /documents/ {
  # 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
  # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
  [ configuration C ]
}
location ~ /documents/Abc {
  # 匹配任何以 /documents/Abc 开头的地址，匹配符合以后，还要继续往下搜索
  # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
  [ configuration CC ]
}
location ^~ /images/ {
  # 匹配任何以 /images/ 开头的地址，匹配符合以后，停止往下搜索正则，采用这一条。
  [ configuration D ]
}
location ~* \.(gif|jpg|jpeg)$ {
  # 匹配所有以 gif,jpg或jpeg 结尾的请求
  # 然而，所有请求 /images/ 下的图片会被 config D 处理，因为 ^~ 到达不了这一条正则
  [ configuration E ]
}
location /images/ {
  # 字符匹配到 /images/，继续往下，会发现 ^~ 存在
  [ configuration F ]
}
location /images/abc {
  # 最长字符匹配到 /images/abc，继续往下，会发现 ^~ 存在
  # F与G的放置顺序是没有关系的
  [ configuration G ]
}
location ~ /images/abc/ {
  # 只有去掉 config D 才有效：先最长匹配 config G 开头的地址，继续往下搜索，匹配到这一条正则，采用
    [ configuration H ]
}
location ~* /js/.*/\.js
```

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
```bash
deno run -A --unstable /home/www/time-mgt-deno/main.ts -m=mongodb://[your user]:[your pwd]@localhost:27017 -i=true --db='time-mgt' -k=[your secert]
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
ExecStart=/root/.deno/bin/deno run -A --unstable main.ts -m=mongodb://[your user]:[your pwd]@localhost:27017 -i=false --db='time-mgt' -k=[your secert]
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

### 添加nginx配置
```bash
vim /etc/nginx/conf.d/api.funran.xyz.conf

server {
    listen  80;
    server_name api.furan.xyz;

    location ^~ /time-mgt/ {
        proxy_pass http://127.0.0.1:8000/;    
    }
}

```

## 前端
### umi打包配置 [官方文档](https://umijs.org/zh-CN/config)
```json
  hash: true, // 开启hash命名
  base: "/time-mgt", // 保证和下面非根匹配目录相同
  publicPath: "/time-mgt/", // 静态资源
  runtimePublicPath: true, // 运行时静态资源
  dynamicImport: {
    loading: "@/Loading", // 按需加载 loading 组件
  },
  favicon: '/assets/favicon.ico', // 图标
```

### 添加nginx配置
```bash
vim /etc/nginx/conf.d/furan.xyz.conf

server {
    listen  80;
    server_name furan.xyz;
    root /home/www;

    location / {
        root /home/www/blog/;
        try_files $uri $uri/ /index.html;
    }

    location ^~ /time-mgt/ {
        try_files $uri $uri/ /time-mgt/index.html;
    }
}

```

## Go 后端
### 交叉编译
分享vscode配置
```json
{
  "version": "2.0.0",
  "type": "shell",
  "echoCommand": true,
  "cwd": "${workspaceFolder}",
  "tasks": [
    {
      "label": "build linux",
      "command": "CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o '${workspaceFolder}/bin/'",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```

`powershell`
```powershell
SET CGO_ENABLED=0
SET GOOS=linux
SET GOARCH=amd64
go build main.go
```

`git bash`
```shell
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
```

查看linux 系统架构  
`arch`
```shell
[root@furan ~]# arch
x86_64
```

| 参数   | 说明                                                  |
| ------ | ----------------------------------------------------- |
| GOOS   | 目标平台的操作系统（darwin、freebsd、linux、windows） |
| GOARCH | 目标平台的体系架构（386、amd64、arm）                 |
| CGO    | C/C++编译；交叉编译不支持  所以要禁用它               |

### systemctl 配置
1. 添加配置文件
`vim /etc/systemd/system/time-mgt-god.service`
```vim
Description=time-mgt-go
Documentation=https://furan.xyz
After=network.target

[Service]
Type=simple
PIDFile=/home/www/time-mgt-go/go.pid
WorkingDirectory=/home/www/time-mgt-go
ExecStart=/home/www/time-mgt-go/time-mgt-go -m=mongodb://furan:FURANO0o0@localhost:27017 -i=false --db=time-mgt -k=6sQXlzCyrIaYYDbb
# On failer, wait 60 seconds before auto-restarting.
RestartSec=60
# Auto-restart on failure.
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

2. 启动 `systemctl start time-mgt-god`
3. 开机启动 `systemctl enable time-mgt-god`

如果权限不够记得，记得加  
`chmod 777 ./time-mgt-go`

### nginx 配置
和[Deno](#添加nginx配置)那里的一致


## 相关链接
[ssl证书](https://certbot.eff.org/lets-encrypt/centosrhel8-nginx)
[jenkins自动化](https://www.jenkins.io/)

## 其他篇章
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [deno后端篇【废弃】](/post/time-mgt/back-end/)  
> [go后端篇](/post/time-mgt/back-end-go/)  
> [部署篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  