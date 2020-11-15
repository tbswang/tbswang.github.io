---
title: not-so-fast-wasm-vs-native
date: 2020-11-15 20:19:05
tags:
  - 翻译
---

## 摘要

现在，所有主要的Web浏览器都支持WebAssembly，这是一种低级字节码，可以由C和C++代码的编译生成。WebAssembly的一个关键目标是与本机原生代码实现性能均等。之前的工作报告显示他们是几乎是等价的，许多编译到WebAssembly的应用程序的运行速度比原始代码平均慢10％。但是，这些评估仅限于一组科学内核，每个内核包含大约100行代码。无法运行大型的应用程序，将代码编译为WebAssembly是难题的一部分,另外标准的Unix API在Web浏览器环境中不可用。为了应对这一挑战，我们构建了BROWSIX-WASM，这是对[BROWSIX][29]的重要扩展，这是第一次, 使在浏览器内直接运行的WebAssembly编译的Unix应用程序。 然后，我们使用BROWSIX-WASM对WebAssemblyvs的性能进行首次大规模评估。在SPEC CPU基准测试套件中，我们发现了巨大的性能差距：编译为WebAssembly的应用程序的运行速度平均降低了45％（Firefox）至55％（Chrome），峰值速度降低了2.08×（Firefox）和2.5×（Chrome ）。我们确定了造成这种性能下降的原因，其中一些是由于缺少优化和代码生成问题而引起的，而另一些是由于WebAssembly所固有的。

<!-- more -->

## 简介
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

### 贡献
* **BROWSIX-WASM:** 我们开发了BROWSIX-WASM, BROWSIX的显着扩展和增强，使我们能够将Unix程序编译为Web-Assembly，并在浏览器中运行它们而无需进行任何修改。 除了集成功能扩展之外，BROWSIX-WASM还提供了可大幅提高其性能的性能优化，从而确保CPU密集型应用程序的运行几乎没有BROWSIX-WASM带来的影响。
  
* **BROWSIX-SPEC** 我们开发了BROWSIX-SPEC，这是一种扩展了BROWSIX-WASM的线束，可以自动收集详细的时序和硬件片上性能计数器信息，以便对应用程序性能进行详细测量（第3节）。


## References


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