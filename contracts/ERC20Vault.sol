pragma solidity 0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Adapted from Open Zeppelin's RefundVault

/**
 * @title Vault
 * @dev This contract is used for storing funds.
 */
contract ERC20Vault is Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public deposits;

    constructor() public
    {
    }

    function depositValue(address payable _beneficiary) external onlyOwner payable
    {
        require(msg.value > 0, "ERC20Vault: Value must be greater than 0");
        require(_beneficiary != address(0), "ERC20Vault: Beneficiary cannot be 0x");

        uint256 balance = deposits[_beneficiary];
        balance = balance.add(msg.value);

        deposits[_beneficiary] = balance;
    }

    function witdraw() external
    {
        uint256 balance = deposits[msg.sender];
        require(balance > 0, "ERC20Vault: Witdraw not allowed if deposit balance is 0.");
        deposits[msg.sender] = 0;

        (bool success, ) = msg.sender.call.value(balance)("");
        require(success, "Transfer failed.");
    }
}
