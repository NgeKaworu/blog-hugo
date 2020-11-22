---
date: 2020-11-18T16:06:36+08:00
title: "【数据结构】栈(stack)学记笔记"
draft: false
tags: ["数据结构"]
keywords:
- "数据结构"
- "date structure"
- "栈"
- "stack"
description : "数据结构学习之栈"
---

## 简述
栈也是一种线性存储结构, 但它只能从栈顶压入, 栈顶弹出数据, 也就是后进先出LIFO(Last In First Out).请和队列(Queue)区分开.

<!--more-->
## 在前端的应用
js函数调用栈就是栈,还有就是浏览器的history也是.

## 代码
[完整代码(附测试用例)](https://github.com/NgeKaworu/goLab/blob/main/struct/stack/stack.go)


### 基本结构
同样,栈也可以用数组和链表实现,下面还是便方便用数组.
```go
// Stack 数据结构 栈
type Stack struct {
	stack []int
}

```

### 基本操作
一般操作也就两个
1. 向栈顶压入一个数据
2. 从栈顶弹出一个数据


```go
// Len 长度
func (s *Stack) Len() int {
	return len(s.stack)
}

func (s *Stack) String() (res string) {
	for _, v := range s.stack {
		res += strconv.Itoa(v)
	}
	return
}

// Push 压栈
func (s *Stack) Push(val int) *Stack {
	s.stack = append(s.stack, val)
	return s
}

// Pop 出栈
func (s *Stack) Pop() (res int) {
	if s.Len() < 1 {
		log.Fatal("Empty stack")
	}
	res = s.stack[s.Len()-1]
	s.stack = s.stack[:s.Len()-1]
	return
}

```