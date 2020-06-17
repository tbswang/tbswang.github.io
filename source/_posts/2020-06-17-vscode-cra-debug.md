---
title: vscode-cra-debug
date: 2020-06-17 10:18:20
tags:
---

## 摘要

## INTRODUCTION
cra(create-react-app)是react官方出品的初始化react的工具.他本质是一个封装了一个webpack.而webpack是依赖node运行的.所以对cra调试, 就是对nodejs调试.

## 配置
首先选择debugg, 生成一个新的launch.json文件.

### cra官方

链接: https://create-react-app.dev/docs/debugging-tests/

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug CRA Tests",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "${workspaceRoot}/node_modules/.bin/react-scripts",
      "args": ["test", "--runInBand", "--no-cache", "--watchAll=false"],
      "cwd": "${workspaceRoot}",
      "protocol": "inspector",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "env": { "CI": "true" },
      "disableOptimisticBPs": true
    }
  ]
}
```

### create-react-app-rewired

```json
{
  "type": "node",
  "request": "launch",
  "name": "Launch Program",
  "runtimeExecutable": "${workspaceFolder}/node_modules/react-app-rewired/bin/index.js",
  "args": ["start"],
},
```

### 通过npm命令 
TODO:暂未成功
```json
{
  "name": "Launch via npm",
  "type": "node",
  "request": "launch",
  "cwd": "${workspaceFolder}",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run-script", "start"],
},
```

## 使用

以react-app-rewired为例, 在`override-config.js`中打断点就可以.