// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestUsdt is ERC20 {
    constructor() ERC20("USDT Test", "tUSDT") {
        _mint(msg.sender, 1000000000000 * 10 ** decimals());
    }
}
