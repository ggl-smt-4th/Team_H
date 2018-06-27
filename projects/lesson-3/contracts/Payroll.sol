pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    
    using SafeMath for uint;

    struct Employee {
        // TODO: your code here
        address id;
        uint salary;
        uint lastPayday;
        
    }
    
    uint constant payDuration = 30 days;
    uint public totalSalary;


    //address owner;
    mapping(address => Employee) public employees;

    //function Payroll() payable public {
    //    owner = msg.sender;
    //}
    
    //modifier onlyOwner {
    //    require(msg.sender == owner);
    //    _;
    //}
    
    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }
    


    function addEmployee(address employeeId, uint salary) public onlyOwner {
        //require(msg.sender == owner);
        // TODO: your code here
        
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        
        totalSalary += salary * 1 ether;
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
        
    }

    function removeEmployee(address employeeId) public onlyOwner employeeExist(employeeId) {
        //require(msg.sender == owner);
        // TODO: your code here

        var employee = employees[employeeId];
        //assert(employee.id != 0x0);
        
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];
    }
    
    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner employeeExist(oldAddress) {
        // TODO: your code here
        
        var employee = employees[oldAddress];
        
        employee.id = newAddress;
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner employeeExist(employeeId) {
        //require(msg.sender == owner);
        // TODO: your code here
        
        var employee = employees[employeeId];
        //assert(employee.id != 0x0);
        
        totalSalary -= employees[employeeId].salary;
        _partialPaid(employee);
        employees[employeeId].salary = salary * 1 ether;
        totalSalary += employees[employeeId].salary;
        employees[employeeId].lastPayday = now;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        // TODO: your code here


        return this.balance / totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }
    
//    function checkEmployee(address employeeId) returns (uint salary, uint lastPayday) {
//        var employee = employees[employeeId];
//        //return (employee.salary, employee.lastPayday);
//        salary = employee.salary;
//        lastPayday = employee.lastPayday;
//    }

    function getPaid() public employeeExist(msg.sender) {
        // TODO: your code here
        var employee = employees[msg.sender];
        //assert(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert (nextPayday <= now);
        
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}

