---
title: react哲学
date: 2021-11-16 13:09:00
tags:

---

> 原文： https://github.com/mithi/react-philosophies 

## 0.介绍

react哲学是：

- 我在编写React代码时会考虑的事情。
- 每当我查看别人或我自己的代码时，我都会想到
- 只是指导方针，而不是严格的规则
- 一个动态的文件，随着我的经验增长和时间变化而变化
- 大多数技术是基本[重构](https://en.wikipedia.org/wiki/Code_refactoring)方法、[SOLID](https://en.wikipedia.org/wiki/SOLID)原则和[极端编程](https://en.wikipedia.org/wiki/Extreme_programming)思想的变体……只是专门应用于React🙂

`react-哲学` 的灵感来自我在编码之旅的不同阶段， 在不同地方的偶然发现。

这里有几个：

- [桑迪梅斯](https://sandimetz.com/)
- [肯特·C·多兹](https://kentcdodds.com/)
- [Python 之禅（PEP 20）](https://www.python.org/dev/peps/pep-0020/)，[Go 之禅](https://dave.cheney.net/2020/02/23/the-zen-of-go)
- [trekhleb/state-of-the-art-shitcode](https://github.com/trekhleb/state-of-the-art-shitcode) , [droogans/unmaintainable-code](https://github.com/Droogans/unmaintainable-code) , [sapegin/washingcode-book](https://github.com/sapegin/washingcode-book/) , [wiki.c2.com](https://wiki.c2.com/)

> 作为一名经验丰富的开发人员，我有一些我所依赖的怪癖、观点和常见模式。不得不向另一个人解释为什么我会以特定的方式解决问题，这对于帮助我改掉坏习惯和挑战我的假设，或为良好的问题解决技巧提供验证真的很有好处。-卡洛琳阿达Ehmke

<!-- more -->

## 1.最低限度

### 1.1 意识到何时计算机比你聪明

1. 使用[ESLint](https://eslint.org/)静态分析代码。启用[rule-of-hooks](https://www.npmjs.com/package/eslint-plugin-react-hooks)和`exhaustive-deps`规则以捕获 React 特定错误。
2. 启用[“严格”](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode)模式。现在是 2021 年。
3. [认真对待依赖](https://overreacted.io/a-complete-guide-to-useeffect/#two-ways-to-be-honest-about-dependencies)。修复useMemo、useCallback 和 useEffect 上的`exhaustive-deps`警告/错误。你可以尝试[“最新的ref模式”](https://epicreact.dev/the-latest-ref-pattern-in-react)来使您的回调始终保持最新状态，而无需进行不必要的重新渲染。
4. 每当您用于map显示组件时，请[始终添加key](https://epicreact.dev/why-react-needs-a-key-prop)。
5. [只在顶层调用hooks](https://reactjs.org/docs/hooks-rules.html)。不要在循环、条件或嵌套函数中调用 Hook。
6. 了解警告“[Can’t perform state update on unmounted component](https://github.com/facebook/react/pull/22114)”
7. 通过在应用程序的添加不同级别[错误边界来](https://reactjs.org/docs/error-boundaries.html)防止[“白屏死机”](https://kentcdodds.com/blog/use-react-error-boundary-to-handle-errors-in-react)。如有必要，您还可以使用它们向错误监控服务（例如[Sentry）](https://sentry.io/)发送警报。（[在 React 中考虑失败](https://brandondail.com/posts/fault-tolerance-react)）
8. 控制台中显示错误和警告是有原因的。
9. 记住[tree-shaking](https://webpack.js.org/guides/tree-shaking/)！
10. [Prettier](https://prettier.io/)（或其他替代）为您格式化代码，每次都为您提供一致的格式。您不再需要考虑它！
11. [Typescript](https://www.typescriptlang.org/) 会让你的生活更轻松。
12. 我强烈推荐[Code Climate](https://codeclimate.com/quality/)（或类似的）用于开源存储库，或者如果你负担得起的话。我发现自动检测到的代码坏味道确实鼓励我， 去减少正在开发应用程序的技术债！
13. [NextJS](https://nextjs.org/) 是一个很棒的框架。

### 1.2 代码是罪恶之源

> “最好的代码根本就是没有代码。你引入世界的每一行新代码， 都是必须被调试的、被阅读和理解、必须被支持的代码。” - Jeff Atwood
> 

> “我最有成效的日子之一就是扔掉 1000 行代码。” - Eric S. Raymond
> 

另外参阅： [Write Less Code - Rich Harris](https://svelte.dev/blog/write-less-code), [Code is evil - Artem Sapegin](https://github.com/sapegin/washingcode-book/blob/master/manuscript/Code_is_evil.md)

**TL;DR**

1. 在添加另一个依赖之前，要三思
2. 使用非 React 独占的技术清理代码
3. 不要聪明。你是不是需要它(You Ain’t Gonna Need it)！

### 1.2.1 在添加另一个依赖项之前要三思

不用说，添加的依赖项越多，发送到浏览器的代码就越多。问问自己，你真的需要那些让一个类库变得优秀的特性吗？

- **🙈 你真的需要吗？***查看您可能不需要的依赖项/代码示例*
    1. 你真的需要[Redux](https://redux.js.org/)吗？这是可能的。但请记住，React 已经是一个[状态管理库](https://kentcdodds.com/blog/application-state-management-with-react)。
    2. 你真的需要[Apollo client](https://www.apollographql.com/docs/react/)吗？Apollo 客户端有许多很棒的功能，比如手动规范化。但是，它会显着增加您的dist包大小。如果您的应用程序仅使用并非 Apollo 客户端独有的功能，请考虑使用较小的库，例如[react-query](https://react-query.tanstack.com/comparison)或[SWR](https://github.com/vercel/swr)（或根本不使用）。
    3. [Axios](https://github.com/axios/axios)? Axios 是一个很棒的库，其功能不易被原生fetch. 但是如果使用 Axios 的唯一原因是它有一个更好看的 API，那么考虑只在 fetch 之上使用一个包装器（例如[redaxios](https://github.com/developit/redaxios)或你自己的）。确定您的应用程序是否真正使用了 Axios 的最佳功能。
    4. [Decimal.js](https://github.com/MikeMcl/decimal.js/)? 也许[Big.js](https://github.com/MikeMcl/big.js/)或[其他较小的库](https://www.npmtrends.com/big.js-vs-bignumber.js-vs-decimal.js-vs-mathjs)就足够了。
    5. [Lodash](https://lodash.com/)/ [underscoreJS](https://underscorejs.org/)? [你不需要/你不需要Lodash-Underscore](https://github.com/you-dont-need/You-Dont-Need-Lodash-Underscore)
    6. [MomentJS](https://momentjs.com/)? [你不需要/你不需要-Momentjs](https://github.com/you-dont-need/You-Dont-Need-Momentjs)
    7. 您可能不需要Context来做主题（light/dark模式），请考虑使用[css variables](https://epicreact.dev/css-variables)。
    8. 您甚至可能不需要Javascript. CSS 很强大。[你不需要/你不需要JavaScript](https://github.com/you-dont-need/You-Dont-Need-JavaScript)

### 1.2.2 使用非 React 独占的技术清理代码

1. 如果可以，请简化[复杂的条件](https://github.com/sapegin/washingcode-book/blob/master/manuscript/Avoid_conditions.md)并尽早退出。
2. 如果没有明显的性能差异，链式高阶函数代替传统的循环（map，filter，find，findIndex，some，等）

### 1.2.3 不要聪明。您是不是要去需要它(You Ain’t Gonna Need it)！

> “我的软件将来会发生什么？哦，是的，也许这个和那个。让我们实现所有这些东西，因为我们正在研究这部分。这样它就可以面向未来。”
> 

总是只在你真正需要它们的时候实现他们，而不是在你预见到你可能需要它们的时候。

另请参阅：[Martin Fowler：YAGNI](https://martinfowler.com/bliki/Yagni.html)，[C2 Wiki：您不需要它！](https://wiki.c2.com/?YouArentGonnaNeedIt)

### 1.3 让它比你发现它的时候更好

**检测代码坏味道并根据需要对其进行处理**。

如果你发现有什么地方不对劲，就当场改正。但是，如果修复不是那么容易，或者您当时没有时间修复它，请至少添加一条注释（FIXME或TODO），并对所识别的问题进行简明的解释。确保每个人都知道它坏了。它向其他人表明您在乎，并且当他们遇到此类事情时也应该这样做。

- **查看易于捕捉的代码异味示例**
    - ❌ 使用大量参数定义的方法或函数
    - ❌ 可能难以理解的布尔逻辑
    - ❌ 单个文件中的代码行过多
    - ❌ 语法相同的重复代码（但格式可能不同）
    - ❌ 可能难以理解的函数或方法
    - ❌ 用大量函数或方法定义的类/组件
    - ❌ 单个函数或方法中的代码行过多
    - ❌ 具有大量返回语句的函数或方法
    - ❌ 不相同但共享相同结构的重复代码（例如变量名称可能不同）

请记住，代码异味并不一定意味着应该更改代码。代码异味只是告诉您，您也许能想出更好的方法来实现相同的功能。

### 1.4 你可以做的更好

**💁‍♀️提示：请记住，您可能不需要将您的state作为依赖项，因为您可以改为传递回调函数。**

您不需要将setState(from useState) 和dispatch(from useReducer) 放入您的依赖数组中，以获取useEffect和 之类的钩子useCallback。ESLint 不会报错，因为 React 保证了它们的稳定性。

- 查看示例
    
    ```
    ❌ Not-so-good
    const decrement = useCallback(() => setCount(count - 1), [setCount, count])
    const decrement = useCallback(() => setCount(count - 1), [count])
    
    ✅ BETTER
    const decrement = useCallback(() => setCount(count => (count - 1)), [])
    ```
    

**💁‍♀️提示：如果您`useMemo`或`useCallback`没有依赖项，则您可能使用错误。**

- 查看示例
    
    ```
    ❌ Not-so-good
    const MyComponent = () => {
       const functionToCall = useCallback(x: string => `Hello ${x}!`,[])
       const iAmAConstant = useMemo(() => { return {x: 5, y: 2} }, [])
       /* I will use functionToCall and iAmAConstant */
    }
           
    ✅ BETTER 
    const I_AM_A_CONSTANT =  { x: 5, y: 2 }
    const functionToCall = (x: string) => `Hello ${x}!`
    const MyComponent = () => {
       /* I will use functionToCall and I_AM_A_CONSTANT */
    }
    ```
    

**💁‍♀️ 提示：用钩子包装你的自定义上下文会创建一个更好看的 API**

它不仅看起来更好，而且您还只需导入一件事而不是两件事。

- 查看示例
    
    ❌ Not-so-good
    
    ```
    // you need to import two things every time 
    import { useContext } from "react"
    import { SomethingContext } from "some-context-package"
    
    function App() {
      const something = useContext(SomethingContext) // looks okay, but could look better
      // blah
    }
    ```
    
    ✅ Better
    
    ```
    // on one file you declare this hook
    function useSomething() {
      const context = useContext(SomethingContext)
      if (context === undefined) {
        throw new Error('useSomething must be used within a SomethingProvider')
      }
      return context
    }
      
    // you only need to import one thing each time
    import { useSomething } from "some-context-package"
    
    function App() {
      const something = useSomething() // looks better
      // blah
    }
    ```
    

[编写 API 很难](http://sweng.the-davies.net/Home/rustys-api-design-manifesto)。`[README 驱动开发](https://tom.preston-werner.com/2010/08/23/readme-driven-development.html)`是一种有助于设计更好 API 的有用技术。我并不是说我们应该如宗教般地使用[RDD](https://rathes.me/blog/en/readme-driven-development/)，只是说它背后的想法很棒。我发现，在实现组件之前， 先编写API（组件如何使用），会比不这样做， 通常会创建一个更好设计的组件

## 🧘 2. 为幸福而设计

> “任何傻瓜都可以编写计算机可以理解的代码。而优秀的程序员编写人类可以理解的代码。” - Martin Fowler
> 

> “阅读和写作的时间比例远远超过 10 比 1。我们不断阅读旧代码，作为编写新代码努力的一部分。所以如果你想快点，如果你想快点完成，如果你希望您的代码易于编写，使其易于阅读。” ——Robert C. Martin（不是说我同意他的政治观点）
> 

**TL;DR**

1. 💖 通过删除冗余状态来避免状态管理的复杂性
2. 💖 传递香蕉，而不是拿着香蕉的大猩猩和整个丛林（更倾向传递原始类型作为了props）
3. 💖 保持你的组件小而简单——单一职责原则！
4. 💖 复制比错误的抽象要容易的得多（避免过早/不适当的抽象）
5. 使用组合（[Michael Jackson](https://www.youtube.com/watch?v=3XaXKiXtNjw)）来避免props透传。`Context`不是每个状态共享问题的唯一解决方案
6. 将巨型`useEffect`拆分为更小的、独立的部分 （[KCD：关于 useEffect 的神话](https://epicreact.dev/myths-about-useeffect)）
7. 将逻辑提取到hooks和辅助函数中
8. 要拆分一个大组件，拥有`logical`和`presentational`组件可能是个好主意（但不一定，请使用您的最佳判断）
9. 更喜欢将原始类型作为`useCallback` ,`useMemo`以及`useEffect`的依赖
10. 不要给 `useCallback`, `useMemo`, and `useEffect`太多的依赖
11. 为简单起见， 如果state的某些值依赖于state和先前state的其他值， 不要使用多个`useState`，而是考虑使用`useReducer`
12. `Context`不必是您的整个应用程序全局变量。把`Context`放在组件树中尽可能低的位置。这与变量、注释、状态（以及一般代码）的就近原则的方式一样。

### 2.1 💖 删除冗余状态来避免状态管理的复杂性

当您有冗余状态时，某些状态可能会不同步；考虑到复杂的交互序列，您可能会忘记更新它们。除了避免同步错误之外，您还会注意到，它也更容易理解并且需要更少的代码。另请参阅：[KCD：不同步状态。派生它！](https://kentcdodds.com/blog/dont-sync-state-derive-it),[井字游戏](https://epic-react-exercises.vercel.app/react/hooks/1)

### 🙈 示例 1

- 查看业务需求/问题陈述
    
    您的任务是显示直角三角形的属性
    
    - 三边中每一边的长度
    - 周长
    - 面积
    
    三角形是一个具有两个数字的对象`{a: number, b: number}`，应该从 API 中获取。这两个数字代表直角三角形的两条短边。
    
- ❌ 查看不太好的解决方案
    
    ```jsx
    const TriangleInfo = () => {
      const [triangleInfo, setTriangleInfo] = useState<{a: number, b: number} | null>(null)
      const [hypotenuse, setHypotenuse] = useState<number | null>(null)
      const [perimeter, setPerimeter] = useState<number | null>(null)
      const [areas, setArea] = useState<number | null>(null)
    
      useEffect(() => {
        fetchTriangle().then(t => setTriangleInfo(t))
      }, [])
    
      useEffect(() => {
        if(!triangleInfo) {
          return
        }
        
        const { a, b } = triangleInfo
        const h = computeHypotenuse(a, b)
        setHypotenuse(h)
        const newArea = computeArea(a, b)
        setArea(newArea)
        const p = computePerimeter(a, b, h)
        setPerimeter(p)
    
      }, [triangleInfo])
    
      if (!triangleInfo) {
        return null
      }
    
      /*** show info here ****/
    }
    ```
    
- ✅ View “better” solution
    
    ```jsx
    const TriangleInfo = () => {
      const [triangleInfo, setTriangleInfo] = useState<{
        a: number;
        b: number;
      } | null>(null)
    
      useEffect(() => {
        fetchTriangle().then((r) => setTriangleInfo(r))
      }, []);
    
      if (!triangleInfo) {
        return
      }
    
      const { a, b } = triangeInfo
      const area = computeArea(a, b)
      const hypotenuse = computeHypotenuse(a, b)
      const perimeter = computePerimeter(a, b, hypotenuse)
     
      /*** show info here ****/
    };
    ```
    

### 🙈 示例 2

- 📝🖊️ 查看业务需求/问题陈述
    
    假设您被分配设计一个组件，该组件：
    
    1. 从 API 中获取一个唯一点list
    2. 包括一个按钮， 用`x` 或者`y`来排序（升序）
    3. 包括一个按钮来改变`maxDistance`（每次增加10，初始值应该是100）
    4. 只显示离`(0, 0)`原点不超过`maxDistance`的点
    5. 假设列表只有 100 个项目（意味着您无需担心优化）。如果您正在处理大量项目，您可以使用`useMemo`
- ❌ View a not-so-good Solution
    
    ```jsx
    type SortBy = 'x' | 'y'
    const toggle = (current: SortBy): SortBy => current === 'x' ? : 'y' : 'x'
    
    const Points = () => {
      const [points, setPoints] = useState<{x: number, y: number}[]>([])
      const [filteredPoints, setFilteredPoints] = useState<{x: number, y: number}[]>([])
      const [sortedPoints, setSortedPoints] = useState<{x: number, y: number}[]>([])
      const [maxDistance, setMaxDistance] = useState<number>(100)
      const [sortBy, setSortBy] = useState<SortBy>('x')
      
      useEffect(() => {
        fetchPoints().then(r => setPoints(r))
      }, [])
      
      useEffect(() => {
        const sorted = sortPoints(points, sortBy)
        setSortedPoints(sorted)
      }, [sortBy, points])
    
      useEffect(() => {
        const filtered = sortedPoints.filter(p => getDistance(p.x, p.y) < maxDistance)
        setFilteredPoints(filtered)
      }, [sortedPoints, maxDistance])
    
      const otherSortBy = toggle(sortBy)
      const pointToDisplay = filteredPoints.map(
        p => <li key={`${p.x}|{p.y}`}>({p.x}, {p.y})</li>
      )
    
      return (
        <>
          <button onClick={() => setSortBy(otherSortBy)}>
            Sort by: {otherSortBy}
          <button>
          <button onClick={() => setMaxDistance(maxDistance + 10)}>
            Increase max distance
          <button>
          Showing only points that are less than {maxDistance} units away from origin (0, 0)
          Currently sorted by: '{sortBy}' (ascending)
          <ol>{pointToDisplay}</ol>
        </>
      )
    }
    ```
    
- ✅ View a “better” Solution
    
    ```jsx
    // NOTE: You can also use useReducer instead
    type SortBy = 'x' | 'y'
    const toggle = (current: SortBy): SortBy => current === 'x' ? : 'y' : 'x'
    
    const Points = () => {
      const [points, setPoints] = useState<{x: number, y: number}[]>([])
      const [maxDistance, setMaxDistance] = useState<number>(100)
      const [sortBy, setSortBy] = useState<SortBy>('x')
    
      useEffect(() => {
        fetchPoints().then(r => setPoints(r))
      }, [])
      
    
      const otherSortBy = toggle(sortBy)
      const filtedPoints = points.filter(p => getDistance(p.x, p.y) < maxDistance)
      const pointToDisplay = sortPoints(filteredPoints, sortBy).map(
        p => <li key={`${p.x}|{p.y}`}>({p.x}, {p.y})</li>
      )
    
      return (
        <>
          <button onClick={() => setSortBy(otherSortBy)}>
            Sort by: {otherSortBy} <button>
          <button onClick={() => setMaxDistance(maxDistance + 10)}>
            Increase max distance
          <button>
          Showing only points that are less than {maxDistance} units away from origin (0, 0)
          Currently sorted by: '{sortBy}' (ascending)
          <ol>{pointToDisplay}</ol>
        </>
      )
    }
    ```
    

### 💖 2.2 传递香蕉，而不是拿着香蕉的大猩猩和整个丛林

> 你想要一根香蕉，但你得到的是一只拿着香蕉的大猩猩和整个丛林。 - Joe Armstrong
> 

为了避免掉入这个陷阱，传递原始类型（boolean，string，number等）作为props是个好主意。（如果你想React.memo用于优化，传递原始类型也是一个好主意）

> 一个组件应该只知道完成它的工作必要信息，仅此而已。尽可能地，组件应该能够在不知道其他组件是什么以及它们做什么的情况下， 与他们共同使用。
> 

当我们这样做时，组件会更加松耦合，两个组件之间的依赖程度会更低。在不会影响其他组件， 松耦合使更改、更换或移除组件更容易。[stackoverflow:2832017](https://stackoverflow.com/questions/2832017/what-is-the-difference-between-loose-coupling-and-tight-coupling-in-the-object-o)

🙈 Example

- 📝🖊️ 查看业务需求/问题陈述
    
    创建一个 MemberCard组件， 显示两个组件：Summary和SeeMore。MemberCard组件在接受一个 id 作为 prop 。MemberCard使用 useMember， 他接受id并返回相应的会员信息。
    
    ```tsx
    type Member = {
      id: string
      firstName: string
      lastName: string
      title: string
      imgUrl: string
      webUrl: string
      age: number
      bio: string
      /****** 100 more fields ******/
    }
    ```
    
    SeeMore组件显示会员的年龄和性别。还有一个按钮，切换年龄和性别的显示和隐藏。
    
    Summary组件显示会员的照片. 它还显示他的title,firstName和lastName（例如Mr. Vincenzo Cassano）。单击会员的名称，会跳转对会员的个人站点。该Summary组件还可以具有其他功能。（例如，每当单击此组件时， 字体、图像大小和背景颜色都会随机更改，为简洁起见，我们将其称为“随机样式功能”）
    
- ❌ View a not-so-good solution
    
    ```
    
    const Summary = ({ member } : { member: Member }) => {
      /*** include "the random styling feature" ***/
      return (
        <>
          <img src={member.imgUrl} />
          <a href={member.webUrl} >
            {member.title}. {member.firstName} {member.lastName}
          </a>
        </>
      )
    }
    
    const SeeMore = ({ member }: { member: Member }) => {
      const [seeMore, setSeeMore] = useState<boolean>(false)
      return (
        <>
          <button onClick={() => setSeeMore(!seeMore)}>
            See {seeMore ? "less" : "more"}
          </button>
          {seeMore && <>AGE: {member.age} | BIO: {member.bio}</>}
        </>
      )
    }
    
    const MemberCard = ({ id }: { id: string })) => {
      const member = useMember(id)
      return <><Summary member={member} /><SeeMore member={member} /></>
    }
    
    ```
    
- ✅ View a “better” solution
    
    ```
    
    const Summary = ({ imgUrl, webUrl, header }: { imgUrl: string, webUrl: string, header: string }) => {
      /*** include "the random styling feature" ***/
      return (
        <>
          <img src={imgUrl} />
          <a href={webUrl}>{header}</a>
        </>
      )
    }
    
    const SeeMore = ({ componentToShow }: { componentToShow: ReactNode }) => {
      const [seeMore, setSeeMore] = useState<boolean>(false)
      return (
        <>
          <button onClick={() => setSeeMore(!seeMore)}>
            See {seeMore ? "less" : "more"}
          </button>
          {seeMore && <>{componentToShow}</>}
        </>
      )
    }
    
    const MemberCard = ({ id }: { id: string }) => {
      const { title, firstName, lastName, webUrl, imgUrl, age, bio } = useMember(id)
      const header = `${title}. ${firstName} ${lastName}`
      return (
        <>
          <Summary {...{ imgUrl, webUrl, header }} />
          <SeeMore componentToShow={<>AGE: {age} | BIO: {bio}</>} />
        </>
      )
    }
    
    ```
    

注意在✅ “better” solution"，SeeMore 和 Summary组件， 不仅通过Member使用。它可能会被其他对象使用，例如CurrentUser, Pet, Post… 任何需要这些特定功能的东西。

### 💖 2.3 保持你的组件小而简单

**什么是单一责任原则？**

> 一个组件应该只有一项工作。它应该做最小的有用的事情。它只有实现其目标责任。
> 

一个有很多功能的组件， 是很难被重复利用的。如果你想重用部分而不是全部功能，它几乎不可能仅提供你需要的功能。 最有可能是与其他的代码纠缠。 一个组件，只做一件事情，并且与应用的其他功能隔离，可以让你不用考虑后果的改变，不用通过复制来实现复用。

**如何知道您的组件是否具有单一职责？**

> 尝试用一句话描述该组件。如果它只负责一件事，那么描述起来应该很简单。如果它使用“and”或“or”这个词，那么你的组件很可能没有通过这个测试。
> 

检查组件的状态、它消耗的 props 和 hooks，以及组件内部声明的变量和方法（不应该太多）。问问你自己：这些东西真的一起工作来实现组件的目的吗？如果其中一些没有，请考虑将它们移到其他地方或将您的大组件分解为较小的组件。

（以上段落基于我 2015 年的文章：[我作为非 Ruby 程序员从 Sandi Metz 的书中学到的三件事](https://medium.com/@mithi/review-sandi-metz-s-poodr-ch-1-4-wip-d4daac417665)）

🙈 Example

- 📝🖊️ 查看业务需求/问题陈述
    
    要求是显示特殊类型的按钮，您可以单击以购买特定类别的商品。例如，用户可以选择包、椅子和食物。
    
    - 每个按钮都会打开一个modal，您可以使用它来选择和“保存”项目
    - 如果用户“保存”了特定类别中的选定项目，则该类别被称为“已预订”
    - 如果已预订，该按钮将有一个复选标记
    - 即使该类别已被预订，您也应该能够编辑您的预订（添加或删除项目）
    - 如果用户将鼠标悬停在按钮上，它也应该显示WavingHand组件
    - 当没有该特定类别的项目可用时，也应禁用按钮
    - 当用户将鼠标悬停在禁用的按钮上时，工具提示应显示“不可用”
    - 如果该类别没有可用的项目，则按钮的背景应为 grey
    - 如果类别已预订，则按钮的背景应为 green
    - 如果该类别有可用项目且未预订，则按钮的背景应为 red
    - 对于每个类别，它对应的按钮都有一个唯一的标签和图标
- ❌ View a not-so-good solution
    
    ```
    type ShopCategoryTileProps = {
      isBooked: boolean
      icon: ReactNode
      label: string
      componentInsideModal?: ReactNode
      items?: {name: string, quantity: number}[]
    }
    
    const ShopCategoryTile = ({
      icon,
      label,
      items
      componentInsideModal,
    }: ShopCategoryTileProps ) => {
      const [openDialog, setOpenDialog] = useState(false)
      const [hover, setHover] = useState(false)
      const disabled = !items || items.length  === 0
      return (
        <>
          <Tooltip title="Not Available" show={disabled}>
            <StyledButton
              className={disabled ? "grey" : isBooked ? "green" : "red" }
              disabled={disabled}
              onClick={() => disabled ? null : setOpenDialog(true) }
              onMouseEnter={() => disabled ? null : setHover(true)}
              onMouseLeave={() => disabled ? null : setHover(false)}
            >
              {icon}
              <StyledLabel>{label}<StyledLabel/>
              {!disabled && isBooked && <FaCheckCircle/>}
              {!disabled && hover && <WavingHand />}
            </StyledButton>
          </Tooltip>
          {componentInsideModal &&
            <Dialog open={openDialog} onClose={() => setOpenDialog(false)}>
              {componentInsideModal}
            </Dialog>
          }
        </>
      )
    }
    
    ```
    
- ✅ View a “better” solution
    
    ```
    // split into two smaller components!
    
    const DisabledShopCategoryTile = ({ icon, label }: { icon: ReactNode, label: string }) => {
      return (
        <Tooltip title="Not available">
          <StyledButton disabled={true} className="grey">
            {icon}
            <StyledLabel>{label}<StyledLabel/>
          </Button>
        </Tooltip>
      )
    }
    
    type ShopCategoryTileProps = {
      icon: ReactNode
      label: string
      isBooked: boolean
      componentInsideModal: ReactNode
    }
    
    const ShopCategoryTile = ({
      icon,
      label,
      isBooked,
      componentInsideModal,
    }: ShopCategoryTileProps ) => {
      const [openDialog, setOpenDialog] = useState(false)
      const [hover, setHover] = useState(false)
    
      return (
        <>
          <StyledButton
            disabled={false}
            className={isBooked ? "green" : "red"}
            onClick={() => setOpenDialog(true) }
            onMouseEnter={() => setHover(true)}
            onMouseLeave={() => setHover(false)}
          >
            {icon}
            <StyledLabel>{label}<StyledLabel/>
            {isBooked && <FaCheckCircle/>}
            {hover && <WavingHand />}
          </StyledButton>
          {openDialog &&
            <Dialog onClose={() => setOpenDialog(false)}>
              {componentInsideModal}
            </Dialog>
          }}
        </>
      )
    }
    
    ```
    

注意：上面的示例是我在生产中实际看到的组件的简化版本

- ❌ View a not-so-good solution
    
    ```
    const ShopCategoryTile = ({
      item,
      offers,
    }: {
      item: ItemMap;
      offers?: Offer;
    }) => {
      const dispatch = useDispatch();
      const location = useLocation();
      const history = useHistory();
      const { items } = useContext(OrderingFormContext)
      const [openDialog, setOpenDialog] = useState(false)
      const [hover, setHover] = useState(false)
      const isBooked =
        !item.disabled && !!items?.some((a: Item) => a.itemGroup === item.group)
      const isDisabled = item.disabled || !offers
      const RenderComponent = item.component
    
      useEffect(() => {
        if (openDialog && !location.pathname.includes("item")) {
          setOpenDialog(false)
        }
      }, [location.pathname]);
      const handleClose = useCallback(() => {
        setOpenDialog(false)
        history.goBack()
      }, [])
    
      return (
        <GridStyled
          xs={6}
          sm={3}
          md={2}
          item
          booked={isBooked}
          disabled={isDisabled}
        >
          <Tooltip
            title="Not available"
            placement="top"
            disableFocusListener={!isDisabled}
            disableHoverListener={!isDisabled}
            disableTouchListener={!isDisabled}
          >
            <PaperStyled
              disabled={isDisabled}
              elevation={isDisabled ? 0 : hover ? 6 : 2}
            >
              <Wrapper
                onClick={() => {
                  if (isDisabled) {
                    return;
                  }
                  dispatch(push(ORDER__PATH));
                  setOpenDialog(true);
                }}
                disabled={isDisabled}
                onMouseEnter={() => !isDisabled && setHover(true)}
                onMouseLeave={() => !isDisabled && setHover(false)}
              >
                {item.icon}
                <Typography variant="button">{item.label}</Typography>
                <CheckIconWrapper>
                  {isBooked && <FaCheckCircle size="26" />}
                </CheckIconWrapper>
              </Wrapper>
            </PaperStyled>
          </Tooltip>
          <Dialog fullScreen open={openDialog} onClose={handleClose}>
            {RenderComponent && (
              <RenderComponent item={item} offer={offers} onClose={handleClose} />
            )}
          </Dialog>
        </GridStyled>
      )
    }
    
    ```
    

### 💖 2.4 复制比错误的抽象便宜得多

避免过早/不恰当的概括。如果您对简单功能的实现需要大量开销，请考虑其他选项。我强烈推荐阅读[Sandi Metz：错误的抽象](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)。

另外参阅： [KCD: AHA Programming](https://kentcdodds.com/blog/aha-programming), [C2 Wiki: Contrived Interfaces](https://wiki.c2.com/?ContrivedInterfaces)/[The Expensive Setup Smell](https://wiki.c2.com/?ExpensiveSetUpSmell)/[Premature Generalization](https://wiki.c2.com/?PrematureGeneralization)

## **🧘 3. 性能提示**

> 过早的优化是万恶之源——Tony Hoare
> 

> 一次准确的测量胜过一千个专家的意见。- Grace Hopper
> 

**TL;DR**

1. **如果你认为它很慢，用一个基准来证明它。** *“面对模棱两可，拒绝猜测的诱惑。”* [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi)（Chrome 扩展）的分析器是你的朋友！
2. 只在昂贵的计算使用`useMemo`
3. 使用`React.memo`, `useMemo`, and `useCallback`为了减少重新渲染，它们不应该有很多依赖项，并且依赖项应该主要是原始类型
4. 确保您的`React.memo`, `useCallback` or `useMemo`正在做您认为正在做的事情（它真的阻止了重新渲染吗？）
5. 每次眨眼时停止打自己（在修复重渲染之前，修复缓慢的渲染）
6. 将你的state尽可能靠近它正在使用的地方，不仅会让你的代码更容易阅读，而且还会让你的应用程序更快（状态托管）
7. `Context`应该在逻辑上分开，不要在一个 context provider 添加许多值。如果您的上下文的任何值发生更改，则所有使用该 context 的组件也会重新渲染，即使这些组件不使用实际更改值。
8. 您可以通过分离`state`和`dispatch` 来优化`context`
9. 了解术语`[lazy loading](https://nextjs.org/docs/advanced-features/dynamic-import)` 和 `[bundle/code splitting](https://reactjs.org/docs/code-splitting.html)`
10. 将大列表置于窗口中（with `[tannerlinsley/react-virtual](https://github.com/tannerlinsley/react-virtual)` or similar）
11. 较小的包大小通常也意味着更快的应用程序。您可以使用诸如`[source-map-explorer](https://create-react-app.dev/docs/analyzing-the-bundle-size/)` 或者r `[@next/bundle-analyzer](https://www.npmjs.com/package/@next/bundle-analyzer)`（用于 NextJS）之类的工具来可视化您生成的代码包。
12. 如果您要为表单使用包，我建议您使用`[react-hook-forms](https://react-hook-form.com/)`. 我认为这是性能和开发者体验的完美平衡。
- 查看其他KCD文章
    - [KCD：状态托管将使您的 React 应用程序更快](https://kentcdodds.com/blog/state-colocation-will-make-your-react-app-faster)
    - [KCD：何时`useMemo`以及`useCallback`](https://kentcdodds.com/blog/usememo-and-usecallback)
    - [KCD：在修复重新渲染之前修复缓慢的渲染](https://kentcdodds.com/blog/fix-the-slow-render-before-you-fix-the-re-render)
    - [KCD：针对性能分析 React 应用程序](https://kentcdodds.com/blog/profile-a-react-app-for-performance)
    - [KCD：如何优化您的上下文价值](https://kentcdodds.com/blog/how-to-optimize-your-context-value)
    - [KCD：如何有效地使用 React Context](https://kentcdodds.com/blog/how-to-use-react-context-effectively)
    - [KCD：一个让你慢下来的 React 错误](https://epicreact.dev/one-react-mistake-thats-slowing-you-down)
    - [KCD：优化 React 重新渲染的一个简单技巧](https://kentcdodds.com/blog/optimize-react-re-renders)

## **🧘 4. Testing principles**

> 编写测试。不是很多。主要是集成。- Guillermo Rauch列尔莫·劳赫
> 

**TL; D**

1. 您的测试应始终类似于您的软件使用方式
2. 确保你没有测试实现细节——用户不使用、看到甚至不知道的东西
3. 如果你的测试不能让你确信你没有破坏任何东西，那么他们没有完成他们的（唯一的）任务
4. 当您在给定相同用户行为的情况下重构代码时很少需要更改测试时，您就会知道您实施了正确的测试
5. 对于前端，不需要 100% 的代码覆盖率，大约 70% 可能就足够了。测试应该让你更有效率，而不是减慢你的速度。保持测试会减慢你的速度。在某个点之后添加更多测试，您会获得逐渐减少的回报
6. 我喜欢使用[Jest](https://jestjs.io/), [React testing library](https://testing-library.com/docs/react-testing-library/intro/), [Cypress](https://www.cypress.io/), and [Mock service worker](https://github.com/mswjs/msw)