---
title: 常用的git命令
date: 2019-08-13 02:11:24
tags:
- git
---

##  Abstract
记录日常开发常用的git命令
<!-- more -->
- 从远程拉取分支

    `git chekcout -b dev origin/dev`

- rebase远程最新的dev代码

    `git rebase origin/dev`

- 修改上一次commit，包括文件和commit message

    `git commit --amend `#之后会打开一个vim，修改信息即可

- 查看当前git的配置信息

    `git config user.email`
    `git config user.name`

- 修改信息

    `git config --global user.email [your email address here]`

- 修改分支名字

    `git branch -m [old-name] new-name `#如果在当前就在旧分之，可以省略old-name

- 删除远程分支

    `git push origin --delete <branch-name>`

- 设置本地分支的远程跟踪分支

    `git branch --set-upstream-to=[origin/<branch-name>]`

- 删除`git add`后暂存文件

    `git reset /path/to/file`

- 删除已经`git commit`之后的文件

    `git reset --soft HEAD~1`
    `git reset /path/to/file`
    `rm /path/to/file`
    `git commit`

- 在本地和远程分别建立代码库之后，添加远程库
```bash
    git remote add origin <remote url>
    git push -u origin master # -u 表示当前将origin的master设置为本地分之的跟踪分支
```
- git的密码更换
```bash
    git config --system --unset credential.helper # 清除http的用户名和密码
    git fetch # 随便一个与远程交互命令都可以
    git config credential.helper store # 用户名密码明文存储在～/.git-crendential文件中。http://<username>:<password>@<git的url>
```
- 删除远程地址
```bash
    git remote -v
    # View current remotes
    > origin  https://github.com/OWNER/REPOSITORY.git (fetch)
    > origin  https://github.com/OWNER/REPOSITORY.git (push)
    > destination  https://github.com/FORKER/REPOSITORY.git (fetch)
    > destination  https://github.com/FORKER/REPOSITORY.git (push)
    git remote rm destination
```
- [合并commit](https://segmentfault.com/a/1190000007748862)
1. 挑选commit记录
```
git rebase -i HEAD~3
或者
git rebase -i [commit id] # 这个commit id不参与合并
```
2. 弹出vim窗口,留下的commit不用动,不想要的就加一个*pick改为squash或者s*
3. 保存退出.解决冲突,然后
```
git add .  

git rebase --continue  
```