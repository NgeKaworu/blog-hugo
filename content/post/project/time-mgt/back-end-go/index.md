---
title: "【柳比歇夫时间管理】 go后端篇"
date: 2020-10-12T17:04:52+08:00
draft: false
tags: ["后端", "个人项目"]
keywords:
- "go"
- "个人项目"
- "mongo"
- json web token
description : "【柳比歇夫时间管理】 go后端篇"
---

## Q&A
为啥用go重构？  
> deno太新了，很多功能没有，github isssu里都是future =- =

重新弄用了多久？
> 算上写blog，两天吧（16h）

改动大吗？
> 不算大，主要是ObjectID的格式和Deration，JS里是毫秒，go是纳秒， 1ms = 10^6ns

<!--more-->

## 项目地图
```bash
$ tree -I "vscode|bin"
.
|-- go.mod
|-- go.sum
|-- main.go
`-- src
    |-- auth
    |   |-- auth.go
    |   |-- crypto.go
    |   `-- jwt.go
    |-- cors
    |   `-- cors.go
    |-- engine
    |   |-- RecordCtrl.go
    |   |-- TagCtrl.go
    |   |-- UserCtrl.go
    |   `-- db.go
    |-- models
    |   |-- Record.go
    |   |-- Tag.go
    |   `-- User.go
    |-- parsup
    |   `-- parsup.go
    |-- resultor
    |   `-- resultor.go
    `-- utils
        `-- required.go
```
总的来说和Deno那套架构是一样的，只是多了个`辅助类`，所以本文将重点说说它的设计思路和实现

## 辅助类
请随本文打开`src/parsup/parsup.go`，我们一步一步的来。

### 结构和工厂方法
结构主要是一些开关，工厂方法默认关闭struct，因为诸如`time.Time`这类的对象其实是一个struct，一不小心就误处理了
```go
// ParamsSupport 参数辅助类
type ParamsSupport struct {
	IsDeep       *bool // 深度递归
	IsConvOID    *bool // 转化ObjectID
	IsConvTime   *bool // 转化时间对象
	IsDenyInject *bool // 防注入
	IsConvStruct *bool // 转结构
}

// ParSup 工厂方法
func ParSup() *ParamsSupport {
	t := true
	f := false
	return &ParamsSupport{
		IsDeep:       &t,
		IsConvOID:    &t,
		IsConvTime:   &t,
		IsDenyInject: &t,
		IsConvStruct: &f,
	}
}
```

### 链式setter
没啥好说的，就是方便开关
```go
// SetIsDeep 设置方法
func (p *ParamsSupport) SetIsDeep(b bool) *ParamsSupport {
	p.IsDeep = &b
	return p
}

// SetIsConvOID 设置方法
func (p *ParamsSupport) SetIsConvOID(b bool) *ParamsSupport {
	p.IsConvOID = &b
	return p
}

// SetIsConvTime 设置方法
func (p *ParamsSupport) SetIsConvTime(b bool) *ParamsSupport {
	p.IsConvTime = &b
	return p
}

// SetIsDenyInject 设置方法
func (p *ParamsSupport) SetIsDenyInject(b bool) *ParamsSupport {
	p.IsDenyInject = &b
	return p
}

