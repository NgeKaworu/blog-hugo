---
date: 2022-01-06T17:40:56+08:00
title: "用户中心重构"
draft: false
tags: ["设计规划", "个人项目"]
keywords:
  - "项目管理"
  - 用户中心
  - RBAC
  - SOLID
  - 去中心化
description: "用户中心重构"
---

一年前写了个用户中心，基本设计在这里[老的设计与实现](/post/project/user-center/)，但只实现了诸如用户的 CURD、登录、注册和登出。根本就没有按 RBAC 来。今年填 qiankun 坑的时候顺便重构了用户中心，基于 RBAC 去实现。

[前端仓库](https://github.com/yingxv/user-center-umi)  
[后端仓库](https://github.com/yingxv/user-center-go)

回顾一下

{{< math "inline" >}}
\begin{matrix}
权限 \in 角色 \in 用户
\end{matrix}
{{< /math >}}

`用户`是`角色`的集合，`角色`又是`权限`的集合，  
RBAC 就是维护这么一个关系

<!--more-->

我们自下而上按 `权限` -> `角色` -> `用户` 来依次实现

### 权限

真实情况下权限、菜单非常的相似。可以说菜单继承自权限。所以我合在了一起实现：

> 权限 modal

```go
type Perm struct {
	ID       *string    `json:"id,omitempty" bson:"_id,omitempty"`                        // id
	Name     *string    `json:"name,omitempty" bson:"name,omitempty" validate:"required"` // 权限名
	CreateAt *time.Time `json:"createAt,omitempty" bson:"createAt,omitempty"`             // 创建时间
	UpdateAt *time.Time `json:"updateAt,omitempty" bson:"updateAt,omitempty"`             // 更新时间
	Order    *int       `json:"order,omitempty" bson:"order,omitempty"`                   // 排序

	// menu
	IsMenu     *bool   `json:"isMenu,omitempty" bson:"isMenu,omitempty" validate:"required"`          // 是否菜单
	IsHide     *bool   `json:"isHide,omitempty" bson:"isHide,omitempty"`                              // 是否不在菜单中显视
	IsMicroApp *bool   `json:"isMicroApp,omitempty" bson:"isMicroApp,omitempty"`                      // 是否微应用入口
	PID        *string `json:"pID,omitempty" bson:"pID,omitempty"`                                    // 父级id
	Url        *string `json:"url,omitempty" bson:"url,omitempty" validate:"required_if=IsMenu true"` // url
	Icon       *string `json:"icon,omitempty" bson:"icon,omitempty" `                                 // icon
}
```

我通过 pid 提供它们的树级关系。建树算法放在前端实现。  
建树是 dfs+memo 实现，复杂度控制在`O（N*logN）`，  
其中`genealogy`是族谱，用于记录路径，  
可以用于防止环状链表生成、溯源等。

> 建树算法

```tsx
export function _perm2Tree(
  origin: Perm[],
  pNode?: PermOpt
): { matched: PermOpt[]; mismatched: PermOpt[] } {
  let _matched: PermOpt[] = [],
    _mismatched: PermOpt[] = [];

  for (const p of origin) {
    let opt: PermOpt = {
      ...p,
      label: p.name,
      value: p.id,
      genealogy: (pNode?.genealogy ?? []).concat(p.id),
    };
    if (p.pID === pNode?.id) {
      _matched.push(opt);
    } else {
      _mismatched.push(opt);
    }
  }

  let solution: PermOpt[] = [];

  for (const match of _matched) {
    let { matched, mismatched } = _perm2Tree(_mismatched, match);
    solution.push({ ...match, children: matched });
    _mismatched = mismatched;
  }

  return {
    matched: solution,
    mismatched: _mismatched,
  };
}
```

> genealogy 的使用

```tsx
const id = getFieldValue(["id"]),
  validOpt = dfsMap<Partial<PermOpt>>(
    { children: perm2Tree(perms?.data?.data) },
    "children",
    (t) => {
      const ouroboros = t?.genealogy?.includes(id); // 衔尾蛇
      return {
        ...t,
        disabled: ouroboros,
        name: (
          <Tooltip title={ouroboros ? "不能选子孙节点" : t.url}>
            {t.name}
          </Tooltip>
        ),
      };
    }
  ).children;
```

### 角色

```go

type Role struct {
	ID       *string    `json:"id,omitempty" bson:"_id,omitempty"`                        // id
	Name     *string    `json:"name,omitempty" bson:"name,omitempty" validtor:"required"` // 角色名
	CreateAt *time.Time `json:"createAt,omitempty" bson:"createAt,omitempty"`             // 创建时间
	UpdateAt *time.Time `json:"updateAt,omitempty" bson:"updateAt,omitempty"`             // 更新时间
	Perms    []*string  `json:"perms,omitempty" bson:"perms,omitempty"`                   // 权限列表
}
```

### 用户

```go
type User struct {
	ID       *primitive.ObjectID `json:"id,omitempty" bson:"_id,omitempty"`                                // id
	Name     *string             `json:"name,omitempty" bson:"name,omitempty" validate:"required"`         // 用户昵称
	Pwd      *string             `json:"pwd,omitempty" bson:"pwd,omitempty" validate:"required,min=8"`     // 密码
	Email    *string             `json:"email,omitempty" bson:"email,omitempty" validate:"required,email"` // 邮箱
	CreateAt *time.Time          `json:"createAt,omitempty" bson:"createAt,omitempty"`                     // 创建时间
	UpdateAt *time.Time          `json:"updateAt,omitempty" bson:"updateAt,omitempty"`                     // 更新时间
	Roles    []string            `json:"roles,omitempty" bson:"roles,omitempty"`                           // 角色列表
}

```

可以看到 RBAC 1.0 的还是偏于简单。 稍微花点时间就是菜单的树状结构管理上。 用户和角色基本就是 CURD。

最终用户中心还要支持 JWT 的签发和权限的校验

### JWT

JWT 网上一搜一大把。[推荐文章](http://www.hyhblog.cn/2017/10/21/json-web-token-intro-and-best-practices/) 我这里不做阅读理解了。  
我分享一下我基于我那渣渣 VPS 作了小小的优化。

```go
func (app *App) cacheSign(w http.ResponseWriter, uid string) {
	dur := time.Hour * 24 * 15
	exp := time.Now().Add(dur).Unix()
	tk, err := app.auth.GenJWT(&jwt.StandardClaims{
		ExpiresAt: exp,
		Issuer:    "fuRan",
		Audience:  uid,
	})

	if err != nil {
		responser.RetFail(w, err)
		return
	}

	sign := strings.Split(tk, ".")[2]
    /**
    / 我这里只截取signature，然后存到redis里。其它server直接读redis 没读到说明 登陆过期，不需要每次都解密jwt；可以省下不少CPU资源。
    / 另外其它server需求用JWT换UID，所以redis是已 signature -> uid 的形式存储。过期时间和jwt过期时间一致。解决实效性问题。
    **/
	cmd := app.rdb.SetEX(context.Background(), sign, uid, dur)

	if cmd.Err() != nil {
		responser.RetFail(w, cmd.Err())
		return
	}

	responser.RetOk(w, sign)
}

```

### 权限校验

我的 RPC 就是简单的 http 的 head 请求。 联表查出所有权限，找到返回 200 否则 403 简单粗暴。

```go
// perm rpc
func (app *App) CheckPermRPC(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	p, err := app.getSetPerm(r.Header.Get("uid"))

	if err != nil {
		w.WriteHeader(http.StatusForbidden)
		return
	}

	for _, role := range p {
		if role == ps.ByName("perm") {
			return
		}
	}

	w.WriteHeader(http.StatusForbidden)
}
```

当然中间件也加了 redis 缓存

```go
func (app *App) CheckPerm(perm string) func(httprouter.Handle) httprouter.Handle {
	return func(next httprouter.Handle) httprouter.Handle {
		//权限验证
		return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
			u := r.Header.Get("uid")
			k := u + ":perm"

			const (
				NONEXIST = 0
				EXIST    = 1
			)

			e, _ := app.rdb.Exists(context.Background(), k).Result()

			if e == EXIST {
				if b, _ := app.rdb.SIsMember(context.Background(), k, perm).Result(); b {
					next(w, r, ps)
					return
				}
				w.WriteHeader(http.StatusForbidden)
				return
			}

			if e == NONEXIST {
				p, err := app.getSetPerm(u)

				if err != nil {
					w.WriteHeader(http.StatusForbidden)
					return
				}

				for _, role := range p {
					if role == perm {
						next(w, r, ps)
						return
					}
				}

				w.WriteHeader(http.StatusForbidden)
			}
		}
	}
}
```

以上