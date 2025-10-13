# 🏦 KipuBank

**Autor:** Gabriela Lavia  
**Red:** Sepolia Testnet  
**Versión:** 1.0.0  
**Licencia:** MIT

---

## 🧩 Descripción

**KipuBank** es un contrato inteligente desarrollado en Solidity que actúa como un banco descentralizado de tokens nativos (ETH).  
Cada usuario puede **depositar** y **retirar** fondos desde su propia bóveda, siguiendo reglas de seguridad y límites definidos en el despliegue.

### Funcionalidades principales

- Los usuarios pueden **depositar ETH** en su bóveda personal.
- Pueden **retirar ETH** hasta un **límite fijo por transacción** (`withdrawLimit`).
- El contrato tiene un **límite global de depósitos** (`bankCap`), definido al desplegar.
- Lleva registro de:
  - Total de depósitos realizados.
  - Total de retiros efectuados.
- Emite **eventos** en cada operación exitosa.
- Usa **errores personalizados** y el patrón `checks-effects-interactions` para máxima seguridad.

---

## ⚙️ Despliegue

### Prerrequisitos

- [Remix IDE](https://remix.ethereum.org/)
- [MetaMask](https://metamask.io/) conectado a **Sepolia Testnet**
- ETH de prueba (puede obtenerse desde un faucet como [https://sepoliafaucet.com/](https://sepoliafaucet.com/))

### Pasos para desplegar

1. Abre **Remix IDE**.
2. Crea un archivo llamado `KipuBank.sol` dentro de la carpeta `/contracts`.
3. Copia el código fuente del contrato.
4. Compila con el compilador Solidity **v0.8.20** o superior.
5. En la pestaña **Deploy & Run Transactions**:
   - Environment: `Injected Provider - MetaMask`
   - Network: `Sepolia`
6. Completa los parámetros del constructor:
   - `bankCap`: límite total del banco (por ejemplo `10 ether`)
   - `withdrawLimit`: límite máximo por retiro (por ejemplo `0.5 ether`)
7. Presiona **Deploy**.
8. Esperar MetaMask se abra y confirma. ( sin no tiene gas buscar en un faucet para agregar https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
9. Espera a que la transacción se confirme.

---

## 💬 Interacción con el contrato

Una vez desplegado:

### Funciones principales

| Función | Tipo | Descripción |
|----------|------|--------------|
| `deposit()` | `external payable` | Permite depositar ETH en la bóveda personal. |
| `withdraw(uint256 amount)` | `external` | Permite retirar hasta el límite definido. |
| `getBalance(address user)` | `external view` | Devuelve el balance almacenado de un usuario. |
| `_updateStats()` | `private` | Función interna que actualiza contadores de operaciones. |

### Eventos

- `Deposit(address indexed user, uint256 amount)`
- `Withdrawal(address indexed user, uint256 amount)`

### Errores personalizados

- `BankCapExceeded(uint256 current, uint256 cap)`
- `WithdrawLimitExceeded(uint256 requested, uint256 limit)`
- `InsufficientBalance(uint256 available, uint256 requested)`

---

## 🧪 Ejemplo de interacción (Remix)

1. Abre la pestaña **Deployed Contracts**.
2. Expande el contrato desplegado.
3. Para **depositar ETH**:  
   - Ingresa un valor en “Value” (por ejemplo, `1 ether`).  
   - Haz clic en **deposit()**.
4. Para **retirar ETH**:  
   - Ingresa un valor menor o igual a `withdrawLimit`.  
   - Haz clic en **withdraw**.
5. Usa **getBalance(address)** para consultar saldos.

---

## 🌐 Dirección del contrato desplegado

**Red:** Sepolia Testnet  
**Dirección:** `0x995EbfDCfF4F5188EdE5D72c990df322cE52Ea79`  
**Código verificado:** [Ver en Etherscan](https://sepolia.etherscan.io/address/0x995EbfDCfF4F5188EdE5D72c990df322cE52Ea79)

---

## 🔒 Buenas prácticas aplicadas

- Uso de `custom errors` en lugar de `require` con strings.
- Patrón `checks-effects-interactions`.
- Funciones bien delimitadas: `external`, `view`, `private`.
- Variables `immutable` y `constant` para límites fijos.
- Eventos y contadores para trazabilidad.
- Documentación NatSpec completa.
- Convenciones de nombres limpias y consistentes.

---

## 🧑‍💻 Autor

Creado por **Gabriela Lavia**  
Proyecto académico y portafolio Web3 personal.  
