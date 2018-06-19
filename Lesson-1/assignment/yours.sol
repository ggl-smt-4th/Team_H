/*作业请提交在这个目录下*/
/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract payRoll {

	uint salary = 1 ether;
	address staff = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c ;
	uint constant payDuration = 10 seconds;
	uint lastPayday = now;
	address admin;
	
	constructor() public {
	    
	    
	    
	    
	    admin = msg.sender;
	    
	}
	
	modifier ownerOnly {
	    
	    require(msg.sender == admin);
	    _;
	}

	//更改员工地址
	function changeStaffAddress(address newAddress) {

		staff = newAddress;
	}

	//更改员工薪水，以ether为单位
	function changeSalary(uint newSalary) ownerOnly {

		salary = newSalary * 10**18;
	}

	function addFund() payable ownerOnly returns(uint) {

		return this.balance;

	}

	function calculateRunway() returns(uint) {

		return this.balance/salary;

	}

	function hasEnoughFund() returns(bool) {

		return calculateRunway() >= 0;

	}

	function getPaid() {

		if(msg.sender != staff) {

			revert();

		}

		uint nextPayday = lastPayday + payDuration;
		if(nextPayday > now) {

			revert();

		}

		lastPayday = nextPayday;
		staff.transfer(salary);

	}
}
