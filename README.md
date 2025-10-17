# 🏦 KipuBank

**Licencia:** MIT  
**Lenguaje:** Solidity ^0.8.27  
**Contrato:** `KipuBank`

---

## 📘 Descripción

**KipuBank** es un contrato inteligente que funciona como una **bóveda descentralizada de ETH**, donde cada usuario puede:

- Depositar ETH en su propia cuenta dentro del contrato.  
- Retirar fondos de manera controlada, respetando un **límite máximo por transacción**.  
- Operar dentro de un **límite global de depósitos (bankCap)** establecido en el momento del despliegue.

El contrato fue diseñado siguiendo **buenas prácticas de seguridad y optimización de gas**, aplicando los patrones y convenciones vistos en clase.

---

## ⚙️ Estructura del contrato

El código está organizado según la guía oficial de layout de Solidity:

1. Variables **inmutables** y **constantes**  
2. Variables de **almacenamiento**  
3. **Mappings**  
4. **Eventos**  
5. **Errores personalizados**  
6. **Constructor**  
7. **Modificadores**  
8. **Funciones externas `payable`**  
9. **Funciones privadas**  
10. **Funciones externas `view`**  
11. **Función externa de retiro (`withdraw`)**

---

## 🚀 Instrucciones de despliegue

### Opción 1 — Remix IDE (recomendada)

1. Abrir [Remix IDE](https://remix.ethereum.org/)  
2. Crear un archivo `KipuBank.sol` y pegar el código del contrato.  
3. Compilar con **Solidity 0.8.27**  
4. Ir a la pestaña **Deploy & Run Transactions**  
5. Seleccionar **Injected Provider - MetaMask**  
6. Conectarse a la red **Sepolia Testnet**  
7. Completar los parámetros del constructor:  
   ```solidity
   _withdrawalLimit = 0.1 ether
   _bankCap = 5 ether
   ```
8. Hacer clic en **Deploy** y confirmar la transacción en MetaMask.  
9. Verificar el contrato en [Etherscan Sepolia](https://sepolia.etherscan.io/address/0xFD30a5102807514C075FFEa2F9ae519dA1Fec421#code).

---

## 🧩 Cómo interactuar con el contrato

### 🔹 `deposit()`
- **Tipo:** `external payable`
- Permite depositar ETH en la bóveda del usuario.  
- Emite el evento `DepositMade(address user, uint256 amount)`.  

### 🔹 `withdraw(uint256 _amount)`
- **Tipo:** `external`
- Retira fondos hasta el límite permitido (`withdrawalLimit`).  
- Emite el evento `WithdrawalMade(address user, uint256 amount)`.  
- Usa el modificador `hasEnoughBalance`.

### 🔹 `getBalance(address _user)`
- **Tipo:** `external view`
- Devuelve el saldo actual del usuario especificado.

---

## ⚠️ Seguridad y validaciones

El contrato implementa verificaciones con **errores personalizados**:

| Situación | Error personalizado | Descripción |
|------------|--------------------|--------------|
| Retiro mayor al balance disponible | `InsufficientBalance(requested, available)` | Evita sobregiros |
| Retiro mayor al límite permitido | `WithdrawalOverLimit(attempted, limit)` | Controla el monto máximo |
| Depósito supera el límite global | `BankCapExceeded(attempted, cap)` | Mantiene el cap total |
| Fallo en la transferencia de ETH | `TransferFailed(recipient, amount)` | Maneja errores de `call` |

---

## 🧠 Buenas prácticas aplicadas

- Patrón **Check-Effects-Interactions**  
- Sin múltiples accesos a las mismas variables de estado  
- Uso de **`unchecked`** donde es seguro  
- **Modifiers** para validaciones lógicas  
- **NatSpec completa** en funciones, errores y parámetros  
- **Eventos** para trazabilidad de operaciones

---

## 📜 Contrato desplegado y verificado

**Dirección:** [`0xFD30a5102807514C075FFEa2F9ae519dA1Fec421`](https://sepolia.etherscan.io/address/0xFD30a5102807514C075FFEa2F9ae519dA1Fec421#code)  
**Red:** Sepolia Testnet  
**Estado:** ✅ Código verificado en Etherscan  
