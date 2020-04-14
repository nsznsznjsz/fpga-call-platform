# 叫号系统

## Data Definition

### Summary

Use 16 bits, 8 bit data and 8 bit flags(include 4 bit group flag)

All undefined code is forbidden

### Detail

- bit 0-1: screen flag
  - 00: non flag
  - 10/11: waiting / called number;

- bit 2~5: groups flag
  - 0000: non flag
  - 1xxx: vip
  - x001: group a
  - x010: group b

- bit 6~7: error description
  - 00: non error
  - 01: unknown
  - 10/11: queue is empty / full

- bit 8~15: numbers
  - 0: error
  - others: numbers

## TODOS

- [ ] screen: decoding flags
- [ ] screen: print queue
- [ ] services: throw error when queue is empty
- [ ] customs: throw error when queue is full
- [ ] service: recall
- [ ] *: reset
- [x] groups flag
- [x] screen flag
- [x] refactor: use library
- [ ] refacotr(flag): use config for bit range 
- [ ] decoder: output length locked
- [ ] refactor: change pins type (set all pins as virtual pins now) 

## ISSUES

- A端取到 A1 号后, b端应取到 B1 or B2?
- How Many Screens?

## Detail Design

### 单个组件流程

> see Waiting's RTL for details

1. 按钮按下, 请求取数据
2. 等待允许取数据
3. 取到数据, 更新flags, 把数据推出去
4. 等待数据推出去
5. 数据成功推出去了
6. 等待下次按钮按下

### 组件层面

#### 取数据

- Customs 端: Waiting -> MultiCounter -> Counter
- Services 端: Waiting -> Arch -> Queue

#### 推数据

- Customs 端: Waiting -> Arch -> Queue
- Services 端: Waiting -> Arch -> Screen
