---
title: send-file-to-kindle-without-USB
date: 2023-03-12 01:34:35
tags:
---

# 不使用USB向kindle发送书

神奇的原理：kindle内置了一个浏览器，可以浏览和下载文件，利用这个，可向kindle发送文件，比如电子书。

## 步骤
### Step1 启动一个http server
> 需要先安装node
```bash
npm i -g http-server
cd <path to you file directory>
http-server
```

启动完之后，会显示内网ip
```bash
Available on:
  http://127.0.0.1:8080
  http://192.168.31.204:8080 // 重要
Hit CTRL-C to stop the server

```
### Step2 在kindle中访问
访问上面显示的地址，根据自己网络环境会不同，以我的为例，是`http://192.168.31.204:8080`

### Step3 点击文件名，下载即可。

「done」