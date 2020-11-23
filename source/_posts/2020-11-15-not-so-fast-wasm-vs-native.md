---
title: not-so-fast-wasm-vs-native
date: 2020-11-15 20:19:05
tags:
  - 翻译
---

# 摘要

现在，所有主要的Web浏览器都支持WebAssembly，这是一种低级字节码，可以由C和C++代码的编译生成。WebAssembly的一个关键目标是与本机原生代码实现性能均等。之前的工作报告显示他们是几乎是等价的，许多编译到WebAssembly的应用程序的运行速度比原始代码平均慢10％。但是，这些评估仅限于一组科学内核，每个内核包含大约100行代码。无法运行大型的应用程序，将代码编译为WebAssembly是难题的一部分,另外标准的Unix API在Web浏览器环境中不可用。为了应对这一挑战，我们构建了BROWSIX-WASM，这是对[BROWSIX][29]的重要扩展，这是第一次, 使在浏览器内直接运行的WebAssembly编译的Unix应用程序。 然后，我们使用BROWSIX-WASM对WebAssemblyvs的性能进行首次大规模评估。在SPEC CPU基准测试套件中，我们发现了巨大的性能差距：编译为WebAssembly的应用程序的运行速度平均降低了45％（Firefox）至55％（Chrome），峰值速度降低了2.08×（Firefox）和2.5×（Chrome ）。我们确定了造成这种性能下降的原因，其中一些是由于缺少优化和代码生成问题而引起的，而另一些是由于WebAssembly所固有的。

<!-- more -->

![图片1](./fig1.png)
# 简介
Web浏览器已成为用户面对的应用程序的最受欢迎的平台，并且直到现在，JavaScript还是所有主流Web浏览器支持的唯一编程语言。 
除了从编程语言设计的角度来看的许多怪异和陷阱之外，JavaScript众所周知也很难有效地进行[编译][12,17,30,31]。 用JavaScript编写或编译的应用程序通常比其本机对应程序运行得慢得多。 为了解决这种情况，一群浏览器供应商联合开发了WebAssembly。

WebAssembly是不需要垃圾回收机制的静态类型语言，并且支持与JavaScript的互操作性。 WebAssembly的目标是成为可以在浏览器中运行的通用编译器目标[15,16,18]。为此，WebAssembly旨在快速编译和运行，可跨浏览器和体系结构移植, 保证类型和内存安全。 之前讨论到,在浏览器中以原生代码速度运行的尝试,[4,13,14,38]并不能满足所有这些标准。

现在，所有主要浏览器都支持WebAssembly [8,34]，并且已被多种编程语言迅速支持。 现在有针对WebAssembly的C，C ++，C＃，Go和Rust [1,2,24,39]后端。 目前，一个策展人包括十多个其他人(什么鬼)[10]。 如今，使用这些语言编写的代码只要编译为WebAssembly，就可以在任何现代的浏览器沙箱中安全地执行。

WebAssembly的主要目标是比JavaScript更快。 例如，介绍Web-Assembly的论文[18]表明，将C程序编译为WebAssembly而不是JavaScript（asm.js）时，它在Google Chrome浏览器中的运行速度提高了34％。 该论文还表明，WebAssembly的性能与原生代码相比也具有竞争力：在评估的24个基准测试中，使用WebAssembly的七个基准的运行时间在本机代码的10％以内，并且几乎所有这些测试都低于本机代码的2倍。图1显示了WebAssembly实现相对于这些基准的不断改进。 在2017年，只有七个基准测试的性能是原生指标的1.1倍以内，但到2019年，这个数字增加到了13个。

**测试WebAssembly的挑战** 前面提到的24个基准测试套件是PolybenchCbenchmark套件[5]，该套件用于测量编译器中多面体循环优化的效果。 该套件中的所有基准都是小型科学计算内核，而不是完整的应用程序（例如，矩阵乘法和LU分解）； 每个大约100LOC。 尽管WebAssembly旨在加速Web上的科学内核，但它也明确地设计用于更丰富的完整应用程序集。

WebAssembly文档重点介绍了几种预期的用例[7]，包括科学内核，图像编辑，视频编辑，图像识别，科学可视化，模拟，编程语言解释器，虚拟机和POSIX应用程序。 因此，WebAssembly在PolybenchC中的科学内核上的出色性能并不意味着它在使用其他类型的应用程序时也能很好地运行。

我们认为，对Web-Assembly的更全面评估应该依赖于已建立的大型程序基准套件，例如SPEC CPU基准套件。事实上，SPEC CPU 2006和2017基准套件包括以下几个应用程序： WebAssembly的八个基准测试是科学应用程序（例如433.milc，444.namd，447.dealII，450.soplex和470.lbm），两个基准测试涉及图像和视频处理（464.h264refand453.povray）， 并且所有基准测试都是POSIX应用程序。


不幸的是，不可能简单地将复杂的本机程序编译为WebAssembly。 本机程序（包括SPEC CPU套件中的程序）需要操作系统服务，例如文件系统，同步I/O和进程，而WebAssembly和浏览器不提供这些服务。 SPEC基准测试工具本身需要文件系统，外壳程序，产生进程的能力以及其他Unix设施。 为了克服将本机应用程序移植到Web时的这些限制，许多程序员都在艰苦地修改其程序，以避免或模仿丢失的操作系统服务。 修改众所周知的基准，例如SPEC CPU，不仅会很耗时，而且会严重影响有效性。

今天运行这些应用程序的标准方法是使用Emscripten，这是一个用于将C和C ++编译为WebAssembly的工具链。 不幸的是，Emscripten仅支持最简单的系统调用，而无法扩展到大型应用程序。 例如，要使应用程序能够使用同步I/O，默认的EmscriptenMEMFS文件系统会在程序开始执行之前将整个文件系统映像加载到内存中。 对于SPEC，这些文件太大而无法放入内存。

