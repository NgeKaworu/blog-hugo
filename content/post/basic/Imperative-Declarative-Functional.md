---
date: 2020-12-11T15:29:48+08:00
title: "【笔记】命令式编程(Imperative)、声明式编程(Declarative)和函数式编程(Functional)"
draft: false
tags: ["计算机科学"]
keywords:
- Imperative
- Declarative
- Functional
- 命令式编程
- 声明式编程
- 函数式编程
description : "命令式编程(Imperative)、声明式编程(Declarative)和函数式编程(Functional)"
---

## 参考资料
先上参考资料  
[入门](https://www.cnblogs.com/sirkevin/p/8283110.html)  
[进阶](https://www.cnblogs.com/doit8791/p/8232821.html)  

<!--more-->

## 示例
我很难用语言描述, 所以还是废话少说, 放码过去吧.(talk is cheap, show you the code)

```js
// 假设我们要找arr里大于3的值
const arr = [1, 2, 3, 4, 5, 6]
```

### 命令式编程(Imperative)
```js
    let res = [];
    // 告诉计算机要遍历
    for(let i = 0; i < arr.lenght; i++){
        // 告诉计算机把 > 3的值取出来
        if(i > 3){
            res.push(i)
        }
    }
```

### 声明式编程(Declarative)
```sql
SELECT * FROM arr WHERE val > 3

```

### 函数式编程(Functional)
```js
    arr.filter(i => i > 3)
```

我个人理解: 
- 命令式重视过程(How)
- 而声明是重视结果(What),
- 而函数式是声明式的进阶.把过程弱化, 只重视结果,且结果可以当做下一个函数的入参, 在数学上称作函数组合(function composition); 即 f(x) -> g(x) = f(g(x)))