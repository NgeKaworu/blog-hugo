---
date: 2021-12-23T17:32:51+08:00
title: "react 路由保护"
draft: false
tags: ["tip", "前端"]
keywords:
  - tip
  - 小技巧
description: "浏览器js获取视频的信息，包括长、宽、时长"
---

退出时路由保护，用于表单场景防止用户误操作退出。
<!--more-->

### 一、window 的 onbeforeunload 事件

```tsx
useEffect(() => {
  window.onbeforeunload = () => {
    return "表单离开保护";
  };
  return () => {
    window.onbeforeunload = null;
  };
}, []);
```

### Prompt

message return 则不触发拦截，另外可以设 when 属性

```tsx
<Prompt
  message={({ pathname: p }, action) => {
    if (action === "REPLACE") return true;

    if (!p.startsWith("/ad-master-plat/promote-mgt/flow")) {
      return "系统可能不会保存您所做的更改。";
    }
    return true;
  }}
/>
```
