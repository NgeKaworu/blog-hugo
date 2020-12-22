---
title: "Js里的调用栈(call stack)、消息队列(message queue) 、工作队列(job queue)、process.nextTick()"
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

`process.nextTick()`是node独有的`插队`方法  


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

## process.nextTick()
Every time the event loop takes a full trip, we call it a tick.   
> 每次事件循环进行一整趟时，我们都将其称为tick。  


When we pass a function to process.nextTick(),   
> 当我们将一个函数传递给process.nextTick（）时，  


we instruct the engine to invoke this function at the end of the current operation, before the next event loop tick starts:   
> 我们指示引擎在下一个事件循环开始之前，在当前操作结束后调用此函数：  


我测试下来, 他的优先级大于微任务, 会在微任务之前执行, 然后执行完所有内部代码, 有趣的是, 它内部如果有微任务, 那么会和外部的微任务交替插入. 具体行为, 请复制下面的代码自己跑一跑, 我现在脑壳疼.

```js
process.nextTick(() => {
    console.log("1 tick");
    setTimeout(() => {
      console.log("in tick macro task")
    }, 0);
    new Promise((res) => res())
    //   Promise.resolve()
        .then(() => console.log("in tick micro task1"))
        .then(() => console.log("in tick micro task2"));
      
    process.nextTick(()=>{
      console.log('in tick') 
    })
  });
  
  const bar = () => {
    console.log("bar");

  
      // new Promise((res) => res())
    Promise.resolve()
      .then(() => console.log("anthor micro task1"))
      .then(() => console.log("anthor micro task2"));

      process.nextTick(() => {
        console.log("6 tick");
      });
  };
  
  const baz = () => console.log("baz");
  
  const foo = () => {
    console.log("foo");
  
    new Promise((resolve, reject) => {
      process.nextTick(() => {
        console.log("2 tick");
      });
      console.log(1);
      resolve("should be right after baz, before bar");
      console.log(2);
      return 3;
    })
      .then((resolve) => {
        process.nextTick(() => {
          console.log("4 tick");
        });
        console.log(resolve);
      })
      .then(() => {
        console.log("second job queue");
        process.nextTick(() => {
          console.log("5 tick");
        });
        setTimeout(() => {
          process.nextTick(() => {
            console.log("7 tick");
          });
          console.log("second message job");
        }, 0);
      });
    setTimeout(bar, 0);
    baz();
  };
  
  foo();
  
  process.nextTick(() => {
    console.log("3 tick");
  });
  // 输出
  // foo
  // 1
  // 2
  // baz
  // 1 tick
  // 2 tick
  // 3 tick
  // in tick
  // should be right after baz, before bar
  // in tick micro task1
  // second job queue
  // in tick micro task2
  // 4 tick
  // 5 tick
  // bar
  // 6 tick
  // anthor micro task1
  // anthor micro task2
  // in tick macro task
  // second message job
  // 7 tick
  
```
  

## 参考资料
[消息队列和事件循环、宏任务和微任务](https://juejin.cn/post/6844903984856055821)  
[The Node.js Event Loop](https://nodejs.dev/learn/the-nodejs-event-loop)
[Understanding process.nextTick()](https://nodejs.dev/learn/understanding-process-nexttick)