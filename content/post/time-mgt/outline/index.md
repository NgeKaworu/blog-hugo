---
title: "[柳比歇夫时间管理] 前言"
date: 2020-09-29T02:51:19+08:00
draft: false
tags: ["线框图", "脑图"]
---

## 目录
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [后端篇](/post/time-mgt/back-end/)  
> [部署篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  

## 写在前面

本文旨在通过“柳比歇夫时间管理”（下称“柳时管”）这个项目，在玩一玩新的语言（deno、ts）同时，尽可能的简述清楚一个项目从**原型设计**到**部署篇开发**的主要过程，并从中锻炼作者写作和表述能力。文中不会涉及到诸如安装、api这样基础的详解；主要是**理念**和**流程**的概述，且技术深度不高，如有不足，还望诸公斧正。

## 什么是柳比歇夫时间管理？

简单地说，柳比歇夫时间管理法就是要记录时间、分析时间、消除时间浪费、重新安排自己的时间。是个人时间定量管理的方法  
[参考链接](https://www.douban.com/note/226926167/)

> 根据用户故事（User Case）可得：我们需要一个**记录**何时发生何事的页面，最好支持**标签**分类，并且要一个统计页，同时最好**用户**可以把记录保存在服务器

## 原型图
![记录页](/post/time-mgt/outline/record-page.png)
![统计页](/post/time-mgt/outline/statistic-page.png)
![用户页](/post/time-mgt/outline/user-page.png)

> 正常流程搞定原型后应交由设计师设计排版，但一是我没这本事，二是这小打小闹也无必要，所以就因陋就简，前端页面开发就用antd的组件库

## 功能拆分

![功能点](/post/time-mgt/outline/key-point.png)

## 表结构

![表设计](/post/time-mgt/outline/table-design.png)