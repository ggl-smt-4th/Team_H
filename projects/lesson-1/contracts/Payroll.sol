pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 30 days;

    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;
    }
    
    function getEmployee() returns(address) {
        return employee;
    }
    
    function updateEmployee(address e, uint s) {
        require(msg.sender == owner);
        
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        
        employee = e;
        salary = s * 1 ether;
        lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        require(msg.sender == employee);
        
        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
    function updateEmployeeAccount(address e) {
        if(msg.sender != employee) {
            revert();
        }
        
        employee = e;
    }
    
    function updateEmployeeSalary(uint s) {
        updateEmployee(employee, s);
    }
}
