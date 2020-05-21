---
title: 深入了解package.json
tags:
  - npm
  - 翻译
date: 2020-05-21 15:10:06
---

原文: https://docs.npmjs.com/files/package.json

描述
package.json文件是一个json文件,不是一个js对象字面量.

> 下面是各个字段的介绍

<!-- more -->

## name

如果想要发布包, 最重要的就是`name`和`version`字段,他们是必须的.`name`和`version`组合起来作为一个标识符, 必须是唯一的.改变包的内容需要改变包的版本号.如果不打算发布,那么名字和版本字段就是可选的.

### 一些规则:
* 名字必须少于或等于214个字符.包括了scoped package的scope. 例如@jd/xxx.
* 名字开头不能是点或者下划线
* 不能包含大写
* 名字可能会作为url的一部分,一个命令行的参数,或者以文件夹名字.所以名字不能包含非URL安全的字符.

### 一些建议:
* 不要与node的核心模块的名字重复
* 不要加入node 或者 js. 因为写了package.json, 就已经认定是js. 另外可以使用`engine`字段指定执行的引擎
* 名字可以作为`require()`函数的参数,所以应该短一些,但要有合理的描述性
* 在用名字之前,最好先在`https://www.npmjs.com/`先检查一下

## version

Version必须可以被 [node-semver](https://github.com/isaacs/node-semver)解析.

## decription 描述
一段描述性的字符串.可以帮助人们发现你的包,可以在`npm search`中展示

## keywords 关键词
一个字符串列表.也可以在`npm search`中展示

## homepage 主页
项目的主页.例如`"homepage": "https://github.com/owner/project#readme"`

## bugs
项目中的issue的跟踪器(比如GitHub issue, jira, gitlab issue)或者一个email 地址, 可以用来报告issue.这对遇到问题的人很有帮助.
他看起来是这样的:
```json
{ 
  "url" : "https://github.com/owner/project/issues",
  "email" : "project@hostname.com"
}
```
可以指定一个或多个值.如果只提供一个url,那么可以把bugs的值设置为一个字符串.

如果设置了url,可以被`npm bugs`命令用到

## license 证书
应该制定一个证书, 这样人们可以知道他们允许如何使用. 你可以把你的任何限制放到这里.

可以使用一个公开的证书比如MIT,比如
```json
{ "license" : "BSD-3-Clause" }
```
如果不想给其他人使用私有的或者未发布的包,可以使用:
```json
{ "license": "UNLICENSED" }
```
也可以设置`"private": true`来避免意外发布.

## 与人相关的字段: author, contributors
作者是一个人,贡献者是人名列表.其中,一个`person`是一个对象,包含`name`字段.`url`和`email`字段是非必填.比如:
```json
{ "name" : "Barney Rubble"
, "email" : "b@rubble.com"
, "url" : "http://barnyrubble.tumblr.com/"
}
```
也可以把这个简化为一个字符串,npm会自动解析
```
"Barney Rubble <b@rubble.com> (http://barnyrubble.tumblr.com/)"
```

## files
文件字段是一个文件通配符的列表,当包作为一个依赖,可以描述包的入口文件. 文件通配符与 `.gitignore` 遵循类似的语法,但是有所保留: 当打包的时候可以包含一个文件,文件夹或者一个通配符文件.忽略这个字段将会默认为`[*]`, 意思是包含所有的文件.

有些特殊的文件和文件夹会包含或者剔除,无论他们是否存在于`file`字段.

也可以提供`.npmingore`文件在包的根目录,可以防止文件被包含进去.在包的根目录下,他不会覆盖`files`字段,但是在子目录中可以.`.npmignore`文件类似于`.gitignore`

无论设置如何, 以下的文件始终被包含:
* package.json
* README
* CHANGES / CHANGELOG / HISTORY
* LICENSE / LICENCE
* NOTICE
* 在'main'字段中的文件

相对的,以下的文件始终被忽略
* .git
* CVS
* .svn
* .hg
* .lock-wscript
* .wafpickle-N
* .*.swp
* .DS_Store
* ._*
* npm-debug.log
* .npmrc
* node_modules
* config.gypi
* *.orig
* package-lock.json (use shrinkwrap instead)

## main
main字段是程序的主入口.如果一个包名字为`foo`,一个用户安装了他,然后`require('foo')`,那么将返回主模块输出对象

他应该是一个相对包文件夹的相对id

对大部分的模块,他最大的意义就是一个入口

## browser
如果模块只在浏览器端使用,那么应该设置`browser`字段而不是`main`字段.这可以提示用户, 这个包用到一些nodejs没有的特性

## bin
很多包有一个或多个可执行文件,他们想要安装在`PATH`中,npm让这个非常简单,

为了使用这个, 提供一个`bin`字段,映射命令的名字和本地文件的名字.当安装的时候, npm会链接文件到`prefix/bin`全局安装, 或者到`./node_modules/.bin`中作为本地使用.

例如:
```json
{ "bin" : { "myapp" : "./cli.js" } }
```

如果只有一个可执行文件,他的名字就是包的名字, 那么可以只提供一个字符串.

还要确认`bin`字段指定的文件是`#!/usr/bin/env node`, 否则脚本就不能使用node的执行环境

## man
给`man`程序指定一个或多个文件.

## directories
commonjs规范指明了使用 `directories`对象来判断包的结构. 如果你看着package.json我,你就会看到他有文档,类库,和说明文档的目录.

在将来,这个信息还可以在一些其他的创造性的方式.

## repository
指定在线代码的位置.这对想贡献代码的人很有帮助.如果git仓库是github,那么`npm docs`命令可以帮你找到.

```json
"repository": {
  "type" : "git",
  "url" : "https://github.com/npm/cli.git"
}

"repository": {
  "type" : "svn",
  "url" : "https://v8.googlecode.com/svn/trunk/"
}
```
如果包不在根目录, 也可以指定在线代码的目录,比如这样:
```json
"repository": {
  "type" : "git",
  "url" : "https://github.com/facebook/react.git",
  "directory": "packages/react-dom"
}
```

## scripts

这个属性指定在包的不同生命周期运行的脚本命令.key是命周期的事件,值是具体的命令.

## config
配置对象是在脚本中一直使用的配置参数.比如
```json
{ "name" : "foo"
, "config" : { "port" : "8080" } }
```
如果之后`start`命令引用了`npm_package_config_port`环境变量,那么用户可以通过`npm config set foo:port 8001`覆盖.例如
```json
// package.json
{
  "name": "npm-start",
  "scripts": {
    "start2":"npm config set 'npm-start':port 8001 && node index.js",
  },
  "config": {
    "port": "8080"
  },
```
```js
// index.js
console.log(process.env.npm_package_config_port);
```

## dependencies

依赖是一个简单的对象, 映射包的名字和版本范围.版本范围是一个字符串,有一个或多个用空格分开的描述符.依赖也可以是一个压缩文件或者一个git url.

不要把测试和中间文件放到依赖中, 可以放到 `devDependencies`中.

`semver`中指定了版本的范围.

```
* version 精确匹配
* >version 大于当前版本
* >=version 大于等于当前版本
* <version
* <=version
* ~version “Approximately equivalent to version” See semver
* ^version “Compatible with version” See semver
* 1.2.x 1.2.0, 1.2.1, etc., but not 1.3.0
* http://... See ‘URLs as Dependencies’ below
* * 任何版本
* "" 空白字符串, 与*相同
* version1 - version2 大于等于版本1, 小于等于版本2
* range1 || range2 
* git... 
* user/repo
* tag 带有标签的版本
* path/path/path 本地路径
```

### url 作为依赖
可以指定一个压缩文件放到版本范围中.
压缩文件可以下载并且本地安装

### git url 作为依赖
git url 如下形式
```
<protocol>://[<user>[:<password>]@]<hostname>[:<port>][:][/]<path>[#<commit-ish> | #semver:<semver>]
```

`<protocol>`是git, git+ssh, git+http, git+https, or git+file中的一个.

如果有`#<commit-ish>`,就可以精确克隆这个提交.

### github url
可以使用`“foo”: “user/foo-project”`来指定github 链接

###  本地路径
如下形式
```
../foo/bar
~/foo/bar
./foo/bar
/foo/bar
```

如果是相对路径,
```json
{
  "name": "baz",
  "dependencies": {
    "bar": "file:../foo/bar"
  }
}
```
这个特性可以帮助本地的离线开发者测试一些不想从外部服务器安装的包.但是在发布的公共库就不能这样使用了.

## devDependencies 开发依赖

如果有人计划在他们的程序中使用你的模块,那么他们可能不想或者不需要使用你的库中用到测试框架.

这时候, 最好把这些额外的配置放到`devDependencies`中. 

这些东西在`npm link`和`npm install`的时候会安装, 可以想其他 npm 配置一样被管理.

如果不指定平台,构建,比如说把 coffeescritp 或者其他语言编译成 js,可以使用 `prepare`脚本完成这个.

比如说:
```json
{ "name": "ethopia-waza",
  "description": "a delightfully fruity coffee varietal",
  "version": "1.2.3",
  "devDependencies": {
    "coffee-script": "~1.6.3"
  },
  "scripts": {
    "prepare": "coffee -o lib/ -c src/waza.coffee"
  },
  "main": "lib/waza.js"
}
```
`prepare`脚本会在发布之前运行, 用户可以自动使用这个功能. 开发模式中,也会运行这个脚本,你可以很容易测试.(TODO:)

## [peerDependencies](https://www.cnblogs.com/wonyun/p/9692476.html)

有些情况, 可能想要表达对宿主环境的兼容性. 你的模块可能暴露一个特定的接口,指定宿主环境的文档.例如
```json
{
  "name": "tea-latte",
  "version": "1.3.5",
  "peerDependencies": {
    "tea": "2.x"
  }
}

```
这确保了你的包可以单独作为一个宿主环境的包安装.安装了`tea-latte`之后,可能会有这样的依赖图.
```
├── tea-latte@1.3.5
└── tea@2.2.0
```

注意:在 npm1 和 npm2 会自动安装`peerDenpendenices`.在 npm3 之后,就不是这样的.使用的时候,可能会收到一个警告,`peerDenpendencies`没有安装.在 npm1 和 
npm2 中的这种行为,可能会导致模块地狱.

当有依赖冲突的时候, 会报错.

## bundledDependencies

这里指定了一些包,如果发布, 就打包他们.

当你需要在本地保留包或者想要通过文件下载, 可以设置 peerDependencies 然后执行 npm pack

```json
{
  "name": "awesome-web-framework",
  "version": "1.0.0",
  "bundledDependencies": [
    "renderized", "super-streams"
  ]
}
```
可以运行`npm pack`获得一个`awesome-web-framework-1.0.0.tgz`的文件.这个文件包含了`renderized and super-streams`这两个依赖.这里的包名不包含版本,相关的信息在 dependencies 中指定.

## optionalDependencies

当使用一个包的时候, 当无法找到或者安装失败, 你想要 npm 处理他,那么你需要把它放到`optionalDependencies`中.

## engines
你可以指定使用的 node 版本.

与Dependencies类似, 如果不指定版本,那么所有的 node 版本都可以.

如果指定了 engine 字段,那么 npm 会在某些地方要求 node 版本.如果 engine 忽略了,npm 会默认是 node.

也可以指定哪个版本的 node 是可以的.比如:
```json
{ "engines" : { "npm" : "~1.0.20" } }
```

## engineStrict
从 npm3.0.0 就被移除啦.

## os
可能指定运行的操作系统.比如:
```json
"os" : [ "darwin", "linux" ]
```

或者指定运行系统的黑名单.

主机的操作系统通过`process.platform`决定.

## cpu
如果你的代码只能在特定架构中运行,你可以指定

## preferGlobal
废弃

## private
如果设置私人为 true,那么 npm 就不会发布他.

这是一个阻止意外发布的方式.如果只想在特定的 registry 发布,那么就用`publishConfig`

## publishConfig

这是一组在发布时使用的配置.

## 默认值

* `"scripts": {"start": "node server.js"}`
  如果在根目录中有一个 server.js, 那么会默认创建一个启动命令.

* `"scripts":{"install": "node-gyp rebuild"}`
  如果有一个`binding.gyp`, 而且也没有定义`install`和`preinstall`脚本.

* `"contributors": [...]`
  如果有`AUTHOR`文件