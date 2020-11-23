---
date: 2020-11-18T16:06:36+08:00
title: "【数据结构】堆(heap)学习笔记"
draft: false
tags: ["数据结构"]
keywords:
- "数据结构"
- "date structure"
- "堆"
- "heap"
description : "数据结构学习之堆"
---

## 简述
这里的堆都是二叉堆, 是一种优先队列(priority queue), 但他不是队列那种链式结构, 而是树型结构.  
它满足以下两个性质
1. 完全二叉树
> 在一颗二叉树中，若除最后一层外的其余层都是满的，并且最后一层要么是满的，要么在右边缺少连续若干节点，则此二叉树为完全二叉树（Complete Binary Tree）。具有n个节点的完全二叉树的深度为
{{< math "inline" >}}
\begin{matrix}
log_{2}n+1
\end{matrix}
{{< /math >}}
深度为k的完全二叉树，至少有
{{< math "inline" >}}
\begin{matrix}
2^{k-1}
\end{matrix}
{{< /math >}}
个节点，至多有
{{< math "inline" >}}
\begin{matrix}
2^{k}-1
\end{matrix}
{{< /math >}}
个节点。
2. 父节点大于(小于)子节点; 大于的是最大堆, 小于的是最小堆.

它和队列一样只有两个操作
1. 插入(insert)
2. 从头部移出一项(pop)

但在这两个操作之后,为了维持上述属性, 还会以下自处理
1. 上浮(swim), 一般在插入(insert)后, 如果插入元素小于(最小堆)父元素, 交换其位置, 循环至满足性质;
2. 下沉(sink), 一般在取走头(pop)后, 用末尾元素填充头部, 如果填充元素大于(最小堆)子元素, 交换其位置,循环至满足性质;
<!--more-->
## 在前端的应用
小弟才疏学浅,还没在前端应用过,不过听说可以用来排序; 而且根据其性质, 用来做有优先级的调度器会很不错

## 代码
[完整代码(附测试用例)](https://github.com/NgeKaworu/goLab/blob/main/struct/heap/heap.go)

完全二叉树不会出现稀疏情况, 所以用数组而不用链表实现,其中: 
- 父节点位置: (i-1)/2
- 左叶子节点: i*2 + 1
- 右叶子节点: i*2 + 2

### 基础结构
```go
// Heap 堆
type Heap struct {
	heap []int
}
```

### 构造函数
```go
// Heapify 堆化
func Heapify(arr []int) *Heap {
	h := new(Heap)
	for _, v := range arr {
		h.Insert(v)
	}
	return h
}
```

### get 属性
```go
// Len 长度
func (h *Heap) Len() int {
	return len(h.heap)
}

func (h *Heap) String() (s string) {
	t, l := 1, 1
	for k, v := range h.heap {
		s += " " + strconv.Itoa(v)
		if k == (l - 1) {
			s += "\n"
			t <<= 1
			l += t
		}
	}
	return
}

```

### 基本操作
```go
// Insert 插入
func (h *Heap) Insert(val int) *Heap {
	h.heap = append(h.heap, val)
	h.swim(h.Len() - 1)
	return h
}

// Pop 弹出
func (h *Heap) Pop() (res int) {
	res = h.heap[0]
	h.heap[0] = h.heap[h.Len()-1]
	h.heap = h.heap[:h.Len()-1]
	h.sink(0)
	return
}

```

### 自修复方法
```go
// swap 交换位置
func (h *Heap) swap(p1, p2 int) *Heap {
	h.heap[p1], h.heap[p2] = h.heap[p2], h.heap[p1]
	return h
}

// Swim 上浮
func (h *Heap) swim(pos int) *Heap {
	for pos > 0 && h.heap[pos] < h.heap[parent(pos)] {
		// 如果第 k 个元素不是堆顶且比上层小
		// 将 k 换上去
		h.swap(pos, parent(pos))
		pos = parent(pos)
	}
	return h
}

// Sink 下沉
func (h *Heap) sink(pos int) *Heap {
	l := h.Len()
	// 如果沉到堆底，就沉不下去了
	for left(pos) < l {
		// 先假设左边节点较小
		t := left(pos)
		// 如果右边节点存在，比一下大小
		if right(pos) < l && h.heap[t] > h.heap[right(pos)] {
			t = right(pos)
		}
		// 结点 k 比俩孩子都小，就不必下沉了
		if h.heap[t] > h.heap[pos] {
			break
		}
		// 否则，不符合最小堆的结构，下沉 k 结点
		h.swap(pos, t)
		pos = t
	}

	return h
}

// parent 返回父节点
func parent(pos int) int {
	return (pos - 1) / 2
}

// left 返回左节点
func left(pos int) int {
	return pos*2 + 1

}

// right 返回左节点
func right(pos int) int {
	return pos*2 + 2

}

```