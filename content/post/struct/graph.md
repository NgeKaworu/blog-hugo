---
date: 2020-11-18T16:06:36+08:00
title: "【数据结构】图(graph)学习笔记"
draft: true
tags: ["数据结构"]
keywords:
- "数据结构"
- "date structure"
- "图"
- "graph"
- "十字链表"
description : "数据结构学习之图"
---

## 简述
图是一种N对N的数据结构, 有`有向图`,`加权图`等等很多花样; 相关算法也很多除了常用的`DFS`、`BFS`, 还有什么`A*`、`弗洛伊德算法`、`迪杰斯特拉算法`;实现方法也有诸如`接邻矩阵`、`接邻表`、`十字链表`. 萌新泪目T^T.  
下面是用`十字链表`实现的`双向加权图`, 只实现了`BFS`、`DFS(backtrack)`,我也就算是入了个门, 挖了坑,以后学到了再填=- =

[基础信息](http://data.biancheng.net/view/200.html)  
[寻路算法参考资料](https://blog.csdn.net/qibofang/article/details/51594673)  


<!--more-->
## 在前端的应用
跟寻路有关的八成都能用, 流程引擎也可以

## 代码
[完整代码(附测试用例)](https://github.com/NgeKaworu/goLab/blob/main/struct/graph/graph.go)

### 示例图
{{< mermaid loadMermaidJS="true" >}}
graph LR
    FIVE((5)) -- 200 --- FOUR((4))
    FIVE((5)) -- 30 --- EIGHT((8))
    FIVE((5)) -- 20 --- THREE((3))
    FIVE((5)) -- 4 --- ONE((1))
    FOUR((4)) -- 300 --- EIGHT((8))
    FOUR((4)) -- 700 --- TEN((10))
    EIGHT((8)) -- 3 --- SEVEN((7))
    THREE((3)) -- 40 --- SEVEN((7))
    SEVEN((7)) --> ONE((1))


  
    style FIVE fill: black,color:white
    style SEVEN fill: black,color:white


{{< /mermaid >}}

### 生成树

{{< mermaid loadMermaidJS="true" >}}
graph TB
    FIVE((5)) -- 200 --- FOUR((4))
    FIVE((5)) -- 30 --- EIGHT((8))
    FIVE((5)) -- 20 --- THREE((3))
    FIVE((5)) -- 4 --- ONE((1))
    EIGHT((8)) -- 3 --- SEVEN1((7))
    FOUR((4)) -- 300 --- EIGHT1((8))
    FOUR((4)) -- 700 --- TEN((10))
    EIGHT1((8)) -- 3 --- SEVEN2((7))
    THREE((3)) -- 40 --- SEVEN3((7))


  
    style FIVE fill: black,color:white
    style SEVEN1 fill: black,color:white
    style SEVEN2 fill: black,color:white
    style SEVEN3 fill: black,color:white
{{< /mermaid >}}


### 基础结构
```go
// Graph 图结构
type Graph struct {
	start *Vertex
}

// Vertex 顶点
type Vertex struct {
	key int             // 键
	in  map[*Vertex]int // 入度
	out map[*Vertex]int // 出度
}
```

### 工厂方法和打印方法
```go
// NewVertex 工厂方法
func NewVertex(k int) *Vertex {
	return &Vertex{key: k, in: map[*Vertex]int{}, out: map[*Vertex]int{}}
}

// BFS 打印
func (g *Graph) String() (res string) {
	// 标记去过的地方
	memo := map[*Vertex]bool{g.start: true}
	queue := []*Vertex{g.start}
	for len(queue) != 0 {
		dequeue := queue[0]
		queue = queue[1:]
		for vertex, weight := range dequeue.out {
			if memo[vertex] == false {
				queue = append(queue, vertex)
				memo[vertex] = true
			}
			res += fmt.Sprintf(" %v --(%v)--> %v ", dequeue.key, weight, vertex.key)
		}
		res += "\n"
	}
	return
}
```

### 查找方法
这里是用backtrack(回溯)的方法实现的DFS(深度优先查询)  
回去看[生成树](./#生成树), 存在重复子问题, 最好用dp剪下枝, 我先挖个坑, 想到了回来填
```go
// FindAllPath 返回所有路径 回溯实现
func (v *Vertex) FindAllPath(end int) []string {
	res := make([]string, 0)

	var backtrack func(v *Vertex, memo map[*Vertex]bool)
	backtrack = func(v *Vertex, memo map[*Vertex]bool) {
		if v.key == end {
			var tmp string
			var pre *Vertex
			for v := range memo {
				if pre != nil {
					tmp += fmt.Sprintf(" --(%v)--> ", pre.out[v])
				}
				pre = v
				tmp += strconv.Itoa(v.key)
			}
			if pre != nil {
				tmp += fmt.Sprintf(" --(%v)--> %v", pre.out[v], v.key)
			}
			res = append(res, tmp)
			return
		}

		for k := range v.out {
			if memo[k] {
				continue
			}
			memo[v] = true
			backtrack(k, memo)
			delete(memo, v)
		}

	}

	m := make(map[*Vertex]bool)
	backtrack(v, m)
	return res
}

// ShortestPath 返回所有路径
func (v *Vertex) ShortestPath(end int) string {
	// 这个用FindAllPath方法算出最小路径即可, 但是会存在重复子问题
	// 这个时候需要dp一下, dp算法还在想, 想好更新
	return ""
}
```

### 节点建立和取消连接方法
```go
/*
Connect 连接两个顶点
degree 度 —— 0: 出度; 1: 入度; 2:双向
weight 权重
*/
func (v *Vertex) Connect(n *Vertex, degree, weight int) *Vertex {
	switch degree {
	case 0:
		v.out[n] = weight
		n.in[v] = weight
		break
	case 1:
		v.in[n] = weight
		n.out[v] = weight
		break
	case 2:
		v.out[n] = weight
		v.in[n] = weight
		n.out[v] = weight
		n.in[v] = weight
		break

	}
	return v
}

/*
Disconnect 取消连接两个顶点
degree 度 —— 0: 出度; 1: 入度; 2:双向
*/
func (v *Vertex) Disconnect(n *Vertex, degree int) *Vertex {
	switch degree {
	case 0:
		delete(v.out, n)
		delete(n.in, v)
		break
	case 1:
		delete(v.in, n)
		delete(n.out, v)
		break
	case 2:
		delete(v.out, n)
		delete(n.out, v)
		delete(v.in, n)
		delete(n.in, v)
		break

	}
	return v
}

```