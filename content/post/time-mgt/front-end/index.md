---
title: "[柳比歇夫时间管理] 前端篇"
date: 2020-10-07T01:23:47+08:00
draft: true
tags: ["umi", "react", "axios"]
lastmod: 2020-10-08T01:25:39+08:00
---

## 项目目录
```bash
$ tree -I js-sdk
.
|-- Loading.tsx             # 按需加载的Loading 页
|-- app.ts                  # 重载dva的逻辑
|-- components
|   `-- TagMgt              
|       |-- TagExec.tsx     # 新增、编辑的弹窗执行者
|       `-- index.tsx       # 标签管理
|-- global.less             # 全局样式
|-- http                    
|   |-- host.ts             # 多host控制
|   |-- index.ts            # http模块 axios的二次封装 
|   `-- proxyCfg.ts         # 参照webpack proxy定的url转发
|-- layouts
|   `-- index.tsx           # 布局主文件
|-- models                  # VM层 dva是对redux redux-saga的封装，把controller和model放一起统一管理
|   |-- global.ts           # 全局
|   |-- record.ts           # 记录
|   |-- tag.ts              # 标签
|   `-- user.ts             # 用户
|-- pages
|   |-- record              
|   |   `-- index.tsx       # 记录页
|   |-- statistic
|   |   `-- index.tsx       # 统计页
|   `-- user
|       `-- index.tsx       # 用户页
|-- theme
|   `-- index.ts            # 全局主题常量
`-- utils                   # 通用工具
    `-- type.ts             
```

