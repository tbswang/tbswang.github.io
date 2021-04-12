---
title: react源码2-react模块
date: 2021-02-28 17:46:09
tags:
---

# 代码结构
```bash
./packages/react/src
├── BadMapPolyfill.js
├── IsSomeRendererActing.js
├── React.js # 入口文件
├── ReactBaseClasses.js
├── ReactChildren.js
├── ReactContext.js
├── ReactCreateRef.js
├── ReactCurrentBatchConfig.js
├── ReactCurrentDispatcher.js
├── ReactCurrentOwner.js
├── ReactDebugCurrentFrame.js
├── ReactElement.js
├── ReactElementValidator.js
├── ReactForwardRef.js
├── ReactHooks.js # hooks的实现
├── ReactLazy.js
├── ReactMemo.js
├── ReactMutableSource.js
├── ReactNoopUpdateQueue.js
├── ReactSharedInternals.js
├── ReactStartTransition.js
├── __tests__
├── forks
└── jsx
```

## ReactChildren

提供React.Children的一些方法

## ReactBaseClasses
提供Component和PureComponent

依赖
### ReactNoopUpdateQueue

## ReactHooks
用户的api, useState, useEffect,等等.所有这些方法都是定义在ReactCurrentDispatcher.

### ReactCurrentDispatcher

#### react-reconciler/src/ReactInternalTypes
  Dispatcher 定义了一堆hooks的方法