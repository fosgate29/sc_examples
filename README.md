# Uniswap example
 - https://gist.github.com/ysinha1/a69559b14ca06ec9f66ec409a27256fe

# HardHat using TypeScript example:
 - https://github.com/wighawag/hardhat-deploy-ts-test
 
# Logs events
 - https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-16e?utm_source=substack&utm_medium=email

# Apache Ethereum workflow
 - https://www.youtube.com/watch?v=hXrULXAi9qM

# Libraries

 - Calendar solidity api - https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
 - Sorting - https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d
 - Bytes - https://github.com/GNSPS/solidity-bytes-utils

# Tutorials:
 - Go and Ethereum - https://medium.com/coinmonks/web3-go-part-1-31c68c68e20e
 - Blockchain explorer - https://medium.com/unibrightio/transthereum-unibrights-open-source-blockchain-explorer-for-developers-2894d0bac293
 - Create a Dapp - https://medium.com/@austin_48503/tl-dr-scaffold-eth-ipfs-20fa35b11c35
 - Strings - https://www.youtube.com/watch?v=gNlwpr3vGYM 
 - Web3 Providers - https://0x.org/docs/guides/web3-provider-explained#notes-on-ledger-subprovider
 - Node - https://diligence.consensys.net/blog/2020/06/legions-a-tool-for-seekers/
 - Upgrade contract - https://yos.io/2018/10/28/upgrading-solidity-smart-contracts/

# Testing
 - https://forum.openzeppelin.com/t/test-smart-contracts-like-a-rockstar/1001

# Solidity Patterns:
 - https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb
 - Factory - https://soliditydeveloper.com/clonefactory
 - https://soliditydeveloper.com/prevrandao (random number)
 
# Gas Optimization
 - https://medium.com/@ayomilk1/maximizing-efficiency-how-gas-optimization-can-streamline-your-smart-contracts-4bafcc6bf321
 - https://medium.com/@bloqarl/save-over-a-hundred-thousand-gas-with-this-solidity-gas-optimization-tip-ba791d6acafd

# Clean code:
 - https://www.wslyvh.com/clean-contracts/

- verify if data is comming from storage. If it is, if it is called more than once it should be a local variable to avoid getting data from storage
- add require at the beginning of the function
- if event is in a onlyOwner function, it isn't necessary to add sender
- NATSPEC examples: https://github.com/primitivefinance/rmm-core/blob/main/contracts/PrimitiveEngine.sol
- https://m1guelpf.blog/d0gBiaUn48Odg8G2rhs3xLIjaL8MfrWReFkjg8TmDoM (optimization tips)
- https://typefully.com/PaulRBerg/nkgrFkU?utm_source=substack&utm_medium=email (more optimization tips)

- https://dacian.me/precision-loss-errors?utm_source=substack&utm_medium=email (precision loss)
 
# Javascript tips:
 - https://kentcdodds.com/blog/javascript-to-know-for-react
 - https://staltz.com/your-ide-as-a-presentation-tool.html
 - Security: https://www.npmjs.com/package/audit-ci  and https://www.npmjs.com/package/@lavamoat/allow-scripts
 
# Tools to help:
`grep \"bytecode\" build/contracts/* | awk '{print $1 " " length($3)/2}'`  (Truffle)

`grep \"bytecode\" artifacts/contracts/*.sol/* | awk '{print $1 " " length($3)/2}'` (Hardhat)

sudo lsof -i -P -n | grep LISTEN  (list all ports in use)
 
# Build NFT app - in Polygon

https://dev.to/dabit3/building-scalable-full-stack-apps-on-ethereum-with-polygon-2cfb

# NFT optimization

https://medium.com/@WallStFam/the-ultimate-guide-to-nft-gas-optimization-7e9289e2d88f

# DAO

https://alisha.mirror.xyz/BIymDSUSm_Di9kS1MafI4ct7IWXPd1LVlgYM2C9A-qc?utm_source=substack&utm_medium=email

# Login

https://www.rainbowkit.com/docs/authentication

# Smart Contracts Examples

ERC1155 using bitmap, optmized: https://etherscan.io/address/0xdfaa1a2d917df08ea9eae22fec2dd729aa93f97b#code

# Docker help
```
docker kill $(docker ps -q)
docker rm $(docker ps -aq)
docker network rm $(docker network ls -q)
docker image rm $(docker image ls -q) -f
docker volume rm $(docker volume ls -q)
docker system prune
docker system prune --volumes
```

---

## 1. How to use call.value
Recently someone asked me about the difference between `transfer()` and `call.value`. Why people were talking about it now? Well, it happened because of Istanbul hard fork in 2019. Gas cost of the SLOAD operation increased, causing a contract's fallback function to cost more than 2300 gas. So everybody should stop using `.transfer()` and `.send()` and instead use `.call()`. More information you can have at this very good repo, Secure Development Recommendations, maintained by ConsenSys Diligence: https://consensys.github.io/smart-contract-best-practices/recommendations/#dont-use-transfer-or-send.

You can easily find a bunch of examples of how to use this new standard, ig, [here](https://ethereum.stackexchange.com/questions/6707/whats-the-difference-between-call-value-and-call-value) and [here](https://solidity-by-example.org/sending-ether/).

But let's talk about one specific topic: the payload. All examples have just a simple ether transfer, `msg.sender.call.value(amount)("")`. What is calling some attention is the 2nd parameter, the empty string **""**. I am going to explain how to use it.

First, let's check how a very simple withdraw() function works:
```
function withdraw(uint256 amount) external {
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed.");
    }
```
But what happens if you would like to send ether to another smart contract? It is almost the same. In my simple example, Bank is a smart contract that has a payable fallback function.

```
function deposit(address bank) external payable {
        (bool success, ) = bank.call.value(msg.value)("");
        require(success, "Transfer failed.");
    }
```

So far so good. Now you would like to send ether to a function called deposit() from Bank smart contract. How to do it? It is also pretty simple. But because of the lack of information, I decided to explain it with more details.

```
function makeDeposit(address bankAddress) public payable {
        bytes32 functionHash = keccak256("deposit()");      
        bytes4 function4bytes = bytes4(functionHash);
        bytes payload = abi.encode(function4bytes);
        
        if (msg.value > 0) {
            (bool success,) = bankAddress.call.value(msg.value)(payload);
            require(success, "Ether transfer failed.");
        }      
    }
```
 - **functionHash** is going to be equal to **0xd0e30db0**3f2e24c6531d8ae2f6c09d8e7a6ad7f7e87a81cb75dfda61c9d83286. The part that is in bold is just to highlight the next step.

 - We just need the first 4 bytes from the function hash, so **function4bytes** is equal to **0xd0e30db0**.

 - **payload** is the result that we want to be used inside call.value. And it is equal to **0xd0e30db000000000000000000000000000000000000000000000000000000000**

I hope that writing in 3 steps you can better understand what is needed to be able to send ether to another smart contract. I created a small test so you can see it in action using [Remix](https://remix.ethereum.org/) here [contracts/Payloadtest.sol](contracts/Payloadtest.sol)
