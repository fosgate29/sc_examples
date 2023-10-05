// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * Simple example of how to use the payload when using call.value
 **/ 
contract Payloadtest {
    
    bytes32 public functionHash;  //it is public so you can easily check the value
    bytes4 public function4bytes; //it is public so you can easily check the value
    bytes public payload ; //it is public so you can easily check the value
    
    /**
     * It sends the value to the Bank smart contract calling deposit() function.
     * It shows that seding the 4 bytes of the hash of deposit() as the payload is like calling the deposit() function from
     * Bank contract
     * @param bank Bank contract address
     */
    function makeADeposit(address bank ) public payable
    {
        functionHash = keccak256("deposit()");
        function4bytes = bytes4(functionHash);
        payload = abi.encode(function4bytes);
        
        if (msg.value > 0) {
            (bool success,) = bank.call{value: msg.value}(payload);
            require(success, "Ether transfer failed.");
        }      
    }
    
    /**
     * It sends the value to the Banck smart contract. Since payload is empty, it
     * is like sending value to the smart contract.
     * @param bank Bank contract address
     */
    function makeATransfer(address bank ) public payable
    {
        if (msg.value > 0) {
            (bool success,) = bank.call{value: msg.value}("");
            require(success, "Ether transfer failed.");
        }      
    }
}


contract Bank {
 
  uint256 public totalDeposit;
  
  event Received(address, uint256);
  
  /// @dev Updates totalDeposit 
  function deposit() public payable
  {
      totalDeposit += msg.value;
  }
  
  /// @dev returns the Bank contract balance
  function balance() external view returns(uint256)
  {
      return address(this).balance;
  }
  
  /// @dev This is the function that is executed on plain Ether transfers 
  receive() external payable {
      totalDeposit += msg.value;
      emit Received(msg.sender, msg.value);
  }
}
