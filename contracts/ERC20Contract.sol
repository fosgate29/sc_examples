pragma solidity 0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract ERC20Contract is ERC20Burnable {

    constructor (
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialBalance
    ) public ERC20(name, symbol) {
        _mint(initialAccount, initialBalance);
    }
}
