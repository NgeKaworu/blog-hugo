---
date: 2022-08-29T10:11:22+08:00
title: "Gitlab CI/CD 搭建笔记"
draft: false
tags: ["环境搭建"]
keywords:
- "gitlab"
- "gitlab-ci"
- "gitlab-ci.yml"
- "CI/CD"
description : "gitlab自动化构建搭建笔记"
---

最近公司在做gitlab ci/cd，因我早前自建过gogs、jenkins、GitHub-flow、coding ci，所以这块任务就落到我的头上了。装电脑这门手艺我真是从小装到大啊【叉腰】。
言归正传，gitlab的ci/cd相对来说很简单。分两个部分，runner和.gitlab-ci.yml。

## 一、runner
1. 先到在gitlab后台的admin area - settings - runner, 注意右上角详细步骤里的url和token，
2. 找一台可以访问公网且安装了docker的电脑
3. 安装gitlab-runner docker
   ``` bash
    docker run -d --name gitlab-runner --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    --privileged
    gitlab/gitlab-runner:alpine
   ```
4. 注册gitlab-runner
   ```bash
    docker run --rm -it \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:alpine register
   ```
   这里会用到刚才的url和token
5. 回到刚才的页面把刚注册的runner的lock去掉。
6. 写一个.gitlab-ci.yml文件测试一下
   
[runner文档](https://docs.gitlab.com/runner/install/)
<!--more-->

## 二、.gitlab-ci.yml
这个没什么好讲的，官方提供了demo。我这先贴个[文档](https://docs.gitlab.cn/jh/ci/yaml/#%E5%85%B3%E9%94%AE%E5%AD%97)。  
因为我们是基于[ssh](https://docs.gitlab.cn/jh/ci/ssh_keys/)部署的，所以对应的ssh配置也放在这里。
最后，我本来想用rules:variables这个功能判断分支，然后写入不同环境变量，但是它己于13.10废弃。所以还是乖乖遵守单一职责，为每一个job写不同的script吧。