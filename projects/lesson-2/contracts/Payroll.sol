pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    struct UnclaimedSalary {
        uint pool;
        uint totalSalary;
        uint lastUpdateTime;
    }

    uint constant payDuration = 30 days;

    address owner;
    Employee[] employees;
    
    UnclaimedSalary unclaimedSalary;
    
    uint totalSalary;
    
    function _initUnclaimedSalary() private {
        unclaimedSalary.pool = 0x0;
        unclaimedSalary.totalSalary = 0x0;
        unclaimedSalary.lastUpdateTime = now;
    }
    
    function _updateUnclaimSalaryAt(uint time) private { 
        // require(time<=now); // only for debug
        // require(time>= unclaimedSalary.lastUpdateTime)
        unclaimedSalary.pool += unclaimedSalary.totalSalary * (time - unclaimedSalary.lastUpdateTime) / payDuration;
        unclaimedSalary.lastUpdateTime = time;
    }
    
    function _claimSalary(uint time, uint claimedValue) private {
        // require(time<=now); // only for debug
        // require(time>= unclaimedSalary.lastUpdateTime)
        
        if(time > unclaimedSalary.lastUpdateTime) {
            _updateUnclaimSalaryAt(time);
        }
        unclaimedSalary.pool -= claimedValue;
    }
    
    function _updateEmployeeSalaryAt(uint time, uint previousSalary, uint currentSalary) private {
        _updateUnclaimSalaryAt(time);
        unclaimedSalary.totalSalary -= previousSalary;
        unclaimedSalary.totalSalary += currentSalary;
    }
    
    function _partialPaid(uint id) private {
        Employee employee = employees[id];
        uint payValue = employee.salary * (now - employee.lastPayday) / payDuration;
        employees[id].lastPayday = now;
        employee.id.transfer(payValue);
        _claimSalary(employees[id].lastPayday, payValue);
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        uint employeeRecordIndex;
        for(employeeRecordIndex; employeeRecordIndex < employees.length; employeeRecordIndex++) {
            Employee e = employees[employeeRecordIndex];
            if(e.id == employeeId) {
                return (e, employeeRecordIndex);
            }
        }
    }

    function Payroll() payable public {
        owner = msg.sender;
        _initUnclaimedSalary();
        totalSalary = 0;
    }

    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        var(e, id) = _findEmployee(employeeAddress);
        assert(e.id == 0x0);

        uint addTime = now;
        uint salaryEther = salary * 1 ether;
        employees.push(Employee({id:employeeAddress, salary:salaryEther, lastPayday:addTime}));
        _updateEmployeeSalaryAt(addTime, 0, salaryEther);
        totalSalary += salaryEther;
    }

    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        
        var(e, id) = _findEmployee(employeeId);
        assert(e.id != 0x0);
        
        _partialPaid(id);
        _updateEmployeeSalaryAt(unclaimedSalary.lastUpdateTime, e.salary, 0);
        totalSalary -= e.salary;
        delete employees[id];
        employees.length --;
        if(id != employees.length) {
            employees[id] = employees[employees.length];
        }
        
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        var(e, id) = _findEmployee(employeeAddress);
        assert(e.id != 0x0);
        
        _partialPaid(id);
        _updateEmployeeSalaryAt(employees[id].lastPayday, employees[id].salary, salary);
        totalSalary = totalSalary - e.salary + salary;
        employees[id].salary = salary;
        
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        if(totalSalary == 0) {
            return this.balance;
        }
        return (this.balance) / totalSalary;
    }

    function calculateRunway_pro_uncheck() public view returns (uint) {
        _updateUnclaimSalaryAt(now);
        if(msg.sender == owner) {
            if(unclaimedSalary.pool > this.balance) {
                return 0;
            } 
            if(unclaimedSalary.totalSalary == 0) {
                return this.balance;
            }
            return (this.balance) / unclaimedSalary.totalSalary;
        }

        // employee
        var(e, id) = _findEmployee(msg.sender);
        assert(e.id != 0x0);
        uint uncalimedEmployeeAmount = e.salary * (now - e.lastPayday) / payDuration;
        if( this.balance > uncalimedEmployeeAmount) { // money amount is enough
            return (uncalimedEmployeeAmount + (this.balance - uncalimedEmployeeAmount)* e.salary/unclaimedSalary.totalSalary)/ payDuration;
        } else { // money not enough
            uint maxRound =  this.balance / e.salary;
            uint roundCanClaim = (now - e.lastPayday) / payDuration;
            if(maxRound > roundCanClaim) {
                return roundCanClaim;
            } else {
                return maxRound;
            }
        }
    }
    
    function calculateRunway_bad() public view returns (uint) {
        uint unclaimedValue = 0;
        uint chkTime = now;
        uint amountSalary = 0;
        for(uint idx=0; idx<employees.length; idx++) {
            amountSalary += employees[idx].salary;
            unclaimedValue += employees[idx].salary * (chkTime - employees[idx].lastPayday) / payDuration;
        }
        if( unclaimedValue > this.balance) {
            return 0;
        }
        if(amountSalary == 0) {
            return 1;
        }
        
        if(msg.sender == owner) {
            return this.balance / amountSalary;
        }

        var(e, id) = _findEmployee(msg.sender);
        assert(e.id != 0x0);
        return (chkTime - employees[id].lastPayday) / payDuration + (this.balance - unclaimedValue)/amountSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        address requestAddr = msg.sender;
        
        var(e, id) = _findEmployee(requestAddr);
        assert(e.id != 0x0);
        
        uint nextPayday = e.lastPayday + payDuration;
        
        if(nextPayday > now) {
            revert();
        }
        
        employees[id].lastPayday = nextPayday;
        e.id.transfer(e.salary);
        _claimSalary(nextPayday, e.salary);
    }
}
