let Payroll = artifacts.require("./Payroll.sol");

// test logic:
// Auth: only owner, not guest, not employee
// function: after remove(remove one not existed, other employee exists)


contract('Payroll', (accounts) => {
  const owner = accounts[0];
  const employee = accounts[1];
  const employee2 = accounts[3]
  const guest = accounts[2];
  const salary = 1;

  let payroll;

  beforeEach("Setup contract for each test cases", () => {
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    });
  });

  it("2.a Test removeEmployee() auth: owner", () => {
    // Remove employee
    return payroll.removeEmployee(employee, {from: owner});
  });

  it("2.b Test removeEmployee() auth: guest", () => {
    return payroll.removeEmployee(employee, {from: guest}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
    });
  });

  it("2.c Test removeEmployee() auth: employee", () => {
    return payroll.removeEmployee(employee, {from: guest}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
    });
  });

  it("2.d Test removeEmployee() function: remove one employee", () => {
    return payroll.addEmployee(employee2, salary, {from: owner}).then(() => {
      return payroll.removeEmployee(employee2, {from:owner});
    }).then(()=> {
      // add two employee and delete one, check another
      return payroll.employees.call(employee2);
    }).then((e) => {
      let employeeSalary = e[1]; // salary
      //assert.equal(employeeSalary.toNumber(), 0, "Salary should clean");
      return payroll.employees.call(employee);
    }).then((e) => {
      let employeeSalary = e[1]; // salary
      assert.equal(employeeSalary.toNumber(), salary* 1000000000000000000, "Salary should remain");
    });
  });

  it("2.e Test removeEmployee() function: employee not existed", () => {
    return payroll.removeEmployee(guest, {from: owner}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() for a non existed employee");
    });
  });

});
