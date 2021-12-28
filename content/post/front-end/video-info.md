---
date: 2021-12-24T14:08:00+08:00
title: "b端js获取视频的信息"
draft: false
tags: ["tip", "前端"]
keywords:
  - design
  - 设计
  - component
  - 组件
  - tip
  - 小技巧
description: "浏览器js获取视频的信息，包括长、宽、时长"
---

获取video info
原理
{{< mermaid loadMermaidJS="true" >}}
graph LR

START((开始)) --> 创建video标签
创建video标签 --> file文件转b64
file文件转b64 --> video加载b64
video加载b64 --> 输出video信息
输出video信息 --> 析构b64释放内存
析构b64释放内存 --> END((结束))
{{< /mermaid >}}

<!--more-->
```tsx
const loadVideo = (file: File) =>
  new Promise<HTMLVideoElement>((resolve, reject) => {
    const videoElem = document.createElement('video');
    const dataUrl = URL.createObjectURL(file);
    videoElem.onloadeddata = function () {
      resolve(videoElem);
      URL.revokeObjectURL(dataUrl);
    };

    videoElem.onerror = function () {
      reject('video 后台加载失败');
    };
    videoElem.src = dataUrl;
  });
```