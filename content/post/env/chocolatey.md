---
date: 2020-11-12T21:18:05+08:00
title: "【win10】使用chocolatey极速搭建开发环境"
draft: false
tags: ["环境搭建"]
keywords:
- "chocolatey"
- "开发工具"
- "win10"
description : "win10使用chocolatey极速搭建开发环境"
---

chocolatey是window平台的包管理工具，我们可以用其完成开发环境的快速搭建  
[官网地址](https://chocolatey.org/)

<!--more-->

## 安装
首先我们要安装它，用以下其一终端执行：  
cmd:
```bash
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
```

PowerShell:
```PowerShell
PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```


## 常用工具
```PowerShell
# 下载工具 需配置
cinst aria2
cinst nvm 
# 类似于mac的聚集搜索
cinst listary
cinst sourcetree
cinst git.install
cinst yarn
cinst miniconda3
cinst teamviewer
cinst 7zip.install
cinst googlechrome
cinst vscode 
cinst mongodb.Portable 
cinst robo3t.install
cinst redis-64
# 下载工具
cinst freedownloadmanager
# 视频播放器
cinst potplayer
cinst jdk8
cinst golang
cinst steam
cinst mingw
cinst msys2
# ssh sftp客户端
cinst bitvise-ssh-client
# go 博客生成器
cinst hugo
```


## 其它命令
```powerShell
# 查看本地所有包
choco list --localonly 
# 更新所有包
choco update all 
```

## 附录
[win10 aria2配置指南](https://juejin.im/post/6844903823803154446)