---
date: 2020-11-18T16:06:36+08:00
title: "【数据结构】队列(queue)学习笔记"
draft: false
tags: ["数据结构"]
keywords:
- "数据结构"
- "date structure"
- "队列"
- "queue"
description : "数据结构学习之队列(queue)"
---

## 简述
队列也是一种线性存储结构, 但它只能从队尾添加数据, 队头取出数据, 也就是先进先出FIFO(First In First Out). 请和栈(Stack)区分开.

<!--more-->
## 在前端的应用
js里微任务和宏任务就是队列, 一些缓存池也可以用队列.

## 代码
[完整代码(附测试用例)](https://github.com/NgeKaworu/goLab/blob/main/struct/queue/queue.go)
### 基础结构
队列可以用数组和链表实现, 为了方便, 这里用数组.
```go
// Queue 队列
type Queue struct {
	queue []int
}
```

### 常用操作

一般操作就两个
1. 向队列后添加一个数据
2. 从队列前取出一个数据


```go
// Len 长度
func (q *Queue) Len() int {
	return len(q.queue)
}

func (q *Queue) String() (s string) {
	for _, v := range q.queue {
		s += strconv.Itoa(v)
	}
	return
}

// Enqueue 进队
func (q *Queue) Enqueue(val int) *Queue {
	q.queue = append(q.queue, val)
	return q
}

// Dequeue 出队
func (q *Queue) Dequeue() (res int) {
	if q.Len() < 1 {
		log.Fatal("Emtpy queue")
	}
	res = q.queue[0]
	q.queue = q.queue[1:]
	return
}
```