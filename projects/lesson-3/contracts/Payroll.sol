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

    uint constant payDuration = 30 days;
    uint public totalSalary = 0;
    address owner;

    mapping (address => Employee) employees;

    //构造器
    function Payroll() payable public {
        
        owner = msg.sender;// TODO: your code here
    }

    modifier checkEmployee(address employeeId) {

        require(employees[employeeId].id != 0x0);
        _;    
    }
    //增加员工
    function addEmployee(address employeeId, uint salary) public checkEmployee(employeeId) onlyOwner  {
        
        employees[employeeId] = Employee(employeeId, salary, now);
        totalSalary += salary;// TODO: your code here
    }

    function removeEmployee(address employeeId) public checkEmployee(employeeId) onlyOwner {
        
        delete employees[employeeId];// TODO: your code here
    }

    function changePaymentAddress(address oldAddress, address newAddress) public checkEmployee(oldAddress) onlyOwner {
        
        employees[oldAddress].id = newAddress;// TODO: your code here
    }

    function updateEmployee(address employeeId, uint salary) public checkEmployee(employeeId) onlyOwner {
        
        employees[employeeId].salary = salary;// TODO: your code here
    }

    function addFund() payable public returns (uint) {
        
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        
        return address(this).balance / totalSalary;// TODO: your code here
    }

    function hasEnoughFund() public view returns (bool) {
        
        return (calculateRunway() > 0);// TODO: your code here
    }

    function getPaid() public checkEmployee(msg.sender) {
        
        uint nextPayDay = employees[msg.sender].lastPayday + payDuration;
        assert(nextPayDay < now);

        employees[msg.sender].lastPayday = nextPayDay;
        employees[msg.sender].id.transfer(employees[msg.sender].salary);// TODO: your code here
    }
}
