# DAI testnet
 - Kovan Medianizer: https://kovan.etherscan.io/address/0x9FfFE440258B79c5d6604001674A4722FfC0f7Bc 
 - Kovan DAI: https://kovan.etherscan.io/address/0x08ae34860fbfe73e223596e65663683973c72dd3

# Libraries

 - Calendar solidity api - https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
 - Sorting - https://medium.com/coinmonks/sorting-in-solidity-without-comparison-4eb47e04ff0d

# Tutorials:
 - Go and Ethereum - https://medium.com/coinmonks/web3-go-part-1-31c68c68e20e
 - Blockchain explorer - https://medium.com/unibrightio/transthereum-unibrights-open-source-blockchain-explorer-for-developers-2894d0bac293
 - Create a Dapp - https://medium.com/@austin_48503/tl-dr-scaffold-eth-ipfs-20fa35b11c35
 - Strings - https://www.youtube.com/watch?v=gNlwpr3vGYM 

# Solidity Patterns:
 - https://dev.to/mudgen/understanding-diamonds-on-ethereum-1fb
 - Factory - https://soliditydeveloper.com/clonefactory
 
# Smart Contracts Examples

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
