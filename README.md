# NFT-ZK Lease: Privacy-Preserving Dynamic Asset Rental

**Hackathon:** Authorized to Act: Auth0 for AI Agents | $10,000

## Overview
NFT-ZK Lease enables NFT owners to grant time-bound, capability-specific access to AI agents without transferring ownership. Uses zero-knowledge proofs to verify lease credentials without revealing identity or usage data on-chain.

## Tech Stack
- **Smart Contracts:** Solidity 0.8.24, Hardhat
- **ZK Proofs:** Circom 2.1.0, snarkjs
- **Frontend:** Vanilla HTML/JS with ethers.js
- **Network:** Sepolia Testnet

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Compile Contracts & Circuits
```bash
npx hardhat compile
circom circuits/leaseProof.circom --wasm --c
```

### 3. Deploy to Sepolia
```bash
# Set SEPOLIA_RPC_URL and PRIVATE_KEY in .env
npx hardhat run scripts/deploy.js --network sepolia
```

### 4. Run Tests
```bash
npx hardhat test
```

### 5. Open Dashboard
```bash
open public/dashboard.html
```

## Contract Addresses (Sepolia)
- **LeaseNFT:** `0x...` (fill after deployment)
- **LeaseVerifier:** `0x...` (fill after deployment)

## Hackathon Submission
- **Repo:** https://github.com/your-org/nft-zk-lease
- **Demo:** https://your-org.github.io/nft-zk-lease
- **Video:** https://youtube.com/watch?v=your-video-id

## License
MIT