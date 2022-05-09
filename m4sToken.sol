// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Meta4SwapToken is ERC20 {
    constructor() {
        totalSupply += 1000;
        balances[msg.sender] += 1000;
    }
}
