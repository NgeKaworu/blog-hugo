---
title: "Js里的调用栈(call stack)、消息队列(message queue) 、工作队列(job queue)、process.nextTick()、setImmediate()"
date: 2020-12-22T09:21:27+08:00
draft: false
tags: ["前端"]
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
- setImmediate()
- process.nextTick()
description : "js 微任务、宏任务、调用栈; node process.nextTick()和setImmedate()使用"
---

`消息队列(message queue)`里的任务也被称作`宏任务(macrotask)`  
> I/O操作、fetch、event(onClick)、渲染任务都是宏任务  

`工作队列(job queue)`里的任务也被称作`微任务(microtask)`  
> MutationObserver、和Promise属于微任务  

`process.nextTick()`和`setImmediate()`是node独有的`插队`方法  


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

### 解释
Every time the event loop takes a full trip, we call it a tick.   
> 每次事件循环进行一整趟时，我们都将其称为tick。  


When we pass a function to process.nextTick(),   
> 当我们将一个函数传递给process.nextTick（）时，  


we instruct the engine to invoke this function at the end of the current operation, before the next event loop tick starts:   
> 我们指示引擎在下一个事件循环开始之前，在当前操作结束后调用此函数：  


我测试下来, 他的优先级大于微任务, 会在微任务之前执行, 然后执行完所有内部代码, 有趣的是, 它内部如果有微任务, 那么会和外部的微任务交替插入. 具体行为, 请复制下面的代码自己跑一跑, 我现在脑壳疼.

### 例子
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

## setImmediate
### 解释
简单的说`setImmediate`会在任何`I/O`操作之后执行, 以下抄自stack overflow的解答 ——   

Use setImmediate if you want to queue the function behind whatever I/O event callbacks that are already in the event queue.  
> 如果要将函数放在事件队列中已经存在的任何I / O事件回调后面，请使用setImmediate。  


Use process.nextTick to effectively queue the function at the head of the event queue so that it executes immediately after the current function completes.   
> 使用process.nextTick将函数有效地放在事件队列的开头，以便在当前函数完成后立即执行。  


So in a case where you're trying to break up a long running, CPU-bound job using recursion, you would now want to use setImmediate rather than process.nextTick to queue the next iteration as otherwise any I/O event callbacks wouldn't get the chance to run between iterations.   
> 因此，在您尝试使用递归分解长时间运行且受CPU限制的作业的情况下，您现在想使用setImmediate而不是process.nextTick将下一次迭代排队，因为否则所有I / O事件回调都不会没有机会在迭代之间运行。  


### 例子
```js
import fs from 'fs';
import http from 'http';

const options = {
  host: 'www.stackoverflow.com',
  port: 80,
  path: '/index.html'
};

describe('deferredExecution', () => {
  it('deferredExecution', (done) => {
    console.log('Start');
    setTimeout(() => console.log('TO1'), 0);
    setImmediate(() => console.log('IM1'));
    process.nextTick(() => console.log('NT1'));
    setImmediate(() => console.log('IM2'));
    process.nextTick(() => console.log('NT2'));
    http.get(options, () => console.log('IO1'));
    fs.readdir(process.cwd(), () => console.log('IO2'));
    setImmediate(() => console.log('IM3'));
    process.nextTick(() => console.log('NT3'));
    setImmediate(() => console.log('IM4'));
    fs.readdir(process.cwd(), () => console.log('IO3'));
    console.log('Done');
    setTimeout(done, 1500);
  });
});

// 输出
// Start
// Done
// NT1
// NT2
// NT3
// TO1
// IO2
// IO3
// IM1
// IM2
// IM3
// IM4
// IO1

```
## setImmediate() 对比 setTimeout()
如果运行以下不在 I/O 周期（即主模块）内的脚本，则执行两个计时器的顺序是非确定性的，因为它受进程性能的约束;但是，如果你把这两个函数放入一个 I/O 循环内调用，setImmediate 总是被优先调用.  
[详情请看][event loop]

## 参考资料
[消息队列和事件循环、宏任务和微任务](https://juejin.cn/post/6844903984856055821)  
[The Node.js Event Loop](https://nodejs.dev/learn/the-nodejs-event-loop)  
[Understanding process.nextTick()](https://nodejs.dev/learn/understanding-process-nexttick)  
[Understanding setImmediate()](https://nodejs.dev/learn/understanding-setimmediate)  
[setImmediate vs. nextTick](https://stackoverflow.com/questions/15349733/setimmediate-vs-nexttick)  


[event loop]: https://nodejs.org/zh-cn/docs/guides/event-loop-timers-and-nexttick/