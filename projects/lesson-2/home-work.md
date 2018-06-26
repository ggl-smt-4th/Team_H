一、

每行第一个数字为transaction gas,第二个数字为execution gas
22974 gas, 1702 gas;
23755 gas, 2483gas;
24536 gas, 3264 gas;
25317 gas, 4045 gas;
…
结论：第一个之后，随着加入员工的次序，gas消耗逐渐增加。
原因：每次加入新员工都要遍历一遍employees中的员工薪水求和。因此，员工数量越多，需要消耗的运算量更大，因此会消耗更多gas。

二、

优化思路：
1.定义状态变量 
uint totalSalary;
2.在addEmployee()中加入代码计算totalSalary，最终如下：

    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);

        var(employee, index) = _findEmployee(employeeAddress);
        assert(employee.employeeAddress == 0x0);

        employees.push(Employee(employeeAddress, salary, now));
		totalSalary += employee.salary;
}
3.在calculateRunway()中删除定义totalSalary的代码和遍历代码，最终如下：

function calculateRunway() returns(uint) {

        return this.balance / totalSalary;
    }
 4.在removeEmployee()中修改totalSalary,最终如下：
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
        }

5.在updateEmployee()中修改totalSalary，最终如下：
    function updateEmployee(address employeeAddress, uint salary) {

        require(msg.sender == owner);

        var (employee, index) = _findEmployee(employeeAddress);
        assert(employee.employeeAddress != 0x0);

        _partialPay(employee);
	totalSalary -= salary;
        employee.salary = salary;
	totalSalary += salary;
        employee.lastPayDay = now;

    }
