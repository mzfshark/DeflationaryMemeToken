# Meme Token Deflationary Project

This Solidity contract represents a customized ERC20 token with deflationary and fee transfer characteristics. 
It inherits from the OpenZeppelin library's ERC20 and Ownable contracts.


### Here's a breakdown of the key parts of this contract:

`Address Variables`: The contract has addresses for a liquidity wallet, a treasury wallet, and two burn addresses.

`Supply`: The initial supply is set to 1 billion tokens, which aligns with the standard 18 decimal places of ERC20 tokens. The supply is minted to the liquidity wallet at the time of deployment.

`Fees and Burn Rate`': The contract sets a liquidity fee, a treasury fee, a selling fee, and a burn rate. These values are represents 1% for each transaction. 0.8% its fee distributed to Treasury (0.5%) and Liquidity Wallets(0.3%) and 0.2% is only for deflationary mechanism (Burned automaticaly). 

```sh    
    uint256 public liquidityFee = 25; // 0.25%
    uint256 public treasuryFee = 50; // 0.5%
    uint256 public sellFee = 5; // 0.05%
    uint256 public burnRate = 20; // 0.20%
```

`Constructor`: During the deployment of the contract, the liquidity and treasury wallets' addresses are initialized using the parameters of the constructor function. It also mints the initial supply to the liquidity wallet.

`Transfer and TransferFrom Functions`: These functions override the standard ERC20 transfer and transferFrom functions. They apply the defined fees and the burn rate before making the transfer. The fee amounts are transferred to the corresponding wallets, and the burn amount is destroyed from the sender's balance.

`ApplyFees Function`: This function applies the fees and the burn rate. It checks if the transaction is being made to or from one of the special addresses (burn addresses, the liquidity wallet, or the treasury wallet). It calculates the amounts for each fee and the burn based on the transaction amount. The fee amounts are transferred to the appropriate wallets, the burn amount is destroyed from the sender's balance, and the remaining amount is returned.

```sh
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
```

`setFees Function`: This function allows the contract owner to change the fee rates and the burn rate. This function is only executable by the owner of the contract due to the onlyOwner modifier. This will seted to turn more easy for futures adjustments on tokenomics and its higly recomended to be voted by community / developers before change it.  

Please note that while this code could be a good start for a deflationary token, it's important to conduct thorough testing, auditing, and potentially add more functionalities depending on your needs before using it in a production environment.
