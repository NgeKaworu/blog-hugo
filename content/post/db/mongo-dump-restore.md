---
date: 2021-02-22T18:12:36+08:00
title: "Mongo 备份数据库和还原"
draft: false
tags: ["db"]
keywords:
  - mongodb
  - 备份
  - 还原
description: "Mongo 备份数据库和还原"
---

### 备份

`mongodump -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 -o 文件存在路径 `
如果想导出所有数据库，可以去掉-d

### 还原

`mongorestore -h IP --port 端口 -u 用户名 -p 密码 -d 数据库 --drop 文件存在路径`

### 报错 Authentication failed

加上这个参数 `--authenticationDatabase admin`

<!--more-->