一种有前途的替代方法是使用BROWSIX，该框架可在浏览器中运行未修改的，功能齐全的Unix应用程序[28,29]。BROWSIX在JavaScript中实现了与Unix兼容的内核，并完全支持进程，文件，管道，同步I / O和其他Unix功能。 而且，它包括一个C / C ++编译器（基于Emscripten），它允许程序在浏览器中运行而无需修改。 BROWSIX案例研究包括复杂的应用程序，例如LATEX，它完全在浏览器中运行，而无需任何源代码修改。

不幸的是，BROWSIX是仅JavaScript的解决方案，因为它是在WebAssembly发布之前构建的。 此外，BROWSIX有高性能开销，这在进行基准测试时将是一个很大的影响因素。使用BROWSIX，很难将性能不佳的基准与BROWSIX引入的性能下降区分开来。

**BROWSIX-WASM:** 我们开发了BROWSIX-WASM, 他是BROWSIX的显着扩展和增强，使我们能够将Unix程序编译为Web-Assembly，并在浏览器中运行它们而无需进行任何修改。 除了集成功能扩展之外，BROWSIX-WASM还提供了可大幅提高其性能的性能优化，从而确保CPU密集型应用程序的运行几乎没有BROWSIX-WASM带来的影响。
  
**BROWSIX-SPEC** 我们开发了BROWSIX-SPEC，这是一个扩展了BROWSIX-WASM的工具，可以自动收集详细的时序和硬件片上性能计数器信息，以便对应用程序性能进行详细测量（第3节）。

**WebAssembly的性能分析**：使用BROWSIX-WASM和BROWSIX-SPEC，我们使用SPEC CPU基准套件（2006年和2017年）进行了Web-Assembly的首次综合性能分析。 该评估证实，WebAssembly的运行速度比JavaScript快（在SPEC CPU上平均快1.3倍）。 但是，与先前的工作相反，我们发现WebAssembly和本机性能之间存在巨大差距：编译为WebAssembly的代码在Chrome中的运行速度平均比本机代码慢1.55倍，在Firefox中运行速度比本机代码慢1.45倍（第4节）。

**根本原因分析和对实施者的建议**：我们借助性能计数器结果进行辩证分析，以找出造成这种性能差距的根本原因。 我们发现以下结果：
1. WebAssembly生成的指令比本地代码需要更多的加载和存储（Chrome中有2.02倍的加载和2.30倍的存储；在Firefox中有1.92倍的加载和2.16倍的存储）。 我们将其归因于减少了寄存器的可用性，次优的寄存器分配器以及无法有效利用更广泛的x86寻址模式。
2. WebAssembly产生的指令具有更多分支，因为WebAssembly需要多次动态安全检查。
3. WebAssembly产生了更多指令，这会导致更多的L1指令高速缓存未命中。我们提供指南，以帮助WebAssembly实现者集中精力进行优化工作，以缩小WebAssembly与本机代码之间的性能差距（第5,6节）。BROWSIX-WASM和BROWSIX-SPEC可在https://browsix.org 获得

# 从BROWSIX到BROWSIX-WASM
BROWSIX[29]在浏览器中模拟Unix内核，并包括一个将本机程序编译为JavaScript的编译器（基于Emscripten [33,39]）。而且,它们允许在C，C++和Go在浏览器中运行，并自由使用操作系统服务，例如管道，进程和文件系统。 但是，BROWSIX有两个必须克服的主要限制。 首先，BROWSIX将本地代码编译为JavaScript，而不是WebAssembly。 其次，BROWSIX内核存在严重的性能问题。 特别是，在BROWSIX中，几个常见的系统调用具有非常高的开销，这使得很难将在BROWSIX中运行的程序的性能与本地运行的程序的性能进行比较。

我们通过构建一个新的浏览器环境来解决这些限制, 叫做BROWSIX-WASM,可以支持webassembly,并且消除Browsix的性能缺陷.

**Emscripten运行时修改** BROWSIX修改Emscripten编译器以允许进程（在WebWorkers中运行）与BROWSIX内核（在页面的主线程上运行）通信。 由于BROWSIX将本机程序编译为JavaScript，因此相对简单：每个进程的内存都是与内核共享的缓冲区（一个共享的arraybuffer），因此系统调用可以直接读写进程内存。但是，这种方法有两个明显的缺点。 首先，它阻止了堆的按需增长；共享内存的大小必须足够大，可以在整个过程中满足应用程序的运行的最大的堆大小。 其次，JavaScript上下文（如主上下文和每个Webworker上下文）对其堆大小有固定的限制，目前在Google Chrome浏览器中约为2.2 GB [6]。此上限对运行多个过程产生了严重限制： 如果每个进程保留500 MB的堆，BROWSIX最多只能运行四个并发进程。更深的问题是WebAssembly内存不能在WebWorkers之间共享，并且不支持Atomic(原子)API，BROWSIX用它来用来等待系统调用。 

BROWSIX-WASM使用不同的方法进行进程内核通信，该方法也比BROWSIX方法更快.BROWSIX-WASM修改Emscripten运行时系统，为与内核共享的每个过程创建一个辅助缓冲区（64MB），但不同于进程内存，该方法也比BROWSIX方法更快。 由于此辅助缓冲区是SharedArray缓冲区，因此BROWSIX-WASM进程和内核可以使用原子API进行通信。当系统调用引用进程堆中的字符串或缓冲区（例如writevorstat）时，其运行时系统会将数据从进程内存复制到共享缓冲区，并向内核发送一条消息，其中包含复制数据在辅助内存中的位置。 类似地，当系统调用将数据写入辅助缓冲区（例如读取）时，其运行时系统会将数据从共享缓冲区复制到指定内存中的进程内存。 此外，如果系统调用在过程存储器中指定了内核要写入（例如，读取）的缓冲区，则运行时在辅助存储器中分配相应的缓冲区，并将其传递给内核。 如果系统调用正在读取或写入大小超过64MB的数据，则BROWSIX-WASM将此调用划分为多个调用，这样每个调用最多只能读取或写入64MB的数据。 这些内存复制操作的成本与系统调用调用的总成本相比是微不足道的，后者涉及在过程和内核JavaScript上下文之间发送消息。 我们在第4.2.1节中显示，BROWSIX-WASM的开销可以忽略不计

