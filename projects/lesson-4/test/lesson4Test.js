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
  it("1、合约所有者调用addEmployee()", function () {
    var payroll;
  
    return Payroll.new().then(instance => {
      payroll = instance;
      console.log("合约所有者调用addEmployee()");
      console.log("设置薪酬为1ether");
      return payroll.addEmployee(employee, salary, {from: owner});//it's resolve
    }).then(function() {
      console.log("操作结果：成功!!");
      console.log("检测地址 employees['"+employee+"']");
      return payroll.employees.call(employee);
    }).then(
      function(storedData) {
        console.log("操作成功，当前添加的账户是：",storedData[0]);
        console.log("账户工资：",web3.fromWei(storedData[1].toNumber(), 'ether'),'ether');
  
    });
  });

//Test02:传入负值的薪酬
it("测试传入负的薪酬", function () {
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
    assert.include(error.toString(), "Error: VM Exception", "Wrong!");
  });
});

//Test03：合约中employeeCall
it("测试员工调用addEmployee", function () {
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
it("测试访客调用addEmployee", function () {
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

it("2、removeEmployee函数", function() {
  return Payroll.deployed().then(function(instance) {
    payroll = instance;
    console.log("删除账号：",employee);
    return payroll.removeEmployee(employee,{from: accounts[0]});
  }).then(function(storedData) {
    console.log("地址删除地功");
    console.log("检测地址 employees['"+employee+"']");
    return payroll.employees.call(employee); 
  }).then(function(storedData) {
    console.log("检测结果：");
    console.log("账户地址：",storedData[0]);
    console.log("账户工资：",web3.fromWei(storedData[1].toNumber(), 'ether'),'ether');
    console.log("上次支付时间：",storedData[2].toNumber());
    var address = web3.toBigNumber(storedData[0]).toNumber();
    assert.equal(address, 0, "测试失败！");   
  });
});


it("3、getPaid()函数", function() {
  return Payroll.deployed().then(function(instance) {
    payroll = instance;
    console.log("3、getPaid()函数");
    console.log("RPC系统时间已经过了10秒");
    web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [10], id: 0});
    console.log("领工资账号：",employee);
    return payroll.getPaid({from: employee});
  }).then(function() {
    console.log("操作结果：成功!!");
    console.log("检测员工信息 employees['"+employee+"']");
    return payroll.employees.call(employee);
  }).then(function(storedData) {
    console.log("检测结果:");
    console.log("账户地址：",storedData[0]);
    console.log("账户工资：",web3.fromWei(storedData[1].toNumber(), 'ether'),'ether');
    console.log("上次支付时间：",storedData[2].toNumber());
  });
});
});