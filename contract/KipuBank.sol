// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @notice Contrato para manejar depósitos y retiros de ETH con límites individuales y globales
contract KipuBank {

    uint256 public immutable withdrawalLimit;
    uint256 public immutable bankCap;
    uint256 public totalDeposits;
    uint256 public depositCount;
    uint256 public withdrawalCount;

    mapping(address => uint256) private balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    error BankCapExceeded(uint256 attemptedDeposit, uint256 availableCapacity);
    error WithdrawalLimitExceeded(uint256 attemptedWithdrawal, uint256 limit);
    error InsufficientBalance(uint256 requested, uint256 available);

    modifier underBankCap(uint256 amount) {
        if (totalDeposits + amount > bankCap) {
            revert BankCapExceeded(amount, bankCap - totalDeposits);
        }
        _;
    }

    modifier underWithdrawalLimit(uint256 amount) {
        if (amount > withdrawalLimit) {
            revert WithdrawalLimitExceeded(amount, withdrawalLimit);
        }
        _;
    }

    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        withdrawalLimit = _withdrawalLimit;
        bankCap = _bankCap;
    }

    function deposit() external payable underBankCap(msg.value) {
        _increaseBalance(msg.sender, msg.value);
        totalDeposits += msg.value;
        depositCount += 1;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external underWithdrawalLimit(amount) {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) {
            revert InsufficientBalance(amount, userBalance);
        }

        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        withdrawalCount += 1;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function _increaseBalance(address user, uint256 amount) private {
        balances[user] += amount;
    }
}