**性能优化** 在构建BROWSIX-WASM并进行初步性能评估时，我们在BROWSIX内核的某些部分发现了一些性能问题。 如果不解决这些性能问题，将影响WebAssembly与本机代码之间的性能比较的有效性。 最严重的情况是在BROWSIX / BROWSIX-WASM，BROWSERFS包含的共享文件系统组件中。 最初，在文件的每个追加操作上，BROWSERFS会分配一个更大的新缓冲区，将先前和新内容复制到新缓冲区中。 小附件可能会导致性能大幅下降。 现在，只要缓冲区支持文件需要额外的空间，BROWSERFS就会使缓冲区至少增加4 KB。 仅此一项更改就将BROWSIX中464.h264基准测试的时间从25秒减少到1.5秒以下。 我们进行了一系列改进，以减少整个BROWSIX-WASM的开销。 类似地，即使不是很引人注目的，也进行了改进, 以减少管道内核实现中的分配内存数量和复制次数。

# BROWSIX-SPEC
为了在获得性能测试数据的同时,可靠地执行WebAssembly基准测试，我们开发了BROWSIX-SPEC。 BROWSIX-SPEC与BROWSIX-WASM一起使用可管理生成的浏览器实例，提供基准测试资料（例如，已编译的WebAssembly程序和测试输入），生成性能测试数据并验证基准输出。

我们使用BROWSIX-SPEC运行三个基准套件来评估WebAssembly的性能：SPEC CPU2006，SPEC CPU2017和PolyBenchC。 这些基准测试使用Clang 4.0和WebAssembly通过BROWSIX-WASM编译为本地代码。 我们没有对Chrome或Firefox进行任何修改，并且浏览器在启用其标准沙箱和隔离功能的情况下运行。BROWSIX-WASM构建在标准的web平台,不需要访问主机的资源,相反,基准测试是对BROWSIX-SPEC发起HTTP请求.

