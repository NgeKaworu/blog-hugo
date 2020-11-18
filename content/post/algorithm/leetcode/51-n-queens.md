---
date: 2020-10-28T02:10:23+08:00
title: "【leetcode】51 N Queens"
draft: false
tags: ["算法"]
keywords:
- 算法
- N后
- 回溯
description: "51 N Queens 思路 解法 例题赏析"
---
# 51. N 皇后

## 题目
The n-queens puzzle is the problem of placing n queens on an n×n chessboard such that no two queens attack each other.  
N后问题是： **n** 皇后在 **n x n**的棋盘上，且两两不能攻击。  
Given an integer n, return all distinct solutions to the n-queens puzzle.  
给一个整数， 返回所有解法。  
Each solution contains a distinct board configuration of the n-queens' placement, where 'Q' and '.' both indicate a queen and an empty space respectively.  
解里Q代表皇后，.代表空位  
<!--more-->

## 思路
~~MD N后是经典DP问题，我能有啥子思路？🤣~~  
~~1. 遍历n * n次~~  
~~2. 判断board[row][col]是否可以落子~~  

其实是个经典的 **回溯** 问题，还是高斯搞出来的=- =  
遍历次数也不是n^2，而是n!  
查阅了资料找到个回溯的框架
```python
result = []
def backtrack(路径, 选择列表):
    if 满足结束条件:
        result.add(路径)
        return

    for 选择 in 选择列表:
        做选择
        backtrack(路径, 选择列表)
        撤销选择
```
接着就套公式咯~
## 代码
### ts
```ts
function solveNQueens(n: number): string[][] {
    let res: string[][] = [];
    let board: string[][] = Array(n).fill(null).map(() => Array(n).fill("."));
    backtrack(board, 0, res)
    return res
};


function backtrack(board: string[][], row: number, res: string[][]) {
    if (row === board.length) {
        res.push(board.map(b => b.join("")))
        return
    }


    for (let col = 0; col < board.length; ++col) {
        if (isValid(board, row, col)) {
            board[row][col] = 'Q'
            backtrack(board, row + 1, res)
            board[row][col] = "."
        }

    }

}


function isValid(board: string[][], row: number, col: number): boolean {
    // 左上
    for (let r = row - 1, c = col - 1; r >= 0 && c >= 0; --r, --c) {
        if (board[r][c] === 'Q') return false
    }
    // 上
    for (let r = row - 1; r >= 0; --r) {
        if (board[r][col] === 'Q') return false
    }

    // 右上
    for (let r = row - 1, c = col + 1; r >= 0 && c < board.length; --r, ++c) {
        if (board[r][c] === 'Q') return false
    }

    return true
}

```
### go
```go
func solveNQueens(n int) [][]string {
	res := make([][]string, 0)
	board := make([][]byte, n)
	for row := 0; row < n; row++ {
		board[row] = make([]byte, n)
		for col := 0; col < n; col++ {
			board[row][col] = '.'
		}
	}
	backtrack(&res, board, 0)
	return res
}

func backtrack(res *[][]string, board [][]byte, row int) {
	n := len(board)
	if row == n {
		format := make([]string, 0)
		for _, v := range board {
			format = append(format, string(v))
		}
		*res = append(*res, format)
		return
	}

	for col := 0; col < n; col++ {
		if isValid(board, row, col) {
			board[row][col] = 'Q'
			backtrack(res, board, row+1)
			board[row][col] = '.'
		}

	}

}

func isValid(board [][]byte, row int, col int) bool {
	// 左上
	for r, c := row-1, col-1; r >= 0 && c >= 0; r, c = r-1, c-1 {
		if board[r][c] == 'Q' {
			return false
		}
	}
	// 上
	for r := row - 1; r >= 0; r-- {
		if board[r][col] == 'Q' {
			return false
		}
	}

	// 右上
	for r, c := row-1, col+1; r >= 0 && c < len(board); r, c = r-1, c+1 {
		if board[r][c] == 'Q' {
			return false
		}
	}

	return true
}
```

## 赏析
无  
最快的我自己测了速度也差不多 故不解释了