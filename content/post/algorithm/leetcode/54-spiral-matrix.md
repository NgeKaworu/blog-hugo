---
date: 2020-10-31T07:16:52+08:00
title: "54 Spiral Matrix"
draft: false
tags: ["leetcode", "algorithm", "算法"]
keywords:
- leetcode
- 算法
- 螺旋矩阵
description : "leetcode 53.螺旋矩阵解题思路，最快代码赏析。"
---

# 54. 螺旋矩阵

## 题目
Given a matrix of m x n elements (m rows, n columns), return all elements of the matrix in spiral order.  
给个m * n 的矩阵，返回顺时针转一圈的数组。  


## 思路
感觉有点像纯数学问题，每遍历n次，n - 1, 遍历m，每两次遍历切换正负遍历方向。
### Example 1:
> Input:
> [
>  [ 1, 2, 3 ],
>  [ 4, 5, 6 ],
>  [ 7, 8, 9 ]
> ]
> Output: [1,2,3,6,9,8,7,4,5]

for i = 0; i < n * m; i++   
m = 3; n = 3;  
1. row = 0, col = 0; i = 0;  
2. row = 0, col = 1; i = 1; col + 1  
3. row = 0, col = 2; i = 2; col + 1  
4. row = 1, col = 2; i = 3; row + 1  
5. row = 2, col = 2; i = 4; row + 1  
6. row = 2, col = 1; i = 5; col - 1  
7. row = 2, col = 0; i = 6; col - 1  
8. row = 1, col = 0; i = 7; row - 1  
9. row = 1, col = 1; i = 8; col - 1  

### Example 2:
> Input:  
> [  
>   [1, 2, 3, 4],  
>   [5, 6, 7, 8],  
>   [9,10,11,12]  
> ]  
> Output: [1,2,3,4,8,12,11,10,9,5,6,7]  
for i = 0; i < n * m; i++   
m = 3; n = 4;  
1. row = 0, col = 0; i = 0;  
2. row = 0, col = 1; i = 1; col + 1  
3. row = 0, col = 2; i = 2; col + 1  
4. row = 0, col = 3, i = 3; col + 1  
5. row = 1, col = 3; i = 4; row + 1  
6. row = 2, col = 3; i = 5; row + 1  
7. row = 2, col = 2; i = 6; col - 1  
8. row = 2, col = 1; i = 7; col - 1  
9. row = 2, col = 0; i = 8; col - 1  
10. row = 1, col = 0; i = 9; row - 1  
11.  row = 1, col = 1; i = 10; col + 1  
12.  row = 1, col = 2; i = 11; col + 1  

## 代码
```go
func spiralOrder(matrix [][]int) []int {
	l := len(matrix) * len(matrix[0])
	res := make([]int, l)

	top, right, bottom, left := 0, len(matrix[0]), len(matrix), 0

	row, col := 0, 0
	x, y := 0, 1

	for i := 0; i < l; i++ {
		res[i] = matrix[row][col]

		// 下边界
		if x == 1 && row+x == bottom {
			right--
			x, y = -y, -x

		} else

		// 上边界
		if x == -1 && row == top {
			left++
			x, y = -y, -x
		}

		// 右边界
		if y == 1 && col+y == right {
			top++
			x, y = y, x

		}

		// 左边界
		if y == -1 && col == left {
			bottom--
			x, y = y, x
		}

		row, col = row+x, col+y
	}
	return res
}
```

## 赏析
无， 这段代码现在100%速度，想转成ts试下，发现leetcode ts无法解析=- =