# CryptoVend v4 — Demo Walkthrough

## Setup Prerequisites

1. **Browser**: Chrome or Firefox with MetaMask installed
2. **Testnet ETH**: Get free testnet ETH from a faucet:
   - Arbitrum Sepolia: https://faucet.quicknode.com/arbitrum/sepolia
   - Base Sepolia: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
3. **IPFS Pinning**: Free account at https://pinata.cloud (get JWT token)
4. **Contract Compilation**: Use Foundry or Remix to compile contracts

## Step 1: Compile Contracts

### Option A: Foundry (recommended)
```bash
# Install Foundry if needed
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Compile
cd CryptoVendV4/contracts
forge build CryptoVendV4.sol OracleNode.sol

# Get bytecodes from out/ directory
cat out/CryptoVendV4.sol/CryptoVendV4.json | jq -r '.bytecode.object'
cat out/OracleNode.sol/OracleNode.json | jq -r '.bytecode.object'
```

### Option B: Remix IDE
1. Open https://remix.ethereum.org
2. Create new files, paste contract code
3. Compile with Solidity 0.8.24, optimizer enabled (200 runs)
4. Copy bytecodes from compilation output

## Step 2: Deploy as Seller

1. Open `seller.html` in your browser
2. Connect MetaMask (make sure you're on a testnet)
3. Select a test file (e.g., a small text file or image)
4. Set price (e.g., 0.001 ETH)
5. Configure threshold: 3-of-5 is a good default
6. Enter your Pinata JWT token
7. Click **Deploy Everything**
8. Approve each MetaMask transaction:
   - Main contract deployment (1 tx)
   - 5 oracle contract deployments (5 tx)
   - 5 oracle registrations (5 tx)
   - Buyer page CID set (1 tx)
   - Total: 12 transactions

**Expected total gas**: ~3M gas (~$0.30 on L2 testnet)

## Step 3: Share the Link

After deployment, you'll get:
- Main contract address
- Oracle contract addresses (5)
- Buyer page IPFS CID
- Buyer page URL: `https://gateway.pinata.cloud/ipfs/<CID>`

Share the buyer page URL — that's all anyone needs to purchase.

## Step 4: Purchase as Buyer

1. Open the buyer page URL in a different browser or incognito window
2. Connect a DIFFERENT MetaMask account (the buyer)
3. Click **Connect Wallet & Buy**
4. Approve the payment transaction in MetaMask
5. Watch the progress:
   - Payment confirms (~1-2 seconds on L2)
   - Shares are collected from oracle contracts (~2-5 seconds)
   - AES key is reconstructed (~instant)
   - File is downloaded from IPFS and decrypted (~1-5 seconds)
6. File downloads automatically

## What to Observe

### During deployment:
- Each oracle contract gets its own address (5 separate contracts)
- Each oracle stores one Shamir share (obfuscated)
- The main contract registers all oracle addresses

### During purchase:
- Payment goes to the main contract (one on-chain transaction)
- Share collection uses eth_call (zero gas, free, instant)
- Only 3 of 5 shares are needed (fault tolerance)
- AES key reconstruction happens in-browser (Lagrange interpolation)
- File decryption happens in-browser (AES-256-GCM via Web Crypto API)

### After purchase:
- The seller's browser is NOT open (and doesn't need to be)
- No servers were contacted (only blockchain RPC + IPFS gateway)
- The buyer has the decrypted file
- The seller can withdraw funds at any time

## Verification

### Check oracle contracts on block explorer:
1. Go to the block explorer (e.g., https://sepolia.arbiscan.io)
2. Look up each oracle contract address
3. Call `info()` — returns vending contract address, share index, commitment
4. Call `canServe(purchaseId)` — returns true if purchase is valid

### Verify the threshold property:
1. If you disable 2 of 5 oracle contracts (e.g., by trying with wrong addresses), the purchase still works (3/5 respond)
2. If you disable 3 of 5, it fails (only 2/5 respond, below threshold)

## Architecture Comparison Demo

| Action | V3 (HTTP Oracles) | V4 (Smart Contract Oracles) |
|--------|-------------------|----------------------------|
| Share retrieval | HTTP GET to server | eth_call to contract |
| Oracle monitoring | Check endpoint health | Nothing (contracts never crash) |
| Oracle failure | Server down = share lost | Contract always available |
| Cost to query | Server bandwidth | Zero (view function) |
| Setup effort | Deploy + coordinate operators | Deploy only |

## Troubleshooting

- **"Wrong network"**: Switch MetaMask to the correct testnet
- **"Insufficient funds"**: Get more testnet ETH from faucet
- **"Could not collect enough shares"**: Check that oracle contract addresses are correct in buyer page
- **"Key reconstruction failed"**: Share integrity check failed — try again (may be a network issue)
- **IPFS timeout**: Try a different IPFS gateway, or wait for propagation
