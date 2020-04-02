pragma solidity ^0.5.13;

/**
 * Simple example of how to use the payload when using call.value
 * 
 **/ 
contract Payloadtest {
    
    bytes32 public functionHash;  //it is public so you can easily check the value
    bytes4 public function4bytes; //it is public so you can easily check the value
    bytes public payload ; //it is public so you can easily check the value
    
    function makeADeposit(address bank ) public payable
    {
        functionHash = keccak256("deposit()");
        
        function4bytes = bytes4(functionHash);

        payload = abi.encode(function4bytes);
        
        if (msg.value > 0) {
            (bool success,) = bank.call.value(msg.value)(payload);
            require(success, "Ether transfer failed.");
        }      
    }
}

contract Bank {
 
  uint public totalDeposit;
  
  function deposit() public payable
  {
      totalDeposit += msg.value;
  }
}
