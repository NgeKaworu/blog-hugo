---
date: 2021-02-04T18:23:53+08:00
title: "【qiankun】关于qiankun的填坑记录"
draft: false
tags: ["前端"]
keywords:
  - qiankun
  - umi-qiankun
  - babel
  - styled-components
description: "关于qiankun的填坑记录"
---

## 前言

qiankun[qiankun]是一个微前端的解决方案，是 single-spa[single-spa]的封装。因同属 umi[umi]体系，用 umi 脚手架，只需要安装[@umijs/plugin-qiankun](https://umijs.org/zh-CN/plugins/plugin-qiankun)这个插件，然后做些简单配置就可以使用。这里不讨论如何使用。开发体验不错，但是 ——

<!--more-->

## 遇到的问题

—— 但是，打包到生产环境却有一堆问题。所以本章主要是记录问题和解决方案。

### 跨域

[官方解决方案](https://qiankun.umijs.org/zh/faq#%E5%BE%AE%E5%BA%94%E7%94%A8%E9%9D%99%E6%80%81%E8%B5%84%E6%BA%90%E4%B8%80%E5%AE%9A%E8%A6%81%E6%94%AF%E6%8C%81%E8%B7%A8%E5%9F%9F%E5%90%97%EF%BC%9F)

### styled-components 样式覆盖

去下[babel-plugin-styled-components](https://styled-components.com/docs/tooling)配置文件，然后在`webpack`配置文件里配置`namesapce`

```json
{
  "plugins": [
    [
      "babel-plugin-styled-components",
      {
        "namespace": "my-app"
      }
    ]
  ]
}
```

### styled-components 切换子应用后丢失

暂时无解，[官方 issues](https://github.com/umijs/qiankun/issues?q=styled-component+)；  
我的应急方案

1. 把不需要交互的样式交给 css 去处理，需要交互的才用 styled-components；
2. 关闭沙盒(sandbox)：

```js
 // 主应用 .umirc
  qiankun: {
    master: {
      sandbox: false,
      }
  }
```

[single-spa]: https://zh-hans.single-spa.js.org/
[qiankun]: https://qiankun.umijs.org/zh
[umi]: https://umijs.org/zh-CN
