---
title: "【人月神话】章节11 阅读笔记"
date: 2020-10-25T02:22:53+08:00
draft: false
tags: ["设计规划"]
keywords:
- "人月神话"
- "项目管理"
description : "人月神话阅读笔记"
---

不变只是愿望，变化才是永恒。  
SWIFT  
> 普遍的做法是，选择一种方法，试试看；如果失败了，没关系，再试试别的。不管怎么样，重要的是先去尝试。


- 富兰克林 D. 罗斯福

----

There is nothing in this world constant but inconstancy.    
SWIFT  
> It is common sense to take a method and try it. If it fails, admit it frankly and try another. Butabove all, try something.  


- FRANKLIN D. ROOSEVELT


<!--more-->

因此，为舍弃而计划，无论如何，你一定要这样做。

## 唯一不变的就是变化本身

Cosgrove 很有洞察力地指出，开发人员交付的是 **用户满意程度** ，而不仅仅是实际的产品。用户的 **实际需要** 和用户 **感觉** 会随着 **程序的构建、测试和使用而变化**。

> 为了应对变化，管理结构也要随之调整，意味着，技术人员和管理人员最好具有互换性，且不要让管理和技术有待遇上的区别。


软件发布后，然后随着用户使用系统的越发熟练，开始走向了噩梦的维护期。

## 前进两步，后退一步

> 对于一个广泛使用的程序，其维护总成本通常是开发成本的 40％或更多。令人吃惊的是，该成本受用户数目的严重影响。用户越多，所发现的错误也越多。

随之而来的就是 —— 你每修复一个bug，就会有两个bug来参加他的葬礼。
> 程序维护中的一个基本问题是——缺陷修复总会以（20－50）%的机率引入新的 bug。所以整个过程是前进两步，后退一步。

而且系统跨度越大，功能越多的系统，这个效应越明显。
> 显然，使用能消除、至少是能指明副作用的程序设计方法，会在维护成本上有很大的回报。同样，设计实现的人员越少、接口越少，产生的错误也就越少。

终于噩梦迎来了梦魇。

## 前进一步，后退一步
我们先品一品这段话

> Lehman 和 Belady 研究了大型操作系统的一系列发布版本的历史。他们发现 **模块数量** 随版本号的增加呈 **线性** 增长，但是 **受到影响** 的模块以版本号 **指数的级别** 增长。所有修改都倾向于破坏系统的架构，增加了系统的混乱程度。用在修复原有设计上瑕疵的工作量越来越少，而早期维护活动本身的漏洞所引起修复工作越来越多。随着时间的推移，系统变得越来越无序，修复工作迟早会失去根基。每一步前进都伴随着一步后退。尽管理论上系统一直可用，但实际上，整个系统已经面目全非，无法再成为下一步进展的基础。而且，机器在变化，配置在变化，用户的需求在变化，所以现实系统不可能永远可用。崭新的、基于原有系统的重新设计是完全必要的。


真是热力学第二定律无处不在

回到开头，这时候应该选择壮士断腕吗？毕竟前面的都是沉没成本了。

> 系统软件开发是减少混乱度（减少熵）的过程，所以它本身是处于亚稳态的。软件维护是提高混度（增加熵）的过程，即使是最熟练的软件维护工作，也只是放缓了系统退化到非稳态的进程。