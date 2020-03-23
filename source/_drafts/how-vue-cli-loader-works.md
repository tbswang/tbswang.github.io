---
title: how-vue-cli-loader-works
tags: vue

date: 2020-01-13
categories: 
- vue
---

# abstract
vue-cli通过 ** 工具实现了对webpack的二次封装。本文主要记录了在配置loader中遇到的问题。首先阅读官方文档，然后是网上有没有类似的配置。如果两者都没有，可以自己尝试， 通过`vue inspect`命令查看实际生成的webpack配置文件。

# introduction
一开始遇到的问题是在想使用svg sprit进行svg icon管理