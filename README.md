# 叫号系统

## Data Definition

> All undefined code is forbidden

> Use 16 bits

- bit 0-1: screen flag, 00/01: queuing / called number;
- bit 2-3: vip flag, 01: yes;
- bit 4~5: groups flag, 00/01/10/11: group a/b/c/d;
- bit 6~7: error description
  - 00: non error
  - 01: unknown
  - 10: queue is empty
  - 11: queue is full
- bit 8~15: numbers, 0: error, others: numbers;

## TODOS

- [ ] screen: print ports, decoding
- [ ] services: throw error when queue is empty
- [ ] customs: throw error when queue is full
- [ ] counter reset
- [ ] groups flag
- [ ] screen flag

## ISSUES

- A端取到 A1 号后, b端应取到 B1 or B2?

## Detail Design

### 单个组件流程

> see Watting's RTL for details

1. 按钮按下, 请求取数据
2. 等待允许取数据
3. 取到数据, 更新flags, 把数据推出去
4. 等待数据推出去
5. 数据成功推出去了
6. 等待下次按钮按下

### 组件层面

#### 取数据

- Customs 端: Watting -> MultiCounter -> Counter
- Services 端: Watting -> Arch -> Queue

#### 推数据

- Customs 端: Watting -> Arch -> Queue
- Services 端: Watting -> Arch -> Screen
