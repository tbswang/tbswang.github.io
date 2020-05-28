---
title: 一次关于vue和js的小误会
date: 2020-05-27 17:21:31
tags:
  - vue
---

## 问题复现
在demo: https://codesandbox.io/s/a-vue-and-js-mistake-fedfo

直接赋值的元素, 不会改变初始值

通过splice改变的元素, 会改变初始值
## 大胆假设
* initialValue只是一个引用, DBList也是一个引用.
* 在data函数中定义的时候, 实质是将 DBlist 变成了响应式
* 在赋值时候, vue将新的变量变成响应式, DBlist 指向新的变量
* 在splice的时候, 直接修改了 tablelist 的值.也就是修改了initialValue的值.

> 在vue3中依然有这样的问题

## 小心求证

## 得出结论