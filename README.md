# 🛡️ NFT-ZK Lease: Privacy-Preserving Dynamic Asset Rental

**One-line Pitch:** Empower NFT owners to grant time-bound, capability-specific access to AI agents without transferring ownership or revealing off-chain usage data.

**Hackathon:** Authorized to Act: Auth0 for AI Agents | $10,000 Prize Pool

---

## 🚀 Tech Stack

![Hardhat](https://img.shields.io/badge/Hardhat-EC4A89?style=for-the-badge&logo=hardhat&logoColor=white)
![Circom](https://img.shields.io/badge/Circom-000000?style=for-the-badge&logo=javascript&logoColor=white)
![Solidity](https://img.shields.io/badge/Solidity-363636?style=for-the-badge&logo=solidity&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=next.js&logoColor=white)
![Sepolia](https://img.shields.io/badge/Sepolia-3B82F6?style=for-the-badge&logo=ethereum&logoColor=white)
![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

---

## 🧩 Problem & Solution

### The Problem
Digital asset sharing in the Web3 ecosystem faces a critical **trust gap**.
1.  **Ownership Risk:** Standard rental marketplaces often require transferring custody, risking permanent loss or misuse of the asset.
2.  **Privacy Leakage:** Off-chain usage data (e.g., AI training inputs, rendering tasks) is often visible or inferable, violating owner privacy.
3.  **Static Metadata:** NFTs cannot dynamically reflect active usage states without complex, centralized off-chain logic.

### The Solution
**NFT-ZK Lease** introduces a privacy-preserving rental layer for ERC-721 assets.
*   **Zero-Knowledge Verification:** A ZK circuit verifies a user holds a valid lease credential without revealing their identity or specific asset details to the public ledger.
*   **Time-Bound Access:** Smart contracts enforce strict expiration times for AI agent access.
*   **Dynamic Metadata:** The NFT's visual representation updates based on active usage states managed on-chain.
*   **No Ownership Transfer:** The owner retains full custody; only specific capabilities are granted temporarily.

---

## 🏗️ Architecture

```text
+----------------+       +----------------+       +----------------+
|   Owner        |       |   AI Agent     |       |   Dashboard    |
| (Wallet A)     |       | (Wallet B)     |       | (Next.js)      |
+-------+--------+       +-------+--------+       +-------+--------+
        |                        |                        |
        | 1. Mint NFT            |                        |
        +------------------------+                        |
        |                        |                        |
        | 2. Grant Lease         |                        |
        | (Sign Tx)              |                        |
        +------------------------+                        |
        |                        |                        |
        v                        v                        v
+---------------------------------------------------------------+
|                    Smart Contract Layer                       |
|  +----------------+      +----------------+                  |
|  | LeaseNFT.sol   |<---->| LeaseVerifier  |                  |
|  | (State Mgmt)   |      | (ZK Proof Vfy) |                  |
|  +----------------+      +----------------+                  |
+---------------------------------------------------------------+
        ^                        ^
        |                        |
+-------+--------+       +-------+--------+
|   ZK Circuit   |       |   Off-Chain    |
| (Circom)       |       |   Data Store   |
| (Proof Gen)    |       | (Usage Logs)   |
+----------------+       +----------------+
```

---

## ⚙️ Setup Instructions

### Prerequisites
*   Node.js v18+
*   Hardhat
*   Circom Compiler
*   MetaMask Wallet (Sepolia Testnet)

### 1. Clone & Install
```bash
git clone https://github.com/77svene/nft-zk-lease
cd nft-zk-lease
npm install
```

### 2. Environment Configuration
Create a `.env` file in the root directory with the following variables:
```env
PRIVATE_KEY=your_wallet_private_key
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_infura_key
DEPLOYER_ADDRESS=0xYourDeployerAddress
```

### 3. Compile Circuits & Contracts
```bash
# Compile ZK Circuit
npx circom circuits/leaseProof.circom --r1cs --wasm --sym

# Compile Solidity Contracts
npx hardhat compile
```

### 4. Deploy Contracts
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

### 5. Run Dashboard
```bash
npm start
# Opens http://localhost:3000 (or serves public/dashboard.html)
```

---

## 🔌 API Endpoints & Contract Interaction

| Endpoint / Function | Type | Description |
| :--- | :--- | :--- |
| `createLease(uint256 tokenId, uint256 duration)` | Contract | Owner grants lease to an address for a specific duration. |
| `verifyLease(address user, uint256 tokenId)` | Contract | Checks if a user has an active lease for a specific NFT. |
| `updateMetadata(uint256 tokenId, string uri)` | Contract | Owner updates the dynamic metadata URI based on usage. |
| `generateProof(leaseData)` | ZK Circuit | Generates the zero-knowledge proof for off-chain verification. |
| `POST /api/lease/status` | Dashboard | Fetches real-time lease state for the connected wallet. |
| `GET /api/lease/history` | Dashboard | Retrieves historical lease data for analytics. |

---

## 📸 Demo Screenshots

### Dashboard Interface
![Dashboard UI](https://via.placeholder.com/800x400/3B82F6/FFFFFF?text=NFT-ZK+Lease+Dashboard+Live+View)
*Live lease states and active AI agent connections.*

### ZK Proof Verification
![ZK Verification](https://via.placeholder.com/800x400/10B981/FFFFFF?text=ZK+Proof+Verification+Success)
*Circom-generated proof validated on-chain.*

### Contract Deployment
![Deployment](https://via.placeholder.com/800x400/8B5CF6/FFFFFF?text=Hardhat+Deployment+Log)
*Successful deployment on Sepolia Testnet.*

---

## 👥 Team

**Built by VARAKH BUILDER — autonomous AI agent**

*   **Architecture & Logic:** VARAKH BUILDER
*   **Smart Contract Dev:** VARAKH BUILDER
*   **ZK Circuit Design:** VARAKH BUILDER
*   **Frontend Integration:** VARAKH BUILDER

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.