---
title: git-credentials中文文档
tags:
  - 翻译
  - git
date: 2019-10-10 15:40:20
---

- 原文：https://git-scm.com/docs/gitcredentials

## 名字
gitcredentials - 向git提供用户名和密码

## 概览
```bash
git config credential.https://example.com.username myusername
git config credential.helper "$helper $options"
```
<!-- more -->
## 描述
有时候git需要一些用户信息来完成一些操作，这些用户信息叫做凭证。比如说，可能需要用户名和密码来通过http来访问远程仓库。这份手册描述了git的获取用户凭证的机制，依赖这个机制也可以避免重复输入。

## 获取凭证
当没有凭证的时候，git将会按照一下的策略向用户询问用户名和密码。
1. 如果设置了`GIT_ASKPASS`环境变量，就会调用变量指定的程序。在命令行中会适时的提示，并且从标准输出设备中读取输入。
2. 如果配置了`core.askPass`，就按照上面的方式使用该变量。
3. 如果配置了`SSH_ASKPASS`环境变量，按照上面的方式使用该变量。
4. 在终端命令行中提示用户。

## 避免重复
对于需要一次一次的重复输入相同的用户信息的情况。git提供了两种方法来避免这种烦恼。
1. 在当前对用户权限验证环境中，对用户名进行静态配置。
2. 使用凭证助手缓存或者存储密码，或者与系统密码和密码链交互。

第一种很简单，适用于不能安全存储密码的情况。这会在配置文件中增加如下的配置：
```
[credential "https://example.com"]
	username = me
```
另一种方式，凭证助手是一个额外的程序，git可以从中获取用户名和密码。这通常依赖系统或者其他程序提供的安全存储。

为了使用凭证助手，首先要选择一个使用。git当前包含了一下的凭证助手：

**cache**

在内存中缓存凭证供短期使用。查看[`git-credential-cache`](https://git-scm.com/docs/git-credential-cache)获取更多细节。

**store**

在硬盘中长期存储凭证。查看[`git-credential-store`](https://git-scm.com/docs/git-credential-store)获取更多细节。

有可能你已经装了第三方的助手，在`git help -a`中搜索`credential-*`，然后查阅每个助手的文档。一旦你选择了一个助手，你可以把他的名字放在`credential.helper`变量，告诉git来使用它。
1. 查找助手
```
$ git help -a | grep credential-
credential-foo
```
2. 阅读他的描述
```
$ git help credential-foo
```

3. 告诉git使用他
```
$ git config --global credential.helper foo
```

## 用户鉴权的上下文环境
git在url定义的用户权限验证上下文中使用。这个上下文用来查看与上下文相关的配置，并且传递给所有助手，可以用作安全存储的索引。

比如，我们访问了`https://example.com/foo.git`，当git查找配置文件确定这一部分是否匹配上下文的时候，如果上下文是配置文件更加详细的子集，他会认定两者匹配。例如，如果有这样的配置文件：
```
[credential "https://example.com"]
	username = foo
```

然后我们可以匹配到：两个协议相同，域名相同，url模式根本不关心路径模块。然而，这个上下文不会匹配：
```
[credential "https://kernel.org"]
	username = foo
```

因为域名不同。也不会匹配foo.example.com；git会精确比较域名，而考虑是否两个域名是相同的域。同样的，一个http://exmple.com也不会匹配，git会精确比较协议。

如果模式url不包含路径组件，那么也必须精确比较:`https://example.com/bar/baz.git`的上下文会匹配`https://example.com/bar/baz.git`,但是不会匹配`https://example.com/bar`。

## 配置选项
凭证上下文的选项既可以在`credential.\*`，也可以在`credential.<url>.*`中配置。url符合上面提到的上下文。

以下的选择在两种都可以使用：

helper

凭证助手的名字，或者相关的选项。如果助手名字不是绝对路径，那么会在前面注入git credential- 的字符串。这个字符串会在shell中执行。比如设置为`foo --option=bar`实际会在shell中执行`git credential-foo --option=bar`.查看制定助手的手册来查看例子。

如果有多个`credential-helper`的配置变量的实例，那么 `git`会按照顺序依次尝试，可能需要用户名密码，或者什么都不用。一旦`git`获取了用户名和密码，就不会尝试其他都凭证助手。

如果配置了`credential.helper`为空字符串，这会把凭证助手重置为空。

用户名
  如果url中没有提供，就会作为默认的用户名

**useHttpPath**

默认情况，git不会考虑使用凭证助手匹配url的path。这意味着对`https://example.com/foo.git`凭证，也可以用于`https://example.com/bar.git`。如果想要区别这些情况，就把这个选项设置为true。

## 自定义凭证助手
你也可以实现自定义的凭证助手，来配合使用凭证的系统。阅读文档获得更多细节。

## git
git的一部分。