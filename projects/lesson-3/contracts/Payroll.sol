pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {

    using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;// TODO, your code here
    }

    uint constant payDuration = 10 seconds;
    uint public totalSalary = 0;
    address owner;
    mapping (address => Employee) employees;
    
    function _partialPay(address employeeId) private {

        uint payment = employees[employeeId].salary * (now - employees[employeeId].lastPayday) / payDuration;
        employees[employeeId].id.transfer(payment);
    }    
    
    //构造器
    function Payroll() payable public {
        
        owner = msg.sender;// TODO: your code here
    }

    modifier checkEmployee(address employeeId) {

        assert(employees[employeeId].lastPayday != 0);
        _;    
    }


    //增加员工
    function addEmployee(address employeeId, uint salary) public onlyOwner  {
        
        var employee = employees[employeeId];
        assert(employee.lastPayday == 0);
        salary = salary.mul(1 ether);
        employees[employeeId] = Employee(employeeId, salary, now);
        totalSalary += salary;// TODO: your code here
    }

    function removeEmployee(address employeeId) public checkEmployee(employeeId) onlyOwner {
        
        _partialPay(employeeId);
        delete employees[employeeId];// TODO: your code here
    }

    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner checkEmployee(oldAddress) {
        
        var employee = employees[newAddress];
        assert(employee.lastPayday == 0);
        var oldEmployee = employees[oldAddress];
        _partialPay(oldAddress);
        
        employees[newAddress] = Employee(newAddress, oldEmployee.salary, now);
        delete employees[oldAddress];// TODO: your code here
    }

    function updateEmployee(address employeeId, uint salary) public checkEmployee(employeeId) onlyOwner {
        
        _partialPay(employeeId);
        totalSalary -= employees[employeeId].salary;
        employees[employeeId].salary = salary * 1 ether;
        totalSalary += employees[employeeId].salary;
        employees[employeeId].lastPayday = now;
        // TODO: your code here
    }

    function addFund() payable public returns (uint) {
        
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        
        return address(this).balance / totalSalary; // TODO: your code here
    }

    function hasEnoughFund() public view returns (bool) {
        
        return (calculateRunway() > 0); // TODO: your code here
    }

    function getPaid() public checkEmployee(msg.sender) {
        
        var employee = employees[msg.sender];

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);// TODO: your code here
    }
}
