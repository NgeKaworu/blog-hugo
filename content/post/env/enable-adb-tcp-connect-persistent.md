---
date: 2022-10-08T10:34:52+08:00
title: "开启adb tcp连接"
draft: false
tags: ["环境搭建"]
keywords:
- "adb"
- 'connect'
- 'tcp'
- 'Connection refused'
- 'setprop'
- 'android'
description : "开启adb tcp连接"
---
经常debug android应用的人应该不会对这条报错感到陌生：
`failed to connect to '192.168.1.21:5555': Connection refused`，
这表示你连接设备时被拒绝了；拒绝的原因有很多，本文只涉及这种场景；即，可以通过USB连接设备，却不能通过TCP连接；这需要你通过setprop修改设备的配置来实现。

<!--more-->

1. 用USB连接你的设备，用`adb devices -l`保证设备已经连接
   ```sh
    $ adb devices -l
    List of devices attached
    343078f54718280a06d0   device usb:338755584X product:tulip_p2 model:QUAD_CORE_A64_p2 device:tulip-p2 transport_id:9
   ```
2. 获取adb的root权限，`adb root`
   ```sh
    $ adb root
    restarting adbd as root
    $ adb root
    adbd is already running as root
   ```
3. 通过`adb shell`连接设备终端，然后通过`setprop`修改设备配置，并重启adb
   ```
    setprop service.adb.tcp.port 5555 && stop adbd && start adbd
   ```
4. 如果你想重启后依旧可以通过TCP连接，你需要用以下命令开起持久化。
    ```sh
    setprop persist.adb.tcp.port 5555
    ```
5. 测试一下，再次执行`adb connect 192.168.1.21`
   ```sh
   $ adb connect 192.168.1.21
   connected to 192.168.1.21:5555
   ```

