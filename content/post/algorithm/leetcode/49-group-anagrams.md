---
title: "49 Group Anagrams"
date: 2020-10-25T21:08:59+08:00
draft: false
tags: ["算法"]
tags:
keywords:
- leetcode
- 算法
- 哈希表
- 字符串
- 49 Group Anagrams
- 49. 字母异位词分组
description: "leetcode 49题 字母异位词分组"
---

# 49. 字母异位词分组

## 题目
Given an array of strings strs, group the anagrams together. You can return the answer in any order.  
给个字符串数组，返回一个“字谜”集合，顺序无所谓。  
An Anagram is a word or phrase formed by rearranging the letters of a different word or phrase, typically using all the original letters exactly once.   
字谜的意思是 —— ~~包含一样的字母但顺序不一样的词，通常每个字母只出现一次~~  

说白了是 **字母的** **可重复** **组合**

PS: 
> 1 <= strs.length <= 104   
> 0 <= strs[i].length <= 100  
> strs[i] consists of lower-case English letters.  
> 英文字典序
<!--more-->

坑：  
`["dgggggggggg","ddddddddddg"]`这两个字符串拥有一样的字母，但是数量不同，所以不能分为一组。

## 思路

~~1. 初始化，把原数组第一项push到目标数组里；~~  
~~2. 从第二项开始循环原数组，得到i；~~  
~~3. 初始化used变量，用于判断i是否被使用；~~  
~~4. 然后循环目标数组，得到j；~~  
~~5. 拿出两个字符串判断，~~如果每个字符都出现过~~，如果两个字符串是相同的组合，那么把i push 到目标数组的j里，并且把used设为true；组合的逻辑：~~  
~~- 1. 长度一致~~  
~~- 2. s1里所有字符要在S2里出现过~~  
~~- 3. 出现过的次数要一致~~  
~~6. 判断used，如果为false，在目标数组里初始化他~~  


上面的思路有两个问题 ——  
1. 循环过多， 两个数组和两个字符串的对比，深度大概有4，时间复杂度在N^4以上；
2. 判断两个字符串是否属于一种组合很麻烦
所以换成：
1. 用一个map管理结果；
2. 每次拿到字符串先用字典序确定组合；
3. 最后逻辑判断是push还是init
4. 转换成数组

## 代码
### ts
```ts
function groupAnagrams(strs: string[]): string[][] {
    const res: Record<string, string[]> = {}
    for (let i = 0; i < strs.length; ++i) {
        const key = strs[i].split('').sort().join()
        if (res[key]) {
            res[key].push(strs[i])
        } else {
            res[key] = [strs[i]]
        }
    }

    return Object.values(res);
}

```

### go

```go
func groupAnagrams(strs []string) [][]string {
  m := make(map[string][]string)

  for _, v := range strs {

      s := strings.Split(v, "")
      sort.Strings(s)
      key := strings.Join(s, "")

      if len(m[key]) != 0 {
        m[key] = append(m[key], v)
      } else {
        m[key] = []string{v}
      }
  }

  res := make([][]string, 0)

  for _, v := range m {
    res = append(res, v)
  }

  return res
}
```

## 仰望大佬

```go
var list = []int{2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101}

func groupAnagrams(strs []string) [][]string {
    product2Index := map[int]int{}
    index := 0
    rets := make([][]string, 0, len(strs))
    for i:=0; i<len(strs); i++ {
        product := helper(strs[i])
        if k, exist := product2Index[product]; exist {
            rets[k] = append(rets[k], strs[i])
        } else {
            rets = append(rets, []string{strs[i]})
            product2Index[product] = index
            index++
        }
    }

    return rets
}

func helper(a string) int {
    ret := 1
    for i:=0; i<len(a); i++ {
        ret *= list[int(a[i]-'a')]
    }
    return ret
}
```

说实话一开始这么玩我没看懂，后来我才发现，他的组合判断是遍历字符串，然后每个字符对应一个质数，然后用乘积来表示一串字符串，并且因为质数不可约分的性质，保证了唯一性。
真是给大佬跪了。

然后我改成了ts版本，瞬间超过100%的用户😂
```ts
var list = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101]

function groupAnagrams(strs: string[]): string[][] {
    let product2Index = []
    let index = 0
    let rets: string[][] = []
    for (let i = 0; i < strs.length; i++) {
        const product = helper(strs[i])
        const k = product2Index[product]
        console.log(k)
        if (k !== undefined) {
            rets[k].push(strs[i])
        } else {
            rets.push([strs[i]])
            product2Index[product] = index
            index++
        }
    }

    return rets
}

function helper(a: string): number {
    let ret = 1
    for (let i = 0; i < a.length; i++) {
        ret *= list[a[i].charCodeAt(0) - 'a'.charCodeAt(0)]
    }
    return ret
}
```