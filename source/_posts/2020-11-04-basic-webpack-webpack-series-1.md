---
title: 打包原理(webpack系列-1)
date: 2020-11-04 11:25:46
tags:
  - webpack
---

# ABSTRACT
  本文主要介绍webpack基本的打包原理.

  打包主要三个步骤: 
  
  1. 转换代码
  2. 生成依赖图
  3. 生成代码字符串

  然后通过`require`函数将代码组织到bundle(代码块)中,就齐活了

# 参考资料

1. https://juejin.im/post/6844903858179670030 :  提供的主要思路
2. https://github.com/airuikun/blog/issues/4 : 这个讲的比第一个详细
3. https://zhuanlan.zhihu.com/p/107125345 : 这个排版和代码看着更舒服. 可以合1,2结合看
4. https://aotu.io/notes/2020/07/17/webpack-analize/index.html 这个实践不错