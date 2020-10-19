---
title: "【人月神话】章节7 阅读笔记"
date: 2020-10-19T11:47:43+08:00
draft: false
tags: ["人月神话","阅读笔记"]
---

本章一开头引了巴比塔的故事，我一直很喜欢这个故事，每次都有不同的解读。所以我也引一下：

> 现在整个大地都采用一种语言，只包括为数不多的单词。在一次从东方往西方迁徙的过
> 程中，人们发现了苏美尔地区，并在那里定居下来。接着他们奔走相告说：“来，让我们制
> 造砖块，并把它们烧好。”于是，他们用砖块代替石头，用沥青代替灰泥（建造房屋）。然后，
> 他们又说：“来，让我们建造一座带有高塔的城市，这个塔将高达云宵，也将让我们声名远
> 扬，同时，有了这个城市，我们就可以聚居在这里，再也不会分散在广阔的大地上了。”于
> 是上帝决定下来看看人们建造的城市和高塔，看了以后，他说：“他们只是一个种族，使用
> 一种的语言，如果他们一开始就能建造城市和高塔，那以后就没有什么难得倒他们了。来，
> 让我们下去，在他们的语言里制造些混淆，让他们相互之间不能听懂。”这样，上帝把人们
> 分散到世界各地，于是他们不得不停止建造那座城市。（创世纪，11:1-8）


> Now the whole earth used only one language, with few words. On the occasion of a migration
> from the east, men discovered a plain in the land of Shinar, and settled there. Then they said to one
> another, "Come, let us make bricks, burning them well." So they used bricks for stone, and
> bitumen for mortar. Then they said, "Come, let us build ourselves a city with a tower whose top
> shall reach the heavens (thus making a name for ourselves), so that we may not be scattered all
> over the earth." Then the Lord came down to look at the city and tower which human beings had
> built. The Lord said, "They are just one people and they all have the same language. If this is what
> they can do as a beginning, then nothing that they resolve to do will be impossible for them. Come,
> let us go down, and there make such a babble of their language that they will not understand one
> another's speech." Thus the Lord dispersed them from there all over the earth, so that they had to
> stop building the city. (Book of Genesis, 11:1-8).

<!--more-->

然后阐述了巴别塔失败的两个方面——`交流`，以及交流的结果——`组织`。他们无法相互交谈，从而无法合作。当合作无法进行时，工作陷入了停顿。通过史书的字里行间，我们推测交流的缺乏导致了争辩、沮丧和群体猜忌。很快，部落开始分裂——大家选择了孤立，而不是互相争吵。

**这里点醒了我一件事，就是`有效的交流`可以`产生组织`，换言之，没有`产生组织`的沟通都是`无效的`、`错误的`,反而会影响到项目。**

然后文中给出了一些交流途径

## 可行的交流途径

- 非正式途径
> 清晰定义小组内部的相互关系和充分利用电话，能鼓励大量的电话沟通，从而达到对
> 所书写文档的共同理解。


- 会议
> 常规项目会议。会议中，团队一个接一个地进行简要的技术陈述。这种方式非常有用，
> 能澄清成百上千的细小误解。


- 工作手册。
> 在项目的开始阶段，应该准备正式的项目工作手册。理所应当，我们专门用一节来讨
> 论它。

当然现在电话会议 都通过社交软件代替了，好处上章分析过了，这里不再赘述。

而后又强调了文档的重要性

## 又双叒叕是文档

### 是什么
项目工作手册不是独立的一篇文档，它是对项目必须产出的一系列文档进行组织的一种结构。  
项目所有的文档都必须是该结构的一部分。这包括**目的**、**外部规格说明**、**接口说明**、**技术标准**、**内部说明**和**管理备忘录**。

### 为什么
技术说明几乎是必不可少的。如果某人就硬件和软件的某部分，去查看一系列相关的用户手册。他发现的不仅仅是思路，而且还有能追溯到最早备忘录的许多文字和章节，这些备忘录对产品提出建议或者解释设计。对于技术作者而言，文章的剪裁粘贴与钢笔一样有用。

### 怎么做
> 因为文中的时间线是20年前，管理方法过于老旧，这里笔者提出一种方案
首先基于文档除了要包含基础的描述信息以外，还需要记录修改的`时间轴`，所以其实用**git** + **markdown**的方式是最好的选择; **git**有天生的版本管理优势而**markdown**则易学和强表现力，另外它们天生低成本。 
通过把一开始提到的那些点，分目录建好入档，维护好一个顶层HOC（目录），可以快速查找到所需内容，且通过git可以马上查看到当前文件的所有历史变更；最后每个文件都需要包含按照以下信息:
1. 任务（a mission）
2. 产品负责人（a producer）
3. 技术主管和结构师（a technical director or architect）
4. 进度（a schedule）
5. 人力的划分（a division of labor）
6. 各部分之间的接口定义（interface definitions among the parts）

这些内容主要是关于组织结构的，书中在稍后有阐述。

## 组织结构

如果项目有**n**个工作人员，则有
{{< math "inline" >}}
\begin{matrix}
(n^2 - n) / 2
\end{matrix}
{{< /math >}}
个相互交流的接口，有将近
{{< math "inline" >}}
\begin{matrix}
2^n
\end{matrix}
{{< /math >}}
个必须合作的潜在团队。团队组织的目的是减少不必要交流和合作的数量，因此良好的团队组织是解决上述交流问题的关键措施。

> 减少交流的方法是人力划分（division of labor）和限定职责范围（specializationof function）。当使用人力划分和职责限定时，树状管理结构所映出对详细交流的需要会相应减少。

然后给出了每个结构的6个基本要素：
1. 任务（a mission）
2. 产品负责人（a producer）
3. 技术主管和结构师（a technical director or architect）
4. 进度（a schedule）
5. 人力的划分（a division of labor）
6. 各部分之间的接口定义（interface definitions among the parts）

接着简述了两种队伍**头部**角色的职责

### 产品负责人
1. 他组建团队，划分工作及制订进度表。
2. 他要求，并一直要求必要的资源。这意味着他主要的工作是与团队外部，向上和水平地沟通。
3. 他建立团队内部的沟通和报告方式。
4. 最后，他确保进度目标的实现，根据环境的变化调整资源和团队的构架。

### 技术主管
1. 他对设计进行构思，识别系统的子部分，指明从外部看上去的样子，勾画它的内部结构。
2. 他提供整个设计的一致性和概念完整性；他控制系统的复杂程度。
3. 当某个技术问题出现时，他提供问题的解决方案，或者根据需要调整系统设计。用Al Capp 所喜欢的一句谚语，他是“攻坚小组中的独行侠”（inside-man at the skunk works.）。
4. 他的沟通交流在团队中是首要的。他的工作几乎完全是技术性的。

最后他给出了三种组合的方式，及其利处

### 组合方式
| 组合方式                     | 利                                                                   | 弊                                                                     | 适用                       |
| ---------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------------------- |
| 同一个人                     | 很小型的队伍（3-6人）                                                | 大型的项目中则不容易得到应用，原因：这类人很少，即便有，工作量也太大了 | 很小型的队伍（3-6人）      |
| 产品负责人为主，技术主管为副 | 1. 使工作很有效 2.项目经理可以使用并不很擅长管理的技术天才来完成工作 | 很难在技术主管不参与任何管理工作的同时，建立在技术决策上的权威         | 正大型项目中的一些开发队伍 |
| 技术主管为主，产品负责人为副 | 小型的团队是最好的选择                                               | PM需要更多的担当                                                       | 小型的团队是最好的选择     |