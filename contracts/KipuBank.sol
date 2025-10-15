// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @notice A decentralized vault that allows users to deposit and withdraw native ETH with safety limits.
/// @author Gabriela Lavia
/// @dev This contract follows the checks-effects-interactions pattern and avoids multiple state reads/writes.
contract KipuBank {

    // --------------------------------------------------------------------
    // ----------------------------- Errors --------------------------------
    // --------------------------------------------------------------------

    /// @notice Thrown when a deposit amount is invalid.
    /// @param amount The provided invalid amount.
    error InvalidDeposit(uint256 amount);

    /// @notice Thrown when trying to withdraw more than allowed per transaction.
    /// @param requested The requested withdrawal amount.
    /// @param limit The fixed withdrawal limit.
    error WithdrawLimitExceeded(uint256 requested, uint256 limit);

    /// @notice Thrown when user tries to withdraw more than available.
    /// @param requested The requested amount.
    /// @param available The user’s current balance.
    error InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Thrown when the global deposit limit is reached.
    /// @param current The total deposits so far.
    /// @param cap The configured bank capacity.
    error BankCapExceeded(uint256 current, uint256 cap);

    /// @notice Thrown when a low-level call fails.
    error TransferFailed();

    // --------------------------------------------------------------------
    // ----------------------------- Events --------------------------------
    // --------------------------------------------------------------------

    /// @notice Emitted when a user deposits ETH successfully.
    /// @param user The address that made the deposit.
    /// @param amount The amount deposited.
    event Deposit(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws ETH successfully.
    /// @param user The address that made the withdrawal.
    /// @param amount The amount withdrawn.
    event Withdrawal(address indexed user, uint256 amount);

    // --------------------------------------------------------------------
    // --------------------------- State -----------------------------------
    // --------------------------------------------------------------------

    /// @notice Tracks each user's balance.
    mapping(address => uint256) private balances;

    /// @notice Total ETH deposited into the bank.
    uint256 public totalDeposits;

    /// @notice Total ETH withdrawn from the bank.
    uint256 public totalWithdrawals;

    /// @notice Maximum total amount of ETH allowed in the contract.
    uint256 public immutable bankCap;

    /// @notice Maximum amount a user can withdraw in a single transaction.
    uint256 public immutable withdrawLimit;

    // --------------------------------------------------------------------
    // -------------------------- Constructor ------------------------------
    // --------------------------------------------------------------------

    /// @param _bankCap The total ETH capacity of the bank.
    /// @param _withdrawLimit The max withdrawal limit per transaction.
    constructor(uint256 _bankCap, uint256 _withdrawLimit) {
        bankCap = _bankCap;
        withdrawLimit = _withdrawLimit;
    }

    // --------------------------------------------------------------------
    // -------------------------- Modifiers --------------------------------
    // --------------------------------------------------------------------

    /// @notice Ensures the caller has enough balance to perform an action.
    /// @param amount The requested amount to validate.
    modifier hasEnoughBalance(uint256 amount) {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) revert InsufficientBalance(amount, userBalance);
        _;
    }

    // --------------------------------------------------------------------
    // --------------------------- Functions -------------------------------
    // --------------------------------------------------------------------

    /// @notice Allows users to deposit native ETH into their personal vault.
    /// @dev Emits a {Deposit} event.
    function deposit() external payable {
        uint256 amount = msg.value;
        if (amount == 0) revert InvalidDeposit(amount);

        uint256 newTotal = totalDeposits + amount;
        if (newTotal >
