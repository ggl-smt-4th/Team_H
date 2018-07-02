let Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', (accounts) => {
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[2];
  const salary = 1;

  let payroll;

  beforeEach("Setup contract for each test cases", () => {
    return Payroll.new().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    });
  });

  it("2.1-合约所有者调用removeEmployee()", () => {
    // Remove employee
    return payroll.removeEmployee(employee, {from: owner}).then(() => {
    console.log("地址删除地功");
  });
});

  it("2.2-访客调用removeEmployee()", () => {
    return payroll.removeEmployee(employee, {from: guest}).then(() => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Cannot call removeEmployee() by guest");
    });
  });
});

/*删除employee后如何测试是否结清之前已经支付的工资？

  it("2.3-合约所有者调用removeEmployee()", () => {
    // Remove employee
    return payroll.removeEmployee(employee, {from: owner});
  }).then(() => {
    console.log("地址删除地功");
    return payroll.employees.call(employee); 
  }).then(employee => {
    var salary = employee

  })
*/



  