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
  uint public lastHeartbeat;
  uint public periodDays;

  function() payable {}

  //
  function DeadManSwitch(address recipientAddress,uint periodInDays){
    owner = msg.sender;

    recipient = recipientAddress;
    periodDays = periodInDays * 1 minutes;

    lastHeartbeat = now;
    Heartbeat(now);
  }

  modifier only_owner(){
    if(msg.sender!=owner) throw;

    lastHeartbeat = now;
    Heartbeat(now);

    _;
  }

  function process(){
    if (now <= lastHeartbeat + periodDays) throw;
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
    periodDays = periodInDays * 1 minutes;
    IntervalChanged(periodInDays);
  }

  function kill() only_owner {
    selfdestruct(owner);
  }
}

