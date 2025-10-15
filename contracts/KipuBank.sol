// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @notice Contrato para manejar depósitos y retiros de ETH con límites individuales y globales
/// @dev Incluye buenas prácticas de seguridad: errores personalizados, checks-effects-interactions, y transferencias seguras
contract KipuBank {

    // ------------------------------
    // Variables de estado
    // ------------------------------

    /// @notice Límite máximo de ETH que un usuario puede retirar por transacción
    uint256 public immutable withdrawalLimit;

    /// @notice Límite global de ETH que puede almacenar el banco
    uint256 public immutable bankCap;

    /// @notice Cantidad total de ETH actualmente depositada en el banco
    uint256 public totalDeposits;

    /// @notice Número total de depósitos realizados
    uint256 public depositCount;

    /// @notice Número total de retiros realizados
    uint256 public withdrawalCount;

    /// @notice Saldo de cada usuario
    mapping(address => uint256) private balances;

    // ------------------------------
    // Eventos
    // ------------------------------

    /// @notice Evento emitido cuando un usuario deposita ETH
    /// @param user Dirección del usuario
    /// @param amount Cantidad depositada
    event Deposited(address indexed user, uint256 amount);

    /// @notice Evento emitido cuando un usuario retira ETH
    /// @param user Dirección del usuario
    /// @param amount Cantidad retirada
    event Withdrawn(address indexed user, uint256 amount);

    // ------------------------------
    // Errores personalizados
    // ------------------------------

    /// @notice Error cuando el depósito excede la capacidad del banco
    error BankCapExceeded(uint256 attemptedDeposit, uint256 availableCapacity);

    /// @notice Error cuando el retiro excede el límite permitido
    error WithdrawalLimitExceeded(uint256 attemptedWithdrawal, uint256 limit);

    /// @notice Error cuando el usuario no tiene suficiente saldo
    error InsufficientBalance(uint256 requested, uint256 available);

    // ------------------------------
    // Modificadores
    // ------------------------------

    /// @notice Valida que el depósito no exceda la capacidad del banco
    /// @param amount Cantidad que se quiere depositar
    modifier underBankCap(uint256 amount) {
        if (totalDeposits + amount > bankCap) {
            revert BankCapExceeded(amount, bankCap - totalDeposits);
        }
        _;
    }

    /// @notice Valida que el retiro no exceda el límite por transacción
    /// @param amount Cantidad que se quiere retirar
    modifier underWithdrawalLimit(uint256 amount) {
        if (amount > withdrawalLimit) {
            revert WithdrawalLimitExceeded(amount, withdrawalLimit);
        }
        _;
    }

    // ------------------------------
    // Constructor
    // ------------------------------

    /// @notice Inicializa el contrato con límites de retiro y capacidad global
    /// @param _withdrawalLimit Límite máximo por retiro
    /// @param _bankCap Capacidad máxima del banco
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        withdrawalLimit = _withdrawalLimit;
        bankCap = _bankCap;
    }

    // ------------------------------
    // Funciones externas
    // ------------------------------

    /// @notice Deposita ETH en la bóveda del usuario
    /// @dev Sigue patrón checks-effects-interactions y emite evento
    function deposit() external payable underBankCap(msg.value) {
        _increaseBalance(msg.sender, msg.value);

        totalDeposits += msg.value;
        depositCount += 1;

        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Retira ETH de la bóveda del usuario
    /// @param amount Cantidad a retirar
    /// @dev Sigue patrón checks-effects-interactions y emite evento
    function withdraw(uint256 amount) external underWithdrawalLimit(amount) {
        uint256 userBalance = balances[msg.sender];
        if (amount > userBalance) {
            revert InsufficientBalance(amount, userBalance);
        }

        // Effects
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        withdrawalCount += 1;

        // Interactions (transfer segura)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Consulta el saldo del usuario
    /// @param user Dirección del usuario
    /// @return Saldo en wei
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    // ------------------------------
    // Funciones privadas
    // ------------------------------

    /// @notice Incrementa el saldo de un usuario
    /// @param user Dirección del usuario
    /// @param amount Cantidad a incrementar
    function _increaseBalance(address user, uint256 amount) private {
        balances[user] += amount;
    }
}
