---
date: 2022-01-12T13:59:01+08:00
title: "实现一个红绿灯"
draft: false
tags: ["设计规划", "数据结构"]
keywords:
  - 设计规划
  - 数据结构
description: "实现一个可手控的红绿灯"
---

前几天遇到一道有意思的题目。  
大意是用 async 和 await 实现一个红绿灯。红灯停 5s、绿灯 10s、黄灯 3s。

> 扩展：支持手动切换当前灯的状态

<!--more-->

非扩展部分很简单，实现一个 sleep 就 OK 了。但是**扩展**部分很好玩。  
本身 Promise 就是 Micro Queue 的实现；所以初步我打算用 queue 实现，正在考虑队列的**防饿死**问题时，我意识到**实效性**的问题。
即便我把红灯手动入队，但是我渲染的还是当前出队的灯，会导致延迟的问题。  
如果我渲染的队首，然后轮训出队。不断入队。则需求考虑队满了之后的策略。  
所以我认为 Queue 不是首选的结构。我最后采用了状态链表实现。

> 节点

```tsx
class Node {
  public color: string;
  public delay: number;
  next: Node | null = null;

  constructor({ color, delay }: { color: string; delay: number }) {
    this.color = color;
    this.delay = delay;
  }
}
```

节点很简单，保存一些 payload 即可

> 链表实现

```tsx
class Ring {
  private head: Node | null;
  private timer: number = 0;

  public onNext?: (n: Node | null) => void;

  constructor() {
    this.head = null;
  }

  set(n: Node) {
    this.head = n;
  }

  reset(n: Node) {
    this.stop();
    this.set(n);
    this.onNext?.(n);
    this.poll();
  }

  poll() {
    if (this.head) {
      this.timer = window.setTimeout(() => {
        this.next();
        this.poll();
      }, this.head?.delay);
    }
  }

  stop() {
    clearTimeout(this.timer);
  }

  next() {
    this.head = this.head?.next ?? null;
    this.onNext?.(this.head ?? null);
  }
}
```

其中 reset 方法用于实现手动控制功能。  
下面我们看下如何使用

```tsx

const red = new Node({ color: 'red', delay: 5000 }),
  yellow = new Node({ color: 'yellow', delay: 3000 }),
  green = new Node({ color: 'green', delay: 10000 });

red.next = yellow;
yellow.next = green;
green.next = red;

const ring = new Ring();

export default () => {
  const [curNode, setCurNode] = useState<Node | null>(red);
  useEffect(() => {
    ring.set(red);
    ring.onNext = setCurNode;
    ring.poll();
    return () => {
      ring.stop();
    };
  }, []);

  return (
    <>
      {curNode?.color}

      <br />
      <button onClick={() => {ring.reset(red)}}>
        red
      </button>

      <button onClick={() => {ring.reset(yellow)}}>
        yellow
      </button>

      <button onClick={() => {ring.reset(green)}}>
        green
      </button>
    </>
  );
};

```

### 总结
总结下用链表的好处：
1. 每个灯（Node）相对独立。复用性高。我可以new 5s的黄灯 10s的黄灯 20s的黄灯应对不同的场景；
2. 更灵活的运行时（runtime）编排；
3. 更好的可读、可维护性。



