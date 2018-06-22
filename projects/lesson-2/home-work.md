## 调用calculateRunway的GAS变化（非优化版本）

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

## calculatRunway的GAS优化思路
消除循环：
1. 总salary数可以在添加删除员工时直接计算  -->  循环中减少一个加法
2. 合约中可以被employee取但是没有被取得钱可以用更简单方法计算。算法为：
在增删employee前以及修改工资前，计算当前总salary对应的没有被取走的钱数量unclaimedValue。
每次取钱，在unclaimedValue 中减少相应值；每当调用calculatRunway时，
计算当前总salary从上次计算unclaimedValue到现在为止，新增的unclaimedValue，并加到当前
unclaimedValue中。  -->  不需要循环了。总计算量为在calculatRunway时做一个uint减法，一个乘法，一个除法。
