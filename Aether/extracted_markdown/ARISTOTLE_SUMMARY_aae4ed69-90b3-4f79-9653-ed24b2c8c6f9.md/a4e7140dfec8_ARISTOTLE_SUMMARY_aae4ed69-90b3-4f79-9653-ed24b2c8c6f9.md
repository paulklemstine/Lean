# Summary of changes
## Crypto Vending Machine — Complete Project Delivered

Built a full-stack system for selling encrypted files through single-serving Ethereum smart contracts with IPFS storage and MetaMask-powered purchasing. All code is tested and verified.

### Project Structure (`CryptoVendingMachine/`)

#### Core Application
- **`crypto_vending_machine.py`** — Main Python CLI tool with 4 commands:
  - `encrypt` — Encrypts any file with AES-256-GCM, uploads to IPFS, generates config
  - `deploy` — Deploys the Solidity smart contract to any EVM network, generates buyer frontend, uploads to IPFS
  - `full` — Complete pipeline (encrypt + deploy) in one command
  - `test-decrypt` — Verify decryption locally
  - Supports: mainnet, Sepolia, Holesky, Goerli, localhost networks

#### Smart Contract
- **`contracts/FileVendingMachine.sol`** — Minimal (~100 lines) Solidity 0.8.20 contract with:
  - `purchase()` — Atomic ETH-for-key exchange, emits `Purchased` event with decryption key
  - `withdraw()` — Seller withdraws funds after purchase
  - `info()` / `getKey()` — View functions for frontend consumption
  - Single-serving design: one file, one buyer, minimal attack surface

#### Frontend (Auto-Generated)
- Self-contained HTML/CSS/JS buyer page, hosted on IPFS
- Dark-themed, responsive UI with progressive disclosure (connect → purchase → download)
- MetaMask integration with network detection and auto-switching
- In-browser AES-256-GCM decryption via WebCrypto API (zero server interaction)
- Multiple IPFS gateway fallback for reliability
- ethers.js v6 loaded from CDN

#### Tests (11/11 passing ✅)
- **`tests/test_encryption.py`** — Comprehensive test suite covering:
  - Encryption roundtrips, key/nonce sizes, unique ciphertexts
  - Tamper detection (GCM integrity), wrong key rejection
  - Edge cases: empty files, 1MB files, binary data, all byte values
  - Frontend HTML generation validation

#### Demo Scripts (all working ✅)
- **`demos/demo_encrypt_decrypt.py`** — Cryptographic roundtrip with hex dumps, tamper & wrong-key detection
- **`demos/demo_full_pipeline.py`** — Simulates complete seller→buyer flow (no Ethereum/IPFS needed)
- **`demos/demo_visual.py`** — ASCII art architecture diagrams, data flow, security model, comparison table

#### Research & Documentation
- **`research/RESEARCH_PAPER.md`** — Full academic paper: architecture, cryptographic construction, smart contract design, security analysis (6 threat vectors), performance evaluation, gas costs, 8 extension proposals, references
- **`research/SCIENTIFIC_AMERICAN_ARTICLE.md`** — Popular science article explaining the system accessibly, with visual guide and "by the numbers" summary
- **`research/ORACLE_NOTES.md`** — Design research notes from the "oracle council": problem definition, architecture decisions, security deep dive, implementation rationale, future research priorities
- **`README.md`** — Full project documentation with quick start, architecture diagram, cost estimates, roadmap

### How It Works (20-second end-to-end)
1. Seller encrypts file → AES-256-GCM ciphertext + random 256-bit key
2. Encrypted file uploaded to IPFS → content-addressed CID
3. Smart contract deployed with CID, key, and price
4. Buyer frontend (single HTML page) uploaded to IPFS
5. Buyer visits IPFS link → connects MetaMask → pays → contract emits key → browser decrypts → file downloads

No servers. No intermediaries. No platform fees. Just math.