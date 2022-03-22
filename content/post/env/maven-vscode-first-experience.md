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

### build通过
```bash
mvn --settings settings.xml -e -DskipTests clean install
```

#### tips：
```bash
--setting 是读本地settings
-e 是显示堆栈信息
-DskipTests 【重要】跳过测试
```