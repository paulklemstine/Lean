# 🗄️ CryptoVending

**A trustless, decentralised file vending machine built on Ethereum + IPFS.**

Encrypt any file, deploy a smart contract, and sell it to anyone on Earth — no server, no intermediary, no trust required.

---

## How It Works

```
SELLER                              BUYER
──────                              ─────
  │                                   │
  │  1. Encrypt file (AES-256-GCM)    │
  │  2. Upload to IPFS                │
  │  3. Deploy smart contract         │
  │  4. Upload buyer page to IPFS     │
  │                                   │
  │  ─── shares IPFS link ──────────► │
  │                                   │
  │                    5. Visit page   │
  │                    6. Connect MetaMask
  │                    7. Generate ECIES keypair
  │  ◄── purchase(pubkey) + ETH ───── │
  │                                   │
  │  8. Encrypt AES key with          │
  │     buyer's public key (ECIES)    │
  │  9. deliverKey(encryptedKey)       │
  │                                   │
  │  ─── encrypted key on-chain ────► │
  │                                   │
  │                   10. Decrypt AES key
  │                   11. Download from IPFS
  │                   12. Decrypt file
  │                   13. 🎉
```

## Quick Start

### Prerequisites

```bash
pip install -r requirements.txt
```

### 1. Create (encrypt + upload)

```bash
python vending_machine.py create \
    --file my_secret_file.pdf \
    --price 0.01 \
    --ipfs mock       # Use 'local' for IPFS daemon, 'pinata' for cloud
```

### 2. Deploy the contract

```bash
# Start a local node first: npx hardhat node  OR  ganache-cli
python vending_machine.py deploy \
    --artifact my_secret_file_vend.json \
    --network localhost
```

### 3. Run the key-delivery watcher

```bash
python vending_machine.py watch \
    --artifact my_secret_file_vend.json \
    --private-key 0xYOUR_SELLER_PRIVATE_KEY
```

### 4. Buyer visits the IPFS page

The buyer opens the IPFS URL from the artifact, connects MetaMask, pays, and the file is decrypted and downloaded automatically.

---

## Architecture

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Encryption | AES-256-GCM | File confidentiality + integrity |
| Key transport | ECIES (secp256k1) | Encrypt AES key for specific buyer |
| Payment | Ethereum smart contract | Trustless payment enforcement |
| File storage | IPFS | Decentralised, content-addressed |
| Buyer UI | IPFS-hosted HTML SPA | No server needed |
| Key delivery | Python watcher daemon | Automated seller-side |

## Security Properties

- ✅ **AES key never on-chain in cleartext** — only ECIES-encrypted
- ✅ **Buyer's private key never leaves browser** — generated and used locally
- ✅ **Authenticated encryption** — GCM tag prevents tampering
- ✅ **Content-addressed storage** — IPFS CID = integrity check
- ✅ **Key commitment** — buyer can verify correct key delivery
- ✅ **Atomic payment** — Ethereum guarantees all-or-nothing

## Project Structure

```
CryptoVending/
├── vending_machine.py          # Main CLI tool
├── contracts/
│   └── FileVendingMachine.sol  # Solidity smart contract
├── templates/
│   └── buyer_page.html         # IPFS-hosted buyer interface
├── src/
│   ├── crypto_utils.py         # AES + ECIES encryption
│   ├── ipfs_utils.py           # IPFS upload/download
│   ├── contract_utils.py       # Solidity compilation + deployment
│   └── watcher.py              # Automated key delivery daemon
├── tests/
│   └── test_encryption.py      # Comprehensive test suite
├── demo/
│   ├── demo_walkthrough.sh     # Shell demo script
│   └── demo_visual.py          # Animated ASCII visualization
├── research/
│   ├── notes.md                # Oracle council research notes
│   ├── paper.md                # Technical research paper
│   └── sci_am_article.md       # Scientific American-style article
├── requirements.txt
└── README.md
```

## Deployment Options

| Network | Use case | Gas cost |
|---------|----------|----------|
| `localhost` / `hardhat` | Development & testing | Free |
| `sepolia` | Testnet (free test ETH) | Free |
| `mainnet` | Production | ~$14/sale at 30 gwei |
| Arbitrum / Base (future) | Low-cost production | ~$1.50/sale |

## IPFS Backends

| Backend | Command | Requirements |
|---------|---------|-------------|
| `mock` | `--ipfs mock` | None (in-memory) |
| `local` | `--ipfs local` | `ipfs daemon` running |
| `pinata` | `--ipfs pinata` | `PINATA_API_KEY` + `PINATA_SECRET` env vars |

## Running Tests

```bash
cd CryptoVending
pytest tests/ -v
```

## Demo

```bash
# Visual demo (no blockchain needed):
python demo/demo_visual.py

# Full walkthrough:
bash demo/demo_walkthrough.sh
```

## Documentation

- **[Research Notes](research/notes.md)** — Oracle council deliberations, design decisions, experiment log
- **[Technical Paper](research/paper.md)** — Formal protocol description, security analysis, economic analysis
- **[Scientific American Article](research/sci_am_article.md)** — Accessible overview for general audiences

## License

MIT
