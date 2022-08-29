<!--
 * @Author: fuRan NgeKaworu@gmail.com
 * @Date: 2022-07-26 12:03:41
 * @LastEditors: fuRan NgeKaworu@gmail.com
 * @LastEditTime: 2022-08-29 10:21:10
 * @FilePath: /blog-hugo/content/post/env/git-note.md
 * @Description: 
 * 
 * Copyright (c) 2022 by fuRan NgeKaworu@gmail.com, All Rights Reserved. 
-->
---
date: 2022-07-26T12:03:41+08:00
title: "git 学习笔记"
draft: false
tags: ["环境搭建", "git"]
keywords:
- "subtree"
- "git"
- "cherry-pick"
description : "git 学习笔记"
---

git 学习笔记
<!--more-->

### subtree常用命令
```bash
    "addEDK": "git remote add -f edk https://github.com/NgeKaworu/js-sdk.git; git subtree add -P src/edk edk master --squash",
    "pullEDK": "git subtree pull -P src/edk edk master --squash",
    "pushEDK": "git subtree push -P src/edk edk master"
```

#### 强制推送远程分支
```bash
git push edk `git subtree split --prefix src/edk tailin-dev`:master --force

`git subtree split --prefix <local-folder> <local-branch>`:<remote-branch> --force
```

#### 需要变基时
```bash
    git rebase --rebase-merges --strategy subtree [branch]
```
[参考](https://stackoverflow.com/a/58709875/13552870)

#### cherry-pick 一条分支
git log feat --not master --format=\%H --reverse | git cherry-pick -n --stdin

-n 是 no-commit