// SetIsConvStruct 设置方法
func (p *ParamsSupport) SetIsConvStruct(b bool) *ParamsSupport {
	p.IsConvStruct = &b
	return p
}
```

### ConvBase 基础处理器
用reflect的反射机制，获取到具体类型，然后分发（dispatch）给其它handler。只有设置了`IsDeep = true`才深度递归。
```go
func (p *ParamsSupport) ConvBase(i interface{}) (interface{}, error) {
	v := reflect.ValueOf(i)
	switch v.Kind() {
	case reflect.Invalid:
		return nil, nil
	case reflect.Map:
		if *p.IsDeep {
			return p.ConvMap(i.(map[string]interface{}))
		}
		break
	case reflect.Slice:
		if *p.IsDeep {
			return p.ConvSlice(i.([]interface{}))
		}
		break
	case reflect.Struct:
		if *p.IsDeep && *p.IsConvStruct {
			return p.ConvStruct(i)
		}
		break
	case reflect.String:
		return p.ConvStr(i.(string))
	}
	return i, nil
}
```

### ConvStr 字符串处理器
防注入、时间处理、ObjectID处理都在这里
```go
func (p *ParamsSupport) ConvStr(s string) (interface{}, error) {
	if *p.IsDenyInject {
		if strings.ContainsAny(s, "$[]{}()") {
			return nil, errors.New("不能包含$[]{}()等特殊符号")
		}
	}

	if *p.IsConvOID {
		if oid, err := primitive.ObjectIDFromHex(s); err == nil {
			return oid, nil
		}
	}
	if *p.IsConvTime {
		if t, err := time.Parse(time.RFC3339, s); err == nil {
			return t.Local(), nil
		}
	}
	return s, nil
}
```

### ConvMap Map处理器
深度优先处理Map
```go
func (p *ParamsSupport) ConvMap(m map[string]interface{}) (map[string]interface{}, error) {
	res := make(map[string]interface{})
	for k, v := range m {
		dv, err := p.ConvBase(v)
		if err != nil {
			return nil, err
		}
		res[k] = dv
	}
	return res, nil
}
```

### ConvSlice 数组处理器
跟`ConvMap`逻辑类似，注意`slice`要用`make([]interface{}, len(s))`方法初始化，否则设置时会报边界错误。
```go
func (p *ParamsSupport) ConvSlice(s []interface{}) ([]interface{}, error) {
	res := make([]interface{}, len(s))
	for k, v := range s {
		dv, err := p.ConvBase(v)
		if err != nil {
			return nil, err
		}
		res[k] = dv
	}
	return res, nil
}
```

### ConvJSON byte处理器
这个方便`ioutil.ReadAll(r.Body)`返回的那个`[]byte`
```go
func (p *ParamsSupport) ConvJSON(s []byte) (map[string]interface{}, error) {
	m := make(map[string]interface{})
	err := json.Unmarshal(s, &m)
	if err != nil {
		return nil, err
	}
	return p.ConvMap(m)
}
```

### ConvStruct 结构体处理器
通过reflect反射机制，根据结构体tag（标签），完成一些行为
```go
func (p *ParamsSupport) ConvStruct(s interface{}) (map[string]interface{}, error) {
	val := reflect.ValueOf(s)
	if val.Kind() != reflect.Struct {
		return nil, errors.New("not a struct")
	}
	t := val.Type()
	o := make(map[string]interface{})
	for i := 0; i < t.NumField(); i++ {
		var omitempty, skip, omitzero bool
		tagsName := t.Field(i).Name
		cur := val.Field(i)
		if tags, ok := t.Field(i).Tag.Lookup("parsup"); ok {
			tagsArr := strings.Split(tags, ",")
			tagsName = tagsArr[0]
			for _, v := range tagsArr {
				switch v {
				case "omitempty":
					omitempty = true
				case "omitzero":
					omitzero = true
				case "-":
					skip = true
				}
			}
		}

		if skip || (cur.Kind() == reflect.Ptr && cur.IsNil() && omitempty) || (cur.IsZero() && omitzero) {
			continue
		}

		ele, err := p.ConvBase(p.safeInterface(cur))

		if err != nil {
			return nil, err
		}

		o[tagsName] = ele
	}

	return o, nil
}
```


### safeInterface 安全取值
```go
多做几层判断 不容易报错
func (p *ParamsSupport) safeInterface(v reflect.Value) interface{} {
	if v.IsValid() && v.CanInterface() {
		return v.Interface()
	}
	return nil
}
```

## 其他篇章
> [前言](/post/time-mgt/outline/)  
> [前端篇](/post/time-mgt/front-end/)  
> [deno后端篇【废弃】](/post/time-mgt/back-end/)    
> [go后端篇](/post/time-mgt/back-end-go/)  
> [部署篇](/post/time-mgt/ops/)  
> [后语](/post/time-mgt/conclusion/)  

