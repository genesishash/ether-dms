pragma solidity ^0.4.8;

contract DeadManSwitch
{
  event Withdraw(uint _amount, address _address);
  event RecipientChanged(address _address);
  event IntervalChanged(uint days);
  event Heartbeat(uint unixTime);

  address public owner;
  address public recipient;

  uint public lastHeartbeat;
  uint public periodSeconds;

  function() payable {}

  //
  function DeadManSwitch(address recipientAddress,uint periodInDays){
    owner = msg.sender;

    recipient = recipientAddress;
    periodSeconds = periodInDays * 1 days;

    lastHeartbeat = now;
    Heartbeat(now);
  }

  modifier only_owner(){
    if(msg.sender!=owner) throw;

    lastHeartbeat = now;
    Heartbeat(now);

    _;
  }

  // attempt to dump funds
  function process(){

    // throw if owner was active recently
    if (now <= lastHeartbeat + periodSeconds) throw;

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
    periodSeconds = periodInDays * 1 days;
    IntervalChanged(periodInDays);
  }

  function kill() only_owner {
    selfdestruct(owner);
  }
}

