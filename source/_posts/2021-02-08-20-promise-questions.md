---
title: promise 20问
date: 2021-02-08 22:31:43
tags:
- js
---
# Abstract

强行收集了20个promise的问题.

promise是一种异步的解决方案, 所有问题都是围绕异步展开的.而异步不外乎是: 创建, 执行, 结束.

## 创建的问题

### 手写一个promise
原理: 一开始new Promise, 都是pending状态, 每一个then, 都是push一下callback, 然后new一个新的Promise; 当变成resole, 执行callback数组里面的回调, 顺便执行将新的promise的状态变成resole. 这就是链式调用. 

### 为什么then里面都是返回一个新的Promise呢? 只有一个可以吗?

### 实现Promise.any
有任何一个成功, 就返回成功; 否则全部失败,就返回一个 [AggregateError](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/AggregateError)
```js

```

### 实现Promise.race

### 如何将callback包装成promise

```js
// 将图片转换为base64
function getBase64(file){
  return new Promise((resole, reject) => {
    const fr = new FileReader();
    fr.readAsDataURL(file);
    fr.onload = () => {
      resole(fr.result);
    }
		fr.onerror = (e) => {
			reject(fr.error)
		}
  })
}
```

## 执行的问题

### promise和Settimeout

这是关于执行顺序的问题

### 最大并发数

### 取消执行

### 如何在then中reject

### 超时取消执行

## 结束的问题

### catch和reject的区别

异常捕获

## 多个异步链式调用

## 多个异步并发

## 参考资料
* 手写: https://juejin.cn/post/6945319439772434469#heading-31