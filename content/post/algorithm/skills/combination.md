---
date: 2020-11-09T00:05:37+08:00
title: "求字符串组合(字母不重复)技巧"
draft: false
tags: ["算法"]
keywords:
- 算法技巧
- 排列组合
- algorithm
description : "求字符串组合(字母不重复)技巧"
---

```ts
var list = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101]

function helper(a: string): number {
    let ret = 1
    for (let i = 0; i < a.length; i++) {
        ret *= list[a[i].charCodeAt(0) - 'a'.charCodeAt(0)]
    }
    return ret
}
```
利用质数映射字母，求出乘积。