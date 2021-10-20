---
title: "React Docker 开发环境搭建结合vscode dev-container"
date: 2021-10-20T10:38:35+08:00
draft: false
tags: ["环境搭建"]
keywords:
  - "docker"
  - "react"
  - vscode
  - dev-container
description: "React Docker 开发环境搭建结合vscode dev-container"
---

### 前言
> 最近总遇到切分支，改点小问题又切回去；    
> 每次`git stash && git stash pop`，   
> 然后重新起`dev server`，  
> 非常影响心流  
> 恰巧最近在玩`docker`，故想用其配个环境，每个切分支就new一个容器，改完留着也行、prune也行。美滋滋。   
> 期间遇到些问题，抱着“好记性不如烂笔头”的想法，索性记下来以便日后检索，故作文以记之

### 正文
如果还没玩过docker，请先阅读这篇[docker及docker-compose入门][入门]。  
我这里直接分享Dockerfile和docker-compose.yml 文件
**注意区分大小写**
> Dockerfile
```Dockerfile
FROM node:lts-alpine

EXPOSE 8000

RUN mkdir -p /home/node/app && \
    apk add --update --no-cache git openssh

WORKDIR /home/node/app

COPY ./package.json .
RUN npm install

COPY . .

ENV BRANCH = "master"

CMD ["sh", "-c", "git fetch && git checkout $BRANCH && git pull && npm install && npm start"]

```

> docker-compose.yml
```yml
version: '3.8'

services:
  front:
    build:
      context: .
      dockerfile: Dockerfile
    image: node-git:dev
    container_name: ${BRANCH:?err}
    environment:
      BRANCH: ${BRANCH:?err}
    volumes:
      - ~/.ssh:/root/.ssh
    ports:
      - ${PORT:-8005}:8000

```

*注意*
> [docker-compose传参参考资料](https://docs.docker.com/compose/environment-variables/)  
> default values using typical shell syntax:  
>   
> ${VARIABLE:-default} evaluates to default if VARIABLE is unset or empty in the environment.  
> ${VARIABLE-default} evaluates to default only if VARIABLE is unset in the environment.  
> Similarly, the following syntax allows you to specify mandatory variables:  
>   
> ${VARIABLE:?err} exits with an error message containing err if VARIABLE is unset or empty in the environment.  
> ${VARIABLE?err} exits with an error message containing err if VARIABLE is unset in the environment.  
${BRANCH:?err}  的意思是BRANCH这个环境变量必传

> 启动容器
```bash
$ export BRANCH = master
$ export PORT = 8020
$ docker-compose --file docker-compose.yml up -d
```

然后通过vscode 的 [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)插件的`>attach to running container` 进入容器。

最后访问http://localhost:8020查看页面， 完美

[github demo](https://github.com/NgeKaworu/umi-lab)
### 后记
#### Q&A
> Q：webpack4 的 dev-server 改了没有热更  

A：无解，实现机制的问题，建议升webpack5；或者本地拷贝几个备份，维护不同分支

> Q：docker-compose rebuild？  
 
A：命令上加 --build 

#### 参考资料
[官方文档][官方文档]  
[入门][入门]  

[官方文档]: https://docs.docker.com/reference/
[入门]: https://chinese.freecodecamp.org/news/the-docker-handbook/