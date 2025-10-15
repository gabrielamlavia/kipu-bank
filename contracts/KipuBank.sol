// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @title KipuBank
/// @author Gabriela Lavia
/// @notice A decentralized ETH vault allowing deposits and controlled withdrawals.
/// @dev Includes security best practices, custom errors, and gas optimizations.
contract KipuBank {
    // ------------------------------------------------------------
    // 1. Immutable and Constant Variables
    // ------------------------------------------------------------

    /// @notice Maximum amount allowed per single withdrawal
    uint256 public immutable withdrawalLimit;

    /// @notice Global limit of total deposits allowed in the contract
    uint256 public immutable bankCap;

    // ------------------------------------------------------------
    // 2. Storage Variables
    // ------------------------------------------------------------

    /// @notice Total ETH deposited across all users
    uint256 public totalDeposits;

    /// @notice Counter for total deposits
    uint256 public totalDepositCount;

    /// @notice Counter for total withdrawals
    uint256 public totalWithdrawCount;

    // ------------------------------------------------------------
    // 3. Mappings
    // ------------------------------------------------------------

    /// @notice Maps each user to their ETH balance
    mapping(address => uint256) private balances;

    // ------------------------------------------------------------
    // 4. Events
    // ------------------------------------------------------------

    /// @notice Emitted when a user deposits ETH
    /// @param user The address that made the deposit
    /// @param amount The amount of ETH deposited
    event DepositMade(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws ETH
    /// @param user The address that made the withdrawal
    /// @param amount The amount of ETH withdrawn
    event WithdrawalMade(address indexed user, uint256 amount);

    // ------------------------------------------------------------
    // 5. Custom Errors
    // ------------------------------------------------------------

    /// @notice Thrown when a user tries to withdraw more than available
    /// @param requested The requested amount
    /// @param available The available balance
    error InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Thrown when a withdrawal exceeds the immutable limit
    /// @param attempted The attempted withdrawal amount
    /// @param limit The allowed per-transaction limit
    error WithdrawalOverLimit(uint256 attempted, uint256 limit);

    /// @notice Thrown when deposits exceed the global bank cap
    /// @param attempted Total amount attempted to deposit
    /// @param cap Global maximum bank cap
    error BankCapExceeded(uint256 attempted, uint256 cap);

    // ------------------------------------------------------------
    // 6. Constructor
    // ------------------------------------------------------------

    /// @param _withdrawalLimit The per-transaction withdrawal limit
    /// @param _bankCap The total maximum allowed deposit in the bank
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        withdrawalLimit = _withdrawalLimit;
        bankCap = _bankCap;
    }

    // ------------------------------------------------------------
    // 7. Modifiers
    // ------------------------------------------------------------

    /// @notice Ensures that the user has enough balance for a withdrawal
    /// @param amount The amount requested for withdrawal
    modifier hasEnoughBalance(uint256 amount) {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) {
            revert InsufficientBalance(amount, userBalance);
        }
        _;
    }

    // ------------------------------------------------------------
    // 8. External Payable Function
    // ------------------------------------------------------------

    /// @notice Deposit ETH into your personal vault
    /// @dev Reverts if deposit would exceed global bank cap
    function deposit() external payable {
        uint256 newTotal = totalDeposits + msg.value;
        if (newTotal > bankCap) {
            revert BankCapExceeded(newTotal, bankCap);
        }

        totalDeposits = newTotal;
        unchecked {
            balances[msg.sender] += msg.value;
            totalDepositCount++;
        }

        emit DepositMade(msg.sender, msg.value);
    }

    // ------------------------------------------------------------
    // 9. Private Function
    // ------------------------------------------------------------

    /// @notice Internal helper to perform ETH transfers safely
    /// @param to The recipient address
    /// @param amount The amount of ETH to send
    /// @return success Whether the transfer succeeded
    function _safeTransfer(address to, uint256 amount) private returns (bool success) {
        (success, ) = to.call{value: amount}("");
        return success;
    }

    // ------------------------------------------------------------
    // 10. External View Function
    // ------------------------------------------------------------

    /// @notice Get the ETH balance of a user
    /// @param user The address to check
    /// @return The current vault balance for the given user
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // ------------------------------------------------------------
    // 11. External Withdraw Function
    // ------------------------------------------------------------

    /// @notice Withdraw ETH from your personal vault
    /// @param amount The amount to withdraw
    function withdraw(uint256 amount)
        external
        hasEnoughBalance(amount)
    {
        if (amount > withdrawalLimit) {
            revert WithdrawalOverLimit(amount, withdrawalLimit);
        }

        // Check-Effects-Interactions pattern
        unchecked {
            balances[msg.sender] -= amount;
            totalDeposits -= amount;
            totalWithdrawCount++;
        }

        bool success = _safeTransfer(msg.sender, amount);
        require(success, "Transfer failed");

        emit WithdrawalMade(msg.sender, amount);
    }
}
