# Meme Token Deflationary Project

This Solidity contract represents a customized ERC20 token with deflationary and fee transfer characteristics. 
It inherits from the OpenZeppelin library's ERC20 and Ownable contracts.


### Here's a breakdown of the key parts of this contract:

`Address Variables`: The contract has addresses for a liquidity wallet, a treasury wallet, and two burn addresses.

`Supply`: The initial supply is set to 1 billion tokens, which aligns with the standard 18 decimal places of ERC20 tokens. The supply is minted to the liquidity wallet at the time of deployment.

`Fees and Burn Rate`': The contract sets a liquidity fee, a treasury fee, a selling fee, and a burn rate. These values are represented per 10,000 (i.e., 25 means 0.25%, 50 means 0.5%, and so on).

```sh    
    uint256 public liquidityFee = 25; // 0.25%
    uint256 public treasuryFee = 50; // 0.5%
    uint256 public sellFee = 5; // 0.05%
    uint256 public burnRate = 20; // 0.20%
```

`Constructor`: During the deployment of the contract, the liquidity and treasury wallets' addresses are initialized using the parameters of the constructor function. It also mints the initial supply to the liquidity wallet.

`Transfer and TransferFrom Functions`: These functions override the standard ERC20 transfer and transferFrom functions. They apply the defined fees and the burn rate before making the transfer. The fee amounts are transferred to the corresponding wallets, and the burn amount is destroyed from the sender's balance.

`ApplyFees Function`: This function applies the fees and the burn rate. It checks if the transaction is being made to or from one of the special addresses (burn addresses, the liquidity wallet, or the treasury wallet). It calculates the amounts for each fee and the burn based on the transaction amount. The fee amounts are transferred to the appropriate wallets, the burn amount is destroyed from the sender's balance, and the remaining amount is returned.

`setFees Function`: This function allows the contract owner to change the fee rates and the burn rate. This function is only executable by the owner of the contract due to the onlyOwner modifier.

Please note that while this code could be a good start for a deflationary token, it's important to conduct thorough testing, auditing, and potentially add more functionalities depending on your needs before using it in a production environment.