使用的是umi的架构体系，[官方文档](https://umijs.org/zh-CN/docs/upgrade-to-umi-3#tsconfigjson)已经写的非常通俗易懂了，本文就不再赘述。  
本文主要讲**http模块**和**executer组件**的设计思路和使用。
<!--more-->
## http，为业务的二次封装
进入`src/http/index.ts`文件，首先我们先看入参：
```js
// 接收一个 url 和 RequestConfig
function request(url: string, options: BizOptions = {}): AxiosPromise<any>
// BizOptions 是对 AxiosRequestConfig的拓展
interface BizOptions extends AxiosRequestConfig {
  errCatch?: boolean; // 是否捕获错误
  silence?: Silence; // 是否通知
  reAuth?: boolean; // 是否重新登录
  coressPorxy?: boolean; // 是否走代理
}
```
这四个开关分别对应四种业务行为，稍后会分别讲解；
我们接着往下看代码先遇到coressPorxy

### 多host多环境下的url分发机制
```js
const proxyUrl = coressPorxy ? proxy(url, proxyCfg) : url;
```
我们看`src/http/proxyCfg.ts`
```js
import { mainHost } from './host';

export default {
  '/main/': {
    target: mainHost,
    pathRewrite: { '^/main/': '/' },
  },
};
```
是不是发现和webpack里的proxy一模一样；举个例子：`main/v1/rencord`这条url会被匹配到`mainHost`去， 并且根据pathRewirte规则重写成`mainHost/v1/record`。 
这样的好处是：假设我们要调多个后端，方便维护和区分。我们扩展下会更好理解：
```js
import { mainHost, subHost, thirdHost } from './host';

export default {
  '/main/': {
    target: mainHost,
    pathRewrite: { '^/main/': '/' },
  },
  '/sub/' {
      target: subHost,
      pathRewrite: { '^/sub/': '/v2' },
  },
  '/3th/' {
      target: thirdHost,
      pathRewrite: { '^/3/': '/' },
  },
};

const url = "/main/v1/tags"     // 匹配mainHost, 转换为 mainHost/v1/tags
const url2 = "/sub/v1/user"     // 匹配subHost, 转换为 sub/v2/v1/tags
const url3 = "/3th/v1/record"   // 匹配thirdHost, 转换为 thirdHost/th/v1/tags
```
我们在来看`src/http/host.ts`
```js
export const mainHost = () => {
    // 通过运行时NODE_ENV变量区分url
    switch (process.env.NODE_ENV) {
        case "production":
            return "https://api.furan.xyz/time-mgt";
    default:
        return "http://localhost:8000";
  }
};

```
如代码所示mainHost在生产环境返回`https://api.furan.xyz/time-mgt`, 其余环境返回`http://localhost:8000`。
如果我们有多个host，并且分dev,test,prod多个环境，只需要在打包时传入对应参入即可区分，省的改来改去。  

然后回到`src/http/index.ts`, 看request的返回：
```js
  return axios(proxyUrl, {
    timeout: 10000,
    headers: {
      Authorization: `${localStorage.getItem("token")}`,
      ...headers,
    },
    ...restOptions, // axios request options
  })
    // 业务pipe
    .then(bizHandler)
    // 请求成功pipe
    .then(successHandler)
    // 请求失败pipe
    .catch(errorHandler);
```
这里有三条管道，对不同响应做了通用处理，主要是践行aop理念。

### bizHandler 业务处理器
先上代码
```js
  // 主要业务处理
  function bizHandler(response: AxiosResponse) {
    if (response?.data?.ok) {
      return response;
    }

    const bizError = new BizError("biz error");
    bizError.response = response;
    throw bizError;
  }
```
后端响应体的是这样的json  
成功:
```json
{
    "ok": true, 
    "data": data
}
```
失败:
```json
{
    "ok": false, 
    "errMsg": "string"
}
```
所以它的作用主要是先判断业务是否成功。成功交给`successHandler`，失败则交给`errorHandler`。可以对具体业务细节进行横向扩展。

### successHandler 全局成功处理
```js
  //全局成功处理
  function successHandler(response: AxiosResponse) {
    const { data } = response;
    if (!(silence === true || silence === "success")) {
      message.success({ content: data?.message || "操作成功" });
    }
    return data;
  }
```

这个handler的行为就很简单了，根据`silence`参数决定是否做全局通知，然后提取`response`的`body`并返回。


### errorHandler 全局错误处理
```js
function errorHandler(error: BizError): any {
    const { response, message: eMsg } = error;
    // reAuth标记是用来防止连续401的熔断处理

    if (response?.status === 401) {
      return reAuth ? reAuthorization() : message.warning({
        content: "请先登录",
        onClose: () => {
          localStorage.clear();
          location.replace(`${window.routerBase}/user/`);
        },
      });
    }
    // silence标记为true 则不显示消息
    if (!(silence === true || silence === "fail")) {
      const timeoutMsg = eMsg.match("timeout") && "连接超时， 请检查网络。";
      const netErrMsg = eMsg.match("Network Error") && "网络错误，请检查网络。";

      message.error({
        content:
          // 超时
          timeoutMsg ||
          netErrMsg ||
          // 后端业务错误
          response?.data?.errMsg ||
          // 错误码错误
          codeMessage[response?.status as number] ||
          "未知错误",
      });
    }
    // 阻止throw
    if (errCatch) {
      return response;
    }

    throw error;
  }
```
这里我们先处理401，根据`reAuth`这个开关，会执行静默登录或是跳转登录页，这个`reAuthorization()`我们后面在讲；  
然后根据`silence`，决定是否发起通知；  
最后根据`errCatch`，决定这个错误是抛出，还是内部消化。

### reAuthorization 重新授权
```ts
  function reAuthorization() {
    return RESTful
      .get("/uc/oauth2/refresh", {
        reAuth: false,
        silence: "success",
        params: { token: localStorage.getStorage("refresh_token") },
      })
      .then((resp: AxiosResponse) => {
        localStorage.setItem("token", resp.data.token);
        localStorage.setItem("refresh_token", resp.data.refresh_token);
        return request(url, { ...options, reAuth: false });
      });
  }
```
这个也很好理解，用旧的jwt换一个新的，然后重新请求原接口。

### 封装RESTful和graphQL的别名方法
剩下的就是一些alias了，主要两块：
1. RESTful
```ts

const restful = ["get", "post", "delete", "put", "patch", "head", "options"];
// 注入别名
export const RESTful = restful.reduce((
  acc: { [k: string]: Function },
  method,
) => ({
  ...acc,
  [method]: (url: string, options?: BizOptions) =>
    request(url, {
      method: method as Method,
      ...options,
    }),
}), {});

```
这样就可以用诸如`RESTful.get()`、`RESTful.post()` 这些别名方法。
2. Graphql
```ts
const graphql = ["query", "mutation"];
export const Graphql = graphql.reduce(
  (acc: { [k: string]: Function }, method) => ({
    ...acc,
    [method]: (
      url: string,
      options?: BizOptions,
    ) => ((...query: any[]) =>
      RESTful.post(url, {
        data: {
          query: `${method} {${
            query[0].reduce(
              (acc: string, cur: string, idx: number) =>
                acc + cur + (query[idx + 1] || ""),
              "",
            )
          }}`,
        },
        ...options,
      })),
  }),
  {},
);
```
现在主流GraphQL还是使用json格式作来传参,所以做了层封装。别名方法仅`graphQL.query()`和 `graphQL.mutation()`。

## 其他篇章
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [后端篇](/post/time-mgt/back-end/)  
> [部署篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  
