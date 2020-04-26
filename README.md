# 叫号系统

## Feature

假设有 A/B 两种服务类型, 现有
- A / B / VIPA / VIPB 客户端各一个, 共4个
- A / B / VIP 服务端各一个, 共3个

其中: 
- A 服务端优先叫 VIP A 的号码, 然后叫 A 的号码,
- B 服务端优先叫 VIP B 的号码, 然后叫 B 的号码,
- VIP 服务端: VIP(按照先后顺序) > B > A

> eg:
> 现有用户取号如下: 
> 1. A 客户端取号, 取到 A01
> 2. VIP A 客户端取号, 取到 A02
> 3. B 客户端取号, 取到 B01
> 4. VIP B 客户端取号, 取到 B02
> 
> 下列case 均独立
> case 1: 
> 1. A服务端叫号, 应叫到 A02,
> 2. A服务端再叫号, 应叫到 A01 (VIP优先)
> 
> case 2:
> 1. VIP服务端叫号, 应叫到 A02  (A02 先于 B02 入队列),
> 2. VIP服务端再叫号, 应叫到 B02, 
> 3. VIP服务端再叫号, 应叫到 B01,
> 4. VIP服务端再叫号, 应叫到 A01

## Data Definition

### Summary

Use 16 bits, 8 bit data and 8 bit flags(include 4 bit group flag)

All undefined code is forbidden

### Detail

- bit 0-1: screen flag
  - 00: non flag
  - 10/11: waiting / called number;

- bit 2~4: error description
  - 111: non error
  - 001: retry, throw by synchronizer
  - 010/011: queue is empty / full
  - 000: unknown

- bit 5~7: groups flag
  - 000: non flag
  - 1xx: vip
  - x01: group a
  - x10: group b

- bit 8~15: numbers
  - 0: error
  - others: numbers

## TODOS

- [ ] Screen: print queue
- [ ] Waiting: throw error when queue is full
- [ ] Decoder: output length locked
- [ ] change pins type (set all pins as virtual pins now)
- [ ] VipQueue: catch queue empty after sync

## ISSUES

- 假设号码`01`闪烁3次, 闪烁中`02`进来了, 是继续显示`01`然后再显示`02`, 还是直接显示`02`
- `Screen` 仿真

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
4. 内部实现: 五队列`A / B / VipA / VipB / VIP`, 后三者通过`VipMixer`混合

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

## Helpers

### push

- 1 -> N: CoupleEmitter (一个 Entity 向多个数据源推数据)
- N -> 1: ManyToOneArch (多个 Entity 向一个数据源推数据)

### pull

- 1 -> N: SourceMux (一个 Entity 从多个数据源取数据)
- N -> 1: OneToManyArch (多个 Entity 从一个数据源取数据)

### VipMixer

左右侧均为三队列`VipA / VipB / Vip`, 取数据时:
1. 取数据
2. 判断是否大于当前记录的最大值
3. case 1: 大于, pass
4. case 2: 小于等于, 则重取数据

亦可视为每次取数据时, 会抛弃队列中前 N 个无用数据, 即同步(Sync)
