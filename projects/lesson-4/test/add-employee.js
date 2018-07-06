var Payroll = artifacts.require("./Payroll.sol")

// test logic:
// Caller : ONLY *Owner*
// var "employee" : not exist, not 0x0, not owner
// var "salary" : > 0, sum(salary)< max(uint256)
// var not affect by any other functions


contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employee_background = accounts[1];
  const employee_target = accounts[2];
  const employee = accounts[1];
  const guest = accounts[5];
  const salary = 10;

  it("1.a addEmployee() Calling Auth: Owner should be able to add a employee", function () {
    var payroll;
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee_background, salary, {from: owner});
    });
  });

  it("1.b addEmployee() Calling Auth: Guest (~Owner) should not be able to add a employee", function () {
    var payroll;
    return Payroll.new().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee_target, salary, {from: guest});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: Guest execution forbidden");
    });
  });

  it("1.c addEmployee() Calling Auth: Employee (~Owner) should not be able to add a employee", function () {
    var payroll;
    return Payroll.new().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee_target, salary, {from: employee_background});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: Employee execution forbidden");
    });
  });

  it("1.d addEmployee() Calling Auth: Owner should not be able to add as a employee", function () {
    var payroll;
    return Payroll.new().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(owner, salary, {from: owner});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: Guest execution forbidden");
    });
  });

  it("1.e addEmployee() employee check: Duplicate employee should not able to add", function () {
    var payroll;
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee_background, salary, {from: owner});
    }).then(() => {
      return payroll.addEmployee(employee_background, salary, {from: owner});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: duplicate employee insertation");
    });
  });

  it("1.f addEmployee() employee check: multiple insertion", function () {
    var payroll;
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee_background, salary, {from: owner});
    }).then(() => {
      return payroll.addEmployee(employee_target, salary, {from: owner});
    }).then(() => {
      return  payroll.employees.call(employee_target);
    }).then((employee) => {
      let employeeSalary = employee[1]; // salary 
      assert.equal(salary * 1000000000000000000, employeeSalary.toNumber(), "Salary not correct");
    }).then(() => {
      return  payroll.employees.call(employee_background);
    }).then((employee) => {
      let employeeSalary = employee[1]; // salary 
      assert.equal(salary * 1000000000000000000, employeeSalary.toNumber(), "Salary not correct");
    });
  });

  it("1.g addEmployee() employee check: address 0x0 not be able to add", function () {
    var payroll;
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee('0x0000000000000000000000000000000000000000', salary, {from: owner});
    }).then(assert.fail).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: total salary will overflow");
    });
  });

  it("1.h addEmployee() salary check: 0 salary", function () {
    var payroll;
    return Payroll.new().then(function (instance) {
      payroll = instance;
      return payroll.addEmployee(employee_target, 0, {from: owner});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: Salary == 0 not support");
    });
  });
 
  it("1.i addEmployee() salary check: super large salary amount: 10 + 2^256 - 2", function () {
    var payroll;
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee_background, salary, {from: owner});
    }).then(() => {
      var superLarge = 0 - salary + 2;
      return payroll.addEmployee(employee_target, superLarge, {from: owner});
    }).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Error: super large salary not support");
    });
  });

});
