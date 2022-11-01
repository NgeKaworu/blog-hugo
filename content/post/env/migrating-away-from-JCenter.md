---
date: 2022-11-01T10:01:48+08:00
title: "RN下迁移JCenter的指南"
draft: false
tags: ["环境搭建"]
keywords:
- "JCenter"
- "gradle"
- "android"
- "403"
- "502"
description : "RN下迁移JCenter的指南"
---

``` bash
   > Failed to list versions for xxx.
         > Unable to load Maven meta-data from https://jcenter.bintray.com/xxx.xml.
            > Could not HEAD 'https://jcenter.bintray.com/xxx.xml'.
               > Read timed out

```

作为一个刚接触android（RN）不久的小白，某天跑项目发现，一些依赖下不下来，并出现了上面👆的报错，起初以为是梯子的问题，几经排查却发现。是仓库关服了，卧槽，公共仓库关服了，当时把我惊呆了。这个被关闭的仓库就是JCenter。


<!--more-->

JCenter的镜像仓库对原仓库的拷贝也不是很到位，所以需求找到适合的代替品；而且`node_modules`里也有项目是依赖JCenter的，这就意味着最好是全局修改。  

几经调查，我发现可以用这两个仓库
- gradlePluginPortal()
- mavenCentral()
**替换**
- JCenter()

至于全局替换需要在这个文件里`~/.gradle/init.gradle`（没有就新增），增加以下脚本
```groovy
allprojects{
    repositories {
        all { ArtifactRepository repo ->
            if(repo instanceof MavenArtifactRepository){
                if (repo.url.toString().startsWith('https://jcenter.bintray.com/')) {
                    project.logger.warn "Repository ${repo.url} removed."
                    remove repo
                    mavenCentral()
                    gradlePluginPortal()
                }
            }
        }
    }
}
```

如果你是RN用户，可能要在项目里的`build.gradle`文件里加上，能保证你的RN不用旧版本。
```groovy
allprojects{
    repositories {
        mavenCentral {
            // We don't want to fetch react-native from Maven Central as there are
            // older versions over there.
            content {
                excludeGroup "com.facebook.react"
            }
        }
    }
}
```


**参考链接**
[jitpack](https://www.jitpack.io/) 可以很方便的把git repo转成maven依赖，可以用于查缺补漏
[阿里仓库服务](https://developer.aliyun.com/mvn/guide)