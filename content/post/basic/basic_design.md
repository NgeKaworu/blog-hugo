---
date: 2021-07-02T13:39:22+08:00
title: "基础设计原则及在React中的应用"
draft: false
---

## 设计基础原则

### 为什么需要设计

> 唯一不变的只有变化本身

1. 降低维护成本
2. 提高开发效率
3. 快速响应多变的需求  
~~4. 准时下班~~

### 如何设计

1. 你可能根本无需设计, 提前设计往往是过度设计.
2. 尽可能遵守[KISS]原则, 使代码保持简单, 根据[三次原则][rot], 重复三次的逻辑再做抽象.
3. 确认功能的边界, 遵守[SOLID]原则, 尽可能保持功能之间的独立.

### 什么是好的设计

1. `一致性`
   一致性的概念很广泛, 包括但不限于同样的`风格`、`数据结构`、`驱动方式`等, 下面就`驱动方式`作例子
   > 不好的例子

```ts
const [val, setVal] = useState();
const [val_1, setVal_1] = useState();
function doSth(){
    setVal(...)
}
useEffect(()=>{
    // 通过观察者去负值val1
    setVal1(val)
}, [val])
```

> 好的例子

```ts
const [val, setVal] = useState();
const [val_1, setVal_1] = useState();
function doSth(){
    // 行为放一起
    setVal(...)
    setVal1(...)
}
```

2. `高复用性`
   这个说白就是别把代码写死, 灵活使用`抽象`和`设计`.

> 坏

```tsx
    {
      title: '项目',
      dataIndex: 'prdId',
      renderFormItem(config) {
        const handledDateTime = dateTime?.map(item => item?.format('YYYY-MM-DD')) as string[];
        return (
          <div {...config}>
            <ProductSelector<number[]>
            // 接收一大堆 莫名奇妙的props 内部也没有多内聚
              prdId={prdIds}
              date={handledDateTime && handledDateTime[1]}
              departmentId={department}
              multiple={true}
              clearable={false}
              autoSelect={true}
              autoSelectAll={true}
              checkType={'checkItem'}
              customAllSelectOptions={{ label: '汇总', value: -999 }}
              onChange={(value: number[], options) => {
                setPrdIds(value);
                if (options?.length) {
                  setPrdOptions(options);
                } else {
                  const newOptions = [...defaultPrdOptions];
                  if (newOptions[0].value === -999) newOptions.shift();
                  newOptions.unshift({ label: '汇总', value: -999 });
                  setPrdOptions(newOptions as Options);
                }
              }}
            />
          </div>
        );
      },
    }
```

> 好

```tsx
    {
      title: '项目',
      dataIndex: 'prdId',
      renderFormItem(config) {
        return (
          <div {...config}>
          // AOP 模式, 每个切片单一责任 分工明确
            {compose(
              SelectAll,
              Search,
            )(
              // 原始组件照常使用
              <Select
                onChange={setPrdIds}
                loading={prds.isLoading}
                options={prds.data}
                maxTagCount={1}
                maxTagTextLength={12}
              />,
            )}
          </div>
        );
      },
    },
```

3. `低耦合度`  
   不要依赖来, 依赖去; 相互的依赖交给统一的`interface`、`context`和`store`去做例如
   > 不要

```tsx
function Father() {
  const store = useStore();
  return (
    <>
      <Child {...store} />
      <Child {...store} />
      <Child {...store} />
    </>
  );
}

function Child(props) {
  // use props.store dosth
}
```

而是
```tsx
function Father() {
  return (
    <>
      <Child />
      <Child />
      <Child />
    </>
  );
}

function Child(props) {
  const store = useStore();
  // use store dosth
}

```

[solid]: https://zh.wikipedia.org/zh-hans/SOLID_(%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1%E8%AE%BE%E8%AE%A1)
[rot]: https://zh.wikipedia.org/wiki/%E4%B8%89%E6%AC%A1%E6%B3%95%E5%88%99_(%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1)
[kiss]: https://zh.wikipedia.org/wiki/KISS%E5%8E%9F%E5%88%99
