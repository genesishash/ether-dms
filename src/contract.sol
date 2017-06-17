pragma solidity ^0.4.8;

contract DeadManSwitch
{
  event RecipientChanged(address _addr);
  event Withdraw(uint _amount, address _addr);
  event Deposit(uint _amount, address _addr);
  event IntervalChanged(uint _days);
  event Heartbeat(uint _time);

  address public owner;
  address public recipient;
  uint public last_heartbeat;
  uint public period_days;

  function() payable {}

  //
  function DeadManSwitch(address recipientAddress,uint periodInDays){
    owner = msg.sender;

    recipient = recipientAddress;
    period_days = periodInDays * 1 minutes;

    last_heartbeat = now;
    Heartbeat(now);
  }

  modifier only_owner(){
    if(msg.sender!=owner) throw;

    last_heartbeat = now;
    Heartbeat(now);

    _;
  }

  function process(){
    if (now <= last_heartbeat + period_days) throw;
    selfdestruct(recipient);
  }

  function heartbeat() only_owner returns(bool) {
    return true;
  }

  function withdraw(uint amount,address recipientAddress) only_owner {
    recipientAddress.transfer(amount);
    Withdraw(amount,recipientAddress);
  }

  function changeRecipient(address recipientAddress) only_owner {
    recipient = recipientAddress;
    RecipientChanged(recipientAddress);
  }

  function changeInterval(uint periodInDays) only_owner {
    period_days = periodInDays * 1 minutes;
    IntervalChanged(periodInDays);
  }

  function kill() only_owner {
    selfdestruct(owner);
  }
}

