# Python程序员的Solidity迁移学习

## 第二课知识点

### 〇、错误检测

assert()
require()

### 一、数组

| 内容 | Solidity | Python |
| :-- | :-- | :-- |
| 申明创建 | 元素类型[*数组长度*] 数组变量名|列表变量名 = [] |
| 数组长度 | 数组名.length |len(列表名) |
| 追加元素 | 数组.push(元素) |列表.append(元素) |
| 元素索引 | 数组[位置] |列表[位置] |
| 起始索引 | 0 | 0 |
| 动态数组用索引赋值 | 不可 |不可 |


### 二、结构

| 内容 | Solidity | Python（无结构体用类实现） |
| :-- | :-- | :-- |
| 申明创建 | struct 首字大写结构名 {<br>&nbsp;&nbsp;&nbsp;&nbsp;属性1;<br>&nbsp;&nbsp;&nbsp;&nbsp;属性2;<br>&nbsp;&nbsp;&nbsp;&nbsp;...;<br>}|class 首字大写类名():<br>&nbsp;&nbsp;&nbsp;&nbsp;def \_\_init\_\_(self, 属性参数1, 属性参数2, ...):<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.属性1 = 属性参数1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;self.属性2 = 属性参数2<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...|
| 创建实例 | 首字大写结构名(属性参数1, 属性参数2, ...) | 首字大写类名(属性参数1, 属性参数2, ...) |


### 三、数据存储

storage
memory
calldata


### 四、遍历循环

| 内容 | Solidity | Python |
| :-- | :-- | :-- |
| 语法 | for (uint i = 0; i < 数组.length; i++) {<br>&nbsp;&nbsp;&nbsp;&nbsp;对第i个元素操作;<br>} | for 元素临时变量 in 列表:<br>&nbsp;&nbsp;&nbsp;&nbsp;对元素临时变量操作 |


### 五、删除数组元素

| 内容 | Solidity | Python |
| :-- | :-- | :-- |
| 语法 | 没有现成函数，需要自己构建：<br>1.用for找到需删除的元素<br>2.delete元素 进行初始化<br>3.将当前空元素赋值为数组最后一个元素<br>&nbsp;&nbsp;&nbsp;&nbsp;数组[i]=数组.length-1<br>4.“裁剪”掉数组最后一个元素<br>&nbsp;&nbsp;&nbsp;&nbsp;数组.length -= 1| del 列表[元素索引]<br>或<br>列表.remove(元素) |

### 六、可见度

| 内容 | Solidity | Python |
| :-- | :-- | :-- |
| 公共函数<br>可外部调用 | contract 合约名{<br>&nbsp;&nbsp;&nbsp;&nbsp;function 公共函数名() *public*{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;函数内容;<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br>} |class 首字大写类名():<br>&nbsp;&nbsp;&nbsp;&nbsp;def 外部方法名(self):<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;函数内容 |
| 私有函数<br>不可外部调用 | contract 合约名{<br>&nbsp;&nbsp;&nbsp;&nbsp;function 私有函数名() private{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;函数内容;<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br>} |class 首字大写类名():<br>&nbsp;&nbsp;&nbsp;&nbsp;def \_\_私有方法名(self):<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;函数内容 |

