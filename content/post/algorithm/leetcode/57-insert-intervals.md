---
date: 2020-11-04T08:10:09+08:00
title: "57 Insert Intervals"
draft: false
tags: ["算法"]
keywords:
- leetcode
- 算法
- 线性查询
- 插入算法
description: "leetcode 57. 插入区间解题思路，最快代码赏析。"
---

# 57. 插入区间

## 题目
Given a set of non-overlapping intervals, insert a new interval into the intervals (merge if necessary).  
给出一个无重叠的 ，按照区间起始端点排序的区间列表。  
You may assume that the intervals were initially sorted according to their start times.  
在列表中插入一个新的区间，你需要确保列表中的区间仍然有序且不重叠（如果有必要的话，可以合并区间）。  

## 思路
56题改一下，先插后合，还不用排序    
然后我试了一下，中间有的元素不用管，纯插入  
插入逻辑，如果当前值小于new值，或者数组最后还没插入，就插入  
```go
if !inserted && newInterval[0] <= intervals[i][0]  {
	intervals = append(intervals[:i+1], intervals[i:]...)
	intervals[i] = newInterval
	inserted = true
}
if !inserted && i == len(intervals)-1 {
	intervals = append(intervals, newInterval)
}
```
---

## 代码
### go
```go
func insert(intervals [][]int, newInterval []int) [][]int {
	res := make([][]int, 0)
	if len(intervals) == 0 {
		res = append(res, newInterval)
		return res
	}
	inserted := false
	for i := 0; i < len(intervals); i++ {
        last := len(res) - 1
        // 如果当前值小于new值，在当前值前插入new值
		if !inserted && newInterval[0] <= intervals[i][0]  {
			intervals = append(intervals[:i+1], intervals[i:]...)
			intervals[i] = newInterval
			inserted = true
        }
        // 如果数组最后还未插入，插入到数组末端
		if !inserted && i == len(intervals)-1 {
			intervals = append(intervals, newInterval)
		}
		if i == 0 || res[last][1] < intervals[i][0] {
			res = append(res, intervals[i])
		} else if intervals[i][1] > res[last][1] {
			res[last][1] = intervals[i][1]
		}
	}
	return res
}
```
inserted 作为标记，防止插多了

