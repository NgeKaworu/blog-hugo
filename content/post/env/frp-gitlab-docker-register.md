---
date: 2022-09-14T17:54:23+08:00
title: "搭建gitlab的docker私服，并通过frp提供外网访问"
draft: false
tags: ["环境搭建"]
keywords:
- "docker"
- 'frp'
- 'frpc'
- 'frps'
- 'docker register'
- 'register'
- 'gitlab'
description : "搭建gitlab的docker私服，并通过frp提供外网访问"
---
书接[上回](/post/env/docker-data-root/),公司搭了android的gitlab-ci，平均一次要10min以上，且rn的好多依赖安装并不简单，我就想提供一个预安装的镜像，当依赖变更时触发这个镜像的build，这样就简化了安装过程，但是，凡事都有个但是，公司并没有镜像仓库，所以还是得自己搞，奇怪的技能又变多了。

<!--more-->

### 一、 启动gitlab docker container register
启动gitlab的docker私服很简单，修改配置文件`/etc/gitlab/gitlab.rb`
```rb
    registry_external_url 'http://registry.gitlab.example.com:7001'
```
找到registry_external_url并去掉前面的注释，然后重启gitlab即可。没错，就是这么简单。随之而来的就是一堆坑。
重启命令
```sh
gitlab-ctl stop;
gitlab-ctl reconfigure;
gitlab-ctl start;
```
1. docker login 失败
    1. 登录失败有两个解法，提供https的外网访问地址
    ```rb
    registry_external_url 'https://registry.gitlab.example.com:7001' #https
    registry_nginx['redirect_http_to_https'] = true # 重定向
    # 默认证书位置在 /etc/gitlab/ssl/
    registry_nginx['ssl_certificate'] = "/path/to/registry.gitlab.example.pem"  # 自定义证书位置
    registry_nginx['ssl_certificate_key'] = "/path/to/registry.gitlab.example.key"  # 自定义证书位置
    ```
    2. 在本机的`~/.docker/daemon.json`或`/etc/docker/daemon.json`文件里加入
      ```json
      {
        "insecure-registries": ["registry.gitlab.example.com:7001"]
      }
      ```
      然后重启docker
2. frpc 内网穿透后，login还是失败
   这个问题我排查下来是因为，gitlab docker的登录是走的还是gitlab的登录链接，这个链接读的是`/etc/gitlab/gitlab.rb`的`external_url`，而且偏偏公司是内网ip，故登录失败。这就需要涉及frp改造。

### 二、frp改造 其の一
frp分服务端和客户端[文档](https://gofrp.org/docs/)  
服务端需要暴露在公网下，并在安全组（VPS提供商后台）、防火墙（Ubuntu: ufw、iptables，CentOS：firewall-cmd)暴露对应端口。配置如下
```ini
[common]
bind_port = 7000 # 本地端口
vhost_http_port=7070 # http转发端口 端口要和 external_url 的一致
vhost_https_port=7001 # https转发端口 端口要和 registry_external_url 的一致
log_file=/opt/frp/frps.log # 日志位置
```

客户端放在内网机器即可
```ini
[common]
server_addr = 127.0.0.1 #服务器地址
server_port = 7000 #服务器端口

[gitlab]
type = https
# 填写实际域名
custom_domains = gitlab.example.com
plugin = https2http
plugin_local_addr = 127.0.0.1:7070

# HTTPS 证书相关的配置
plugin_crt_path = /home/frp/gitlab.example.com.pem
plugin_key_path = /home/frp/gitlab.example.com.key
plugin_host_header_rewrite = gitlab.example.com:7001
plugin_header_X-From-Where = frp

[docker]
type = https
# 填写实际域名
custom_domains = docker.gitlab.example.com
plugin = https2http
plugin_local_addr = 127.0.0.1:7001

# HTTPS 证书相关的配置
plugin_crt_path = /home/frp/gitlab.example.com.pem
plugin_key_path = /home/frp/gitlab.example.com.key
plugin_host_header_rewrite = docker.gitlab.example.com:7001
plugin_header_X-From-Where = frp

[gitlab-http]
type = http
# 填写实际域名
custom_domains = gitlab.example.com
local_port = 7070
host_header_rewrite = gitlab.example.com:7070

[docker-http]
type = http
# 填写实际域名
custom_domains = docker.gitlab.example.com
local_port = 7001
host_header_rewrite = docker.gitlab.example.com:7070
```

现在去修改gitlab配置文件`/etc/gitlab/gitlab.rb`，并重启
```rb
    external_url 'http://gitlab.example.com:7070' # 这个地址要和你frps穿透的一致
```