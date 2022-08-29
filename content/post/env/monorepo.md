---
date: 2022-08-01T10:48:31+08:00
title: "Monorepo填坑笔记"
draft: false
tags: ["环境搭建"]
keywords:
- "monorepo"
- "pnpm"
- "go"
description : "Monorepo填坑笔记"
---

monorepo填坑笔记
<!--more-->

### 小目标
- [x] monorepo 是个啥？
~~- [ ] monorepo 怎么用？~~

#### js技术栈
- [x] pnpm 是个啥？
- [ ] pnpm 怎么用？
- [ ] monorepo + pnpm workspace 迁移现有项目
- [ ] CI/CD
- [ ] changesets 工作流管理

#### go 技术栈
- [ ] go 解决方案

#### Q: Monorepo是个啥？
A：
> &#8195;&#8195;**monorepo** 是仓库管理的一种策略，mono的意思是“单个”，repo当然就是表示仓库啦；连起来就是所有项目放在一个仓库里。  
&#8195;&#8195; 我们用的更多的策略是**polyrepo**(也叫**multirepo**)，就是多仓库；指每一个项目一个仓库；每个仓库分开管理，分开维护。  
&#8195;&#8195;听起来第一种会很反直觉，对吧。但想象一下 —— 你有三个项目，三个项目都依赖一样的lint、一样的依赖、一样的Dockerfile等等等等... 你每次更新版本，你都需要对重复的事情做3遍。然后随着时间的推移，这个3成长成了n。


