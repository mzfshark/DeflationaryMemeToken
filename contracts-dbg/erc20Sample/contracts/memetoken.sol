// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeflationaryToken is IERC20 {
    using SafeMath for uint256;
    using Address for address;

    string public constant name = "[TEST] Deflationary Token";
    string public constant symbol = "DFT04";
    uint8 public constant decimals = 18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 1000000000 * 10**18;

    address public constant burnAddress1 = 0x000000000000000000000000000000000000dEaD;
    address public constant burnAddress2 = 0x0000000000000000000000000000000000000000;
    address public constant liquidityWallet = 0x2C604d9E15e6524F0bB2a2A22F63a7Ca041e84C3;
    address public constant treasuryWallet = 0xcC5e043C5142033a800A72286356317dAcb57A77;

    uint256 public constant liquidityFee = 50;
    uint256 public constant treasuryFee = 90;
    uint256 public constant sellFee = 30;
    uint256 public constant burnRate = 30;

    constructor () {
        _balances[liquidityWallet] = _totalSupply;
        emit Transfer(address(0), liquidityWallet, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply.sub(_balances[burnAddress1]).sub(_balances[burnAddress2]);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 liquidityAmount = amount.mul(liquidityFee).div(100);
        uint256 treasuryAmount = amount.mul(treasuryFee).div(100);
        uint256 sellAmount = recipient == burnAddress1 || recipient == burnAddress2 ? amount.mul(sellFee).div(100) : 0;
        uint256 burnAmount = amount.mul(burnRate).div(100);

        uint256 totalFee = liquidityAmount.add(treasuryAmount).add(sellAmount);
        uint256 receiveAmount = amount.sub(totalFee).sub(burnAmount);

        _balances[sender] = senderBalance.sub(amount);
        _balances[recipient] = _balances[recipient].add(receiveAmount);
        _balances[liquidityWallet] = _balances[liquidityWallet].add(liquidityAmount);
        _balances[treasuryWallet] = _balances[treasuryWallet].add(treasuryAmount);

        if (sellAmount > 0) {
            _balances[burnAddress1] = _balances[burnAddress1].add(sellAmount.div(2));
            _balances[burnAddress2] = _balances[burnAddress2].add(sellAmount.div(2));
        }

        emit Transfer(sender, recipient, receiveAmount);
        if (totalFee > 0) {
            emit Transfer(sender, liquidityWallet, liquidityAmount);
            emit Transfer(sender, treasuryWallet, treasuryAmount);
        }
        if (burnAmount > 0) {
            emit Transfer(sender, burnAddress1, burnAmount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
