# Call Platform

## 0.1.1 (c7dd015)

- refactor: rename `Customs` to `Queuing`, create .vhd instead .bdf
- refactor: remove useless components `NumberGetter` and `QueueEmitter`

## 0.1.2 (55a145b)

- refactor: global GENERIC config
- refactor: create `Services.vhd` instead `Services.bdf`

## 0.1.3 (5e14b23)

- feat: update flags, see readme for detail

## 0.1.4 (bee5059)

- feat: add decoder
- refactor(Waiting/Service): output a default value (an ERROR) when it is not `pushing` state
- refactor: create config package

## 0.1.5
- feat(Service): recall number
- refactor: rename waiting parameter `FLAGS` to `GROUP_FLAG`

## 0.1.6

- feat(Waiting): normal waiting and vip waiting use the same counter now
- feat(Service): normal service can call vip first now
- feat(*): support reset
- refactor(Waiting): rename ports, use more common names
- refactor(Arch): remove latch of N-1 Arch
- refactor(Arch): remove useless state
- refactor(*): remove `Waitings` `Services`

## 0.1.7

- feat(Queue): `Queue VIP` include `Queue B` and `Queue A`
- fix(*): update error flag, decode a error when (others => '0')
- fix(*): `Service A` can't call `Queue A`

## 0.2.0

- feat(Waiting): normal waiting and vip waiting use the same counter ([0.1.6](#0.1.6))
- feat(Service): normal service can call vip first ([0.1.6](#0.1.6))

## 0.3.0

- feat(Queue): sync vip queues, see [readme](./README.md) for details
- feat(Config): add error_retry flag, error flag width increased to 3, group flag width reduced to 3 corresponding
- refactor(Waiting): rename `MultiWaitings` to `TheWaitings`
- refactor(Service): rename `MultiServices` to `TheServices`
- refactor(Queue): rename `MultiQueues` to `TheQueues`
- refactor(*): remove useless entity `Waitings` and `Services`

## 0.3.1
- feat(Screen): add screen

## 0.3.2
- feat(Screen): add enable
- feat(Screen): show student id only disenabled
- feat(Screen): show last number after blink

## 0.3.3
- fix(Queue): sync logic of synchronizer
- test: update all testbench

## 1.0.0
- test: update testbench
