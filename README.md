## 说明
用于保存个人博客.

其中jekyll分支保存了jekyll模板,hexo分支是hexo分支的文件.master分支是github托管时的要求, 博客个静态文件需要放在master分支下面.另外, hexo分支设置为主分支, 执行git pull 命令的时候默认拉取hexo分支.

## 使用
* git clone xxxx.git
* `hexo new draft <文章名字>`, 此时文章在draft目录下,不会发布
* `hexo publish post <文章名字>`, 移动文章到post目录下,会发布.
* 在 source/_post文件夹下面编辑文档
* 执行 `hexo server`, 可以在本地预览效果
  * 预览draft: `hexo s --draft`
* 执行 `hexo generate`,本地生成网页文件.
* 部署:`hexo deploy` 会将生成好的文件自动推送到github的origin master分支
* 最后, 把hexo分支推送到origin hexo 分支: `git push origin hexo`
* 在整个过程中, 都不需要处理master分支.


## 一键发布
运行`./pub.sh`
