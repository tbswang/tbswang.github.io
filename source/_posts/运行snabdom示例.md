---
layout: post
title: 运行snabbdom的示例
date: 2019-04-02
modified: 
categories: 
- 前端

tags:
- snabbdom
---

## 1. Abstract
本文介绍如何运行snabbdom的示例。
<!-- more -->
## 2. Introduction
vue的Virtual DOM是基于snabbdom。所以，要了解vue，先了解snabbdom也有必要。

## 3. 环境配置
这一部分其实是本文的重点。因为snabbdom的开发年代相距想在（2019.04）比较久远。而且snabbdom是用typescript开发的，比JavaScript的上手难度要大一点。
### 3.1 配置babel
babel是一个代码转换工具，不同的版本各有差异。如果直接使用现在的版本，编译之前的代码，会有莫名其妙的错误，所以考虑使用使用sanbbdom时代的babel
```
npm install --save-dev babel-preset-es2015
echo '{ "presets": ["es2015"] }' > .babelrc //这俩不用纠结，直接安装
npm install --save-dev babelify // 我当前的（2019-03-05）是babel10. 不能用
npm uninstall babelify //卸载
npm install babelify@8 // 按照提示
npm install babel-core // 按照提示
```
## 4. 编译代码
研究一下package.json中的命令
```
"compile": "npm run compile-es && npm run compile-commonjs",
"compile-es": "tsc --outDir es --module es6 --moduleResolution node", // es6的模块语法
"compile-commonjs": "tsc --outDir ./commonjs",  // 用于在浏览器中require引用
"prepublish": "npm run compile",
```
为了配合example中的require，使用`npm run compile-commonjs`。编译完之后，代码结构如下:
```
.
├── commonjs //刚刚生成的文件
├── dist 
├── es // 执行 npm run compile-es生成的文件
├── examples
├── package-lock.json
├── package.json
├── src
```
## 5. 示例使用
### 5.1 新的示例
以下是对示例代码稍作修改生成的示例：
```js
var snabbdom = require('../../commonjs/snabbdom.js');
var patch = snabbdom.init([
  require('../../commonjs/modules/class').default, // makes it easy to toggle classes
  require('../../commonjs/modules/props').default, // for setting properties on DOM elements
]);
var h = require('../../commonjs/h').default; // helper function for creating vnodes

window.addEventListener("DOMContentLoaded", function () {
  var container = document.getElementById('container');

  var vnode = h('div#container.two.classes',  [
    h('span', 'This is bold '),
    ' and this is just normal text',
    h('a',  "I'll take you places!")
  ]);
  // Patch into empty DOM element – this modifies the DOM as a side effect
  patch(container, vnode);
})
```
### 5.2 示例编译
利用babel将require的库文件编译为一个文件使用。找到一个这样的[关于如何编译的github的issue][1]
```bash
§ ./node_modules/.bin/browserify examples/carousel-svg/script.js -t babelify -o examples/carousel-svg/build.js //我的browserify没有全局安装
```
之后在HTML文件中直接引入编译好的build.js文件就可以啦。

## 6. summary
主要记录了在学习snabbdom源码中遇到的babel版本及代码编译的问题。

## 7. 参考
1. [关于如何编译的github的issue][1]

[1]: https://github.com/snabbdom/snabbdom/issues/263