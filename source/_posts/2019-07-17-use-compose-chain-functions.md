---
title: compose-函数链式执行
date: 2019-07-17 08:21:49
tags:
---
## abstract

使用Array.prototype.reduce，将一组函数链式执行。比如
```
    const chain = compose(a,b,c)
    chain();
```
## 1. 思路
<!-- more -->
我们有一组函数a,b,c，要变成依次调用，只需要a(b(c()))就可以。

但是，如果有多个函数，总不能光明正大的写出来调用吧。在js中可以通过将函数作为一个参数传递，毕竟回调函数。我们能不能把这一组函数变成a(b())的形式。

### 1.1 reduce的执行顺序

reduce函数，原意是用在数组中，将之前的返回的结果作为下次的运行的参数。以mdn的例子([https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce#reduce()_如何运行](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce#reduce()_%E5%A6%82%E4%BD%95%E8%BF%90%E8%A1%8C))
```js
    [0, 1, 2, 3, 4].reduce(function(accumulator, currentValue, currentIndex, array){
      return accumulator + currentValue;
    });
```
调用顺序

|callback|acc|cur value | cur index | array | return value|
|--|--|--|--|--|--|
first call | 0 | 1 | 1 | \[0, 1, 2, 3, 4\] | 1 |
second call | 1 | 2 | 2 | \[0, 1, 2, 3, 4\] | 3 |
third call | 3 | 3 | 3 | \[0, 1, 2, 3, 4\] |6 |
fourth call | 6 | 4 | 4 | \[0, 1, 2, 3, 4\] | 10 |

reduce的执行是给定一个函数，将所有的元素传入这个函数，每次函数的执行结果作为下一次的执行参数。如果没有给定初始值，第一次传入的是第一个和第二个元素。

假设现在有a,b,c三个函数，
```js
    function a() {
        console.log('a');
    }
    function b() {
        console.log('b')
    }
    function c(){
        // console.log(n)
        console.log('c')
    }
```
最简单的使用

    [a,b,c].reduce((a,b)=>a(b()));

是什么结果呢？
```bash
    b
    a
    c 
    TypeError: a is not a function
        at chain.reduce (d:\workspace\learn\compose.js:12:39)
        at Array.reduce (<anonymous>)
        at Object.<anonymous> (d:\workspace\learn\compose.js:12:23)
        at Module._compile (internal/modules/cjs/loader.js:773:14)
        at Object.Module._extensions..js (internal/modules/cjs/loader.js:787:10)
        at Module.load (internal/modules/cjs/loader.js:653:32)
        at tryModuleLoad (internal/modules/cjs/loader.js:593:12)
        at Function.Module._load (internal/modules/cjs/loader.js:585:3)
        at Function.Module.runMain (internal/modules/cjs/loader.js:829:12)
        at startup (internal/bootstrap/node.js:283:19)
```
这里出错了，是什么原因呢？

第一次循环，实际执行是a(b()),先执行b，在执行a。所以打印b, a。第二次循环，之前的返回是一个函数执行，b执行完之后的结果作为参数传入a，a执行完之后返回undefined，所以此时a就是undefined。所以实际执行就是undefined(c())。

可以看出是第一次没有返回值导致的错误。所以关键是在这个执行的函数中。

### 1.2 函数闭包

上面的问题主要有

1. 我们不知道a是否返回，我们也不可能去修改a中的代码，所以就有调用undefined方法的情况。
2. 上面的执行顺序也是不对的。

解决办法其实就是在用一个函数包裹一下，作为返回值。
```
    const chain = [a,b,c,d].reduce((a,b)=>()=>a(b()))
```
测试一下，非常完美。

1. 第一次执行，输入的是a,b。然后返回一个函数，()⇒(a(b())。我们把这个匿名函数叫做acc1。
2. 第二次执行，输入的是acc1,c。然后返回一个函数()⇒(acc1(c())。
3. 最后这个chain就是这个样子
```js
    function () {
    	return acc1(c());
    }
```
4. 最后执行一次chain()就万事大吉。

### 1.3 内存泄漏

既然使用闭包，就会有内存泄露的风险。

在reduce中，其实是将a,b,c,d这些函数不断包裹在外层包裹闭包。所以对函数要有限制。

一般v8中的stack的大小为1M左右。根据每个函数的占用字节，就可以算出一共多少函数。

## 2. reduce里面发生了啥

reduce是一次函数遍历。我们可以通过他的pollyfill来大致了解一下[https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce#Polyfill](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce#Polyfill)
```js
    while (k < len) {
            if (k in o) {
              value = callback(value, o[k], k, o);
            }
            k++;
          }
    return value;
```
比较关键的几行就是这里。将数组里面所有元素遍历，然后每次执行的结果记住，最后将结果返回。

## 3. 实际使用

前文就是理清reduce中的执行过程。那么在实际使用中还要哪些呢？

1. 参数的传递

实际中每个处理的函数需要接收参数,参照一下redux中设计 [https://github.com/reduxjs/redux/blob/master/src/compose.js](https://github.com/reduxjs/redux/blob/master/src/compose.js)
```js
    export function compose(...funcs) {
      if (funcs.length === 0) {
        return arg => arg;
      }
      if (funcs.length === 1) {
        return funcs[0];
      }
      return funcs.reduce((a, b) => (...args) => a(b(...args)));
    }
```
除此之外， mdn也有类似的实现
```js
    const pipe = (...functions) => input => functions.reduce(
        (acc, fn) => fn(acc),
        input
    );
```
具体使用都是一样的。