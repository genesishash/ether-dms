pragma solidity ^0.4.8;

contract DeadSwitch
{
  event ContractCreated();
  event RecipientChanged(address _addr);
  event Withdraw(uint _amount, address _addr);
  event Deposit(uint _amount, address _addr);
  event IntervalChanged(uint _days);
  event PayloadDumped(address _addr);

  event Heartbeat(uint _time);
  event Ping(bool _dumped);

  address public owner;
  address public recipient;

  uint public last_ping;
  uint public last_heartbeat;
  uint public period_days;

  function() payable {}

  //
  function DeadSwitch(address recipient_address,uint period_in_days){
    owner = msg.sender;

    recipient = recipient_address;
    period_days = period_in_days * 1 minutes;

    ContractCreated();

    last_heartbeat = now;
    Heartbeat(now);
  }

  modifier only_owner(){
    if(msg.sender!=owner) throw;
    _;
    last_heartbeat = now;
    Heartbeat(now);
  }

  function ping() returns (bool){
    last_ping = now;
    Ping();

    if (now <= last_heartbeat + period_days){
      return false;
    }

    PayloadDumped(recipient);
    selfdestruct(recipient);

    return true;
  }

  function heartbeat() returns (bool) only_owner {
    return true;
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

