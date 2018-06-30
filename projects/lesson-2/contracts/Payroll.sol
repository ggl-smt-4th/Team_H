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

    function _findEmployee(address employeeAddress) private view returns(int) {

        for (uint i = 0; i < employees.length; i++) {

            if (employees[i].employeeAddress == employeeAddress) {

                return int(i);
            }
        }
        
        return -1;
    }

    function _partialPay(uint employeeIndex) private {
        uint payment = employees[employeeIndex].salary * (now - employees[employeeIndex].lastPayDay) / payDuration;
        employees[employeeIndex].employeeAddress.transfer(payment);
    }

    //转入用于支付薪酬的gas进合约
    function addFund() payable returns(uint) {

       return this.balance;
    }

    //计算剩余资金足以支付的周期
    function calculateRunway() public view returns(uint) {
        
        require(employees.length > 0);
        return address(this).balance / totalSalary;
    }

    //是否有足够支付下一周期的资金
    function hasEnoughFund() returns(bool) {

        return (calculateRunway() > 0);
    }

    //支付薪水
    function getPaid() {

        int i = _findEmployee(msg.sender);
        assert(i > -1);
        
        uint index = uint(i);
        uint nextPayDay = employees[index].lastPayDay + payDuration;
        assert(nextPayDay < now);
    //修改-0628
        employees[index].lastPayDay = nextPayDay;
        employees[index].employeeAddress.transfer(employees[index].salary);
    }

    function updateEmployee(address employeeAddress, uint salary) {

        require(msg.sender == owner);

        int index = _findEmployee(employeeAddress);
        assert(index > -1);
    
        uint i = uint(index);
        _partialPay(i);
        uint oldSalary = employees[i].salary;
        
        salary = salary * 1 ether;
        totalSalary -= employees[i].salary;
        employees[i].salary = salary;
        employees[i].lastPayDay = now; 
        totalSalary += salary - oldSalary;

    }

    //在元组中加入新的元素
    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);

        int i = _findEmployee(employeeAddress);
        assert(i == -1);
        salary = salary * 1 ether;
        employees.push(Employee(employeeAddress, salary, now));
        totalSalary += salary;// TODO: your code here
    }

    //移除元组中的员工
    function removeEmployee(address employeeAddress) public {
        require(msg.sender == owner);
        int index = _findEmployee(employeeAddress);
        assert(index > -1);

        uint i = uint(index);
        _partialPay(i);
        totalSalary -= employees[i].salary;
        delete employees[i];
        employees[i] = employees[employees.length -1];
        employees.length -= 1;

            }
        }// TODO: your code here
    
