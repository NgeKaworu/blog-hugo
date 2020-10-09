---
title: "[柳比歇夫时间管理] 后端篇"
date: 2020-09-29
draft: true
tags: ["deno", "mongo"]
---

## 项目地址
项目源码在这[github](https://github.com/NgeKaworu/time-mgt-deno)，欢迎clone下来配合食用

## Deno 初体验
先说说Deno用起来的感受。  
首先它支持url导入了，这意味着不用被node_modules恶心了，但是如果你要重装依赖，好像也没区别=- =。  
然后原生支持`await\async`、`typescript`；当然他最近又要把内部核心包转回`js`写了，不过这主要是为了性能，和我们关系不大。  
最后，更新还是蛮频繁的，玩玩就行了，不能拿去做生产。  
<!--more-->

## 项目地图
```shell
$ tree -I ".deno_plugins|.vscode"
.
|-- main.ts                     # main文件
`-- src
    |-- controller              # controller
    |   |-- record.ts
    |   |-- tag.ts
    |   `-- user.ts
    |-- db                      # mongo 实例
    |   |-- createIndexes.js
    |   `-- init.ts
    |-- models                  # models
    |   |-- record.ts
    |   |-- tag.ts
    |   `-- user.ts
    `-- tools                   # 工具集
        |-- checks.ts           # 入参验证
        |-- crypto.ts           # 加解密
        |-- jwt.ts              # jwt
        |-- resultor.ts         # 约定的response
        `-- strconv.ts          # string 格式化
```
整个项目很精简，用的是MVC模式。

## 正文
看了整个目录，发现没什么可写的。姑且从创建http服务、建立mongo连接池到处理请求、返回响应来叙述吧。

先看`main.ts`

### main.ts
```ts
// 解析命令行的入参
const { i: isInit, m: dbUrl, db: dbname = "time-mgt" } = parse(Deno.args);

// 创建mongo客户端
db.Connect(dbUrl, dbname, FormatBool(isInit));

const controller = new AbortController();

// 路由处理
const router = new Router();
router
  //...ommit user controller
  //tag controller
  // 这里是请求的url, jwt中间件和controller
  .post("/v1/tag/create", JWT, AddTag)
  .put("/v1/tag/update", JWT, UpdateTag)
  .get("/v1/tag/list", JWT, FindTag)
  .delete("/v1/tag/:id", JWT, DeleteTag)
  //...omit record controller
  

// 终止信号
const { signal } = controller;

// http 服务
const app = new Application();


// 错误处理中间件
app.use(async (ctx, next) => {
  try {
    await next();
  } catch (err) {
    console.error(err);
    return RetFail(ctx, err.message);
  }
});
// 跨域处理
app.use(oakCors({ allowedHeaders: ["Content-Type", "Authorization"] }));
app.use(router.routes());
app.use(router.allowedMethods());

await app.listen({ port: 8000, signal });

// http服务关闭之后 关闭mongo连接
db.Close()

console.log("http close");

```

### mongo初始化
`src/db/init.ts`
```ts
class DbEngine {
  async Connect(url: string, dbName: string, init: boolean = false) {
    this.url = url;
    this.name = dbName;
    this.client = new MongoClient();                                    //初始化客户端
    this.client.connectWithUri(url);                                    //建立连接
    this.db = this.client.database(dbName);
    // equal node __dirname
    const __dirname = path.dirname(path.fromFileUrl(import.meta.url));  //获取当前项目路径

    if (init) {                                                         //初始化索引
      const cmd = Deno.run({                                            //deno的mongo驱动还无法创建索引和事务，这里是用命令行实现的
        cmd: [
          "mongo",
          `${url}/${dbName}`,
          path.resolve(__dirname, "createIndexes.js"),
        ],
        stdout: "piped",
        stderr: "piped",
      });

      cmd.close();                                                      //执行后记得close()
    }
  }

  GetColl<T>(table: string) {
    return this.db.collection<T>(table);
  }

  Close() {
    return this.client.close();
  }
}

export const db = new DbEngine();
```

### request处理
这里用登录来做例子，顺便带出jwt和resutor
`src/controller/user.ts`
```ts
export async function Login(ctx: Context) {
  if (!ctx.request.hasBody) {
    return RetFail(ctx, "not has body");
  }
  // 解body
  const result = ctx.request.body(); // content type automatically detected
  if (result.type === "json") {
    const value = await result.value; // an object of parsed JSON
    //校验必要参数
    const missingKey = CheckRequired(value, ["email", "pwd"]);
    if (missingKey.length) {
      return RetMissing(ctx, missingKey, {
        "email": "邮箱不能为空",
        "pwd": "密码不能为空",
      });
    }

    const { pwd } = value;
    // 加密密码
    const encryptedPwd = await Encrypt(pwd);
    // 查库
    const tUser = db.GetColl<UserSchema>(T_User);
    try {
      const hasUser = await tUser.findOne(
        { ...value, pwd: encryptedPwd },
      );
      if (hasUser) {
        const { _id: { $oid } } = hasUser;
        // 颁发 jwt
        const jwt = await GenJwt($oid);
        // 成功响应
        return RetOK(ctx, jwt);
      } else {
        // 失败响应
        return RetFail(ctx, "没有此用户");
      }
    } catch (e) {
      return RetFail(ctx, e.message);
    }
  } else {
    return RetFail(ctx, "body must a json");
  }
}
```
### jwt身份认证
`src/tools/jwt.ts`
```ts
// 从运行时命令行获取加密用的key
const { k: key } = parse(Deno.args);

// 验证
export async function JWT(ctx: Context, next: () => Promise<void>) {
  // 从header拿到jwt
  const jwt = ctx.request.headers.get("Authorization") || "";
  // 验证
  const vJwt = await validateJwt(
    { jwt, key, algorithm: "HS256" },
  );
  // 验证成功
  if (vJwt.isValid) {
    // 把解出来的数据提取出来放到header里
    const { aud } = vJwt.payload as PayloadObject;
    ctx.request.headers.set("uid", aud as string);
    // 走后面的controller
    await next();
  } else {
    // 验证失败 返回401
    return RetFail(ctx, "身份认证失败", 401);
  }
}

// GenJwt 生成一个jwt
export async function GenJwt(aud: string) {
  // jwt 是由header.body.sign 组成的
  // payload主要是body部分
  const payload: Payload = {
    iss: "fuRan",
    aud,
    exp: setExpiration(60 * 60 * 24 * 15),
  };
  // 这里是head部分 主要描述jwt的信息，如加密方式alg，类型typ等
  const header: Jose = {
    alg: "HS256",
    typ: "JWT",
  };

  // 生成jwt
  return await makeJwt({ header, payload, key });
}

```
### resutor前后端一致的响应体
这个看上去很简单，但是非常重要，在响应体上保持一致，可以省去很多因为格式问题出的错。
`src/tools/resutor.ts`
```ts
// 成功返回，返回Ok和成功数据
export function RetOK(ctx: Context, data: Object) {
  ctx.response.body = {
    ok: true,
    data,
  };
}

// 失败返回，返回false和错误信息
export function RetFail(ctx: Context, errMsg: string, status: number = 200) {
  ctx.response.body = {
    ok: false,
    errMsg,
  };
  ctx.response.status = status;
}

```

## 其他篇章
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [后端篇](/post/time-mgt/back-end/)  
> [部署篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  
