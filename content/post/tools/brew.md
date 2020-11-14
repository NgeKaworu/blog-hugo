---
date: 2020-11-12T21:18:15+08:00
title: "[mac]使用brew安装常用开发工具"
draft: true
tags: ["开发环境"]
keywords:
- "开发工具"
- "mac"
- "brew"
description : "mac使用brew安装常用开发工具"
---

好气，我这种windows一把梭，中午一小时装三台开发机的人，捣鼓了一天mac，装了个有道=- =

<!--more-->

## 安装
要使用brew我们需要先安装它，终端运行
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

然后要设置proxy，`vim ~/.zshrc`,加入`export ALL_PROXY=[protocol]:[host]:[port]`


## 常用工具
```zsh
# proxy
brew cask install v2rayu
brew cask install google-chrome
# 下载工具
brew cask install free-download-manager
# 飞书
brew cask install feishu
# 微信
brew cask install wechat
brew cask install onedrive
brew cask install robo-3t
brew cask install postman
brew cask install sourcetree
# sftp 客户端
brew cask install electerm
brew install mongodb-community@4.4
brew cask install steam

# go blog 生成器
brew install hugo
brew install go
brew install yarn
brew install deno
# 下载工具 配置见附录
brew install aria2
brew install p7zip
brew install nvm
# 解压工具
brew cask install keka
# 剪切板
brew cask install maccy
# 温度监控 收费
brew cask install istat-menus
# 快捷键助手
brew cask install cheatsheet
# 窗口管理
brew cask install rectangle
# 播放器
brew cask install iina
```

## 附录
[mac aria2指南](https://gist.github.com/maboloshi/#file-aria2-conf)
[mac go mod配置](https://www.jianshu.com/p/760c97ff644c)
[mac 配置mongo](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/)
[mac 配置vscode右键菜单](https://liam.page/2020/04/22/Open-in-VSCode-on-macOS/)