pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    
    using SafeMath for uint;
        
    struct Employee {
        address id;
        uint salary;
        uint lastpayday;
    }

    uint constant payDuration = 30 days;
    uint public totalSalary = 0;
    mapping (address => Employee) public employees;

    
    modifier employeeExist (address employeeId) {
        var employee = employees[employeeId];
        assert (employee.id != 0x0);
        _;
    }
    
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastpayday)/payDuration;
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeId, uint salary) public onlyOwner {
        var employee = employees[employeeId];
        assert (employee.id == 0x0);
        employees[employeeId] = Employee (employeeId, salary* 1 ether, now);
        totalSalary += employees[employeeId].salary;
    }

    function removeEmployee(address employeeId) public onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        delete employees[employeeId];
    }

    function changePaymentAddress(address oldAddress, address newAddress) public onlyOwner employeeExist(oldAddress) {
        var employee = employees[oldAddress];
        _partialPaid(employee);
        employees[newAddress] = Employee (newAddress, employees[oldAddress].salary, now);
        delete employees[oldAddress];
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner employeeExist(employeeId){
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary -= employees[employeeId].salary;
        employees[employeeId].salary = salary * 1 ether;
        employees[employeeId].lastpayday = now;
        totalSalary += employees[employeeId].salary;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        return address(this).balance/totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public employeeExist(msg.sender){
        var employee = employees[msg.sender];
        uint nextPayday = employee.lastpayday + payDuration;
        assert (nextPayday < now);
        
        employees[msg.sender].lastpayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
