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
### 如何将callback包装成promise
```js
// 将图片转换为base64
function promisify(){
  return new Promise((resovle, reject) => {

  })
}

```

## 执行的问题
### promise和Settimeout
这是关于执行顺序的问题


### 取消执行


## 结束的问题
### catch和reject的区别
异常捕获

## 多个异步链式调用

## 多个异步并发
