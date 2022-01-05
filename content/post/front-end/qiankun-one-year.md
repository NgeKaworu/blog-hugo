---
date: 2022-01-05T10:15:55+08:00
title: "【qiankun】关于qiankun使用一年后的心得"
draft: false
tags: ["前端"]
keywords:
  - qiankun
  - umi-qiankun
description: "关于qiankun使用一年后的心得"
---

自我入 qiankun 坑已经快一年了[传送门](/post/front-end/qiankun/)。因 umi 体系的无缝衔接，对我个人来说基本没有障碍。本文依旧是记录我遇到的一些问题和解决方案。

<!--more-->

首先整理一些关于 qiankun 的学习资源

| 标题            | 链接                                                            |
| --------------- | --------------------------------------------------------------- |
| 关于微前端      | [传送门](https://www.cnblogs.com/everfind/p/microfrontend.html) |
| HTML entry 原理 | [传送门](https://juejin.cn/post/6885212507837825038)            |
| HTML entry      | [传送门](https://github.com/kuitos/import-html-entry)           |

### 跨域

常见两种解决方案

1. CORS
2. proxy_pass

[二者对比](https://blog.csdn.net/Reagan_/article/details/98328590)  
我选择的是 **proxy_pass**

> micro-app nginx conf

```conf
server {
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    location /micro {
        alias /usr/share/nginx/html/;
    }
}
```

> 主 nginx 配置 太长贴个传送门

[传送门](https://github.com/yingxv/nginx)
| server | 说明 |
| --- | --- |
| furan.xyz | 网关入口 |
| micro.furan.xyz | 微应用入口 |

### 鉴权

这个应由 RBAC 那边提供，再通过 runtime 注册机制注册 micro-app。  
[运行时动态配置](https://umijs.org/zh-CN/plugins/plugin-qiankun#b-%E8%BF%90%E8%A1%8C%E6%97%B6%E5%8A%A8%E6%80%81%E9%85%8D%E7%BD%AE%E5%AD%90%E5%BA%94%E7%94%A8%EF%BC%88srcappts-%E9%87%8C%E5%BC%80%E5%90%AF%EF%BC%89)

### css-in-js 样式丢失

一年前我的解决方案是前缀+关沙箱。  
今年我全部改成 css module 之后效果拔群。  
有条件一开始就不要用 css-in-js 的方案

### code-split(dynamic important) 后 chunk 404 解决

[issues](https://github.com/umijs/qiankun/issues/1041#issuecomment-721491087)
