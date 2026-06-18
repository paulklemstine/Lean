# Summary of changes
## CryptoVending — Complete Decentralised File Vending Machine

Built a comprehensive system in `CryptoVending/` (3,322 lines, 16 files) that encrypts any file into a single-serving Ethereum vending machine contract with IPFS storage and an IPFS-hosted buyer page. All 9 unit tests pass.

### Core System (`src/` + `vending_machine.py`)

**CLI workflow:**
1. `python vending_machine.py create --file secret.pdf --price 0.01` — Encrypts file with AES-256-GCM, uploads ciphertext to IPFS, generates the buyer HTML page, saves deployment artifact JSON.
2. `python vending_machine.py deploy --artifact vend.json --network sepolia` — Compiles and deploys the Solidity contract to testnet or mainnet.
3. `python vending_machine.py watch --artifact vend.json --private-key 0x...` — Runs an automated daemon that watches for purchase events and delivers ECIES-encrypted decryption keys to buyers.

**Buyer flow:** Customer visits the IPFS-hosted page → connects MetaMask → pays ETH + sends ECIES public key → seller's watcher encrypts AES key with buyer's public key → buyer's browser decrypts key, downloads encrypted file from IPFS, decrypts locally. The AES key never appears in cleartext on-chain.

### Smart Contract (`contracts/FileVendingMachine.sol`)
- Solidity 0.8.19, single-serving or multi-serving mode
- Stores IPFS CID, price, key commitment (keccak256 hash)
- `purchase(buyerPublicKey)` — accepts payment + 65-byte secp256k1 public key
- `deliverKey(purchaseId, encryptedKey)` — seller delivers ECIES-encrypted AES key
- Events: `PurchaseInitiated`, `KeyDelivered`, `FundsWithdrawn`

### Buyer Page (`templates/buyer_page.html`)
- Self-contained IPFS-hosted SPA with dark crypto-native UI
- Uses ethers.js v6 + noble-secp256k1 for in-browser ECIES
- 7-step progress visualization: connect wallet → generate keypair → pay → wait → decrypt key → download → decrypt file
- Fully decentralised — no server needed

### Modules
- `src/crypto_utils.py` — AES-256-GCM encryption + ECIES key transport
- `src/ipfs_utils.py` — Local IPFS daemon, Pinata cloud, or mock backend
- `src/contract_utils.py` — Solidity compilation (solcx) + web3.py deployment
- `src/watcher.py` — Automated key delivery daemon with event polling

### Demo Scripts (`demo/`)
- `demo_visual.py` — Animated ASCII visualization of the full protocol flow with colour-coded phases
- `demo_walkthrough.sh` — End-to-end shell script walkthrough

### Research Documentation (`research/`)
- **`notes.md`** — "Oracle Council" research log with 6 domain perspectives (cryptography, distributed systems, game theory, UX, legal/ethics, economics), experiment results, iteration history
- **`paper.md`** — Formal research paper with protocol description, security theorems (confidentiality, integrity, atomicity), gas cost analysis ($14/sale L1, $1.50/sale L2), architecture diagrams, comparison with OpenSea/Ocean/Lit
- **`sci_am_article.md`** — Scientific American-style accessible article explaining the system to general audiences

### Tests (`tests/test_encryption.py`)
All 9 tests pass: AES round-trip, wrong-key rejection, 1MB large file, pack/unpack with Unicode filenames, mock IPFS, and full end-to-end pipeline.