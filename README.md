# EVM Bridge

**A cross-chain bridge for transferring Porta tokens between EVM-compatible chains using a Node.js relayer service.**

## Overview

This project implements a token bridge that allows users to transfer Porta tokens between different EVM-compatible blockchains. The bridge uses a lock-and-mint / burn-and-unlock mechanism with a Node.js backend service acting as a relayer to facilitate cross-chain communication.

## Architecture

### Smart Contracts

The bridge consists of four main smart contracts:

1. **Porta.sol** - The native ERC20 token on the source chain
2. **PortaBridge.sol** - Bridge contract for the native token chain
3. **WrappedPorta.sol** - Wrapped ERC20 token on the destination chain
4. **WrappedPortaBridge.sol** - Bridge contract for the wrapped token chain

### Bridge Flow

#### Native Chain → Wrapped Chain
1. User calls `deposit(amount)` on **PortaBridge** (locks native tokens)
2. Node.js relayer detects `Deposit` event
3. Relayer calls `mint(user, amount)` on **WrappedPortaBridge**
4. User receives wrapped tokens on destination chain

#### Wrapped Chain → Native Chain
1. User calls `burn(amount, targetAddress)` on **WrappedPortaBridge** (burns wrapped tokens)
2. Node.js relayer detects `Burn` event
3. Relayer calls `burnedOnOppositeChain(user, amount)` on **PortaBridge**
4. User calls `withdraw(amount)` on **PortaBridge** to unlock native tokens

### Node.js Relayer Service

The Node.js backend service handles:
- Event monitoring on both chains
- Transaction relay and execution
- Security validations and nonce management
- Error handling and retry logic
- Optional: Multi-signature validation for enhanced security

## Smart Contract Details

### PortaBridge.sol

**Key Functions:**
- `deposit(uint256 amount)` - Lock native tokens for bridging
- `burnedOnOppositeChain(address user, uint256 amount)` - Called by relayer when wrapped tokens are burned
- `withdraw(uint256 amount)` - Withdraw unlocked tokens after burning on wrapped chain

**Events:**
- `Deposit(address indexed user, uint256 amount)`
- `PendingBalanceIncreased(address indexed user, uint256 amount)`
- `Withdraw(address indexed user, uint256 amount)`

### WrappedPortaBridge.sol

**Key Functions:**
- `mint(address to, uint256 amount)` - Called by relayer when native tokens are deposited
- `burn(uint256 amount, string targetAddress)` - Burn wrapped tokens to unlock native tokens

**Events:**
- `Mint(address indexed to, uint256 amount)`
- `Burn(address indexed from, uint256 amount, string targetAddress)`

## Security Features

- **Owner-only functions**: Critical bridge operations are restricted to authorized relayers
- **Input validation**: All functions include proper input validation and error handling
- **Event-driven architecture**: All bridge operations emit events for transparency and monitoring
- **Pending balance system**: Two-step withdrawal process prevents double-spending

## Development Setup

### Prerequisites

- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit
- [Node.js](https://nodejs.org/) - For the relayer service
- [Git](https://git-scm.com/) - Version control

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd evm_bridge
```

2. Install Foundry dependencies:
```bash
forge install
```

3. Build the contracts:
```bash
forge build
```

4. Run tests:
```bash
forge test
```

### Contract Deployment

1. **Deploy on Native Chain:**
```bash
# Deploy Porta token
forge create src/Porta.sol:Porta --rpc-url <NATIVE_CHAIN_RPC> --private-key <PRIVATE_KEY>

# Deploy PortaBridge
forge create src/PortaBridge.sol:PortaBridge --constructor-args <PORTA_TOKEN_ADDRESS> --rpc-url <NATIVE_CHAIN_RPC> --private-key <PRIVATE_KEY>
```

2. **Deploy on Wrapped Chain:**
```bash
# Deploy WrappedPorta token
forge create src/WrappedPorta.sol:WrappedPorta --rpc-url <WRAPPED_CHAIN_RPC> --private-key <PRIVATE_KEY>

# Deploy WrappedPortaBridge
forge create src/WrappedPortaBridge.sol:WrappedPortaBridge --constructor-args <WRAPPED_PORTA_ADDRESS> --rpc-url <WRAPPED_CHAIN_RPC> --private-key <PRIVATE_KEY>
```

## Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
# Chain Configuration
NATIVE_CHAIN_RPC=https://...
WRAPPED_CHAIN_RPC=https://...
NATIVE_CHAIN_ID=1
WRAPPED_CHAIN_ID=137

# Contract Addresses
PORTA_BRIDGE_ADDRESS=0x...
WRAPPED_PORTA_BRIDGE_ADDRESS=0x...

# Relayer Configuration
RELAYER_PRIVATE_KEY=0x...
CONFIRMATION_BLOCKS=12
GAS_LIMIT=200000
MAX_GAS_PRICE=100000000000
```

## Node.js Relayer Service

The relayer service will be implemented as a separate Node.js application that:

1. **Monitors Events**: Listens for bridge events on both chains
2. **Validates Transactions**: Ensures transaction integrity and prevents replay attacks
3. **Executes Relays**: Submits transactions to complete bridge operations
4. **Handles Errors**: Implements retry logic and error recovery

### Key Features (Planned)

- Event filtering and processing
- Transaction queuing and batch processing
- Gas optimization strategies
- Monitoring and alerting
- Database integration for transaction history
- REST API for bridge status and analytics

## Testing

Run the test suite:

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -vvv

# Run specific test file
forge test --match-path test/PortaBridge.t.sol

# Run tests with gas reporting
forge test --gas-report
```

## Security Considerations

⚠️ **Important Security Notes:**

- This bridge implementation uses a centralized relayer service
- The relayer has significant privileges and should be secured appropriately
- Consider implementing multi-signature validation for production deployments
- Regularly monitor bridge operations and implement alerting for unusual activity
- Conduct thorough security audits before mainnet deployment

## Roadmap

- [ ] Complete Node.js relayer service implementation
- [ ] Add comprehensive test coverage
- [ ] Implement multi-signature validation
- [ ] Add monitoring and alerting system
- [ ] Deploy to testnet for public testing
- [ ] Security audit
- [ ] Mainnet deployment

## Support

For questions, issues, or contributions, please open an issue on GitHub or contact the development team.
