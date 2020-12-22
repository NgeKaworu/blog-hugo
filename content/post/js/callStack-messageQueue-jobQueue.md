---
title: "Js里的调用栈(call stack)、消息队列(message queue) 和工作队列(job queue)"
date: 2020-12-22T09:21:27+08:00
draft: false
tags: ["js"]
keywords:
- 调用栈
- call stack
- 消息队列
- message queue
- 工作队列
- job queue
- 宏任务
- macrotask
- 微任务
- microtask
description : "散列函数的介绍"
---

`消息队列(message queue)`里的任务也被称作`宏任务(macrotask)`
> I/O操作、fetch、event(onClick)、渲染任务都是宏任务
`工作队列(job queue)`里的任务也被称作`微任务(microtask)`
> MutationObserver、和Promise属于微任务

<!--more-->
以下图片、例子均来自node官网

## 调用栈(call stack)

众所周知,js是单线程事件驱动的语言.它自上而下执行, 把遇到的函数压入`调用栈(call stack)`, 然后按顺序执行.

### 举个例子
```js
const bar = () => console.log('bar')

const baz = () => console.log('baz')

const foo = () => {
  console.log('foo')
  bar()
  baz()
}

foo()

// 输出
// foo
// bar
// baz
```

### 调用顺序如下
![stack1](https://nodejs.dev/static/270ebeb6dbfa7d613152b71257c72a9e/c83ae/call-stack-first-example.png)

![stack2](https://nodejs.dev/static/ca404c319c6fc595497d5dc097d469ff/fc1a1/execution-order-first-example.png)

## 消息队列(message queue)
消息队列会在每次清空调用栈后, 工作队列清空后才执行

### 例子
```js
const bar = () => console.log('bar')

const baz = () => console.log('baz')

const foo = () => {
  console.log('foo')
  setTimeout(bar, 0)
  baz()
}

foo()

// 输出
// foo
// baz
// bar

```

### 执行顺序
![msg1](https://nodejs.dev/static/be55515b9343074d00b43de88c495331/966a0/call-stack-second-example.png)

![msg2](https://nodejs.dev/static/585ff3207d814911a7e44d55fbde483b/f96db/execution-order-second-example.png)

## 工作队列(job queue)
工作队列会在调用栈后, 消息队列前执行, 它在当间

### 例子
因为node官网没画图, 我这里写上注释

```js
const bar = () => console.log("bar");

const baz = () => console.log("baz");

const foo = () => {
  // 2. 顺序执行
  console.log("foo");

  new Promise((resolve, reject) => {
    // 3. new Promise里面是同步的 
    console.log(1);
    // 4. resolve进入工作队列(job queue)
    resolve("should be right after baz, before bar");
    // 5. 顺序执行
    console.log(2);
    return 3;
  })
    // 6. then 进入工作队列(job queue)
    .then((resolve) => 
    // 10. 调用栈结束, 开始执行微任务(microtask), 清空工作队列(job queue)
    console.log(resolve)
    )
    // 7. then 进入工作队列(job queue)
    .then(() => {
    // 11. 执行第二个微任务(micro task)
      console.log("second job queue");
    // 12. 压入第二个宏任务(macro task)到消息队列(message task)
      setTimeout(() => {
        // 14. 执行第二个宏任务
        console.log("second message job");
      }, 0);
    });
  // 8. 压入消息队列(message queue) 
  setTimeout(
    // 13. 任务队列清空, 执行第一个宏任务
      bar, 
  0);
  // 9. 顺序执行   
  baz();
};

// 1. 调用栈从这里进去
foo();

//输出
// foo
// 1
// 2
// baz
// should be right after baz, before bar
// second job queue
// bar
// second message job 
```