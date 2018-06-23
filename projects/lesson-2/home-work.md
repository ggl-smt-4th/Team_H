第1次

transaction cost: 22974
execution cost: 1702


第2次

transaction cost: 23755
execution cost: 2483


第3次

transaction cost: 24536
execution cost: 3264


第4次

transaction cost: 25317
execution cost: 4045


第5次

transaction cost: 26098
execution cost: 4826


第6次

transaction cost: 26098
execution cost: 4826


第7次

transaction cost: 26879
execution cost: 5607


第8次

transaction cost: 27660
execution cost: 6388


第9次

transaction cost: 28441
execution cost: 7169


第10次

transaction cost: 29222
execution cost: 7950


增加越多员工，消耗的gas增加，原因应该是因为数组的length增加了，所以需要计算总工资的循环次数增加了。

calculateRunway()优化思路：用一个全局变量totalSalary，每新增一个员工增加相应的工资，每删除一个员工减去相应的工资，每更新一个员工工资，减去原先的工资，加上更新的工资。
