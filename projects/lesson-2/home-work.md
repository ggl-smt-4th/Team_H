## 调用calculateRunway 基本版 的GAS变化（非优化版本）

| Round | Transaction Gas | Execution Gas |
| - | - | - |
| 1 | 27003 | 5731 |
| 2 | 29698 | 8426 |
| 3 | 32393 | 11121 |
| 4 | 35008 | 13816 |
| 5 | 37783 | 16511 |
| 6 | 40478 | 19206 |
| 7 | 43173 | 21901 |
| 8 | 45868 | 24596 |
| 9 | 48563 | 27291 |
| 10 | 51258 | 29986 |

原因： 随着元素增加，循环次数线性增加，所以可以看到gas也在线性增加

## 调用calculateRunway 平易近人版 的GAS变化（无变化）
| Round | Transaction Gas | Execution Gas |
| - | - | - |
| 0 | 22160 | 888 |
| 1 | 22381 | 1109 |

测试程序已经证明，1-10都是一样的；0是因为没有employee，直接返回了

## calculatRunway的GAS优化思路
消除循环：

记下来salary amount，每次增删改员工的时候修改；，在求runway的时候和balance做除法。

这样就从O(n)-->O(1)

## calculateRunway 的合理计算
根据不同case计算：
1. owner视角，根据unclaimed 的总salary进行估计，根据当前balance支付unclaimed以后剩余的金额来看后面还能跑多少个pay cycle
2. employee视角：如果当前balance不能够支付所有unclaimed salary，那么作为这个employee能够保证拿到的最多的钱，是当前balance能够用于支付他unpaid的工资数，所以应该是balance/e.salary 和（now-e.lastPaidDay)/payDuration 两者中更小的；当balance够的时候，则是到now为止，unpaid salary总数中输入当前员工的部分+(balance-unpaid_salary) * e.salary / 当前所有员工的salary和

这种解法要用很多乘除法，看起来要比naive方法跑10轮还费资源也说不定
