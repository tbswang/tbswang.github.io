---
layout: the
title: 字符串中最多的字符
date: 2020-05-26 16:37:56
tags:
---
给定一段字符串, 查找查找其中做的字符和个数.

## 方法一
### 思路
遍历所有的字符串, 记录每个字符出现的个数,然后取出最多的.

### 时间复杂度
o(n)

## 空间复杂度
o(n)


```js
let str = 'awfoeifaoifauwefa';

let out = {};
for(i of str){
  if(!out[i]){
    out[i] = 1;
  } else{
    out[i] += 1;
  }
}

let maxNum = 0;
let maxItem = '';
for(i in out){
  if(out[i] > maxNum){
    maxItem = i
    maxNum = out[i]
  }
}

console.log(maxItem, maxNum);
```

## 方法二 删除法
### 思路:
每次取出第一个元素, 然后删除全部相同的, 哪一次删除的最多, 就哪一个元素最多

```js

let str = 'awfoeifaoifauwefa';

let maxItem = '';
let maxNum = 0;
while (str.length > 0) {
  const s = str[0];
  const originLen = str.length;
  const reg = new RegExp(s, 'g')
  str = str.replace(reg, '');
  const rLen = str.length;
  
  const diffLen = Math.abs(originLen - rLen);
  if (diffLen > maxNum) {
    maxItem = s;
    maxNum = diffLen;
  }
}

console.log(maxItem, maxNum);
```

## 方法三: 
### 先排序, 然后找出最多连续的
```js
let str = 'awfoeifaoifauwefa';

str = str.split('').sort();
let cnt = 1;
let maxNum = 1;
let maxItem = '';
for (let i = 0; i < str.length -1; i++) {
  if (str[i+1] === str[i]) {
    cnt++;
  } else {
    if (cnt > maxNum) {
      maxNum = cnt;
      maxItem = str[i];
    }
    cnt = 1;
  }
}
console.log(maxItem, maxNum);

```