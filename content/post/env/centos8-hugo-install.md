---
title: "Centos8 Hugo 安装"
date: 2020-10-24T00:12:42+08:00
draft: false
---

## 安装go

```bash
yum -y install golang
# 查看版本，安装成功
go version
go version go1.13.15 linux/amd64
```

<!--more-->

## 安装 hugo

```bash
dnf copr enable daftaupe/hugo
sudo dnf install hugo
# 查看版本，安装成功
hugo version
Hugo Static Site Generator v0.75.1 linux/amd64 BuildDate: 2020-09-19T15:38:39Z
```