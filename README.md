# 叫号系统

## Data Definition

### Summary

Use 16 bits, 8 bit data and 8 bit flags(include 4 bit group flag)

All undefined code is forbidden

### Detail

- bit 0-1: screen flag
  - 00: non flag
  - 10/11: waiting / called number;

- bit 2~3: error description
  - 00: non error
  - 01: unknown
  - 10/11: queue is empty / full

- bit 4~7: groups flag
  - 0000: non flag
  - 1xxx: vip
  - x001: group a
  - x010: group b

- bit 8~15: numbers
  - 0: error
  - others: numbers

## TODOS

- [ ] feat(screen): print queue
- [ ] feat(customs): throw error when queue is full
- [ ] feat(service): normal service should call vip (eg: `Service A` can call `VIP A`) 
- [ ] fix(decoder): output length locked
- [ ] refactor(*): change pins type (set all pins as virtual pins now)

## ISSUES

- 假设号码`01`闪烁3次, 闪烁中`02`进来了, 是继续显示`01`然后再显示`02`, 还是直接显示`02`

## Detail Design

### 宏观组件

所有组件数据交换流程均遵循[单组件流程](#单组件流程)

#### Multi Waitings

1. 将用户操作转换为对 `Counter` 取数据和 `A / B / VipA / VipB` 四个队列的入队列操作
2. 将数据推入 `Screen` 队列显示

#### Multi Services

1. 将用户操作转换为 `A / B / VIP` 三个队列的出队列操作
2. 将数据推入 `Screen` 队列显示

#### Multi Queues

1. 对左侧而言, 显示四个操作受限的队列 `A / B / VipA / VipB` (只能入队列)
2. 对右侧而言, 显示三个操作受限的队列 `A / B / VIP` (只能出队列)
3. 内部逻辑: 右侧`A`队列先取`VipA`再取`A`, `B`队列同理, 右侧`VIP`队列等效于左侧`VipA + VipB`
4. 内部实现: TODO

### 单组件流程

> see Waiting's RTL for details

1. 按钮按下, 请求取数据 (pull = '1')
2. 等待允许取数据 (wait enable_pull)
3. 取到数据 
4. 更新flags
5. 把数据推出去 (push = '1')
6. 等待数据推出去 (wait pushed)
7. 数据成功推出去了 
8. 等待下次按钮按下 (wait button)

### 组件层面

#### 取数据

- Customs 端: Waiting -> MultiCounter -> Counter
- Services 端: Waiting -> Arch -> Queue

#### 推数据

- Customs 端: Waiting -> Arch -> Queue
- Services 端: Waiting -> Arch -> Screen
