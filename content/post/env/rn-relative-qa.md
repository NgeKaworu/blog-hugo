---
date: 2022-07-21T10:17:27+08:00
title: "RN开发相关Q&A"
draft: false
tags: ["环境搭建"]
keywords:
- "react-native"
- "adb"
- "android"
description : "RN开发相关Q&A"
---

RN开发相关Q&A
<!--more-->

#### 手机打开工程模式
拨号下
``` 
*#*#2846579#*#*
```

#### adb 相关命令
```bash
adb connect ip //wifi连接
adb kill-server // 关服务
adb start-server // 开服务
adb tcpip :port // 重启到某个端口

adb devices -l // 列出所有设备


adb shell settings put global policy_control immersive.full=1 // 显示navigate bar
打开adb，输入指令：

adb shell settings put global policy_control key=value

---------------------------------------------------

key和value 是需要自己填写的键值对 

key的含义
immersive.full 同时隐藏 

immersive.status 隐藏状态栏 

immersive.navigation 隐藏导航栏

immersive.preconfirms ?


value的含义
apps 所有应用
* 所有界面
packagename 指定应用
-packagename 排除指定应用

adb push $local $remote // 推文件到设备

adb install ./local.apk  // 安装本地文件
adb uninstall com.package.name  // 删除设备上的包
```

##### Q: more than one device and emulator
A: 命令后面加 -s 设备 id 

#### mac 相关命令
```
system_profiler SPUSBDataType // 查看USB口状态
```

##### Q：接入react-query，开启聚集refetch等功能
A：https://tanstack.com/query/v4/docs/react-native?from=reactQueryV3&original=https://react-query-v3.tanstack.com/react-native
