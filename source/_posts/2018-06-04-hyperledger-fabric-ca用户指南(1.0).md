---
layout: post
title: hyperledger-fabric-ca用户指南(1.0)
date: 2018-06-05
modified: 2018-08-03
categories: 
- hyperledger
- fabric

tags:
- 翻译
---
# fabric ca 的用户指南(1.0版)

## 摘要：
这篇文章是翻译自[hyperledger farbric ca](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.0/)的文档。记录了自己实践文档内容过程中，遇到一些问题以及解决办法。相关的内容在`注释`中

hyperledger fabric ca是一个对hyperledger fabric进行用户授权的组件.

他提供了以下的特性:
* 身份注册,或者连接到ldap作为用户注册中心.
* 颁发登录证书(ECerts)
* 颁发交易证书(Tcerts), 当在Hyperledger fabric 区块链中交易的时候, 提供匿名和不可连接的连接.
* 证书更新和撤回

Hyperledger fabric ca 包含服务端和一个客户端, 下文将会描述.

对于贡献Hyperledger fabric ca 的开发者, 可以查看 [fabric ca 仓库](https://github.com/hyperledger/fabric-ca)来查询更多信息.
<!-- more -->

# 概览
下图展示了如何把hyperledger fabric ca 服务器放在hyperledger fabric 的整体架构中.

![img](./fabric-ca-arch.png) 

 有两个方式与fabric ca服务器端交互:通过fabric ca的客户端或者sdk.所有的与服务端的交互都是通过rest api.可以查看[fabric-ca/swagger/swagger-fabric-ca.json](https://github.com/hyperledger/fabric-ca/blob/release-1.1/swagger/swagger-fabric-ca.json) 这份文档来查看文档化的REST API.

 客户端或者sdk可以连接一个ca服务器端的集群的某一台服务器.上图右上边说明的是这个部分. 客户端使用haproxy代理做负载均衡,连接到fabric ca server的集群中的一个.

 所有的ca服务端共用一个数据库, 来跟踪身份和证书.如果配置了LDAP,用户身份验证信息就会存放在ldap中, 而不是数据库.

 每个服务器可能包含多个ca.每个ca要么是根ca,要么是中间ca.每个中间ca的父节点要么是根ca,要么是一个中间ca.

# 开始

## 预安装

* go.x 安装
* 正确设置环境变量 `GOPATH`
* 安装libtool 和libtdhl-dev 安装包

> 注释:
* 如何设置gopath:https://segmentfault.com/a/1190000003933557
* 一般来说, GOPATH的路径是/users/{用户名}/go.里面存储了golang的依赖包和一些可执行命令.依赖包的路径是$GOPATH/src,使用go get命令下载的包, 也是默认存在这里.可执行命令的包一般是在$GOPATH/bin.mac推荐使用homebrew安装

以下的命令是在ubuntu 上安装libtool的依赖包

```
sudo apt install libtool libltdl-dev
```

以下的命令是在macox安装libtool依赖:

```
brew install libtool
```

> 说明:
对于mac,如果使用homebrew安装了libtool, 就不需要再安装libtdl-dev

关于libtool的信息, 可以查看: https://www.gnu.org/software/libtool.

关于libltdl-dev的信息, 可以查看:
https://www.gnu.org/software/libtool/manual/html_node/Using-libltdl.html


## 安装

下面的命令会在会在$GOPATH/bin中安装fabric-ca-server和fabric-ca-client的二进制文件.
```
go get -u github.com/hyperledger/fabric-ca/cmd/...
```

>注释:
`go get -u`是u的意思是升级, 如果包已经在本地, 就不下载,如果没有才下载



>说明: 如果你clone了fabric-ca 的仓库,在运行go get 命令之前 确保你在master 分支,否则你可能会看到这样的错误: 
```bash
<gopath>/src/github.com/hyperledger/fabric-ca; git pull --ff-only
There is no tracking information for the current branch.
Please specify which branch you want to merge with.
See git-pull(1) for details.

    git pull <remote> <branch>

If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=<remote>/<branch> tlsdoc

package github.com/hyperledger/fabric-ca/cmd/fabric-ca-client: exit status 1
```

## 启动原生的服务器
这个命令使用默认配置,其中fabric-ca-server
```bash
fabric-ca-server start -b admin:adminpw
```
-b选项 是提供引导管理员用户(fabric中默认存在第一个用户)的登录id和密码.如果在关于ldap的配置中没有使用ldap.enabled设置, 这个选项就是必须的.

>  注释: ldap的作用是接管fabric-ca中用户注册的功能, 所有的fabric-ca的用户都是在ldap中,所以不需要提供引导用户.

以上操作会创建一份叫做fabric-ca-server-config.yml的文件, 我们可以对这份文件进行定义.

>  注释: 创建的fabric-ca的配置文件一般会在/etc/hyperledger/fabric-ca-server

## 使用docker
### docker hub
在 https://hub.docker.com/r/hyperledger/fabric-ca/tags/ 这个网页找到合适的架构和版本的镜像

在$GOPATH/src/github.com/hyperledger/fabric-ca/docker/server 打开docker-compose.yml文件.

把这个配置里面的image选项换成之前相应的标记.下面的文件是给x86架构的beta版本

```yml
fabric-ca-server:
  image: hyperledger/fabric-ca:x86_64-1.0.0-beta
  container_name: fabric-ca-server
  ports:
    - "7054:7054"
  environment:
    - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
  volumes:
    - "./fabric-ca-server:/etc/hyperledger/fabric-ca-server"
  command: sh -c 'fabric-ca-server start -b admin:adminpw'
```

打开docker-compose.yml文件路径所在一个终端.执行下面的命令:
```
docker-compose up -d
```

> 注释: docker-compose的命令常用的有两个, 一个是`docker-compose up`, 用户启动docker多容器, 另一个是`docker-composer down`, 用于关闭docker多容器

如果指定的fabric-ca镜像不存在, 这会从docker拉取(pull)镜像, 然后开启一个fabric-ca 的服务器的实例.

### 生成自己的docker镜像
你可以使用下面的命令, 通过docker-compose 来启动服务器.
```bash
cd $GOPATH/src/github.com/hyperledger/fabric-ca
make docker
cd docker/server
docker-compose up -d
```

hyperledger/fabric-ca的docker镜像包含了fabric-ca-server和fabric-ca-client
```
# cd $GOPATH/src/github.com/hyperledger/fabric-ca
# FABRIC_CA_DYNAMIC_LINK=true make docker
# cd docker/server
# docker-compose up -d
```


## 浏览cli命令
这一部分只是简单说明fabric ca 服务端和客户端的使用信息.另外的使用信息在接下来的部分中.

> 注释:
这部分内容请参考源文档:https://hyperledger-fabric-ca.readthedocs.io/en/release-1.0/users-guide.html#explore-the-fabric-ca-cli

>  说明: 使用字符串分割的命令行选项可以使用逗号分隔符来指定多个命令, 或者多次指定这个选项,每个字符串值来组成一个列表.比如, 为了给csr.host指定host1和host2,你可以传递参数 --csr.host 'host1,host2' 或者 -csr.host host1 --csr.host host2. 当使用第一种的时候, 确保在逗号的前面和后面都没有空格.

# 文件格式
## fabric ca服务器端的配置文件的格式
在fabric-ca启动的时候,会在服务端的主目录创建一份默认配置文件.

> 注释: 这部分内容查看原文件https://hyperledger-fabric-ca.readthedocs.io/en/release-1.0/users-guide.html#fabric-ca-server-s-configuration-file-format

## ca 客户端的配置文件的格式
在client端的主目录会创建一份默认的配置文件

> 注释: 这部分内容查看原文件https://hyperledger-fabric-ca.readthedocs.io/en/release-1.0/users-guide.html#fabric-ca-server-s-configuration-file-format


# 配置文件生效的优先级
fabric ca提供三种方式来设置fabric ca 服务端和客户端.优先级如下:
1. 命令行里面的参数设置
1. 环境变量
1. 配置文件

在这个文档后面部分中, 我们修改配置文件.但是,配置文件可能被环境变量和命令行参数覆盖.

比如说, 你有如下的客户端配置文件:

```
tls:
  # Enable TLS (default: false)
  enabled: false

  # TLS for the client's listenting port (default: false)
  certfiles:
  client:
    certfile: cert.pem
    keyfile:
```
下面的环境变量可能会覆盖配置文件中的 cert.pem.

```bash
export FABRIC_CA_CLIENT_TLS_CLIENT_CERTFILE=cert2.pem
```

如果你想覆盖环境变量和配置文件, 你可以使用命令行参数.

```bash
fabric-ca-client enroll --tls.client.certfile cert3.pem
```

同样的方式也适用于fabric-ca-server,除了把环境变量前缀从`FABRIC_CA_CLIENT`改成`FARBIC_CA_SERVER`.

# 关于文件路径的说明
所有在fabric ca 服务端和客户端的配置文件中关于文件名字的属性,都可以支持相对路径和绝对路径.相对路径是相对于配置文件所在的配置目录.例如, 如果配置文件是在 `~/config`中,, tls的设置下面所示,那么fabric ca 服务端和客户端会在`~/config`目录中查找root.pem, 在`~/config/certs` 这个目录中查找cert.pem, 使用绝对路径在`/abs/path`中查找key.pem

```yml
tls:
  enabled: true
  certfiles:
    - root.pem
  client:
    certfile: certs/cert.pem
    keyfile: /abs/path/key.pem
```

# fabric ca 服务器端
可以在启动fabric ca 服务器之前初始化,这样就可以在启动服务器之前生成一个服务器的默认配置文件,可以查看和修改.

ca的主文录由下面决定:
* FABRIC_CA_SERVER_HOME 的环境变量
* FABRIC_CA_HOME 环境变量
* CA_CFG_PATH 的环境变量
* 当前的目录

下面假设设置的`FABRIC_CA_HOME`的环境变量的值为`$home/fabric-ca/server`.

下面的介绍中, 假设服务器端配置文件已经在服务器的主目录中存在.

## 初始化服务器端
使用如下命令初始化fabric ca 服务器:
```
fabric-ca-server init -b admin:adminpw
```

当不使用LDAP的时候, -b这个参数必须要有.为了启动一个fabric ca 服务器, 至少需要一个启动实体.-b 这个参数指定了一个启动的身份.这个用户就是server的管理者.

服务器的配置文件包含了可以配置的证书签名请求部分(csr).下面是一个csr的例子:

```
cn: fabric-ca-server
names:
   - C: US
     ST: "North Carolina"
     L:
     O: Hyperledger
     OU: Fabric
hosts:
  - host1.example.com
  - localhost
ca:
   expiry: 131400h
   pathlength: 1
```

上面所有的部分都属于在x509标准,这个在执行`fabric-ca-server init`中产生.这些会相应存在于的在server的配置文件ca.certfile和ca.keyfile中.配置文件中的字段含义如下:
* cn: 公共的名字
* O: 组织名称
* OU: 组织单位
* L:位置或者城市
* ST: 状态
* C: 国家

如果需要自定义csr,需要自定义配置文件,先删除ca.certfile和ca-keyfile,然后再次运行 fabric-ca-server init -b admin:adminpw

> 注释: 
第一次执行fabric-ca-server inti 的时候, 使用默认的配置, 生成了一个ca.certfile和ca-keyfile. 这两个文件是由csr这部分参数生成的.所以, 如果用自己的cn, ou等,就要先把csr改成自己组织的信息, 然后重新生成.生成的证书文件是在`/etc/hyperledger/fabric-ca-server-config/org1.example.com-cert.pem`这个文件.
关键信息是Issuer发证机构和Subject(证书持有者)的cn(common name)
![](server-init-cert.png)
暂时还没弄明白这个证书是用在哪里

fabric-ca-server会产生一个自签名的ca证书,除非在指定了 -u <parent-fabric-ca-server-URL>. 如果指定-u, 服务器的ca证书就会被父级fabric ca 服务器签名.为了收到来自父级的授权,指定的url必须是`<scheme>://<enrollmentID>:<secret>@<host>:<port>`这种格式.这里的enrollmentID和secret对应于一个用户, 这个用户的‘hf.IntermediateCA的属性值是true.fabric-ca-server init命令还会在server的home目录生成一个叫做fabric-ca-server.yaml的配置文件.

如果想要用自己的ca签名证书, 必须把你的文件放到相应的ca.certfile和ca.keyfile文件中.两个文件必须是PEM编码, 而且不能加密.而且, 这个ca证书文件必须又`-----BEGIN CERTIFICATE-----`开始,秘钥的内容必须`-----BEGIN PRIVATE KEY-----`开始, 而不能是 `-----BEGIN ENCRYPTED PRIVATE KEY-----`

### 算法和key的大小
csr部分可以自定义来生成x.509格式的椭圆曲线法生成的证书和秘钥(ECDSA).下面的设置是一个椭圆曲线法的实现的例子, 使用曲线 prime256v1和签名算法 ecdsa-with-SHA256:
```
key:
   algo: ecdsa
   size: 256
```

算法和秘钥的选择取决于你的安全需求.
椭圆曲线法提供了如下的秘钥大小选项:

大小 | ASN1 OID | 签名算法 
:---: | :---: |:--:
256 | prime256v1 | ecdsa-with-SHA256
384 | secp384r1 | ecdsa-with-SHA384
521 | secp521r1 | ecdsa-with-SHA512



## 开启服务器
使用如下命令开启服务器:
```bash
fabric-ca-server start -b <admin>:<adminpw>
```

如果server之前没有初始化,他会在第一次启动的时候初始化.在初始化的时候,如果ca-pert.pem和ca-key.pem文件不存在, server会产生各自生成一份.如果默认的配置文件不存在,也会生成一份.

除非使用ldap,否则至少一个预先注册的实体来注册和登录其他用户.-b 选项指定了启动实体的名字和密码.

为了监听https而不是http,需要把tls.enable设置为true.

为了限制相同密码登录的次数,registry.maxenrollments设置为合适的数字.如果设置1, 只能登录一次,如果设置-1,可以无限制登录.默认值-1.设置为0,就会禁止任何实体的登录和注册.

fabric-ca-server监听在7054端口

## 配置数据库
这一部分描述如何配置连接PostgreSQL or MySQL数据库.默认的数据库是sqlite,默认的数据库文件是fabric-server.db,在home文件夹.

如果不关心在集群中运行服务器,可以跳过这一部分.支持的数据库版本
* PostgreSQL:.5 或者之后
* MySQL:.16 或者之后

### postgresql
在server的配置文件中,增加下面的部分,可以连接到postgresql中.确认好要把下面自定义的值合适.关于db名字的有字符的限制.参考这个文件https://www.postgresql.org/docs/current/static/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS

```
db:
  type: postgres
  datasource: host=localhost port=5432 user=Username password=Password dbname=fabric_ca sslmode=verify-full
```
通过sslmode来配置ssl验证的思路.sslmode的有效值是:

|mode|描述|
|--|--|
|disable| 没有ssl
|require|总是ssl(跳过验证)
|verify-ca|总是ssl(验证当前服务器的证书由可信的ca签名)
|verify-full|与verify-ca相同,验证当前的证书由可信的ca签名,并且server的hostname与其中一个证书一致

如果你想使用tls, 必须在fabric ca server 配置文件中指定db.tls部分.如果ssl在postgresql服务器中enbaled, 那么客户端证书和秘钥文件需要在db.tls.client部分指定,下面是一个db.tls部分的例子:
```
db:
  ...
  tls:
      enabled: true
      certfiles:
        - db-server-cert.pem
      client:
            certfile: db-client-cert.pem
            keyfile: db-client-key.pem
```
certfiles: 一系列经过pem编码的可信 的根证书文件
certfile和keyfile: 由pem编码的,由fabric ca 的服务器用来和postgresql服务器安全交流的

#### postgresql的ssl配置
##### 在postgresql服务器中配置ssl的基本介绍

1. 在postgresql.conf中,取消注释ssl,设置为on(ssl=on)
2. 把证书文件和秘钥文件放到postgresql的数据目录.

生成自签名文件的介绍https://www.postgresql.org/docs/9.5/static/ssl-tcp.html

> 说明: 自签名的证书只能用来测试, 不能再生产环境中使用.

##### PostgreSQL的服务器-需要客户端的证书
1. 把ca的证书放在放在PostgreSQL的数据目录的root.crt文件中
2. 在PostgreSQL.conf中, 设置ssl_ca_file指向客户端的root证书
3. pg_hba.conf的文件中,把clientcert这个参数设置为1

更多细节可以查看postgresql的文档:https://www.postgresql.org/docs/9.4/static/libpq-ssl.html

### mysql
下面的例子可以加入到fabric ca server的配置文件中,用来连接db.确认好要把下面自定义的值合适.关于db名字的有字符的限制.使用这个文件 https://dev.mysql.com/doc/refman/5.7/en/identifiers.html 来查看更详细的描述.

在5.7.x中,某些模式决定 '0000-00-00' 是否为一个合法的日期.需要允许这个使用.我们想允许server接收0 值的日期.

在my.cnf中,找到sql_mode,移除NO_ZERO_DATA值.然后重启mysql server

查阅mysql文档选择合适的设置.https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html

```
db:
  type: mysql
  datasource: root:rootpw@tcp(localhost:3306)/fabric_ca?parseTime=true&tls=custom
```
如果需要连接tls,就需要db.tls.client部分,可以在在上面postgresql查看相关的介绍.

> 注释:
> 下面是在从配置中遇到一些问题:
>1. 在docker-compose启动时, 从fabric-ca-server中的报错信息:
>```
Error occurred initializing database: Failed to create user registry for MySQL: Failed to connect to MySQL database: dial tcp 172.18.0.3:3306: getsockopt: connection refused
```
>或者是这样的信息
```
[ERROR] Error occurred initializing database: Failed to create user registry for MySQL: Failed to connect to MySQL database: Error 1045: Access denied for user 'root'@'172.18.0.4' (using password: YES)
```
>或者是
```bash
Error: Error response from server was: Failed to initialize DB: Failed to create user registry for MySQL: Failed to create MySQL tables: Error creating certificates table: Error 1067: Invalid default value for 'expiry'
```

>这些问题主要有两个原因, 一个是fabric ca 服务端连接的参数不对,无法正常连接, 另一个就是MySQL在运行中出现问题,主动断开.
对于前者, 主要是这条命令:`FABRIC_CA_SERVER_DB_DATASOURCE=root:123456@tcp(mysql_ca:3306)/fabric_ca?parseTime=true`这里的这个配置是指用root用户,123456密码连接mysql,而mysql_ca是启动mysql的容器的名字,用这个名字作为hostname,fabric ca服务端就可以解析到myslq的ip地址.(在docker中默认有一个网关,172.18.0.1)

>对于第二个原因, 在MySQL中有一个模式叫做no-zero-data.这个模式是禁止向mysql中添加日期值为0 的数值. 而fabric-ca 存储的数据到MySQL的时候,创建的certificates表中有一个revoked_at的字段, 存入的数值是0000-00-00 00:00:00.如果没有关闭这么模式, mysql也会断开连接.所以要把no-zero-data模式关闭,才可以正常使用.

>对于mysql的配置, 也可以参考这里的介绍 https://dev.mysql.com/doc/refman/5.5/en/docker-mysql-more-topics.html#docker_var_mysql-root-host 

>总的来说, 对于mysql可以在两个地方配置.

>一个是设置docker-compose.yaml文件,在mysql的service中添加如下内容:
```yml
environment:
      MYSQL_ROOT_PASSWORD: passw0rd
      MYSQL_ALLOW_EMPTY_PASSWORD: "true"
      MYSQL_ROOT_HOST: "%"
command: mysqld --sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```
>这条命令的意思是, docker-compose在逐个启动各个container(在docker-compose中, 各个container被定义为一个一个的service)的时候,会执行command的这个命令.这个mysqld是指mysql的服务进程.

>另一个办法是设置mysql的配置文件,这个配置文件就是叫做my.cnf,一般来说路径是/etc/mysql.下面就是在my.cnf文件的相关的部分.
```conf
[mysqld]
sql-mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
```

>设置了这个配置文件之后, 要把这个在宿主机上的配置文件挂载到container中.可以使用docker-compose中的volumes属性.另外,把mysql的端口映射到宿主机,可以在宿主机登录查看
```yml
ports:
    - "3306:3306"
volumes:
      # 把mysql的数据挂载到宿主机
      - 主机目录:/var/lib/mysql
      # 把mysql服务器的配置挂载到宿主机
      - 主机目录/my.cnf:/etc/mysql/my.cnf
```
>顺便可以把mysql的整个数据目录一起映射的宿主机.省得单独导出了.

>在mysql连接成功之后, 如何验证?只需要连接到docker中的mysql,就可以查看到.正常情况, fabric ca 服务端会在mysql中创建一个fabric-ca的数据库,这个数据库包含三张表,分别是 affiliations,certificates(用于记录已经颁发的证书),和users(用户记录已经认证的用户).

>连接成功后在workdbench中可以看到如下的:

>![](./fabric-ca-tables.png)

>![](fabric-ca-tables-users.png)

>![](./fabric-ca-table-certicates.png)

>在配置ldap之后,users表的功能就被ldap替代,所以users表空闲.

#### mysql的ssl设置.
基本介绍

1. 打开或者新建一个my.cnf在server中.在mysqld下面,增加或者解除注释.这应该指向了server的key或者证书,和根root证书.
创建客户端和服务端的证书的介绍:http://dev.mysql.com/doc/refman/5.7/en/creating-ssl-files-using-openssl.html

```
[mysqld] 
ssl-ca=ca-cert.pem 
ssl-cert=server-cert.pem 
ssl-key=server-key.pem
```

运行下面的命令来确认已经启用了ssl连接:
mysql> SHOW GLOBAL VARIABLES LIKE ‘have_%ssl’;

2. 等服务端的ssl配置完成, 下一步是创建一个使用用户,可是使用ssl连接的特权.为此,登录进入mysql服务器,输入:
```
mysql> GRANT ALL PRIVILEGES ON . TO ‘ssluser’@’%’ IDENTIFIED BY ‘password’ REQUIRE SSL; mysql> FLUSH PRIVILEGES;
```
如果你特定ip可以访问, 把%改成你的ip

#### mysql 服务端-需要客户端证书
安全连接的配置和其他服务端的配置类似.

* ssl-ca: 指明用户授权的证书.如果使用这个选项, 必须在fabric-ca服务端使用相同的证书.
* ssl-cert: 指明mysql端的证书
* ssl-key: 指明mysql服务端的私钥

假设说,你想用一个没有加密的账户连接,或者说使用包含REQUIRE SSL选项的GRANT语句创建该帐户.作为推荐的安全连接选项,至少开启ssl-cert和ssl-key选项.然后设置db.tls.certfiles选项,再开启fabric ca 服务器.

要指定客户端证书, 使用REQUIRE X509 创建证书.然后客户端必须指定合适的client key和证书文件,否则, mysql会拒绝连接.为了指定client key和证书文件, 必须db.tls.client.certfile, and db.tls.client.keyfile

>下面是配置ssl中遇到问题: 

>首先是要对ssl连接要一定的了解.一下几个概念需要了解一下:

>签名: 服务端用自己的私钥对内容的摘要加密, 把加密后的密文和原文发送客户端, 这就是签名.客户端收到之后, 可以用服务端的公钥对密文进行解密,解密之后的内容与收到的原文做摘要之后做比较, 如果相同,说明可以这个内容确实来自服务端(抗抵赖),而且,收到的内容也是完整的(完整性)

>证书: 为了防止中间人攻击,确保客户端拿到的公钥确实是服务端的,需要对公钥做一些措施.所以,找了一个中间机构(发证机构),服务端把自己的公钥,自己机构的一些消息(就是上面的csr部分)和钱(自签名就交给自己吧orz), 交给发证机构.发证机构用自己的私钥对所有的这些信息进行加密(类似于签名的过程),把加密后的内容和服务器机构信息等放在一起,这就是一个证书.

>ssl的简单过程:服务端把自己的证书发给客户端,客户端本地要实现安装了发证机构的证书,所以取得发证机构的公钥,解密证书,验证证书有效,这样客户端就获得了服务端的公钥.然后服务端发送一份带有签名的信息(交换对称加密的秘钥在这个过程),这样客户端就可以确定对方是服务端.至此,客户端和服务端就可以愉快的使用对称加密了.

>更详细的描述可以查看这篇博客:http://www.cnblogs.com/JeffreySun/archive/2010/06/24/1627247.html

>可以参考这篇文章 https://segmentfault.com/a/1190000007819751 ,使用openssl工具生成一套ssl所需要的配置文件

>需要注意的是在生成的时候要指定服务器的名字,也就是cn这个字段.
>具体可以参考如下的设置.
```bash
#!/bin/bash
# 需要使用openssl工具
# 配置ssl连接的证书
#-subj /CN=mysql_ca 这个参数用来指定common name, 要与mysql container的name相同.
if [ -z "$1" ]; then 
        echo '$1 is null '
        commonName="mysql_ca"
fi
openssl genrsa 2048 > ca-key.pem #生成私钥
openssl req -new -x509 -nodes -days 3600 \
        -key ca-key.pem  -out ca.pem # 在执行这条会要求输入csr消息,可以直接回车
openssl req -newkey rsa:2048 -days 3600 \
        -nodes -keyout server-key.pem -subj /CN=$commonName -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 3600 \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
openssl req -newkey rsa:2048 -days 3600 \
        -nodes -keyout client-key.pem -subj /CN=$commonName -out client-req.pem
openssl rsa -in client-key.pem -out client-key.pem
openssl x509 -req -in client-req.pem -days 3600 \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem
openssl verify -CAfile ca.pem server-cert.pem client-cert.pem
openssl x509 -text -in ca.pem
```

>上面的代码一共会生成8个文件:
* ca.pem: CA 证书, 用于生成服务器端/客户端的数字证书.
* ca-key.pem: CA 私钥, 用于生成服务器端/客户端的数字证书.
* server-key.pem: 服务器端的 RSA 私钥
* server-req.pem: 服务器端的证书请求文件, 用于生成服务器端的数字证书.
* server-cert.pem: 服务器端的数字证书.
* client-key.pem: 客户端的 RSA 私钥
* client-req.pem: 客户端的证书请求文件, 用于生成客户端的数字证书.
* client-cert.pem: 客户端的数字证书.

>使用`openssl x509 -text -in [证书名字].pem`可以查看一个证书的内容:
![](cert-sample.png)

>在mysql端需要my.cnf中如下配置
```
general_log = 1
ssl-ca=/etc/mysql/fabric_ca_ssl/ca.pem 
ssl-cert=/etc/mysql/fabric_ca_ssl/server-cert.pem 
ssl-key=/etc/mysql/fabric_ca_ssl/server-key.pem
```
>此处`general_log = 1`值mysql日志的级别,通过这种方式可以查看是否使用ssl连接

>把上面生成的ssl文件拷贝到相应的目录中,通过volumns挂在到mysql的容器中.可以参考下面的配置:
```yml
volumes:
        - ./mysql2/fabric_ca_ssl:/etc/mysql/fabric_ca_ssl
```

>对于fabric-ca端的配置,在环境变量中配置ssl的文件
```yml
- FABRIC_CA_SERVER_DB_DATASOURCE=root:passw0rd@tcp(mysql_ca:3306)/fabric_ca?parseTime=true&tls=custom
      - FABRIC_CA_SERVER_DB_TLS_ENABLED=true
      - FABRIC_CA_SERVER_DB_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server-mysql-config/ca.pem
      - FABRIC_CA_SERVER_DB_TLS_CLIENT_CERTFILE=/etc/hyperledger/fabric-ca-server-mysql-config/client-cert.pem
      - FABRIC_CA_SERVER_DB_TLS_CLIENT_KEYFILE=/etc/hyperledger/fabric-ca-server-mysql-config/client-key.pem
```
>需要注意的是必须加上`tls=custom`这一句,这是指定使用tls连接,`FABRIC_CA_SERVER_DB_TLS_CERTFILES`是指定发证机构的证书,`FABRIC_CA_SERVER_DB_TLS_CLIENT_CERTFILE`是指定客户端的证书,`FABRIC_CA_SERVER_DB_TLS_CLIENT_KEYFILE`是指定客户端的私钥

>同样要记得把相应的文件导入到fabric-ca的容器中,可以参考如下的配置:
```yml
volumes:
      - ./mysql2/fabric_ca_ssl:/etc/hyperledger/fabric-ca-server-mysql-config
```

![](./mysql-log.png)

>上图显示的172.18.0.2是fabric-ca分配的ip,下面的172.18.0.1是在宿主机中用workbench连接是,通过docker网关(172.18.0.1)进行连接.

>可以使用如下命令查看某个容器的ip:
```
docker inspect [容器名字] | grep IPAddress
```


## 配置ldap
fabric ca服务端也可以配置为从ldap服务器读取.

特别是,fabric ca连接到ldap后做以下的事情:
* 在注册之前验证身份
* 检索用于授权的身份的属性值

修改Fabric CA服务器配置文件的LDAP部分，将服务器配置为连接到LDAP服务器。
```
ldap:
   # Enables or disables the LDAP client (default: false)
   enabled: false
   # The URL of the LDAP server
   url: <scheme>://<adminDN>:<adminPassword>@<host>:<port>/<base>
   userfilter: filter
```

此处参数的含义:
* where: 其中一个ldap
* adminDN: admin用户的独有的名字
* pass: admin用户的密码
* host:ldap服务器的hostname或者ip
* port: 可选的,ldap默认389, ldaps默认636
* base:用于搜索的LDAP树的可选根目录;
* filter: 在搜索时, 把登录名字转换为一个独特的名字.例如: 一个uid=%的值是搜索的值是一个在登录时有uid属性的值.email=%s可能用来使用email地址登录.

以下是一个openldap服务器的默认设置, docker镜像在
https://github.com/osixia/docker-openldap.

```
ldap:
   enabled: true
   url: ldap://cn=admin,dc=example,dc=org:admin@localhost:10389/dc=example,dc=org
   userfilter: (uid=%s)
```
查看`FABRIC_CA/scripts/run-ldap-tests`这个脚本来开启openldap的docker镜像,配置, 运行,使用这个`FABRIC_CA/cli/server/ldap/ldap_test.go`测试, 并且停止openldap服务器.

当一个ldap配置后, enrollment的工作流是这样的:
* fabric ca client或者client 登录请求,在头部带有一个授权信息(就是enroll的时候用户名和密码).
* fabric ca server 收到enroment请求,解码授权头部中的实体的名字,密码.使用'userfilter'查找与这个实体名字相关的distinguished name. 尝试使用这个密码进行ldap绑定.如果ldap绑定成功,那么, enrollment过程就被授权,和继续执行.

当ldap配置后, 获取属性的工作流是这样的:
* 一个客户端的sdk向fabric ca服务端发送一个请求来获取一些有一个或者多个属性的证书.
* 当fabric ca 服务端收到tcert的请求后的工作流:
  * 根据在授权头部中的token来提取enrollment id.(在验证了token之后)
  * 向ldap服务器做一个ldap搜索和查询, 请求所有在tcert请求中的属性名.
  * 属性值就会被放在tcert中.

>注释: 主要是两个地方的配置,一个是ca中开启ldap,
```yml
  - FABRIC_CA_SERVER_LDAP_ENABLED=true
  - FABRIC_CA_SERVER_LDAP_URL=ldap://cn=admin,dc=example,dc=org:adminpw@fabric_ca_openldap:389/dc=example,dc=org
      - FABRIC_CA_SERVER_LDAP_URL_USERFILTER=(uid=%s)
```
>fabric-ca服务端已经实现了ldap的客户端, 另一个添加ldap服务到docker-compose中.为了方便查看,还可以安装ldapPhpAdmin来查看和管理ldap中的用户.
```yml
ldap:
      image: osixia/openldap:1.2.1
      container_name: fabric_ca_openldap
      environment:
        LDAP_LOG_LEVEL: "-1" # 	enable all debugging
        LDAP_ADMIN_PASSWORD: "adminpw"
      volumes:
        # 数据文件
        - ./openldap/ldap:/var/lib/ldap
        # 配置文件
        - ./openldap/slapd.d:/etc/ldap/slapd.d
        - ./openldap_data/add-user.ldif:/tmp/add-user.ldif
      ports:
        - "389:389"
        - "636:636"
      networks:
        - basic

  phpLDAPadmin:
    image: osixia/phpldapadmin:0.7.1
    container_name: fabric_phpLDAPadmin
    ports:
      - "8080:80"
    environment:
      - PHPLDAPADMIN_LDAP_HOSTS=fabric_ca_openldap
      - PHPLDAPADMIN_HTTPS="false"
    depends_on:
      - ldap
    networks:
      - basic
```
>这里的`add-user.ldif`相当于mysql中的sql文件,可以执行这个命令向ldap中添加用户.
```bash
docker exec fabric_ca_openldap ldapadd -cxD cn=admin,dc=example,dc=org -w adminpw -f /tmp/add-user.ldif

docker exec fabric_ca_openldap ldappasswd -xD cn=admin,dc=example,dc=org -w adminpw uid=jsmith,dc=example,dc=org -s jsmithpw
```
>可以到浏览器访问`localhost:8080`,使用`cn=admin,dc=example,dc=org,adminpw`这个管理员的用户密码登录,就可以发现刚刚添加的用户.
![](ldap-jsmith.png)

>使用ldap之后, fabric-ca服务端的执行start的时候就不用-b选项了.

>可以在fabric-ca服务端登录这个用户,可以看到jsmith这个用户已经拿到证书:
![](jsmith-enroll.png)
![](jsmith-cert.png)


## 配置集群
你可能会用ip sprayer来对一个ca集群做负载均衡.本部分提供一个例子, 如何设置haproxy作为一个ca服务集群的路由.确定把hostname和端口设置到与ca服务器相符.

haproxy.conf的配置:
```
global
      maxconn 4096
      daemon

defaults
      mode http
      maxconn 2000
      timeout connect 5000
      timeout client 50000
      timeout server 50000

listen http-in
      bind *:7054
      balance roundrobin
      server server1 hostname1:port
      server server2 hostname2:port
      server server3 hostname3:port
```
注意, 如果使用tls, 要使用tcp模式.

> 说明:
要完成这个需要启动一个haproxy服务
```yml
  haproxy_ca:
    image: haproxy
    container_name: haproxy_ca
    ports:
      - "70:70"
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
      - ./haproxy/log:/dev/log
    networks:
      - basic
```
>而对于haproxy, 要做这样的配置:
```conf
global
# 支持的最大连接数
      maxconn 4096 
       # 以守护进程的方式运行
      daemon

defaults
# 代理模式有http和tcp两种, tls需要tcp模式.http是七层模式，tcp是四层模式，health是健康检测，返回OK
      mode http
      maxconn 2000
      timeout connect 5000
      timeout client 50000
      timeout server 50000

frontend balancer
      bind *:7054
      mode http
      default_backend servers

#  定义后端节点
# listen http-in
# 监听7054
backend servers
# 负载均衡的算法: roundrobin: 权重轮训, 动态, static-rr: 权重轮训, 静态
# leastconn:到最少连接数, 动态, 长时间会话
# source: 同一个ip始终到特定服务器.
# uri: 同一uri始终到特定服务器
# hdr:
      balance roundrobin
      server ca1 ca1.example.com:7054
      server ca2 ca2.example.com:7054
      server ca3 ca3.example.com:7054

listen status
      mode http
      default_backend servers
      bind 0.0.0.0:70
      stats enable
      stats hide-version
      stats uri     /stats
      stats auth    admin:password
      stats admin if TRUE
```
>而且,通过将70端口映射到宿主机访问`http://localhost:70/stats`, 用户名和密码在haproxy.cfg文件中, 可以查看haproxy的信息
![](haproxy-stats.png)

>分别登录三个ca1,ca2,ca3执行一次之后

![](haproxy-stats-after.png)

## 设置多个ca
每个ca服务器默认包含一个ca.然而, 可以使用cafiles或者cacount配置选项来向一个ca服务器中增加多个ca.每个增加的ca都有自己的主目录.

### cacout:
cacout提供了一种快速x个ca的方案.他的主目录与服务器的主目录相关.当开启这个选项,目录结构如图:
```
--<Server Home>
  |--ca
    |--ca1
    |--ca2
```
每个额外的ca都在自己的主目录中生成一个默认的配置文件, 在这个目录文件中, 会包含一个唯一的ca名字.

例如, 如下的命令开启默认开启2个ca实例:
```
fabric-ca-server start -b admin:adminpw --cacount 2
```
### cafiles:
在使用cafile配置选项的时候, 没有提供绝对路径,那么ca的目录就是相对于服务器的目录.

为了使用这个选项,必须事先生成ca的配置文件,并且每个将要开启的ca配置好.每个配置文件必须有一个唯一的ca名字和一个common name, 否则就会开启失败, 因为名字必须唯一.ca的配置文件会覆盖所有的ca默认配置文件, 任何在ca配置文件中缺失的选项将会使用ca 的默认值来替换.

优先级如下所示:
1. ca 配置文件
2. 默认的的cli命令
3. 默认的ca环境变量
4. 默认的配置文件

一个ca的配置文件必须要有一下几个:
```
ca:
# Name of this CA
name: <CANAME>

csr:
  cn: <COMMONNAME>
```

你可以如下配置目录结构:
```
--<Server Home>
  |--ca
    |--ca1
      |-- fabric-ca-config.yaml
    |--ca2
      |-- fabric-ca-config.yaml
```

例如: 下面的命令会开启两个自定义的ca实例.
```
fabric-ca-server start -b admin:adminpw --cafiles ca/ca1/fabric-ca-config.yaml --cafiles   ca/ca2/fabric-ca-config.yaml
```


## 登录一个中间ca
为了给一个中间ca创建一个签名证书,这个中间ca必须向一个父级ca登录,与一个fabric-ca 客户端登录的方式相同.这个可以类似下面展示的方式, 使用-u选项来指定父级的ca的URL,登录的id和密码.这个登录id的用户必须有一个名为"hr.IntermediateCA"的属性,它的值是`true`.颁发的证书的CN(common name)设置为登录id.如果一个中间ca指定名字, 会发生错误.

```bash
fabric-ca-server start -b admin:adminpw -u http://<enrollmentID>:<secret>@<parentserver>:<parentport>
```

更多关于中间ca的标记可以查看https://hyperledger-fabric-ca.readthedocs.io/en/release-1.0/users-guide.html#fabric-ca-server-s-configuration-file-format


# fabric ca 客户端

这一部分描述如何使用fabric-ca客户端命令.

fabric-ca的客户端的主目录有以下的顺序决定:
* 如果设置了`FABRIC_CA_CLIENT_HOME`环境变量,就用这个
*  如果设置了`FABRIC_CA_HOME`环境变量,就用这个
*  如果设置了`CA_CFG_PATH`环境变量,就用这个
*  如果设置了`$HOME/.fabric-ca-client`环境变量,就用这个

下面的介绍假定客户端的配置文件存在于客户端的主目录中.

## 登录启动实体
首先, 如果需要, 要在client的配置文件中, 自定义csr部分.注意: csr.cn部分必须是启动实体的id.以下是默认的csr值:
```
csr:
  cn: <<enrollment ID>>
  key:
    algo: ecdsa
    size: 256
  names:
    - C: US
      ST: North Carolina
      L:
      O: Hyperledger Fabric
      OU: Fabric CA
  hosts:
   - <<hostname of the fabric-ca-client>>
  ca:
    pathlen:
    pathlenzero:
    expiry:
```

可以查看csr部分详细描述.https://hyperledger-fabric-ca.readthedocs.io/en/release-1.0/users-guide.html#csr-fields

然后运行`fabric-ca-client enroll`来登录实体.比如,以下命令,调用运行在locahost:7054的fabric ca 服务,登录一个实体,id是admin,密码是adminpw.
```bash
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054
```
这个登录命令将一个登录证书ecert,相应的私钥,和ca证书存储到fabric ca客户端msp目录.你会看到pem在哪里存储的信息.

>  注释:
执行的结果:
在fabric-ca中:
![](client-enroll.png)

>在user表中:
![](user-table-enroll.png)

>在certificate表中:
![](cert-tabel-enroll.png)

>登录一个用户的过程是这样的: client端生成一份私钥,存在`$FABRIC_CA_CLIENT_HOME/msp/keystore`.比方说amin登录就需要指定为amin的值.当然这个值也可以按照上面的规则用环境变量或者命令行参数覆盖.接着,向服务端发起请求.服务端的返回发证机构的一个证书,放在文件夹`$FABRIC_CA_CLIENT_HOME/msp/cacerts `中,命名为上面请求的`{hostname}-{port}.pem`,这个证书实际上就是fabric-ca服务端的发证机构的证书,也就是服务端的`/etc/hyperledger/fabric-ca-server-config/org1.example.com-cert.pem`这个文件.还有一个是fabric-ca服务端给客户端的证书`$FABRIC_CA_CLIENT_HOME/msp/signcerts/cert.pem `,会存放在这个证书是在issure是fabric-ca服务端,subject(证书持有者)是admin用户.
![](ca-client-admin-cert.png)

## 注册一个新的用户
执行注册的身份必须已经登录,也必须要有相应的权限来注册这种类型的用户.

通常, 在fabric ca server注册期间会实行两个授权检查:
1. 登录的身份必须要有hf.Registrar.Roles属性,可以用逗号分隔,其中一个值是正在注册的值.例如, 调用身份的hf.Registrar.Roles属性值是peer,app,user”,那么只能注册这其中的一个, 不能是order
2. 调用者身份的隶属关系必须等于被登记身份的隶属关系的前缀.例如, ，具有“a.b”属性的调用者可以注册与“a.b.c”属性相同的身份，但不可以注册属于“a.c”属性的身份。

例如, 下面的命令用admin证书,注册一个新的用户,enrollment id 是admin2, 类型user, 丛书关系 org1.department, 属性名字hr.Revoker为true,还有一个属性foo,值是bar
```
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/admin
fabric-ca-client register --id.name admin2 --id.type user --id.affiliation org1.department1 --id.attrs 'hf.Revoker=true,foo=bar'
```
密码, 或者登陆凭证, 会被打印.这个密码可以用来注册.这可以让管理员注册身份并把enrollment ID和密码给别人注册.

>  注释:
fabric-ca的输出:
![](admin2-reg.png)

>user表的内容:
![](user-table-admin2-reg.png)

certficate表没有变化

多个属性可以用id.attrs flag的一部分, 并且用分号分隔.对于包含逗号的属性, 要用双引号
```
fabric-ca-client register -d --id.name admin2 --id.type user --id.affiliation org1.department1 --id.attrs '"hf.Registrar.Roles=peer,user",hf.Revoker=true'

```
或者
```
fabric-ca-client register -d --id.name admin2 --id.type user --id.affiliation org1.department1 --id.attrs '"hf.Registrar.Roles=peer,user"' --id.attrs hf.Revoker=true
```

可以在客户端配置文件中设置默认值,如下是一个支持的配置文件格式
```yaml
id:
  name:
  type: user
  affiliation: org1.department1
  maxenrollments: -1
  attributes:
    - name: hf.Revoker
      value: true
    - name: anotherAttrName
      value: anotherAttrValue
```
一下命令会注册一个新的用户,注册id时admin3,有cli指定,从配置文件读取其余的参数.
```
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/admin
fabric-ca-client register --id.name admin3
```
要注册具有多个属性的标识，需要在配置文件中指定所有属性名称和值，如上所示.

将maxenrollments设置为0或将其从配置中删除将导致身份被注册为使用CA的最大注册值。此外，注册身份的最大注册值不能超过CA的最大注册值。例如，如果CA的最大注册值为5.任何新身份的值必须小于或等于5，也不能将其设置为-1（无限注册）。

接下来，让我们注册一个peer身份，这将用于在以下部分注册用户。以下的命令注册了peer1.注意, 我们自己指定密码而不是让服务器生成.
```bash
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/admin
fabric-ca-client register --id.name peer1 --id.type peer --id.affiliation org1.department1 --id.secret peer1pw
```
> 说明
在fabric-ca中输出:

![](peer-reg.png)

>在user表中:

![](user-table-peer-reg.png)

## 注册peer用户
既然已经注册peer用户, 可以使用给定的enrollment ID和密码enroll.这个与enroll启动身份很相似,除了我们演示的用-m 选项来指定hyperledger fabric msp部分的目录结构.

以下的命令enroll peer1.确认要把-m中的目录指定到自己的peer 的msp目录中, msp路径在peer的core.yaml文件中.你也可以设置FABRIC_CA_CLIENT_HOME.
```
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/peer1
fabric-ca-client enroll -u http://peer1:peer1pw@localhost:7054 -M $FABRIC_CA_CLIENT_HOME/msp
```

登录一个order也是类似的,除了在order.yaml中指定LocalMSPDir的不同.

>注释:
 注册用户的过程是这样的: peer1用户借助admin用户来注册.先前amdin用户登录之后, 在本地就存了一份admin用户的证书.如果没有证书,会提示重新登录
![](not-enroll.png)
 一份默认的配置文件,就是`/root/fabric-ca/clients/peer1/fabric-ca-client-config.yaml`,通过读取配置中`csr.cn`的值,指定登录的身份,当然,在这里只能为admin,而不能是其他用户,因为只有admin的属性中带有了注册其他角色的权限(可以查看user表中的attribute字段).服务端返回的响应是给peer1用户的一个证书.可以看出发证机构是`ca.org1.example.com`,而证书的持有者就是`peer1`
![](peer1-cert.png)

## 从另一个ca服务器获得一个ca证书
通常，MSP目录的cacerts目录必须包含其他证书颁发机构的证书颁发机构链，代表所有peer节点的所有信任根。

`fabric-ca-client getcacerts`这个命令可以获取从其他fabric-ca服务器的证书链.


例如, 以下会在locahost启动第二个ca服务器在端口7055,名为CA2..这表示一个完全独立的信任根，并由区块链上的其他成员管理。
```
export FABRIC_CA_SERVER_HOME=$HOME/ca2
fabric-ca-server start -b admin:ca2pw -p 7055 -n CA2
```
以下命令将CA2的证书链安装到peer1的MSP目录中。
```
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/peer1
fabric-ca-client getcacert -u http://localhost:7055 -M $FABRIC_CA_CLIENT_HOME/msp
```

## 重新enroll一个实体
假如你的证书要过期或者撤销,可以使用下面的命令更新证书.

```
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/peer1
fabric-ca-client reenroll
```
> 结果如图所示:
![](reenroll.png)

## 撤销一个证书
一个实体或者证书都是可以撤销的.撤销一个实体会撤销这个实体所拥有的所有证书,并且会阻止这个实体获取新的证书.撤销证书只是让证书失效

为了撤销证书, 实体必须要有hrRevoke属性.撤销身份只能撤销证书或身份，其身份与撤销身份的隶属关系相同或以前缀为准。例如,具有隶属关系orgs.org1的撤销者可以撤销与orgs.org1或orgs.org1.department1相关联的身份，但不能撤销与orgs.org2相关的身份。
以下的命令会撤销一个实体并且撤销与此实体相关的所有证书.
```
fabric-ca-client revoke -e <enrollment_id> -r <reason>
```

以下是-r 标记可以使用的原因:
1. unspecified : 未指明
2. keycompromise : 秘钥无效
1. cacompromise : ca 无效
1. affiliationchange : 改变隶属关系
1. superseded :被替代
1. cessationofoperation : 操作终止
1. certificatehold 
1. removefromcrl
1. privilegewithdrawn
1. aacompromise

例如,与从属关系树相关的启动admin可以撤销peer1的身份.
```
export FABRIC_CA_CLIENT_HOME=$HOME/fabric-ca/clients/admin
fabric-ca-client revoke -e peer1
```
>![](revoke.png)
![](revoke-mysql.png)

通过指定其AKI（授权密钥标识符）和序列号，可以撤销属于某个身份的注册证书，如下所示：
```
fabric-ca-client revoke -a xxx -s yyy -r <reason>

```
例如，您可以使用openssl命令获取AKI和证书的序列号，并将它们传递给revoke命令以撤消该证书，如下所示：

```
serial=$(openssl x509 -in userecert.pem -serial -noout | cut -d "=" -f 2)
aki=$(openssl x509 -in userecert.pem -text | awk '/keyid/ {gsub(/ *keyid:|:/,"",$1);print tolower($0)}')
fabric-ca-client revoke -s $serial -a $aki -r affiliationchange
```
## 使用tls
以下可以在 fabric-ca-client-config.yaml 中配置
```
tls:
  # Enable TLS (default: false)
  enabled: true
  certfiles:
    - root.pem
  client:
    certfile: tls_client-cert.pem
    keyfile: tls_client-key.pem
```
这个证书选项就是一系列被client信任的root证书.这通常只是在ca-cert.pem文件中的服务器主目录中找到的根结构CA服务器的证书。

只有服务端配置了tls, 才需要在客户端配置

## 联系指定的ca实例
等运行在一个服务器上多个ca,可以指定ca.默认,如果ca的名字没有在客户端的请求中指定,就会请求fabric-ca服务端的默认ca.一个ca 的名字可以客户端的命令行中指定
```
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054 --caname <caname>
```

# 相关资料
1. 在2018-7, fabric更新到了1.2.[文档](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.2/users-guide.html)也更加丰富,更加人性化.建议先去看一下.

1. 之前的中文翻译文档:https://hyperledgercn.github.io/hyperledgerDocs/
