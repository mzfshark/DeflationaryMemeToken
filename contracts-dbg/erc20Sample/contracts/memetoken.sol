// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MemeToken is IERC20, Ownable, ERC20, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 private constant _totalSupply = 1000000 * 10**18; // Initial token supply

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Deflationary mechanism
    uint256 private constant _burnRate = 2; // 2% burn rate on every transaction
    uint256 private constant _maxBurnAmount = 5000 * 10**18; // Maximum burn amount per transaction

    // Fee addresses
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    address public liquidityWallet = 0x2C604d9E15e6524F0bB2a2A22F63a7Ca041e84C3;
    address public treasuryWallet = 0xcC5e043C5142033a800A72286356317dAcb57A77;
    address public rewardsWallet = 0x833123d7AF220758a5484887aC582d4D39e9Ede0;
    
    // Fee configuration
    uint256 private feeDecimals = 18;
    uint256 private feeRate = 2; // 2% fee rate
    uint256 private burnTaxRate = 1; // 1% burn tax rate
    bool private isBurnTaxToZero = true; // Whether to send burn tax fee to ZERO address

    constructor() ERC20("Meme Token", "MEME") {
        _mint(_msgSender(), _totalSupply);
    }

    function collectFeeToTreasury(uint256 amount) private {
        uint256 fee = amount.mul(feeRate).div(10**feeDecimals);
        _transfer(_msgSender(), treasuryWallet, fee);
    }

    function collectFeeToLiquidity(uint256 amount) private {
        uint256 fee = amount.mul(feeRate).div(10**feeDecimals);
        _transfer(_msgSender(), liquidityWallet, fee);
    }

    function collectFeeToRewards(uint256 amount) private {
        uint256 fee = amount.mul(feeRate).div(10**feeDecimals);
        _transfer(_msgSender(), rewardsWallet, fee);
    }

    function sendBurnTaxFee(uint256 amount) private {
        uint256 fee = amount.mul(burnTaxRate).div(10**feeDecimals);
        address feeAddress = isBurnTaxToZero ? ZERO : DEAD;
        _burn(_msgSender(), fee);
        _transfer(_msgSender(), feeAddress, fee);
    }

    function setFees(uint256 _feeRate, uint256 _burnTaxRate, bool _isBurnTaxToZero) external onlyOwner {
        require(_feeRate <= 100, "Invalid fee rate"); // Fee rate should not exceed 100%
        require(_burnTaxRate <= 100, "Invalid burn tax rate"); // Burn tax rate should not exceed 100%

        feeRate = _feeRate;
        burnTaxRate = _burnTaxRate;
        isBurnTaxToZero = _isBurnTaxToZero;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        
        uint256 burnAmount = amount.mul(_burnRate).div(100); // Calculate burn amount
        if (burnAmount > _maxBurnAmount) {
            burnAmount = _maxBurnAmount;
        }

        uint256 transferAmount = amount.sub(burnAmount); // Calculate transfer amount

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(transferAmount);
        _totalSupply = _totalSupply.sub(burnAmount);

        collectFeeToTreasury(amount);
        collectFeeToLiquidity(amount);
        collectFeeToRewards(amount);
        sendBurnTaxFee(amount);

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, address(0), burnAmount);
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
}
