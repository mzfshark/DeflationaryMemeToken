// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ThinkinCoinToken is ERC20, Ownable {
    address public liquidityWallet;
    address public treasuryWallet;
    
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** 18); // 1 billion tokens, 18 decimal places

    uint256 public liquidityFee = 25; // 0.25%
    uint256 public treasuryFee = 50; // 0.5%
    uint256 public sellFee = 5; // 0.05%
    uint256 public burnRate = 20; // 0.20%

    constructor(address _liquidityWallet, address _treasuryWallet) ERC20("ThinkinCoinToken", "COINT") {
        liquidityWallet = _liquidityWallet;
        treasuryWallet = _treasuryWallet;
        _mint(liquidityWallet, INITIAL_SUPPLY);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return super.transfer(recipient, applyFees(msg.sender, recipient, amount));
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        return super.transferFrom(sender, recipient, applyFees(sender, recipient, amount));
    }

    function applyFees(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (recipient == DEAD || recipient == ZERO || sender == liquidityWallet || sender == treasuryWallet) {
            return amount;
        }

        uint256 liquidityFeeAmount = amount * liquidityFee / 10000;
        uint256 treasuryFeeAmount = amount * treasuryFee / 10000;
        uint256 burnAmount = amount * burnRate / 10000;

        if (recipient != liquidityWallet) {
            super.transfer(liquidityWallet, liquidityFeeAmount);
        }

        if (recipient != treasuryWallet) {
            super.transfer(treasuryWallet, treasuryFeeAmount);
        }

        _burn(sender, burnAmount);

        uint256 sellFeeAmount = 0;
        if (sender != liquidityWallet && sender != treasuryWallet) {
            sellFeeAmount = amount * sellFee / 10000;
            super.transfer(liquidityWallet, sellFeeAmount);
        }

        return amount - liquidityFeeAmount - treasuryFeeAmount - burnAmount - sellFeeAmount;
    }

    function setFees(uint256 _liquidityFee, uint256 _treasuryFee, uint256 _sellFee, uint256 _burnRate) external onlyOwner {
        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        sellFee = _sellFee;
        burnRate = _burnRate;
    }
}