## 3.1 BROWSIX-SPEC基准测试执行
图片2显示, BROWSIX-SPEC运行是的主要片段,比如*401.bzip2*. 
首先（1），BROWSIX-SPEC基准测试工具使用WebBrowser自动化工具[Selenium](https://www.seleniumhq.org/)启动新的浏览器实例.
（2）浏览器从基准测试工具通过HTTP加载页面的HTML，执行JS和BROWSIX-WASM内核JS。 
（3）执行的JS初始化BROWSIX-WASM内核并启动执行runspecshell脚本的BROWSIX-WASM进程（图2中未显示）。runspecin生成标准规范调用（未显示），该规范是从SPEC2006中提供的C源代码编译而成的。 specinvoke读取BROWSIX-WASM文件系统中的.cmd文件，并使用适当的参数启动401.bzip2。 
（4）在实例化WebAssembly模块之后在调用基准测试的主要功能之前，BROWSIX-WASM用户空间运行时向BROWSIX-SPEC发出了XHR请求，以开始记录性能计数器的统计信息。 
（5）该基准测试程序找到与Web Worker401.bzip2进程相对应的Chrome线程，并将其附加到该进程。 
（6）在基准测试结束时，BROWSIX-WASM用户空间运行时对基准测试工具发送最终的XHR，以结束性能记录过程。 当runspec程序退出时（可能多次调用了测试二进制文件之后），

SPEC归档的控制JS POST（7）一个tar压缩包目录进入BROWSIX-SPEC。 BROWSIX-SPEC收到完整的结果存档后，将结果解压缩到一个临时目录中，并使用SPEC 2006随附的cmptool验证输出。最后，BROWSIX-SPEC杀死浏览器进程并记录基准测试结果。

![图片2:在浏览器中SPEC基准测试的框架.加粗的部分是新的或者大量修改的](./fig2.png)

# 评估
我们使用BROWSIX-WASM和BROWSIX-SPEC的SPEC CPU2006, SPEC CPU2017, and PolyBenchC三个基准来评估WebAssembly的性能.我们使用PolybenchC基准测试，以与原始WebAssembly论文进行比较[18]，但认为这些基准测试并不代表典型的工作负载。 SPEC基准是具有代表性的，通过BROWSIX-WASM成功运行。 我们在具有超线程功能的6核IntelXeon E5-1650 v3 CPU和64 GB的RAM（运行Ubuntu 16.04和Linux内核v4.4.0）上运行所有基准测试。 我们使用两种最先进的浏览器运行所有基准测试：GoogleChrome 74.0和Mozilla Firefox 66.0。 我们使用Clang 4.0将基准编译为远原生代码，并使用BROWSIX-WASM（基于Emscripten withClang 4.0）将基准编译为WebAssembly。每个基准执行了五次。 记录所有运行时间的平均值和标准错误。执行时间是通过程序开始运行的时间差计算的, 例如, 开始时间是webassembly的编译结束开始.

## PolyBenchC Benchmarks
哈斯等[18]使用PolybenchC来对webassembly实现进行基准测试，因为PolybenchC基准测试不会进行系统调用。 正如我们已经论证的那样，PolybenchC基准是小型科学内核，通常用于基准多面体优化技术，并不代表较大的应用程序。 但是，对我们来说，使用BROWSIX-WASM运行PolybenchC仍然很有价值，因为它表明我们使用的基础结构是调用没有任何开销。 图3a显示了在本机运行时BROWSIX-WASM中PolyBenchC基准测试的执行时间。 我们能够从原始WebAssembly论文[18]中复制大部分结果。 我们发现，BROWSIX-WASM的开销非常低：平均为0.2％，最大为1.2％。
![图片3:使用BROWSIX-WASM和BROWSIX-SPEC编译为WebAssembly（在Chromeand Firefox中执行）的PolyBenchC和SPEC CPU基准测试的性能。 SPEC CPU基准测试的总体开销比PolyBenchC套件更高，这表明WebAssembly与本机之间存在明显的性能差距。](./fig3.png)

## SPEC Benchmarks
现在，我们使用SPEC CPU2006和SPEC CPU2017（新的C / C ++基准和速度基准）中的C / C ++基准评估BROWSIX-WASM，它们广泛使用系统调用。 我们排除了不能编译为WebAssembly5或分配的内存超出WebAssembly允许范围的四个数据点。表1显示了在Chrome和Firefox中都使用BROWSIX-WASM运行时以及本机运行时SPEC基准测试的绝对执行时间。
![表格1: SPEC CPU基准测试本机（Clang）和WebAssembly（Chrome和Firefox）的执行时间（共5次）的详细细分； 所有时间都以秒为单位。 对于Chrome浏览器，WebAssembly的平均降低速度为1.53倍，对于Firefox，则为1.54倍。](./table1.png)

![表格2: 针对Clang 4.0和WebAssembly (Chrome)的SPEC CPU基准测试的编译时间(平均5次);时间以秒为单位。](./table2.png)

对于所有基准而言，WebAssembly的性能都比本地性能差，除了429.mcfand433.milc。 在Chrome浏览器中，Web-Assembly的最大开销是原生的2.5倍，并且15个基准测试中有7个的运行时间是本机的1.5倍。 在Firefox中，对于15个基准测试中的7个，WebAssembly的性能是本机的2.08倍，性能是本机的1.5倍。平均而言，WebAssembly比Chrome中的本机慢1.55倍，比Firefox中的慢1.45倍。表格2展示的是编译为SPEC的时间.据我们所知，Fire-fox无法报告WebAssembly的编译时间。）在所有情况下，与执行时间相比，编译时间可以忽略不计。 但是，Clang编译器比WebAssembly编译器低几个数量级。 最后，请注意，Clang从C ++源代码编译基准，而Chrome编译WebAssembly，这是比C ++更简单的格式。

### BROWSIX-WASM开销
非常重要的一件事, 是要排除运行速度是下降是由于BROWSIX-WAS性能不佳的可能。 特别是，BROWSIX-WASM在不修改浏览器的情况下实现了系统调用，而系统调用涉及到复制数据（第2节），这可能会很昂贵。 为了量化BROWSIX-WASM的开销，我们对系统调用进行了分析，以测量在BROWSIX-WASM中花费的所有时间。图4显示了使用SPEC基准测试在Firefox中在BROWSIX-WASM中花费的时间百分比。 对于15个基准中的14个，间接费用不到0.5％。 最大开销为1.2％。 平均而言，BROWSIX-WASM的开销仅为0.2％。 因此，我们得出结论，BROWSIX-WASM的开销可以忽略不计，并且基本上不会影响WebAssembly中执行的程序的性能结果.
![图片4:irefox中为SPEC基准测试而在Firefox中的BROWSIX-WASM调用中花费的时间（％）已编译为WebAssembly.BROWSIX-WASM的平均开销仅为0.2%](./fig4.png)

### WebAssembly 和asm.js比较
WebAssembly原始工作的一个主要说法是，它的运行速度明显快于assm.js。 现在，我们使用SPEC基准测试该声明。 为了进行比较，我们修改了BROWSIX-WASM还支持编译为asasm.js的进程。 替代方法是使用原始的BROWSIX对theasm.js进程进行基准测试。 但是，正如我们前面所讨论的那样，BROWSIX的性能问题可能会威胁到我们结果的有效性。图5显示了使用WebAssembly的SPEC基准测试的加速，相对于同时使用Chrome和Firefox的asm.js的运行时间. WebAssembly在Chrome中比asasm.js快1.54倍，在Firefox中比assm.js快1.39倍.
![图片5: asm.js到Chrome和Firefox WebAssembly的相对时间。 WebAssembly在Chrome中比asasm.js快1.54倍，在Firefox中比assm.js快1.39倍](./fig5.png)

![图片6: sm.js的相对最佳时间与WebAssembly的最佳时间相对。 WebAssembly比asm.js快1.3倍。](fig6.png)

由于Chrome和Firefox的性能差异很大，因此在图6中，我们通过选择性能最佳的WebAssembly浏览器和性能最佳的asm.js浏览器（即，它们可能是不同的浏览器）来显示每个基准测试的加速。 这些结果表明，WebAssembly始终比asm.js表现更好，平均速度提高了1.3倍。 哈斯等[18]还发现，使用PolyBenchC，WebAssembly的平均速度为1.3×overasm.js。


# 例子研究: 矩阵操作
在本节中，我们将使用执行矩阵乘法的C函数来说明WebAssembly与本机代码之间的性能差异，如图7a所示。矩阵作为函数的参数提供，A（NI×NK）和B（NK×NJ）的结果存储在C（NI×NJ）中，其中NI，NK，NJ是程序中定义的常数。
![](fig7.png)

在WebAssembly中，此功能比具有各种矩阵大小的Chrome和Firefox慢2到3.4倍（图8）。 由于WebAssembly不支持矢量化指令，因此我们使用-O2编译了该功能并禁用了自动矢量化。
![](fig8.png)

图7b显示了由clang-4.0为功能生成的本机代码。 按照SystemV AMD64 ABI调用约定[9]中的指定，参数将传递到rdi，rsi和rdx寄存器中的函数。 第2-26行是迭代器inr8d的第一个循环的主体。 第5至21行包含带有inr9d的第二个循环的主体。 第10-16行包含带有迭代器存储的inrcx的第三个循环的主体。 Clang可以通过使用-NJ初始化rcx，在第15行的每次迭代中递增rcx并使用jneto测试状态寄存器的零标志（当rcx变为0时设置为1）来消除内循环中的错误。

图7c显示了Chrome为其WebAssembly编译版本的matmul编写的x86-64代码。 该代码已被稍作修改-生成的代码中的小点已删除，以供演示。 Chrome的调用约定后，函数参数通过intherax，rcx和rdx寄存器传递。 在第1–3行，由于寄存器在第7–9行溢出，寄存器rax，rdx和rcx的内容存储在堆栈中。第7–45行是带有迭代器inedi的第一个循环的主体。 第18–42行包含带有迭代器存储在inr11中的第二个循环的主体。 第27–39行是迭代器存储的ineax的第三个循环的主体。 为了避免由于寄存器在第一个循环的第一次迭代中在第7-9行溢出而导致的内存负载，在第5行产生一个额外的跳转。类似地，分别在第16行和第25行为第二个和第三个循环生成额外的跳转。
> 译注: 这两段把我看蒙了. 汇编都出来了. 都忘干净了.


## 区别
Chrome的JIT本机代码具有更多指令，可以防止寄存器压力增加，并且具有比Clang生成的本机代码更多的分支。

### 增加的代码体积
Chrome生成的代码（图7c）中的指令数为53，其中包括点，而clang生成的代码（图7b）仅包含28条指令。 Chrome的指令选择算法不佳是代码大小增加的原因之一。

此外，Chrome无法利用x86指令的所有可用内存寻址模式。 在图7b中，Clang在第14行使用add指令，以寄存器寻址模式，在同一操作中从内存地址加载和写入内存地址。另一方面, chrome加载ecx, 加到esx,最后存到ecx, 需要三个指令而不是一个.

### 增加的寄存器压力
Clang在图7b中生成的代码不会产生溢出，仅使用10个寄存器。 另一方面，Chrome生成的代码（图7c）使用13个通用寄存器-所有可用的寄存器（r13和r10由V8保留）。 如第5.1.1节所述，避免使用该指令的寄存器寻址模式需要使用一个临时寄存器。 所有这些寄存器效率低下的化合物，在第1–3行向堆栈引入了三个寄存器。 堆栈中存储的值在第7-9行和第18行再次加载到寄存器中。

### 额外的分支
Clang（图7b）通过反转循环计数器（第15行）来生成具有单个分支perloop的代码。 相比之下，Chrome（图7c）生成更直接的代码，这需要在循环开始时有条件地跳转。 此外，Chrome会生成额外的跳转，以避免在循环的第一次迭代中由于寄存器溢出而导致的内存负载。 例如，第5行的跳跃避免了第7-9行的溢出。

# 性能分析
我们使用BROWSIX-SPEC记录了系统上所有受支持的性能计数器的测量结果，这些指标针对编译为WebAssembly并在Chrome和Firefox中执行的SPECCPU基准测试，以及编译为本机代码的SPEC CPU基准测试（第3节）。

表3列出了我们使用的性能计数器,这里，与本地相比，BROWSIX-WASM性能对这些计数器的影响的摘要。 我们使用这些结果来说明WebAssemblyover本机代码的性能开销。 我们的分析表明，第5节中描述的低效率是普遍存在的，并转化为整个SPEC CPU基准测试套件的性能下降。

![](table3.png)


## 增加的寄存器压力
本节重点介绍两个性能计数器，这些计数器显示增加的套准压力的效果。 图9a给出了相对于本机代码中已退休的加载指令的数量，WebAssembly的SPEC基准在Chrome和Firefox中已退休的加载指令的数量。 类似地，图9b显示了已退休的存储指令的数量。请注意，“已退休”指令是一条离开指令流水线的指令，其结果正确且在体系结构状态下可见（即，不是推测性的）。

Chrome生成的代码为2.02 ×淘汰了更多的加载指令，而淘汰了2.30×的存储指令比本地代码多。 由Firefox生成的代码比本机代码淘汰了1.92倍的加载指令，淘汰了2.16倍的存储指令。 这些结果表明，WebAssembly编译的SPEC CPU基准测试受到寄存器压力增加和内存引用增加的困扰。 下面，我们概述了增加套准压力的原因。

### 保留的寄存器
在Chrome中，累积生成三个寄存器溢出，但不使用两个x86-64寄存器：r13和r10（图7c，第7–9行）。这是因为Chrome保留了这两个寄存器。对于JavaScript垃圾收集器，Chrome reserver13指向一个GC数组 随时都有根。 此外，Chrome使用r10和xmm13作为专用的暂存器。类似地，Firefox保留r15作为指向堆开始的指针，而r11和xmm15是JavaScript暂存器。8这些寄存器中的任何一个都不可用于WebAssembly代码。

### 糟糕的寄存器分配
除了可用的寄存器数量减少之外，chrome和Firefox在分配寄存器方面都做得很糟糕.
![图片9:WebAssembly相对于本机代码的处理器性能计数器样本。](fig9.png)
例如，Chrome格式生成的代码会使用12个寄存器，而Clang生成的本机代码仅使用10个寄存器（第5.1.2节）。 在Firefox和Chrome中，增加的注册使用率是由于它们使用了快速但不是特别有效的注册分配器。 Chrome和Firefox都使用线性扫描寄存器分配器[36]，而Clang使用贪婪的图形着色寄存器分配器[3]，该分配器始终生成更好的代码。


### x86寻址模式
x86-64指令集为每个操作数提供了几种寻址模式，包括寄存器模式（其中指令从寄存器中读取数据或将数据写入寄存器）以及内存地址模式（例如寄存器间接或直接偏移地址），其中操作数位于存储器地址中，并且指令可以 从该地址读取或写入。 通过使用后一种模式，代码生成器可以避免不必要的寄存器压力。 但是，Chrome无法利用这些模式。 例如，由Chrome格式生成的代码不会为该指令使用寄存器间接寻址模式（第5.1.2节），这会产生不必要的寄存器压力。

## 额外的分支结构
本节重点介绍两个性能计数器，这些计数器测量执行的分支指令的数量。 图9c显示了Web-Assembly退出的分支指令的数量，相对于本机代码中退出的分支指令的数量。 类似地，图9d显示了退出的条件分支指令的数量。 在Chrome中，分别撤消了1.75倍和1.65倍的无条件和有条件分支指令，而在Firefox中，撤消了1.65倍和1.62倍。 这些结果表明，所有SPEC CPU基准测试都会产生额外的分支，我们在下面解释原因。

### 6.2.1 对循环来说额外的跳跃指令
与withmatmul（第5.1.3节）一样，Chrome会为循环生成不必要的跳转语句，从而比Firefox产生更多的分支指令。

### 为每个函数进行栈溢出检查
WebAssembly程序使用在每次函数调用时都会增加的aglobal变量来跟踪当前堆栈大小。程序员可以为程序定义最大堆栈大小。为了保证程序不会栈溢出,Chrome和Firefox都在每个函数的开头添加了堆栈检查，以检测当前堆栈大小是否小于最大最大堆栈大小。 这些检查包括额外的比较和条件跳转指令，这些指令必须在每个函数调用上执行。

### 函数表格索引检查
WebAssembly动态检查所有间接调用，以确保目标是有效函数，并且该函数的运行时类型与调用地址上指定的类型相同。在WebAssembly模块中，函数表存储函数列表及其类型，Web-Assembly生成的代码使用函数表来实现这些检查。在C / C ++中调用函数指针和虚拟函数时，这些检查是必需的。 这些检查会导致额外的比较和条件跳转指令，这些指令将在每次间接函数调用之前执行。

## 增加代码体积
Chrome和Firefox生成的代码比Clang生成的代码大得多。 我们使用三个性能计数器来衡量此效果。 （i）图9e显示了相对于本机代码中退休的指令数量，基准被编译为WebAssembly并在Chrome和Firefox中执行的基准退休的指令数量。 类似地，图9f显示了编译到WebAssembly的基准测试所花费的CPU周期的相对数量，图10显示了L1指令高速缓存未命中的相对数量。

图9e显示，Chrome比本机代码平均执行多1.80倍的指令，而Firefox比本机代码平均执行多1.75倍的指令。 由于指令选择不当，寄存器分配器性能不佳而产生了更多的寄存器溢出（第6.1节）和额外的分支语句（第6.2节），因此WebAssembly的代码生成量大于本机代码，从而导致执行了更多指令。 执行的指令数量的这种增加导致图10中的L1指令高速缓存未命中率增加。平均而言，Chrome遭受的I-cache丢失率比本机代码高出2.83倍，而Firefox遭受的L1指令缓存未命中率高于本机代码。 更多的未命中意味着需要花费更多的CPU周期来等待指令的提取。

我们注意到一个异常：尽管429.mcf在Chrome中退休的指令比本地代码多1.6倍，在Firefox中退休的指令比本地代码多1.5倍，但它的运行速度比本地代码快。 图3b显示其相对于本机的减慢速度在Chrome中为0.81倍，在Firefox中为0.83倍，此异常的原因直接归因于其L1指令高速缓存未命中的数量较少.429.mcf包含一个主循环并且该循环中的大多数指令都适合 在L1指令缓存中。 同样，433.milc的性能由于较少的L1指令高速缓存未命中而更好。在450.soplex,由于执行了多个虚拟功能，Chrome和Firefox中的L1指令高速缓存未命中的错误比本地错误多4.6倍，从而导致更多的间接函数调用

## 讨论
值得一问的是，这里确定的性能问题是否是根本的。 我们认为，两个已确定的问题不是：也就是说，可以通过改进实现来改善它们。 今天的WebAssembly实现使用的寄存器分配器（第6.1.2节）和代码生成器（第6.2.1节）的性能要比Clang的差。 但是，像Clang这样的脱机编译器可能会花费更多的时间来生成更好的代码，而WebAssembly编译器必须足够快才能在线运行。 因此，其他JIT所采用的解决方案，如进一步优化热代码，很可能适用于此处[19，32]。

我们定位了四个其他问题, 看起来像是webassembly设计的时候限制:堆栈溢出检查（第6.2.2节），间接调用检查（第6.2.3节）和保留的寄存器（第6.1.1节）会增加运行时成本，并导致代码大小增加（第6.3节）。 不幸的是，这些检查对于WebAssembly的安全保证是必需的。 经过重新设计的WebAssembly，具有更丰富的内存和功能指针类型[23]，也许能够在编译时执行其中的某些检查，但是这可能会使生成WebAssembly的编译器的实现复杂化。 最后，浏览器中的Web-Assembly实现必须与高性能JavaScript实现互操作，这可能会施加其自身的约束。 例如，当前的JavaScript实现保留了一些寄存器供自己使用，这增加了WebAssembly的寄存器压力。


# 相关工作
**WebAssembly先驱** 这里尝试了在浏览器中执行本机代码的几种尝试，但是它们都没有满足WebAssembly的所有设计标准。

ActiveX [13]允许网页嵌入签名的x86库，但是这些二进制文件对Windows API的访问不受限制。 相反，WebAssembly模块是沙盒装的。 ActiveX现在已被弃用

Native Client [11,37]（NaCl）向Web应用程序添加了一个模块，其中包含平台特定的机器代码。 NaCl引入了沙盒技术，以接近本机的速度执行特定于平台的机器代码。 由于NaCl依赖于机器代码的静态验证，因此它要求代码生成器遵循某些模式，因此仅支持浏览器中的x86，ARM和MIPS指令集的子集。为解决NaCl固有的可移植性问题，PortableNaCl（PNaCl）[ [14]使用LLVM位码作为二进制格式。但是，PNaCl在压缩性方面没有比NaCl提高，并且仍然暴露了编译器和/或平台特定的细节，例如调用堆栈布局。 两者都已被WebAssembly弃用。

asm.jsis是JavaScript的一个子集，旨在有效地编译为本机代码。asm.js使用强类型来避免JavaScript的动态类型系统。 由于assm.js是JavaScript的子集，因此将所有本机功能（例如64位整数）添加到asm.js时，首先需要扩展JavaScript。与asm.js相比，WebAssembly提供了一些改进：（i）WebAssembly二进制文件由于其轻量级的表示形式而比JavaScript源码紧凑，（ii）WebAssembly更易于验证，（iii）WebAssembly提供形式安全性和隔离性的形式保证，并且（iv）WebAssembly已被证明比assm.js具有更好的性能。

WebAssembly是一个堆栈机，它类似于java虚拟机[21]和通用语言运行时[25]。然而，WebAssembly与这些平台有很大的不同。例如，WebAssembly不支持对象，也不支持非结构化的控制流.

WebAssembly规范定义了其操作语义和类型系统。 使用Isabelle定理证明者对该证明进行了机械化，并且机械化工作发现并解决了规范中的许多问题[35]。 RockSalt [22]是针对NaCl的类似验证工作。 它在Coq中实施NaCl验证工具链，并针对NaCl支持的x86指令的子集模型提供正确性证明

**使用性能计数器对SPEC基准进行分析**一些论文使用性能计数器来分析SPEC基准。 熊猫等。 [26]分析SPECCPU2017基准，应用统计技术确定基准之间的相似性。 Phansalkar等。 对SPEC CPU2006进行类似的研究[27]。 Limaye和Adegija指出了SPEC CPU2006和SPEC CPU2017之间的工作负载差异[20]。




# 结论
本文进行了WebAssembly的首次综合性能分析。 我们开发了BROWSIX-WASM（BROWSIX的重要扩展）和BROWSIX-SPEC（可进行详细性能分析的工具），以便在Chrome和Firefox中以WebAssembly的形式运行SPEC CPU2006和CPU2017基准测试。 我们发现，在SPEC基准测试中，WebAssembly相对于本机的均值降低为Chrome浏览器的1.55倍和Firefox的1.45倍，Chrome的峰值降低为2.5倍，Firefox的峰值降低为2.08倍。 我们找出造成这些性能差距的原因，为将来的优化工作提供可操作的指导。

# References


[1]: Blazor.https://blazor.net/.   [Online; accessed5-January-2019].


[2]: CompilingfromRusttoWebAssembly.https://developer.mozilla.org/en-US/docs/WebAssembly/Rust_to_wasm.[Online;   accessed5-January-2019].

[3]: LLVM Reference Manual.https://llvm.org/docs/CodeGenerator.html.

[4]: NaCl and PNaCl.https://developer.chrome.com/native-client/nacl-and-pnacl. [Online; accessed5-January-2019].

[5]: PolyBenchC:the    polyhedral   benchmark   suite.http://web.cs.ucla.edu/~pouchet/software/polybench/.  [Online; accessed 14-March-2017].

[6]: Raise   Chrome   JS   heap   limit?-   Stack   Over-flow.https://stackoverflow.com/questions/43643406/raise-chrome-js-heap-limit.  [Online;accessed 5-January-2019].

[7]: Use   cases.https://webassembly.org/docs/use-cases/.

[8]: WebAssembly.https://webassembly.org/.   [On-line; accessed 5-January-2019].

[9]: SystemVApplicationBinaryInterfaceAMD64ArchitectureProcessorSupplement.https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf,2013.

[10]: Steve   Akinyemi.A   curated  list  of  languagesthat  compile  directly  to  or have  their VMs  in  Web-Assembly.https://github.com/appcypher/awesome-wasm-langs.   [Online; accessed 5-January-2019].

[11]: Jason Ansel, Petr Marchenko, Úlfar Erlingsson, ElijahTaylor, Brad Chen, Derek L. Schuff, David Sehr, Cliff L.Biffle, and Bennet Yee.  Language-independent Sand-boxing of Just-in-time Compilation and Self-modifyingCode.InProceedings of the 32nd ACM SIGPLANConference on Programming Language Design and Im-plementation, PLDI ’11, pages 355–366. ACM, 2011.

[12]: Michael Bebenita, Florian Brandner, Manuel Fahndrich,Francesco Logozzo, Wolfram Schulte, Nikolai Tillmann,and Herman Venter.  SPUR: A Trace-based JIT Com-piler for CIL.  InProceedings of the ACM InternationalConference on Object Oriented Programming SystemsLanguages and Applications, OOPSLA ’10, pages 708–725. ACM, 2010.

[13]: David A Chappell.Understanding ActiveX and OLE.Microsoft Press, 1996.

[14]: Alan Donovan, Robert Muth, Brad Chen, and DavidSehr.PNaCl:    Portable  Native  Client  Executa-bles.https://css.csail.mit.edu/6.858/2012/readings/pnacl.pdf, 2010.

[15]: Brendan    Eich.From    ASM.JS    to    Web-Assembly.https://brendaneich.com/2015/06/from-asm-js-to-webassembly/, 2015.  [Online;accessed 5-January-2019].

[16]: Eric  Elliott.What  is  WebAssembly?https://tinyurl.com/o5h6daj, 2015.    [Online;  accessed 5-January-2019].

[17]: Andreas Gal, Brendan Eich, Mike Shaver, David An-derson,  David Mandelin,  Mohammad R.  Haghighat,Blake Kaplan, Graydon Hoare, Boris Zbarsky, JasonOrendorff, Jesse Ruderman, Edwin W. Smith, Rick Re-itmaier, Michael Bebenita, Mason Chang, and MichaelFranz.   Trace-based Just-in-time Type Specializationfor Dynamic Languages.   InProceedings of the 30thACM SIGPLAN Conference on Programming LanguageDesign and Implementation, PLDI ’09, pages 465–478.ACM, 2009.

[18]: Andreas Haas,  Andreas Rossberg,  Derek L.   Schuff,Ben L.  Titzer, Michael Holman, Dan Gohman, LukeWagner, Alon Zakai, and JF Bastien.  Bringing the WebUp to Speed with WebAssembly.  InProceedings of the38th ACM SIGPLAN Conference on Programming Lan-guage Design and Implementation, PLDI 2017, pages185–200. ACM, 2017.

[19]: Thomas  Kotzmann,   Christian  Wimmer,   HanspeterMössenböck, Thomas Rodriguez, Kenneth Russell, andDavid Cox.   Design of the Java HotSpot Client Com-piler for Java 6.ACM Trans.  Archit.  Code Optim.,5(1):7:1–7:32, 2008.

[20]: Ankur Limaye and Tosiron Adegbija.  A Workload Char-acterization of the SPEC CPU2017 Benchmark Suite.In2018 IEEE International Symposium on PerformanceAnalysis of Systems and Software (ISPASS), pages 149–158, 2018.

[21]: Tim Lindholm, Frank Yellin, Gilad Bracha, and AlexBuckley.The Java Virtual Machine Specification, JavaSE 8 Edition.  Addison-Wesley Professional, 1st edition,2014.USENIX Association2019 USENIX Annual Technical Conference    119


[22]: Greg  Morrisett,  Gang  Tan,  Joseph  Tassarotti,  Jean-Baptiste Tristan, and Edward Gan.   RockSalt:  Better,Faster, Stronger SFI for the x86.    InProceedings ofthe 33rd ACM SIGPLAN Conference on ProgrammingLanguage Design and Implementation, PLDI ’12, pages395–404. ACM, 2012.

[23]: Greg Morrisett,  David Walker,  Karl Crary,  and NealGlew.  From System F to Typed Assembly Language.ACM Trans.   Program.   Lang.   Syst.,  21(3):527–568,1999.

[24]: Richard Musiol.    A compiler from Go to JavaScriptfor running Go code in a browser.https://github.com/gopherjs/gopherjs, 2016.    [Online;  accessed5-January-2019].

[25]: George C. Necula, Scott McPeak, Shree P. Rahul, andWestley Weimer.CIL:  Intermediate Language andTools for Analysis and Transformation of C Programs.In R. Nigel Horspool, editor,Compiler Construction,pages 213–228. Springer, 2002.

[26]: Reena Panda, Shuang Song, Joseph Dean, and Lizy K.John.  Wait of a Decade: Did SPEC CPU 2017 Broadenthe Performance Horizon?  In2018 IEEE InternationalSymposium on High Performance Computer Architec-ture (HPCA), pages 271–282, 2018.

[27]: Aashish  Phansalkar,  Ajay  Joshi,  and  Lizy  K.   John.Analysis of Redundancy and Application Balance inthe SPEC CPU2006 Benchmark Suite.  InProceedingsof the 34th Annual International Symposium on Com-puter Architecture, ISCA ’07, pages 412–423.  ACM,2007.

[28]: Bobby  Powers,  John  Vilk,  and  Emery  D.Berger.Browsix: Unix in your browser tab.https://browsix.org.

[29]: Bobby  Powers,  John  Vilk,  and  Emery  D.Berger.Browsix:   Bridging  the  Gap  Between  Unix  and  theBrowser.  InProceedings of the Twenty-Second Inter-national Conference on Architectural Support for Pro-gramming Languages and Operating Systems, ASPLOS’17, pages 253–266. ACM, 2017.

[30]: Gregor Richards, Sylvain Lebresne, Brian Burg, andJan Vitek.   An Analysis of the Dynamic Behavior ofJavaScript Programs.  InProceedings of the 31st ACMSIGPLAN Conference on Programming Language De-sign and Implementation, PLDI ’10, pages 1–12. ACM,2010.

[31]: Marija Selakovic and Michael Pradel.    PerformanceIssues and Optimizations in JavaScript: An EmpiricalStudy.  InProceedings of the 38th International Confer-ence on Software Engineering, ICSE ’16, pages 61–72.ACM, 2016.

[32]: Toshio Suganuma, Toshiaki Yasue, Motohiro Kawahito,Hideaki Komatsu, and Toshio Nakatani. A Dynamic Op-timization Framework for a Java Just-in-time Compiler.InProceedings of the 16th ACM SIGPLAN Conferenceon Object-oriented Programming, Systems, Languages,and Applications, OOPSLA ’01, pages 180–195. ACM,2001.

[33]: Luke Wagner. asm.js in Firefox Nightly | Luke Wagner’sBlog.https://blog.mozilla.org/luke/2013/03/21/asm-js-in-firefox-nightly/.[Online;  ac-cessed 21-May-2019].

[34]: Luke   Wagner.A   WebAssembly   Milestone:ExperimentalSupportinMultipleBrowsers.https://hacks.mozilla.org/2016/03/a-webassembly-milestone/,   2016.[Online;accessed 5-January-2019].

[35]: Conrad Watt.Mechanising and Verifying the Web-Assembly Specification.InProceedings  of the  7thACM SIGPLAN International Conference on CertifiedPrograms and Proofs, CPP 2018, pages 53–65. ACM,2018.

[36]: Christian Wimmer and Michael Franz.    Linear ScanRegister Allocation on SSA Form.  InProceedings ofthe 8th Annual IEEE/ACM International Symposium onCode Generation and Optimization, CGO ’10, pages170–179. ACM, 2010.

[37]: Bennet  Yee,  David  Sehr,  Greg  Dardyk,  Brad  Chen,Robert Muth,  Tavis  Ormandy,  Shiki  Okasaka,  NehaNarula, and Nicholas Fullagar.  Native Client: A Sand-box  for  Portable,  Untrusted  x86  Native  Code.InIEEE Symposium on Security and Privacy (Oakland’09),IEEE, 2009.

[38]: Alon Zakai.   asm.js.http://asmjs.org/.   [Online;accessed 5-January-2019].

[39]:  Alon Zakai.  Emscripten: An LLVM-to-JavaScript Com-piler.   InProceedings of the ACM International Con-ference Companion on Object Oriented ProgrammingSystems Languages and Applications Companion, OOP-SLA ’11, pages 301–312. ACM, 2011.