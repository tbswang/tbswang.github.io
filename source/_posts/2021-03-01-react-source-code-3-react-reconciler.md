---
title: react-source-code-3-react-reconciler
date: 2021-03-01 16:04:45
tags:
---

# 代码结构
```bash
./packages/react-reconciler/src
├── DebugTracing.js
├── MaxInts.js
├── ReactCapturedValue.js
├── ReactChildFiber.new.js
├── ReactChildFiber.old.js
├── ReactCurrentFiber.js
├── ReactFiber.new.js
├── ReactFiber.old.js
├── ReactFiberBeginWork.new.js
├── ReactFiberBeginWork.old.js
├── ReactFiberCacheComponent.new.js
├── ReactFiberCacheComponent.old.js
├── ReactFiberClassComponent.new.js
├── ReactFiberClassComponent.old.js
├── ReactFiberCommitWork.new.js
├── ReactFiberCommitWork.old.js
├── ReactFiberCompleteWork.new.js
├── ReactFiberCompleteWork.old.js
├── ReactFiberComponentStack.js
├── ReactFiberContext.new.js
├── ReactFiberContext.old.js
├── ReactFiberDevToolsHook.new.js
├── ReactFiberDevToolsHook.old.js
├── ReactFiberErrorDialog.js
├── ReactFiberErrorLogger.js
├── ReactFiberFlags.js
├── ReactFiberHooks.new.js # 
├── ReactFiberHooks.old.js
├── ReactFiberHostConfig.js
├── ReactFiberHostConfigWithNoHydration.js
├── ReactFiberHostConfigWithNoMicrotasks.js
├── ReactFiberHostConfigWithNoMutation.js
├── ReactFiberHostConfigWithNoPersistence.js
├── ReactFiberHostConfigWithNoScopes.js
├── ReactFiberHostConfigWithNoTestSelectors.js
├── ReactFiberHostContext.new.js
├── ReactFiberHostContext.old.js
├── ReactFiberHotReloading.js
├── ReactFiberHotReloading.new.js
├── ReactFiberHotReloading.old.js
├── ReactFiberHydrationContext.new.js
├── ReactFiberHydrationContext.old.js
├── ReactFiberInterleavedUpdates.new.js
├── ReactFiberInterleavedUpdates.old.js
├── ReactFiberLane.new.js
├── ReactFiberLane.old.js
├── ReactFiberLazyComponent.new.js
├── ReactFiberLazyComponent.old.js
├── ReactFiberNewContext.new.js
├── ReactFiberNewContext.old.js
├── ReactFiberOffscreenComponent.js
├── ReactFiberReconciler.js
├── ReactFiberReconciler.new.js
├── ReactFiberReconciler.old.js
├── ReactFiberRoot.new.js
├── ReactFiberRoot.old.js
├── ReactFiberScope.new.js
├── ReactFiberScope.old.js
├── ReactFiberStack.new.js
├── ReactFiberStack.old.js
├── ReactFiberSuspenseComponent.new.js
├── ReactFiberSuspenseComponent.old.js
├── ReactFiberSuspenseContext.new.js
├── ReactFiberSuspenseContext.old.js
├── ReactFiberThrow.new.js
├── ReactFiberThrow.old.js
├── ReactFiberTransition.js
├── ReactFiberTreeReflection.js
├── ReactFiberUnwindWork.new.js
├── ReactFiberUnwindWork.old.js
├── ReactFiberWorkLoop.new.js
├── ReactFiberWorkLoop.old.js
├── ReactHookEffectTags.js
├── ReactInternalTypes.js
├── ReactMutableSource.new.js
├── ReactMutableSource.old.js
├── ReactPortal.js
├── ReactProfilerTimer.new.js
├── ReactProfilerTimer.old.js
├── ReactRootTags.js
├── ReactStrictModeWarnings.new.js
├── ReactStrictModeWarnings.old.js
├── ReactTestSelectors.js
├── ReactTypeOfMode.js
├── ReactUpdateQueue.new.js
├── ReactUpdateQueue.old.js
├── ReactWorkTags.js
├── SchedulerWithReactIntegration.new.js
├── SchedulerWithReactIntegration.old.js
├── SchedulingProfiler.js
├── __tests__
└── forks
```

## 这么多 new 和 old 是干什么用的

## ReactFiberHooks.new

这里定义了具体的hooks的逻辑

line: 2186: hooks会在三个阶段调用, mount, update, rerender

> 为啥没有unMount阶段呢

以mount中的useState为例, 调用了mountState(initialState), 

