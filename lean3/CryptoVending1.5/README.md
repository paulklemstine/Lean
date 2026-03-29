# ⚡ CryptoVend v2

**Sell any digital file with no server, no intermediary, no trust — just two HTML files and a smart contract.**

CryptoVend is a decentralized file vending machine built entirely from browser-native technologies. The seller opens an HTML page, drops in a file, and deploys a vending machine. The buyer visits an IPFS-hosted page, pays via MetaMask, and receives the decrypted file in ~25 seconds. Everything runs on Ethereum Layer 2 for pennies in gas fees.

---

## Architecture

```
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│  seller.html │          │  Smart       │          │  Buyer Page  │
│  (local)     │──deploy──│  Contract    │──pay────│  (IPFS)      │
│              │          │  (L2 chain)  │          │              │
│  • Encrypt   │──watch──▶│  • Escrow    │◀─events─│  • ECIES     │
│  • Deploy    │          │  • Refund    │          │  • Decrypt   │
│  • Pin IPFS  │──key───▶│  • Deliver   │──key───▶│  • Download  │
│  • Deliver   │          └──────────────┘          └──────────────┘
└──────┬───────┘                                           │
       │                                                   │
       ▼                                                   ▼
┌──────────────┐                                   ┌──────────────┐
│     IPFS     │ ─────── encrypted file ──────────▶│     IPFS     │
│  (pin data)  │                                   │  (fetch data)│
└──────────────┘                                   └──────────────┘
```

## How It Works

### Seller Flow
1. Open `seller.html` in your browser
2. Connect MetaMask
3. Select a file, choose L2 network, set price
4. Click **Deploy** — the browser:
   - Generates a random AES-256 key
   - Encrypts the file with AES-256-GCM
   - Uploads encrypted file to IPFS
   - Deploys smart contract on L2
   - Generates buyer page HTML
   - Pins buyer page to IPFS
5. Share the buyer page IPFS link
6. **Keep the tab open** — it watches for purchases and delivers keys automatically

### Buyer Flow
1. Visit the IPFS buyer page link
2. Click **Connect & Buy**
3. MetaMask pops up — approve the transaction
4. Wait ~10-25 seconds for the seller to deliver the decryption key
5. File downloads automatically, decrypted

### What Happens Cryptographically
- **AES-256-GCM** encrypts the file (authenticated encryption)
- **ECIES over secp256k1** transports the AES key to the buyer
- **keccak256 commitment** on-chain proves the correct key was delivered
- **Refund mechanism** returns buyer's ETH if seller is offline for >1 hour

## Cost Comparison

| | Ethereum L1 | Arbitrum | Base |
|---|---|---|---|
| Deploy | ~$67.50 | ~$0.15 | **~$0.08** |
| Per sale (total) | ~$14.13 | ~$0.033 | **~$0.017** |
| Min viable price | $283 | $0.66 | **$0.40** |

| | Gumroad | Apple | Stripe | **CryptoVend** |
|---|---|---|---|---|
| Fee on $10 sale | $1.09 | $3.00 | $0.59 | **$0.02** |
| Seller keeps | 89% | 70% | 94% | **99.8%** |

## Project Structure

```
CryptoVending2/
├── seller.html                    # Seller SAP — the main application
├── buyer_template.html            # Reference buyer page template
├── contracts/
│   └── CryptoVendL2.sol           # Smart contract (Solidity 0.8.24)
├── research/
│   ├── oracle_notes.md            # Oracle Council research log
│   ├── research_paper.md          # Full research paper
│   └── scientific_american.md     # Scientific American article
├── demo/
│   ├── demo_visual.html           # Interactive visual walkthrough
│   └── demo_script.md             # Demo presentation script
└── README.md                      # This file
```

## Quick Start

### Prerequisites
- Chrome or Firefox
- MetaMask extension
- Testnet ETH on Arbitrum Sepolia ([faucet](https://www.alchemy.com/faucets/arbitrum-sepolia))
- Optional: [Web3.Storage](https://web3.storage) API token for IPFS pinning

### Compile the Contract
Before deploying, you need the contract bytecode:

1. Go to [Remix IDE](https://remix.ethereum.org)
2. Create a new file, paste `contracts/CryptoVendL2.sol`
3. Compile with Solidity 0.8.24 (enable optimizer, 200 runs)
4. Copy the bytecode from compilation artifacts
5. Paste into `getContractBytecode()` in `seller.html`

Or use Foundry/Hardhat:
```bash
# Foundry
forge build contracts/CryptoVendL2.sol

# Hardhat
npx hardhat compile
```

### Run the Demo
1. Open `seller.html` in your browser
2. Connect MetaMask (switch to Arbitrum Sepolia)
3. Select a file, set price
4. Click "Deploy" and confirm transactions
5. Copy the buyer page IPFS link
6. Open in a second browser profile/window
7. Buy the file!

### View the Demo Walkthrough
Open `demo/demo_visual.html` in any browser — no MetaMask needed.

## The Elephant in the Room 🐘

The seller must keep `seller.html` open in their browser to deliver keys. If the seller goes offline:

- **Buyer protection**: After 1 hour, buyers can trigger automatic refund
- **No money lost**: The worst case is wasted time, not wasted money

### Future Solutions
| Approach | Complexity | Description |
|----------|-----------|-------------|
| VPS + headless browser | Low | Run seller.html on a $5/month server |
| Serverless function | Medium | AWS Lambda watches events + delivers keys |
| Lit Protocol PKPs | High | Decentralized key management, no seller needed |
| Threshold cryptography | Research | Split key across network of nodes |

## Security Model

| Property | Guarantee |
|----------|-----------|
| File confidentiality | AES-256-GCM (128-bit security) |
| Key transport | ECIES/secp256k1 (128-bit security) |
| Key authenticity | keccak256 commitment on-chain |
| File integrity | AES-GCM auth tag + IPFS content addressing |
| Payment atomicity | Smart contract escrow |
| Buyer protection | Time-locked refund mechanism |
| Non-repudiation | Blockchain immutability |

## Supported Networks

| Network | Chain ID | Type | Status |
|---------|---------|------|--------|
| Arbitrum One | 42161 | Mainnet | ✅ Ready |
| Base | 8453 | Mainnet | ✅ Ready |
| Optimism | 10 | Mainnet | ✅ Ready |
| Arbitrum Sepolia | 421614 | Testnet | ✅ Ready |
| Base Sepolia | 84532 | Testnet | ✅ Ready |
| OP Sepolia | 11155420 | Testnet | ✅ Ready |

## Research

The `research/` directory contains:

- **`oracle_notes.md`** — Detailed research log from six specialist oracles (Cryptography, Distributed Systems, Game Theory, UX, Economics, Security)
- **`research_paper.md`** — Full academic-style research paper with security analysis, economic model, and protocol specification
- **`scientific_american.md`** — Popular-science article explaining the system to a general audience

## License

MIT
