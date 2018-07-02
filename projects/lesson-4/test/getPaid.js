var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[5];
  const salary = 1;
  const runway = 20;
  const payDuration = (30 + 1) * 86400;
  const fund = runway * salary;

  it("3.1-合约创建者调用getPaid()", function () {
    var payroll;
    return Payroll.new.call(owner, {from: owner, value: web3.toWei(fund, 'ether')}).then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    }).then(() => {
      return payroll.calculateRunway();
    }).then(runwayRet => {//检验calculateRunway()返回的是否整数？？？
      if (!runwayRet.toNumber || typeof runwayRet.toNumber !== "function") {
        assert(false, "the function `calculateRunway()` should be defined as: `function calculateRunway() public view returns (uint)` | `calculateRunway()` 应定义为: `function calculateRunway() public view returns (uint)`");
      }
      assert.equal(runwayRet.toNumber(), runway, "Runway is wrong");
      return web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration], id: 0}); //通过增加时间超过payDuration
    }).then(() => {
      return payroll.getPaid({from: employee})
    }).then((getPaidRet) => {
      return payroll.calculateRunway();
    }).then(runwayRet => {
      assert.equal(runwayRet.toNumber(), runway - 1, "The runway is not correct");
    });
  });

  it("3.2-测试在付薪日之前getPaid()", function () {
    var payroll;
    return Payroll.new.call(owner, {from: owner, value: web3.toWei(fund, 'ether')}).then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    }).then(() => {
      return payroll.calculateRunway();
    }).then(runwayRet => {
      assert.equal(runwayRet.toNumber(), runway, "Runway is wrong");
      return payroll.getPaid({from: employee})
    }).then((getPaidRet) => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Should not getPaid() before a pay duration");
    });
  });

  it("3.3非员工调用getPaid()", function () {
    var payroll;
      return Payroll.new.call(owner, {from: owner, value: web3.toWei(fund, 'ether')}).then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    }).then(() => {
      return payroll.calculateRunway();
    }).then(runwayRet => {
      assert.equal(runwayRet.toNumber(), runway, "Runway is wrong");
      return payroll.getPaid({from: guest})
    }).then((getPaidRet) => {
      assert(false, "Should not be successful");
    }).catch(error => {
      assert.include(error.toString(), "Error: VM Exception", "Should not call getPaid() by a non-employee");
    });
  });
});