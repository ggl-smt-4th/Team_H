 ### 作业

* 完成第二课所讲智能合约，添加 100ETH 到合约中

* 加入十个员工，每个员工的薪水都是 1ETH

    每次加入一个员工后调用 `calculateRunway()` 这个函数，并且记录消耗的 gas。Gas 变化么？如果有，为什么？

* 如何优化 `calculateRunway()` 这个函数来减少 gas 的消耗？

    1. gas 变化的记录。
    
    第1次 transaction：22966 ； execution：1694 ；
    第2次 transaction：23749 ； execution：2477 ；
    第3次 transaction：24532 ； execution：3260 ；
    第4次 transaction：25315 ； execution：4043 ；
    第5次 transaction：26098 ； execution：4826 ；
    第6次 transaction：26881 ； execution：5609 ；
    第7次 transaction：27664 ； execution：6392 ；
    第8次 transaction：28447 ； execution：7175 ；
    第9次 transaction：29230 ； execution：7958 ；
    第10次 transaction：30013 ； execution：8741 ；


    2. `calculateRunway()` 函数的优化思路和过程, 放到 `projects/lesson-2/home-work.md` 中。
    
    calculateRunway()函数里有for循环，如果把totalSalary单独设置为一个函数，每次只调用函数的结果，就节省了许多运算了。

