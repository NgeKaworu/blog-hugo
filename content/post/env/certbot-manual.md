---
date: 2021-11-20T22:29:40+08:00
title: "Certbot 手动生成证书"
draft: false
tags: ["环境搭建"]
keywords:
- "certbot"
- "manual"
description : "手动生成证书"
---

### 新增
certbot certonly --email ngekaworu@gmail.com --manual --key-type ecdsa -d furan.xyz -d api.furan.xyz -d micro.furan.xyz -d blog.furan.xyz

--email 邮箱
--manual 手动
--key-type 加密类型
-d 域名

### 删除
certbot delete --cert-name furan.xyz

### 更新
certbot renew