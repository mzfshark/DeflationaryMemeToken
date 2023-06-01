// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ThinkinCoinToken is ERC20, Ownable {
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;
    address public treasuryWallet;
    address public liquidityWallet;

    uint256 public constant TREASURY_FEE = 50; //  0.5%
    uint256 public constant LIQUIDITY_FEE = 25; //  0.25%
    uint256 public constant BURN_RATE = 35; //  0.35%
    uint256 public constant TOTAL_SUPPLY = 10000000 * (10 ** 18); // 10 million tokens, scaled by 18 decimal places

    constructor(address _liquidityWallet, address _treasuryWallet) ERC20("Think in Coin", "NEURONS") {
        liquidityWallet = _liquidityWallet;
        treasuryWallet = _treasuryWallet;
        _mint(liquidityWallet, TOTAL_SUPPLY);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return _processTransaction(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return _processTransaction(sender, recipient, amount);
    }

    function _processTransaction(address sender, address recipient, uint256 amount) private returns (bool) {
        uint256 burnAmount = 0;
        uint256 treasuryFee = 0;
        uint256 liquidityFee = 0;

        if (sender != treasuryWallet && sender != liquidityWallet) {
            burnAmount = amount * BURN_RATE / 10000;
            treasuryFee = amount * TREASURY_FEE / 10000;
            liquidityFee = amount * LIQUIDITY_FEE / 10000;
        }

        uint256 transferAmount = amount - burnAmount - treasuryFee - liquidityFee;

        if (burnAmount > 0) {
            _burn(sender, burnAmount);
            _transfer(sender, treasuryWallet, treasuryFee);
            _transfer(sender, liquidityWallet, liquidityFee);
        }
        
        _transfer(sender, recipient, transferAmount);

        return true;
    }
}

