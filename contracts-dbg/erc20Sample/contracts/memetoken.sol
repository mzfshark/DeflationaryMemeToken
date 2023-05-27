// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DeflationaryToken is ERC20 {
    using SafeMath for uint256;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    address private liquidityWallet = 0x2C604d9E15e6524F0bB2a2A22F63a7Ca041e84C3;
    address private treasuryWallet = 0xcC5e043C5142033a800A72286356317dAcb57A77;

    uint256 private maxFee = 2 * 10 ** 2;
    uint256 private liquidityFee = 5 * 10 ** 1;
    uint256 private treasuryFee = 9 * 10 ** 1;
    uint256 private sellFee = 3 * 10 ** 1;
    uint256 private burnRate = 3 * 10 ** 1;

    constructor() ERC20("DeflationaryToken", "DTK") {
        _mint(liquidityWallet, 1000000000 * (10 ** uint256(decimals())));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (recipient == DEAD || recipient == ZERO) {
            super._transfer(sender, recipient, amount);
        } else {
            uint256 liquidityAmount = amount.mul(liquidityFee).div(maxFee);
            uint256 treasuryAmount = amount.mul(treasuryFee).div(maxFee);
            uint256 sellAmount = amount.mul(sellFee).div(maxFee);
            uint256 burnAmount = amount.mul(burnRate).div(maxFee);

            super._transfer(sender, liquidityWallet, liquidityAmount);
            super._transfer(sender, treasuryWallet, treasuryAmount);
            super._transfer(sender, DEAD, burnAmount);

            uint256 sendAmount = amount.sub(liquidityAmount).sub(treasuryAmount).sub(sellAmount).sub(burnAmount);
            super._transfer(sender, recipient, sendAmount);
        }
    }
}
