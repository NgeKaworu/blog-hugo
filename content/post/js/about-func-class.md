---
title: "关于js里，函数、类的一些Q&A"
date: 2021-01-28T18:28:35+08:00
draft: false
tags: ["前端"]
keywords:
  - class
  - function
  - 函数
  - 类
  - 继承
  - 构造函数
  - 箭头函数
  - new
description: "js 微任务、宏任务、调用栈; node process.nextTick()和setImmedate()使用"
---

本篇主要记录一些关于`函数`、`类`、`箭头函数`、`继承`、`构造函数`等相关的一些问答

<!--more-->

### Q： 函数声明和函数表达式的定义和区别

A:

```js
// 表达式
const fn = () => {};
// 声明
function fn() {}
```

区别在于声明会存在提升（hoisting）

```js
console.log(fn) // 报错， 暂时性死区， 如果改成var来定义， 将打印undefined
const fn = () => {}

console.log(fn1) //fn1(){} OK 因为函数声明存在提升（hoisting）
function fn1(){}

//另外注意一点，如果存在表达式
if(true){
    fn2(){
        return 2
    }
}else{
    fn2(){
        return 1
    }
}
// 这里因为提升关系， fn2会返回1， 通过表达式可以解决

let fn2;
if(true){
    fn2 = () => { return 2}
}else{
    fn2 = () => { return 1}
}

```

### Q： 闭包是什么？

A: 闭包是指引用了另一个函数作用域中变量的函数，通过是在嵌套函数中实现。 —— 《红宝书 第四版》

### Q： 类在 es5 es6 区别

A： es5 的类不继承 static 方法和成员

### Q： 私有方法和私有成员

es6 不提供[参考](https://www.bookstack.cn/read/es6-3rd/spilt.5.docs-class.md)；ts 用 private，类似 c++；es5 使用表达式，如下：

```js
function Class() {
  let privateMember;
  let privateFunc = () => {};
}
```

### Q： 继承的方式

A： es6 用 extend， es5 有下面几种方式，详细翻红宝书：

- 原型链
- 盗用构造函数
- 组合继承
- 原型式继承
- 寄生式继承
- 寄生式组合继承

这是详细说下`寄生式组合继承`，因为这算是引用继承的最优方式

```js
function inheritPrototype(subType, superType) {
  let prototype = Object.create(superType.prototype); // 拷贝原型
  prototype.constructor = subType; // 改变原型指向
  subType.prototype = prototype; // 赋值给子类
}

// 基类
function SuperType(name) {
  // 成员属性
  this.name = name;
  this.colors = ["red", "yellow", "green"];
}

// 成员方法
SuperType.prototype.sayName = function () {
  console.log(this.name);
};

// 子类
function SubType(name, age) {
  // super, 盗用构造函数
  SuperType.call(this, name);
  this.age = age;
}

// 寄生组合继承
inheritPrototype(SubType, SuperType);

// 子类成员方法
SubType.prototype.SayAge = function () {
  console.log(this.age);
};
```

### Q： new 的时候发生了啥

A： new 关键字会进行如下的操作：(摘自 MDN)

1. 创建一个空的简单 JavaScript 对象（即{}）；
2. 链接该对象（设置该对象的 constructor）到另一个对象 ；
3. 将步骤 1 新创建的对象作为 this 的上下文 ；
4. 如果该函数没有返回对象，则返回 this。

```js
// 写成代码
function Fn(age) {
  this.age = age;
}

const fn = new Fn(1)

(
  // 用IIFE模拟
  function () {
    // 1. 创建空对象
    let temp = {};
    // 2. 把该对象的__proto__属性指向构造函数的原型链（prototype）
    temp.__proto__ = Fn.prototype;
    // 3. 用该对象做为this调用构造函数
    Fn.call(temp, 1);
    // 4. 返回“this”
    return temp;
  }
)();
```

### Q： 箭头函数定义
A： 箭头函数表达式的语法比函数表达式更简洁，并且没有自己的this，arguments，super或new.target。箭头函数表达式更适用于那些本来需要匿名函数的地方，并且它不能用作构造函数。 -- 《MDN》
- 箭头函数不会创建自己的this,它只会从自己的作用域链的上一层继承this。
- 由于 箭头函数没有自己的this指针，通过 call() 或 apply() 方法调用一个函数时，只能传递参数（不能绑定this---译者注），他们的第一个参数会被忽略。（这种现象对于bind方法同样成立---译者注）
- 箭头函数不能用作构造器，和 new一起用会抛出错误。
- 箭头函数没有prototype属性。
-  yield 关键字通常不能在箭头函数中使用（除非是嵌套在允许使用的函数内）。因此，箭头函数不能用作函数生成器。