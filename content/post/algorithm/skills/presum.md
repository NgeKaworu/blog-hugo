---
date: 2020-11-09T00:12:35+08:00
title: "【算法技巧】前缀和"
draft: true
tags: ["算法"]
keywords:
- "前缀和"
- "算法技巧"
- "prefix sum"
description : "算法技巧之前缀和"
---

```c++
int n = nums.length;
// 前缀和数组
int[] preSum = new int[n + 1];
preSum[0] = 0;
for (int i = 0; i < n; i++)
    preSum[i + 1] = preSum[i] + nums[i];
```

这个前缀和数组 preSum 的含义也很好理解，preSum[i] 就是 nums[0..i-1] 的和。那么如果我们想求 nums[i..j] 的和，只需要一步操作 preSum[j+1]-preSum[i] 即可，而不需要重新去遍历数组了。