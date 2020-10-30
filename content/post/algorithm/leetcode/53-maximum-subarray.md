---
date: 2020-10-30T21:57:33+08:00
title: "53 Maximum Subarray"
draft: false
tags: ["leetcode", "algorithm", "算法"]
keywords:
- leetcode
- 算法
- 最大子序和
description : "leetcode 53.最大子序和解题思路，最快代码赏析。"
---

# 53. 最大子序和

## 题目
Given an integer array nums, find the contiguous subarray (containing at least one number) which has the largest sum and return its sum.  
给个整数数组nums，返回最大子序和。
Follow up: If you have figured out the O(n) solution, try coding another solution using the divide and conquer approach, which is more subtle.  
进阶：如果找到了O(n)的解，尝试优化它。

## 思路
双指针  
循环 [-2,1,-3,4,-1,2,1,-5,4]  
#### I.   
[-2, 1, -3, 4, -1, 2, 1, -5, 4]  
[-2, -1, -4, 0, -1, 1, 2, -3, 1] max=1;  
sub = [-2, 1, -3, 4, -1, 2]  

#### II.   
[1, -3, 4, -1, 2, 1, -5, 4]   
[1, -2, 2, 1, 3, 4, -1, 3] max=3  
sub = [1, -3, 4, -1, 2]  

#### III.   
[-3, 4, -1, 2, 1, -5, 4]  
[-3, 1, 0, 2, 3, -2, 2] max=3  
sub = [-3, 4, -1, 2, 1]  

#### IV.   
[4, -1, 2, 1, -5, 4]   
[4, 3, 5, 6, 1, 5] max=6  
sub = [4, -1, 2, 1]  

#### V.   
[-1, 2, 1, -5, 4]    
[-1, 1, 2, -3, 1] max=2  
sub = [-1, 2, 1]

#### VI.   
[2, 1, -5, 4]    
[2, 3, -2, 2] max = 3  
sub = [2, 1]  

#### VII.   
[1, -5, 4]    
[1, -4, 0] max= 1  
sub = [1]  

#### VIII.   
[-5, 4]    
[-5, -1] max = -1  
sub = [-5, 4]    

#### IX.   
[4]    
[4] max = 4  
sub = [4]  

[-1, -2, -3, 6]



## 代码
###go
```go
func maxSubArray(nums []int) int {
	max := nums[0]
	for k, v := range nums {
		temp := v
		var acc int
		for _, v2 := range nums[k:] {
			acc += v2
			temp = intMax(temp, acc)
		}
		max = intMax(max, temp)
	}
	return max
}

func intMax(a, b int) int {
	if b > a {
		return b
	}
	return a
}
```

## 赏析
```go
func maxSubArray(nums []int) int {
	max := nums[0]
	cursum := 0
	for _, num := range nums {
		if cursum <= 0 {
			cursum = num
		} else {
			cursum += num
		}
		max = intMax(max, cursum)
	}
	return max
}

func intMax(a, b int) int {
	if b > a {
		return b
	}
	return a
}
```

1. 先把正负数分开；  
2. 负数最长连续的一定是最小的负数；  
3. 累加值小于0则可以舍弃，因为任意正数都大于负累加

```ts
function maxSubArray(nums: number[]): number {
    let sum: number = nums[0];
    let num: number = 0;
    for (let i: number = 0; i < nums.length; i++) {
        num = num + nums[i];
        if (sum < num) {
            sum = num;
        }
        if (num < 0) {
            num = 0;
        }
    }
    return sum;
};
```
比上述的更少了一步判断