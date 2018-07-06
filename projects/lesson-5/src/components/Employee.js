import React, { Component } from 'react'
import { Card, Col, Row, Layout, Alert, message, Button } from 'antd';

import Common from './Common';

class Employer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      salary: 0,
      lastPaidDate:0,
      balance:0
    };
    this.staticAccount = '0x44cefc060bbe286ebb3785dca45bdb61abe12749';
  }

  componentDidMount() {
    this.checkEmployee();
  }

  checkEmployee = () => {
    //const { account, payroll, web3 } = this.props;
    const { payroll, web3 } = this.props;
    var account = this.staticAccount;

    payroll.getEmployeeInfoById.call(account, {from:account}).then((result) => {
      this.setState({
        salary: web3.fromWei(result[0].toNumber()),
        lastPaidDate: new Date(result[1].toNumber()*1000).toString(),
        balance: web3.fromWei(result[2].toNumber())
      })
    });
  }

  getPaid = () => {
    //const { account, payroll, web3 } = this.props;
    const { payroll, web3 } = this.props;
    var account = this.staticAccount;
    
    payroll.getPaid({from:account, gas:3000000}).then( () => {
      this.checkEmployee();
    }).catch(() => {
      message.error('周期没到或者老板跑路');
    })
  }

  renderContent() {
    const { salary, lastPaidDate, balance } = this.state;

    if (!salary || salary === '0') {
      return   <Alert message="你不是员工" type="error" showIcon />;
    }

    return (
      <div>
        <Row gutter={16}>
          <Col span={8}>
            <Card title="薪水">{salary} Ether</Card>
          </Col>
          <Col span={8}>
            <Card title="上次支付">{lastPaidDate}</Card>
          </Col>
          <Col span={8}>
            <Card title="帐号金额">{balance} Ether</Card>
          </Col>
        </Row>

        <Button
          type="primary"
          icon="bank"
          onClick={this.getPaid}
        >
          获得酬劳
        </Button>
      </div>
    );
  }

  render() {
    const { account, payroll, web3 } = this.props;
    
    return (
      <Layout style={{ padding: '0 24px', background: '#fff' }}>
        <Common account={account} payroll={payroll} web3={web3} />
        <h2>个人信息</h2>
        {this.renderContent()}
      </Layout >
    );
  }
}

export default Employer
