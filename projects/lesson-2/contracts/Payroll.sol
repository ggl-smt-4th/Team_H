pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address employeeAddress;
        uint salary;
        uint lastPayDay;// TODO: your code here
    }

    uint constant payDuration = 30 days;

    address owner;
    Employee[] employees;
    uint totalSalary;

    //构造器，保证owner == 合约创建者
    function Payroll() payable public {
        owner = msg.sender;
    }

    function _findEmployee(address employeeAddress) private returns(Employee, uint) {

        for (uint i = 0; i < employees.length; i++) {

            if (employees[i].employeeAddress == employeeAddress) {

                return (employees[i], i);
            }
        }
    }

    function _partialPay(Employee employee) private {

        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.employeeAddress.transfer(payment);
    }

    //转入用于支付薪酬的gas进合约
    function addFund() payable returns(uint) {

       return this.balance;
    }

    //计算剩余资金足以支付的周期
    function calculateRunway() public view returns(uint) {

        return this.balance / totalSalary;
    }

    //是否有足够支付下一周期的资金
    function hasEnoughFund() returns(bool) {

        return (calculateRunway() > 0);
    }

    //支付薪水
    function getPaid() {

        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.employeeAddress != 0x0);

        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);
    //修改-0628
        employees[index].lastPayDay = nextPayDay;
        employees[index].employeeAddress.transfer(employee.salary);
    }

    function updateEmployee(address employeeAddress, uint salary) {

        require(msg.sender == owner);

        var (employee, index) = _findEmployee(employeeAddress);
        assert(employee.employeeAddress != 0x0);

        _partialPay(employee);
        totalSalary -= employee.salary;
        employee.salary = salary;
        totalSalary += salary;
        employee.lastPayDay = now;

    }

    //在元组中加入新的元素
    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);

        var(employee, index) = _findEmployee(employeeAddress);
        assert(employee.employeeAddress == 0x0);

        employees.push(Employee(employeeAddress, salary * 1 ether, now));
        totalSalary += salary;// TODO: your code here
    }

    //移除元组中的员工
    function removeEmployee(address employeeAddress) public {
        require(msg.sender == owner);
        var(employee, index) = _findEmployee(employeeAddress);
        assert(employee.employeeAddress != 0x0);

        _partialPay(employee);
        totalSalary -= employee.salary;
        delete employees[index];
        employees[index] = employees[employees.length -1];
        employees.length -= 1;

            }
        }// TODO: your code here
    
