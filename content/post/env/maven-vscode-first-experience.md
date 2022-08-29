---
date: 2022-03-22T11:16:04+08:00
title: "Maven Vscode First Experience（初体验）"
draft: false
tags: ["环境搭建"]
keywords:
- "maven"
- "mac"
description : "vscode maven 初体验"
---
用vscode 跑maven项目
<!--more-->

### build通过
```bash
mvn --settings settings.xml -e -DskipTests clean install
```

#### tips：
```bash
--setting  //是读本地settings
-e  //是显示堆栈信息
-DskipTests  //【重要】跳过测试
-DdownloadSources  //下载源码


```

### mvn 打源码包
```bash
mvn source:jar //打源码包
```
### mvn 手动安装
```bash
mvn install:install-file -Dfile=sass-starter-applets-auto-release-sources.jar -DgroupId=com.zwx -DartifactId=sass-starter-applets-auto-release -Dversion=9.3.0-SNAPSHOT -Dpackaging=jar-source
```

#### tips：
```bash
-Dfile=sass-starter-applets-auto-release-sources.jar // 文件路径
-DgroupId=com.zwx // 组名
-DartifactId=sass-starter-applets-auto-release 模块名
-Dversion=9.3.0-SNAPSHOT //版本
-Dpackaging=jar-source // 源码包

-Dpackaging=jar // jar包

-Dpackaging=javadoc //文档包
```


#### 编译后无法查看源码解决
1. 使用DeCompiler 插件（不推荐）
2. 打一个source包，然后右键attach source选择它
