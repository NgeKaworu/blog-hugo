---
date: 2020-11-02T17:57:05+08:00
title: "56 Merge Intervals"
draft: false
tags: ["leetcode", "algorithm", "算法"]
keywords:
- leetcode
- 算法
- 排序
- 快速排序
description : "leetcode 56. 合并区间解题思路，最快代码赏析。"
---

# 56. 合并区间

## 题目
Given a collection of intervals, merge all overlapping intervals.
给出一个区间的集合，请合并所有重叠的区间。

## 思路
说实话一脸懵逼,查了标签才知道先要排序,然后合并,合并逻辑很简单,当前闭区间小于开区间合并.关键go没排序,只能自己实现,一查发现快速排序还挺有意思.

## 代码
### go
快速排序， 然而leetcode 不知道为啥不能用=- =
```go
func quickSort(arr [][]int, c chan bool) {
	pivot, left, right := 0, 0, len(arr)-1
	for i := left; i < right; i++ {
		if arr[i][0] <= arr[right][0] {
			arr[pivot], arr[i] = arr[i], arr[pivot]
			pivot++
		}
	}
	arr[right], arr[pivot] = arr[pivot], arr[right] // 把pivot移到它最後的地方

	if pivot+1 < right {
		go quickSort(arr[pivot+1:], c)
		<-c
	}

	if left < pivot-1 {
		go quickSort(arr[:pivot], c)
		<-c
	}

	c <- true
}
```
只能用实现interface的办法了=- =
```go
type intss [][]int

func (s intss) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s intss) Less(i, j int) bool {
	return s[i][0] < s[j][0]
}

func (s intss) Len() int {
	return len(s)
}

```

最终代码
```go
func merge(intervals [][]int) [][]int {
	sort.Sort(intss(intervals))
	res := make([][]int, 0)

	for _, v := range intervals {
		if len(res) == 0 || res[len(res)-1][1] < v[0] {
			res = append(res, v)
		} else if v[1] > res[len(res)-1][1] {
			res[len(res)-1][1] = v[1]
		}
	}
	return res
}

type intss [][]int

func (s intss) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s intss) Less(i, j int) bool {
	return s[i][0] < s[j][0]
}

func (s intss) Len() int {
	return len(s)
}
```

## 赏析
无