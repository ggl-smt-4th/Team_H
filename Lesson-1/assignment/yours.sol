pragma solidity ^0.4.14;

contract Payroll {
    uint salary = 0;
    address employer;
    address employee;
    uint constant payDuration = 10 seconds;
    uint lastPayday = now;
    
    function Payroll() {
        employer = msg.sender;
    }
    
    function setSalary (uint s) {
        if (msg.sender != employer) {
            revert();
        }
        salary = s * 1 ether;
    }
    
    function setAddress (address add) {
        if (msg.sender != employer) {
            revert();
        }
        employee = add;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        if (salary == 0) {
            revert();
        }
        return this.balance/salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        if (msg.sender != employee || employee == 0 || salary == 0) {
            revert();
        }

        uint nextPayday = lastPayday + payDuration;

        if (nextPayday > now) {
            revert();
        }
        
        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}
