---
date: 2020-11-09T00:00:50+08:00
title: "【数据结构】红黑树学习笔记"
draft: true
tags: ["数据结构"]
keywords:
- "数据结构"
- "date structure"
- "红黑树"
description : "数据结构学习之红黑树"
---
## 简述
红黑树(RBT)是一种自平衡的二叉搜索树(BST), 首先看BST的定义
>  二叉查找树，也称有序二叉树（ordered binary tree），或已排序二叉树（sorted binary tree），是指一棵空树或者具有下列性质的二叉树：

- 若任意节点的左子树不空，则左子树上所有结点的值均小于它的根结点的值；
- 若任意节点的右子树不空，则右子树上所有结点的值均大于它的根结点的值；
- 任意节点的左、右子树也分别为二叉查找树。
- 没有键值相等的节点（no duplicate nodes）。

如图
{{< mermaid loadMermaidJS="true" >}}
graph TD
    ROOT((1000)) --> A((100))
    ROOT((1000)) --> B((10000))
    A --> A1((10))
    A --> A2((500))
    B --> B1((5000))
    B --> B2((100000))
{{< /mermaid >}}

> 在这些基础上再加上以下五条性质
1. 每个结点要么是红的要么是黑的。  
2. 根结点是黑的。  
3. 每个叶结点（叶结点即指树尾端NIL指针或NULL结点）都是黑的。  
4. 如果一个结点是红的，那么它的两个儿子都是黑的。  
5. 对于任意结点而言，其到叶结点树尾端NIL指针的每条路径都包含相同数目的黑结点。 

{{< mermaid loadMermaidJS="true" >}}
graph TD
    ROOT((10)) --> A((5))
    ROOT((10)) --> B((15))
    A --> A1((3))
    A --> A2((7))
    B --> B1((13))
    B --> B2((20))
    A1 --> A11((1))
    A1 --> A12[NIL]
    A2 --> A21[NIL]
    A2 --> A22[NIL]
    B1 --> B11[NIL]
    B1 --> B12[NIL]
    B2 --> B21((18))
    B2 --> B22((25))
  
    style ROOT fill: black,color:white
    style A1 fill: black,color:white
    style A12 fill: black,color:white
    style A2 fill: black,color:white
    style A21 fill: black,color:white
    style A22 fill: black,color:white
    style B1 fill: black,color:white
    style B11 fill: black,color:white
    style B12 fill: black,color:white
    style B2 fill: black,color:white

    style A fill: red,color:black
    style A11 fill: red,color:black
    style B fill: red,color:black
    style B21 fill: red,color:black
    style B22 fill: red,color:black

{{< /mermaid >}}

 **最下面应试还有一层nil节点, mermaid毕竟是画流程图的, 画树还是有点勉强**
<!--more-->
## 在前端的应用
我没在前端用过, 不过这货读写成本都是logN, 1B的数据量只用30次操作就能搞定, 
{{< math "inline" >}}
\begin{matrix}
2^{30} = 1073741824
\end{matrix}
{{< /math >}}

## 代码
[完整代码(附测试用例)](https://github.com/NgeKaworu/goLab/blob/main/struct/rbtree/rbtree.go)

### 基本结构
```go
// RBTree 红黑树
type RBTree struct {
	root *RBLeaf
}

// RBLeaf 红黑节点
type RBLeaf struct {
	key                 int
	left, right, parent *RBLeaf
	red                 bool
}

```




### replace 替换
```go
// 用目标替换当前节点
func (t *RBTree) replace(old, new *RBLeaf) {
	if old == t.root {
		// 如果要替换的是root
		t.root = new
	} else {
		p := old.parent

		if p.left == old {
			p.left = new
		}

		if p.right == old {
			p.right = new
		}
	}

}

```
### 打印 (bfs队列实现)
```go
// BFS 广度优先 打印
func (t *RBTree) String() (str string) {
	// 初始化队列
	queue := []*RBLeaf{t.root}
	count, line := 0.0, 1.0
	for len(queue) != 0 {
		// 插入换行
		// 高度h = h(n) = log2(n) + 1, n是节点数
		h := math.Floor(math.Log2(count + 1))
		if h == line {
			str += "\n"
			line++
		}
		count++

		// pop
		leaf := queue[0]
		queue = queue[1:]
		if leaf != nil {
			str += fmt.Sprintf("(%v, %v) ", leaf.key, leaf.red)
			queue = append(queue, leaf.left, leaf.right)
		} else {
			str += " nil "
		}

	}
	return
}
```

### 查询 (dfs循环实现)
```go
// Find 查找
func (t *RBTree) Find(k int) *RBLeaf {
	cur := t.root
	for cur != nil {
		if k > cur.key {
			cur = cur.right
		} else if k < cur.key {
			cur = cur.left
		} else {
			return cur
		}
	}
	return nil
}

```

### 插入 (dfs递归实现)
```go
func (l *RBLeaf) insert(k *RBLeaf) {
	// 绑个父元素
	k.parent = l
	// DFS 深度优先
	if k.key <= l.key {
		// 小于等于走左边
		if l.left == nil {
			// 左树为空, 左树即是节点
			l.left = k
		} else {
			// 递归左树
			l.left.insert(k)
		}
	} else {
		// 大于走右边
		if l.right == nil {
			// 右树为空, 右树即节点
			l.right = k
		} else {
			// 递归右树
			l.right.insert(k)
		}
	}
}

// Insert 插入 DFS
func (t *RBTree) Insert(k int) *RBTree {
	n := &RBLeaf{key: k, red: true}
	if t.root == nil {
		t.root = n
	} else {
		t.root.insert(n)
	}

	return t
}

```

### 删除
```go
// Remove 删除
// 删除逻辑
// 如果同时有左右子叶, 则用右子叶的最左子叶代替位置(逻辑上 左子叶的最右子叶也可以),
// 否则用存在的子叶代替
func (t *RBTree) Remove(k int) *RBTree {
	l := t.Find(k)
	if l == nil {
		return t
	}
	if l.left == nil && l.right == nil {
		// 左右子叶都为空, 用nil代替
		t.replace(l, nil)
	} else if l.left != nil && l.right != nil {
		// 左右子叶都不为空
		// 找到右子叶的最左子叶节点
		cur := l.right
		for cur.left != nil {
			cur = cur.left
		}

		// 从父节点用它的右树替换它
		t.replace(cur, cur.right)
		// 把原节点的左右子叶赋给目标
		cur.left = l.left
		cur.right = l.right
		// 替换他
		t.replace(l, cur)

	} else if l.left == nil {
		// 左子叶为空
		t.replace(l, l.right)
	} else {
		// 右子叶为空
		t.replace(l, l.left)
	}

	return t
}

```

### 左旋

### 右旋

### 变色

### 自平衡