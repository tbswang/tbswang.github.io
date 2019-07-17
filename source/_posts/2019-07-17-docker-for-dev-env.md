---
title: 使用docker构建统一的开发环境
date: 2019-07-17 09:17:34
tags:
---

## abstract

把要使用的软件通过dockerfile打包成一个镜像，托管到自己的registry中，这样就可以在任意别地方使用了。
<!-- more -->
## 1. 步骤

- 安装docker
- 使用如下的dockerfile
```dockerfile
    FROM ubuntu:18.04
    
    RUN apt-get  update && \
        apt-get upgrade -y && \
        apt-get -y install git && \
        apt-get -y install vim && \
        apt-get -y install curl && \
        curl -sL https://deb.nodesource.com/setup_8.x | bash && \
        apt-get -y install nodejs && \
        npm install -g nrm
    CMD git --version && bash --version && ssh -V && npm -v && node -v
```
- 运行构建命令。
```dockerfile
    docker build -t tbswang-dev-env:0.0.1 . # t表示镜像名称，版本号 .是指当前路径中的dockerfile
```
## 2. docker中常用命令

- 拉取一个docker命令
```dockerfile
    docker pull 镜像名字
```
- 新建一个docker
```dockerfile
    docker run -d -it --name my-ubuntu -v $(pwd):/root ubuntu /bin/bash # v后面是挂在路径，前面是主机路径，后面是docker容器内的路径
```
## 3. 目前存在的问题

1. 打包出的镜像将近300m。比较大
2. run的时候执行

## 参考资料

1. dockerfile参考[https://www.cnblogs.com/ityouknow/p/8595384.html](https://www.cnblogs.com/ityouknow/p/8595384.html)
2. dockerfile参考 [https://segmentfault.com/a/1190000007875949](https://segmentfault.com/a/1190000007875949)
3. 找不到npm的问题： [https://askubuntu.com/questions/720784/how-to-install-latest-node-inside-a-docker-container](https://askubuntu.com/questions/720784/how-to-install-latest-node-inside-a-docker-container)
4. docker build命令解析：[https://zhuanlan.zhihu.com/p/38144369](https://zhuanlan.zhihu.com/p/38144369)
5. 前端环境构建： [https://juejin.im/post/5b127087e51d450686184183](https://juejin.im/post/5b127087e51d450686184183)