//引入Payroll这个要测试的合约
var Payroll = artifacts.require("./Payroll.sol");
/*使用contract这个关键词，后面跟了一个字符Payroll，加上一个function。
使用contract的时候truffle会创建一个cleanEnvironment的环境，
帮助我们有一个完全空白的环境，进行合约的测试，
不会影响到当前已经部署到网络上的合约

*/
contract('Payroll', function (accounts) {

  //const形式,表示常量可以是任意合法的表达式
  const owner = accounts[0];
  const employee = accounts[1];
  const guest = accounts[2];
  const salary = 1;

/*it描述我们实际要做的测试，跟上function，先获取了当前已经部署了的payroll的
instance，然后我们调用了addEmployee方程并将参数传入

*/
//Test01:合约所有者call
  it("1.1-合约所有者调用addEmployee()", function () {
    var payroll;
  
    return Payroll.new().then(instance => {
      payroll = instance;
      console.log("合约所有者调用addEmployee()");
      console.log("设置薪酬为1ether");
      return payroll.addEmployee(employee, salary, {from: owner});//it's resolve
    });
  });

//Test02:传入负值的薪酬
it("1.2-测试传入负的薪酬", function () {
  var payroll;
  return Payroll.new().then(instance => {
    payroll = instance;
/*assert.fail:断言失败而不检查任何条件

    promise
  .then(...)    //返回一个新的promise，如果then之前的promise是rejected则延续
  .catch(...);    //又返回一个新的promise，如果catch之前的promise是resolved则延续

  promise
  //返回一个新的promise
  //如果then之前的promise是resolved，则由第一个参数返回
  //如果then之前的promise是rejected，则由第二个参数返回。
  .then(..., ...);    

*/
    return payroll.addEmployee(employee, -salary, {from: owner});
  }).then(assert.fail).catch(error => {
    assert.include(error.toString(), "Error: VM Exception", "Wrong!"); //error.name = "Error:VM Exception" error.message = "Wrong!"
  });
});

//Test03：合约中employeeCall
it("1.3-测试员工调用addEmployee", function () {
  var payroll;
  return Payroll.new().then(function (instance) {
    payroll = instance;

    return payroll.addEmployee(employee, salary, {from: employee});
  }).then(() => {
    assert(false,"false");
  }).catch(error => {
    assert.include(error.toString(),"Error: VM Exception", "Wrong!");
  });
});



//Test04:合约访问者call
it("1.4-测试访客调用addEmployee", function () {
  var payroll;
  return Payroll.new().then(function (instance) {
    payroll = instance;

    return payroll.addEmployee(employee, salary, {from: guest});
  }).then(() => {
    assert(false,"false");
  }).catch(error => {
    assert.include(error.toString(),"Error: VM Exception", "wrong!");
  });
});
});