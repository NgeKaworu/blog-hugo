---
date: 2020-11-01T09:49:27+08:00
title: "【leetcode】55 Jump Game"
draft: false
tags: ["算法"]
keywords:
- leetcode
- 算法
- 数组
description : "leetcode 55. 跳跃游戏解题思路，最快代码赏析。"
---

# 55. 跳跃游戏

## 题目
Given an array of non-negative integers, you are initially positioned at the irst index of the array.  
给定一个非负整数数组，您最初位于该数组的第一个索引处。  
Each element in the array represents your maximum jump length at that position.  
数组中的每个元素代表该位置的最大跳转长度。  
Determine if you are able to reach the last index.  
确定您是否能够达到最后一个索引  

## 思路
正解是贪心
~~回溯吧~~
```go
func canJump(nums []int) bool {
	return backtrack(nums, 0, len(nums)-1)
}

func backtrack(nums []int, start, max int) bool {
	if start+nums[start] >= max {
		return true
	}

	for i := 1; i <= nums[start]; i++ {
		if backtrack(nums, start+i, max) {
			return true
		}
	}
	return false
}
```
~~超时了, 加一个局部最优解的优化试试=- =~~

## 代码
### go
```go
func canJump(nums []int) bool {
	return backtrack(nums)
}

func backtrack(nums []int) bool {
	maxStep := nums[0]

	if len(nums) == 1 {
		return true
	}

	if maxStep == 0 {
		return false
	}

	optimal := 1
	for i := 1; i <= maxStep; i++ {

		if nums[i]+i >= nums[optimal]+optimal {
			optimal = i
		}

		if optimal+nums[optimal] >= len(nums)-1 {
			return true
		}
	}

	if optimal+nums[optimal] <= maxStep {
		return false
	}

	return backtrack(nums[optimal:])
}
```

## 赏析
```go
func canJump(nums []int) bool {
	maxPosition := 0

	for i := 0; i < len(nums); i++ {
		if i+nums[i] > maxPosition {
			maxPosition = i + nums[i]
		}
		if i >= maxPosition && maxPosition < len(nums)-1 {
			return false
		}
	}

	return true

}
```
- 单次遍历
- 每次计算出新的最大值
- 如果`i`已经大于最大值，且最大位置不是数组最后位置，那么说明没有解了