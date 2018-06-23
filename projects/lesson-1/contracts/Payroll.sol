pragma solidity ^0.4.14;
//设计思路：定义雇主地址、雇员地址、增加资金池、查看工资池剩余、付出工资、员工工资余额自查、老板查看某地址下的余额

contract Payroll {
    uint constant payDuration = 10 seconds;
    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    //定义雇主地址owner
    function Payroll () {
        owner = msg.sender;
    }
    
    //定义员工地址，工资
    function updateEmployee(address e, uint s) returns (uint){
        require(msg.sender == owner);
        
        //如果employee不为0，则结清该employee的工资
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        //定义地址、工资、最新时间
        employee = e;
        salary = s * 1 ether;
        lastPayday = now;
        
        //返回该员工当前工资余额
        return employee.balance;
    }

    //增加工资发放池
    function addFund() payable returns (uint) {
        return this.balance;
    }

    //计算工资池剩余量
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }

    //返回工资池是否足够发工资
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    //发工资
    function getPaid() {
        require(msg.sender == employee);//仅员工自己可以领取工资

        uint nextPayday = lastPayday + payDuration;
        require(nextPayday < now);
        /*或者
        if (nextPayday > now){
            revert(); }
        */
        uint payment = salary * (now - nextPayday) / payDuration;
        lastPayday = nextPayday;
        employee.transfer(payment);
    }
    
    //新增：员工工资余额自查
    function employeeFund() returns (uint) {
        require(msg.sender == employee);
        return employee.balance;
    }
    
    //新增：查看某一地址下的余额（仅限老板）
    function ownerLookup(address x) returns (uint){
        require(msg.sender == owner);
        
        employee = x;
        return employee.balance;
    }
    
}
