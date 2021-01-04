---
title: "【mac】通过git-svn操作用git命令操作svn"
date: 2021-01-04T15:08:09+08:00
draft: false
tags: ["环境搭建"]
keywords:
- "git"
- "mac"
- "brew"
- "svn"
- "git-svn"
description : "通过git-svn操作用git命令操作svn"
---

## 参考资料
[安装](https://github.com/hfdiao/git-svn-tutorial/blob/master/install-git-svn.md)  
[报错 Can't locate SVN/Core.pm](https://www.jianshu.com/p/6a3afcb59fa9)  
[基本操作](https://tonybai.com/2019/06/25/using-git-with-svn-repo/)

## Q&A
- SouceTree 无法工作 `Can't locate Git/SVN.pm in @INC`
> vim /Applications/Sourcetree.app/Contents/Resources/git_local/libexec/git-core/git-svn   
> 第一行 `#!/usr/bin/perl`改成`#!/usr/local/bin/perl`