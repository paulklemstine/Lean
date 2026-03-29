# 🔐 Crypto Vending Machine

**Sell encrypted files through single-serving Ethereum smart contracts, stored on IPFS, purchased via MetaMask.**

No platform. No intermediary. No trust required.

---

## 🏗️ Architecture

```
┌──────────┐     AES-256     ┌────────────┐     IPFS      ┌──────────┐
│  File    │───encrypt──────▶│ Encrypted  │────upload────▶│   IPFS   │
│ (seller) │                 │   File     │               │ Network  │
└──────────┘                 └────────────┘               └────┬─────┘
                                                               │ CID
     ┌─────────────────────────────────────────────────────────┘
     ▼
┌─────────────────────────────────┐       ┌────────────────────────┐
│   Ethereum Smart Contract       │◀──────│  Buyer (MetaMask)      │
│   • IPFS CID                    │  ETH  │  • Connect wallet      │
│   • AES-256 key                 │───────│  • Pay contract        │
│   • Price                       │  key  │  • Decrypt in browser  │
│   • Seller address              │──────▶│  • Download file       │
└─────────────────────────────────┘       └────────────────────────┘
```

## 📁 Project Structure

```
CryptoVendingMachine/
├── crypto_vending_machine.py    # Main CLI tool
├── contracts/
│   └── FileVendingMachine.sol   # Solidity smart contract
├── frontend/                    # Generated buyer UI (IPFS-hosted)
├── demos/
│   ├── demo_encrypt_decrypt.py  # Encryption roundtrip demo
│   ├── demo_full_pipeline.py    # Full seller→buyer simulation
│   └── demo_visual.py           # Architecture diagrams
├── tests/
│   └── test_encryption.py       # Encryption test suite
├── research/
│   ├── RESEARCH_PAPER.md        # Academic research paper
│   ├── SCIENTIFIC_AMERICAN_ARTICLE.md  # Popular science article
│   └── ORACLE_NOTES.md          # Design research notes
├── requirements.txt             # Python dependencies
└── README.md                    # This file
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install pycryptodome web3 requests
```

### 2. Encrypt a File

```bash
python crypto_vending_machine.py encrypt --file secret.pdf --price 0.01
```

This will:
- Encrypt `secret.pdf` with AES-256-GCM
- Upload the encrypted file to IPFS (or simulate if no daemon)
- Save configuration to `output/config.json`

### 3. Deploy to Testnet

```bash
export PRIVATE_KEY="0xYourPrivateKey"
export RPC_URL="https://rpc.sepolia.org"

python crypto_vending_machine.py deploy \
  --config output/config.json \
  --network sepolia
```

This will:
- Compile and deploy the smart contract
- Generate the buyer frontend HTML
- Upload the frontend to IPFS
- Print the buyer link

### 4. Full Pipeline

```bash
python crypto_vending_machine.py full \
  --file secret.pdf \
  --price 0.01 \
  --network sepolia
```

## 🎮 Demos

### Encryption Demo
```bash
python demos/demo_encrypt_decrypt.py
```
Shows the cryptographic roundtrip: encrypt → inspect → decrypt → verify integrity.

### Full Pipeline Demo
```bash
python demos/demo_full_pipeline.py
```
Simulates the entire seller→buyer flow without needing Ethereum or IPFS.

### Visual Architecture
```bash
python demos/demo_visual.py
```
Displays ASCII art diagrams of the system architecture, data flow, and security model.

## 🧪 Tests

```bash
python -m pytest tests/ -v
```

Tests cover:
- Encryption/decryption roundtrips
- Key size and nonce uniqueness
- Tamper detection (GCM integrity)
- Wrong key rejection
- Edge cases (empty files, large files, binary data)
- Frontend HTML generation

## 🔒 Security Model

| Layer | Technology | Guarantee |
|-------|-----------|-----------|
| Encryption | AES-256-GCM | 2^256 brute-force resistance, tamper detection |
| Storage | IPFS | Content-addressed (CID = hash), tamper-evident |
| Payment | Ethereum | Atomic, immutable, verifiable |
| Decryption | WebCrypto API | Client-side only, hardware-accelerated |
| Frontend | IPFS-hosted | No server, censorship-resistant |

## 🌐 Supported Networks

| Network | Chain ID | Use Case |
|---------|----------|----------|
| `mainnet` | 1 | Production sales |
| `sepolia` | 11155111 | Testing |
| `holesky` | 17000 | Testing |
| `localhost` | 31337 | Development (Hardhat/Anvil) |

## 📊 Cost Estimates

| Operation | Gas | Cost (mainnet) | Cost (L2) |
|-----------|-----|----------------|-----------|
| Deploy contract | ~1M | ~$90 | ~$1-5 |
| Purchase | ~60K | ~$5 | ~$0.10 |
| Withdraw | ~30K | ~$3 | ~$0.05 |

*Prices at 30 gwei gas, $3000 ETH. L2 estimates for Arbitrum/Base.*

## 🧑‍💻 How the Buyer Experience Works

1. Buyer opens the IPFS-hosted link in their browser
2. Page shows file info, price, and network
3. Buyer clicks "Connect MetaMask" → wallet connects
4. Buyer clicks "Purchase" → MetaMask pops up with transaction
5. Transaction confirms → contract emits decryption key in event
6. Frontend fetches encrypted file from IPFS
7. Browser decrypts file using WebCrypto API (AES-256-GCM)
8. Decrypted file is offered as a download

**Total time: ~20-30 seconds.** No servers involved. Everything runs on Ethereum + IPFS + the buyer's browser.

## 📄 Research

- **[Research Paper](research/RESEARCH_PAPER.md)** — Full academic paper with security analysis, gas costs, and extensions
- **[Scientific American Article](research/SCIENTIFIC_AMERICAN_ARTICLE.md)** — Accessible explanation for general audiences
- **[Oracle Notes](research/ORACLE_NOTES.md)** — Design decision research notes

## 🛣️ Roadmap

- [ ] Multi-buyer licensing (N-purchase contracts)
- [ ] Threshold encryption (Shamir's Secret Sharing)
- [ ] Time-locked refund mechanism
- [ ] EIP-1167 minimal proxy factory for cheaper deployment
- [ ] L2 deployment guides (Arbitrum, Base, Optimism)
- [ ] Arweave permanent storage option
- [ ] Content preview mechanism
- [ ] On-chain seller reputation system

## ⚖️ License

MIT License — use freely, build upon it, sell your files.
