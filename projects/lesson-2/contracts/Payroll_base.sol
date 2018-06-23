pragma solidity ^0.4.14;

contract Payroll {
    
    //定义Employee结构（相当于类）
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    //定义参数
    uint constant payDuration = 10 seconds;
    address owner;
    Employee[] employees;
    
    //结构函数
    function Payroll() payable public {
        owner = msg.sender;
    }
    
    //支付之前的工资
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }
    
    //寻找某位雇员
    function _findEmployee(address employeeId) private returns (Employee) {
        for (uint i = 0; i< employees.length; i+=1){
            if (employees[i].id == employeeId){
                return employees[i];
            }
        }
    }

    //增加雇员
    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        //参考 http://me.tryblockchain.org/solidity-data-location.html
        Employee memory employee = _findEmployee(employeeAddress);
        assert(employee.id == 0x0);
        
        /*for (uint i = 0; i< employees.length; i+=1){
            if (employees[i].id == employeeAddress){
                revert();
            }
        }*/
        
        employees.push(Employee(employeeAddress, salary, now));
    }

    //移除雇员
    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        
        for (uint i = 0; i< employees.length; i+=1){
            if (employees[i].id == employeeId){
                _partialPaid(employees[i]);
                delete employees[i];
                employees[i] = employees[employees.length-1];
                employees.length -= 1;
                return;
            }
        }        
    }

    //更新雇员工资信息
    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        for (uint i = 0; i< employees.length; i+=1){
            if (employees[i].id == employeeAddress){
                _partialPaid(employees[i]);
                //预留安全彩蛋 
                employees[i].salary=salary;
                employees[i].lastPayday=now;
                return;
            }
        }
    }

    //增加工资发放池
    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    //计算工资池剩余量
    function calculateRunway() public view returns (uint) {
        // TODO: your code here
    }

    //返回工资池是否足够发工资
    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    //发工资
    function getPaid() public {
        // TODO: your code here
    }
}

