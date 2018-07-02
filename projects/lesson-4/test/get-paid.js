var Payroll = artifacts.require("./Payroll.sol");

// logic:
// auth: employee
// function: after pay duration, get paid once, otherwise no paid
// Pay currect case: check contract balance(new=old-salary) 
//       and employee balance(new = old+salary-gasCost)
// Cases type: same as liao



contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[5];
  const salary = 1;
  const runway = 20;
  const payDuration = (31) * 86400;
  const fund = runway * salary;

  it("Test getPaid() function: get pay in a duration ", function () {
    var payroll;
    var contractBalance;
    var employeeBalance;
    var gasPrice = 20000000000;
    return Payroll.new.call(owner, {from: owner, value: web3.toWei(fund, 'ether')}).then(instance => {
      payroll = instance;
      return payroll.addEmployee(employee, salary, {from: owner});
    }).then(() => {
      return web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [payDuration], id: 0});
    }).then(() => {
      contractBalance = web3.eth.getBalance(payroll.address).toNumber();
      employeeBalance = web3.eth.getBalance(employee).toNumber();
      return payroll.getPaid({from: employee, gasPrice:gasPrice});
    }).then((result) => {
      var contractBalanceNow = web3.eth.getBalance(payroll.address).toNumber();
      var employeeBalanceNow = web3.eth.getBalance(employee).toNumber();
      var gasUsed = result.receipt.gasUsed;
      //var gasPrice = web3.eth.gasPrice; // this is not the actual price of the previous transaction
      var gasCost = Number(gasPrice)*Number(gasUsed);
      //console.log("gas price: "+ gasPrice);
      assert.equal(contractBalanceNow, contractBalance - web3.toWei(salary, 'ether'), "Contract value should recude exact as the salary");
      assert.equal(employeeBalanceNow, Number(employeeBalance)+Number(web3.toWei(salary,'ether'))-Number(gasCost), "employeeBalanceNow = employeeBalanceOld+salary-gasCost");
    });
  });

  it("Test getPaid() before duration", function () {
    var payroll
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

  it("Test getPaid() by a non-employee", function () {
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