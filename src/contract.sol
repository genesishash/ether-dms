pragma solidity ^0.4.8;

contract DeadSwitch
{
  event ContractCreated();
  event RecipientChanged(address _addr);
  event Withdraw(uint _amount, address _addr);
  event Deposit(uint _amount, address _addr);
  event IntervalChanged(uint _days);
  event PayloadDumped(address _addr);

  event Heartbeat();
  event Ping();

  address owner;
  address recipient;

  uint public last_ping;
  uint public last_heartbeat;
  uint public period_days;

  //
  function DeadSwitch(address recipient_address,uint period_in_days){
    owner = msg.sender;

    recipient = recipient_address;
    period_days = period_in_days * 1 minutes;

    ContractCreated();

    last_heartbeat = now;
    Heartbeat();
  }

  modifier only_owner(){
    if(msg.sender!=owner) throw;
    last_heartbeat = now;
    Heartbeat();
    _;
  }

  //
  function ping(){
    last_ping = now;
    Ping();

    if (now <= last_heartbeat + period_days) throw;

    PayloadDumped(recipient);
    selfdestruct(recipient);
  }

  function heartbeat() only_owner {
    last_heartbeat = now;
    Heartbeat();
  }

  function withdraw(uint amount,address recipient_address) only_owner {
    Withdraw(amount,recipient_address);
    recipient_address.transfer(amount);
  }

  function change_recipient(address recipient_address) only_owner {
    recipient = recipient_address;
    RecipientChanged(recipient_address);
  }

  function change_interval(uint period_in_days) only_owner {
    period_days = period_in_days * 1 minutes;
    IntervalChanged(period_in_days);
  }

  function kill() only_owner {
    selfdestruct(owner);
  }
}

