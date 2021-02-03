---
date: 2021-02-03T23:45:16+08:00
title: "【单词卡】Eggjs + TS + Systemctl 部署巨坑"
draft: false
tags: ["环境搭建", "个人项目"]
keywords:
- "个人项目"
- "linux"
- "centos"
- "systemctl"
description : "【单词卡】 部署篇"
---

## 前言
本次填Eggjs，开发体验尚可。结果部署巨坑。做个记录。

<!--more-->

## 访问报错 Internal Server Error, real status: 500
要把ts转js
```
npm run ci
```
[参考资料](https://blog.tcs-y.com/2018/10/05/egg-ts-deploy/)  
[官方文档](https://eggjs.org/zh-cn/tutorials/typescript.html#%E9%83%A8%E7%BD%B2deploy)  

## Systemctl 开机启动
脚本
```bash
Description=flashcard-egg 
Documentation=https://github.com/NgeKaworu/flash-card-egg
After=network.target

[Service]
Type=simple
PIDFile=/home/www/flashcard/be/egg.pid
WorkingDirectory=/home/www/flashcard/be
ExecStart=/home/www/flashcard/be/node_modules/.bin/egg-scripts start --title=egg-server-flashcard 
EXecStop=/home/www/flashcard/be/node_modules/.bin/egg-scripts stop --title=egg-server-flashcard
Environment=PATH=/root/.nvm/versions/node/v15.4.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
# On failer, wait 60 seconds before auto-restarting.
RestartSec=60
# Auto-restart on failure.
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
两点注意：
1. Environment那里是你的node绝对路径
2. egg-scripts也是你项目里的绝对路径

[参考资料](https://www.v2ex.com/t/477209)

