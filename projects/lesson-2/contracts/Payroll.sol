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

    uint constant payDuration = 10 seconds; //30 days;

    address owner;
    Employee[] employees;
    
    UnclaimedSalary unclaimedSalary;
    
    function _initUnclaimedSalary() private {
        unclaimedSalary.pool = 0x0;
        unclaimedSalary.totalSalary = 0x0;
        unclaimedSalary.lastUpdateTime = now;
    }
    
    function _updateUnclaimSalaryAt(uint time) private { 
        // require(time<=now); // only for debug
        // require(time>= unclaimedSalary.lastUpdateTime)
        
        uint unpaiedValue = unclaimedSalary.totalSalary * (time - unclaimedSalary.lastUpdateTime) / payDuration;
        unclaimedSalary.pool += unpaiedValue;
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
        unclaimedSalary.lastUpdateTime = time;
    }
    
    function _partialPaid(Employee employee) private {
        uint payValue = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.lastPayday = now;
        employee.id.transfer(payValue);
        _claimSalary(employee.lastPayday, payValue);
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
    }

    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        var(e, id) = _findEmployee(employeeAddress);
        assert(e.id == 0x0);
        uint addTime = now;
        uint salaryEther = salary * 1 ether;
        employees.push(Employee({id:employeeAddress, salary:salaryEther, lastPayday:addTime}));
        _updateEmployeeSalaryAt(addTime, 0, salaryEther);
    }

    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        
        var(e, id) = _findEmployee(employeeId);
        assert(e.id != 0x0);
        
        _partialPaid(e);
        _updateEmployeeSalaryAt(e.lastPayday, e.salary, 0);
        delete employees[id];
        employees.length --;
        employees[id] = employees[employees.length];
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        
        var(e, id) = _findEmployee(employeeAddress);
        assert(e.id != 0x0);
        
        _partialPaid(e);
        _updateEmployeeSalaryAt(e.lastPayday, employees[id].salary, salary);
        employees[id].salary = salary;
        
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }
    
    function calculateRunway() public view returns (uint) {
        var(e, id) = _findEmployee(msg.sender);
        assert(e.id != 0x0);
        
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
        
        return (chkTime - employees[id].lastPayday) / payDuration + (this.balance - unclaimedValue)/amountSalary;
    }

    function calculateRunwayUncheck() public view returns (uint) {
        _updateUnclaimSalaryAt(now);
        // owner
        if(msg.sender == owner) {
            if(unclaimedSalary.pool > this.balance) {
                return 0;
            }
            return (this.balance - unclaimedSalary.pool) / unclaimedSalary.totalSalary;
        }
        
        // employee
        var(e, id) = _findEmployee(msg.sender);
        assert(e.id != 0x0);
        
        // sync unclaimedSalary
        if(unclaimedSalary.pool > this.balance) { // TODO: not optimized
            // there is no enough fund for every person.
            // how much can I get at this time?
            uint maxRound = this.balance/e.salary;
            uint workingCycle = (now - e.lastPayday) / payDuration;
            if(maxRound > workingCycle) {
                return workingCycle;
            } else {
                return maxRound;
            }
        } else {
            // money may be enough
            uint employeeUnclaimedDays = unclaimedSalary.lastUpdateTime - e.lastPayday;
            uint employeeUncalculateDays = this.balance/unclaimedSalary.totalSalary;
            return (employeeUnclaimedDays + employeeUncalculateDays) / payDuration;
        }
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        address requestAddr = msg.sender;
        
        var(e, id) = _findEmployee(requestAddr);
        assert(e.id == 0x0);
        
        if(employees[id].lastPayday + payDuration < now) {
            revert();
        }
        
        employees[id].lastPayday += payDuration;
        e.id.transfer(e.salary);
    }
    
    function dbg_viewUnclaimedSalary() returns(uint, uint, uint) {
        return (unclaimedSalary.pool, unclaimedSalary.totalSalary, unclaimedSalary.lastUpdateTime);
    }
    
    function dbg_viewEmployee(uint idx) returns(uint, uint) {
        Employee e = employees[idx];
        return (e.salary, e.lastPayday);
    }
}
