// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


contract PokeToken  {
    uint public poke;

    function increasePoke() payable external virtual  {
        poke++;
    }

    function getPoke() external view returns(uint){
        return poke;
    }
    
    receive () payable external {
        //do nothing
    }
    
    fallback () payable external{
        //do nothing
    }
    
    function getBalance() external view returns(uint){
        return address(this).balance;
    }
}
