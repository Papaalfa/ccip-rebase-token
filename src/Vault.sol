// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IRebaseToken } from "./interfaces/IRebaseToken.sol";

contract Vault {
    IRebaseToken public immutable I_REBASE_TOKEN;

    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    error Vault__RedeemFailed();

    constructor(IRebaseToken _rebaseToken) {
        I_REBASE_TOKEN = _rebaseToken;
    }

    // allows the contract to receive rewards
    receive() external payable {}
    
    /**
     * @dev Deposits underlying asset and mints rebase token
     * 
     */
    function deposit() external payable {
        I_REBASE_TOKEN.mint(msg.sender, msg.value, I_REBASE_TOKEN.getInterestRate());
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev redeems rebase token for the underlying asset
     * @param _amount the amount being redeemed
     *
     */
    function redeem(uint256 _amount) external {
        if (_amount == type(uint256).max) {
            _amount = I_REBASE_TOKEN.balanceOf(msg.sender);
        }
        I_REBASE_TOKEN.burn(msg.sender, _amount);
        // executes redeem of the underlying asset
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender, _amount);
    }
}