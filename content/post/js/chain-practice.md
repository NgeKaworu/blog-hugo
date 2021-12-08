---
date: 2021-12-07T15:53:28+08:00
title: "从一次HOC开发引申出链表的应用"
draft: false
tags: ["前端"]
keywords:
  - chain
  - 链表
  - front end
  - 前端
description: "链表在前端的应用"
---

### 需求简化

一个 Table，基于 antd。
需要提供大量默认`render`，如格式化、map、前后缀等；  
而各个`render`间效果需要叠加

### 核心逻辑

基于用户故事，我采用链式渲染机制，流程如下。
{{< mermaid loadMermaidJS="true" >}}
graph LR
START((渲染)) --> renderA
renderA -->|next| renderB
renderB -->|next| renderC
renderC -->|next| renderD
renderD --> END((返回标准 render))
{{< /mermaid >}}

如图，直观上有点像中间件，所以我们需要处理好渲染链和渲染节点的关系。  
特别是后来居上的`render`，因为前者的渲染行为会被后者覆盖。

> 所以会有个问题，`顺序重要`，稍后我会通过代码来解释

```tsx
function _tsumugi<RecordType>(
  c: LightColumnProps<RecordType>
): TableColumnProps<RecordType>["render"] {
  const { basicRenderNode, ...node } = _toLightRenderNode(_factory(c));

  const chain = new RenderChain(basicRenderNode);
  const prepend = _pickNode(
      ["valueEnum", "valueType", "prefix", "suffix", "paragraph"],
      node
    ),
    append = _pickNode(["columnEmptyText"], node);

  chain
    .Prepend(basicRenderNode, ...prepend)
    ?.Append(basicRenderNode, ...append);

  return (v, r, i) => {
    let tmp = v;

    for (const n of chain) {
      tmp = n?.render?.(tmp, r, i, v);
    }

    return tmp;
  };
}
```

画成图是
{{< mermaid loadMermaidJS="true" >}}
graph TB
START((开始)) --> valueEnum
valueEnum -->|next| valueType
valueType -->|next| prefix
prefix -->|next| suffix
suffix -->|next| paragraph
paragraph -->|next| basic
basic -->|next| columnEmptyText
columnEmptyText --> END((结束))
{{< /mermaid >}}

我具体解释一下每个 render 的职责

| render          | 职责                              | 函数签名                 |
| --------------- | --------------------------------- | ------------------------ |
| valueEnum       | 值映射 select radio 用到          | string => string         |
| valueType       | 格式化， dateTime dateRange digit | string => string         |
| prefix          | 前缀                              | string => string         |
| suffix          | 后缀                              | string => string         |
| paragraph       | 文本处理，ellipsis copyable       | string => React.Node     |
| basic           | 原点，手动渲染                    | any => React.Node        |
| columnEmptyText | 补 "-"                            | any => React.Node \| "-" |

至此我们可以解释`为什么顺序是重要的` —— 因为最后的 render 可以决定最终渲染行为。

> 所以我们需要一个`有序`的数据结构，并且可以考虑到将来，我们需要满足对各`render`的`顺序`的各种（插入、交换、删除等）操作。

我们来看下 js 世界内置的数据结构

| 数据结构 | 有序 | 易用 |
| -------- | ---- | ---- |
| Object   | 否   | 否   |
| Array    | 是   | 中等 |
| Set      | 是   | 否   |
| Map      | 是   | 否   |

> Object 无序
>
> ```ts
> console.log({
>   a: "a",
>   1: 1,
> });
> // { '1': 1, a: 'a' }
>
> console.log({
>   1: 1,
>   a: "a",
> });
>
> // { '1': 1, a: 'a' }
> ```

> set 和 map 的 weak 版本不参与讨论

看上去我们好像没得选，只能选数组了，虽然 js 的数组是对象、插入要用 splice、删除要用 splice(用 delete 导致不连续)、交换还是 splice。但是我知道，她是个好数据结构。

> js 的数组是对象
> ![数组](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2019/10/9/16daf8b790b95a88~tplv-t2oaga2asx-watermark.awebp)
>
> ```ts
> typeof [] === "object"; // true
> ```

> delete 导致不连续
>
> ```ts
> a = [1, 2, 3, 4, 5];
>
> delete a[0];
>
> console.log(a);
> // [ <1 empty item>, 2, 3, 4, 5 ]
> ```

> swap 3 5
>
> ```ts
> a = [1, 2, 3, 4, 5];
> a[a.indexOf(5)] = a.splice(a.indexOf(3), 1, a[a.indexOf(5)])[0];
> console.log(a);
> // [1, 2, 5, 4, 3]
> ```

乍一看封装一下也能用，且 js 动态数组是 hash-table 实现的，性能跟 chain 应该差不多。所以 chain 就没有优势了吗？
我们不妨换个角度思考问题：

- 职责边界：数组太万能了，完全可以被滥用；
- 维护成本：滥用引出的一个问题之一，一个通用的包应该是内聚且收敛的，不然迭代几个版本下来就变歪了。
- 心智成本：同样是滥用引出的问题 —— 你不能因为一个物体有四条腿，然后是黄色的就说它是条狗吧。

综上所述，我决定把 chain 约束为链表，一来压缩了类型；二是降低职责。

> 额外思考  
> 内存安全？  
> 实现 reverse?
