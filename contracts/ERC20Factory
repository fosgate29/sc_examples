pragma solidity 0.6.2;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC20Contract.sol";
import "./ERC20Vault.sol";
import "./DaiToken.sol";
import "./ReadableI.sol";


contract ERC20Factory is Ownable{

    ERC20Vault public trustedVault;
    DaiToken public daiToken;
    ReadableI public makerDAOMedianizer;

    mapping(address => address) public tokenRegister;

    constructor (address _daiToken, address _makerDAOMedianizer) public {
        trustedVault = new ERC20Vault();
        daiToken = DaiToken(_daiToken);
        makerDAOMedianizer = ReadableI(_makerDAOMedianizer);
    }

    //Carol goes and creates 100CarolTokenDebts
    function createERC20(
        string calldata _name,
        string calldata _symbol,
        uint256 _usdAmount) external {

        ERC20Contract newERC20TokenDebt = new ERC20Contract(_name,
                                        _symbol,
                                        msg.sender,
                                        _usdAmount);

        tokenRegister[address(newERC20TokenDebt)] = msg.sender;
    }

    //Dai source code https://github.com/makerdao/dss/blob/6fa55812a5fcfcfa325ad4d9a4d0ca4033c38cab/src/dai.sol
    function createERC20_Dai(
        string calldata _name,
        string calldata _symbol,
        uint256 _initialBalance,
        address _debtOwner,
        uint256 _daiAmount) external {

        require(daiToken.balanceOf(msg.sender) >= _daiAmount, "ERC20Factory: Insufficient balance in faucet for withdrawal request");
		        
        //it will transfer from msg.sender to _debtOwner x amount of Dai                
		daiToken.transfer(_debtOwner, _daiAmount);

        ERC20Contract newERC20TokenDebt = new ERC20Contract(_name,
                                        _symbol,
                                        msg.sender,
                                        _initialBalance);

        address[] storage tokenList = tokenRegister[_debtOwner];
        tokenList.push(address(newERC20TokenDebt));                                         

    }
}
