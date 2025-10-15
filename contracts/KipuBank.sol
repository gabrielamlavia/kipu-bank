// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @notice A secure decentralized vault for native ETH deposits.
/// @author Gabriela Lavia
contract KipuBank {

    // ----------- Errors -----------
    /// @param amount The invalid amount passed.
    error InvalidAmount(uint256 amount);
    /// @param requested The requested withdrawal amount.
    /// @param available The user's available balance.
    error InsufficientBalance(uint256 requested, uint256 available);
    /// @param current The current total deposits.
    /// @param cap The maximum bank capacity.
    error BankCapExceeded(uint256 current, uint256 cap);
    /// @param requested The requested withdrawal amount.
    /// @param limit The withdrawal limit per transaction.
    error WithdrawLimitExceeded(uint256 requested, uint256 limit);

    // ----------- Events -----------
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    // ----------- State variables -----------
    mapping(address => uint256) private balances;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;

    uint256 public immutable bankCap;
    uint256 public immutable withdrawLimit;

    // ----------- Constructor -----------
    constructor(uint256 _bankCap, uint256 _withdrawLimit) {
        bankCap = _bankCap;
        withdrawLimit = _withdrawLimit;
    }

    // ----------- Modifiers -----------
    modifier hasEnoughBalance(uint256 amount) {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) revert InsufficientBalance(amount, userBalance);
        _;
    }

    // ----------- External functions -----------
    function deposit() external payable {
        if (msg.value == 0) revert InvalidAmount(msg.value);

        uint256 newTotal = totalDeposits + msg.value;
        if (newTotal > bankCap) revert BankCapExceeded(newTotal, bankCap);

        balances[msg.sender] += msg.value;
        totalDeposits = newTotal;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external hasEnoughBalance(amount) {
        if (amount > withdrawLimit) revert WithdrawLimitExceeded(amount, withdrawLimit);

        unchecked {
            balances[msg.sender] -= amount;
            totalWithdrawals += amount;
        }

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // ----------- Private helpers -----------
    function _incrementDeposits() private {
        unchecked { totalDeposits++; }
    }
}
