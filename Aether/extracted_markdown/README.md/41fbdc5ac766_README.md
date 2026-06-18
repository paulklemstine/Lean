# ⚡ CryptoVend v3 — Threshold Edition

**Sell any digital file with no server, no intermediary, no trust, and no seller online — just HTML pages, a smart contract, and threshold cryptography.**

CryptoVend v3 eliminates the last remaining bottleneck from v2: the requirement for the seller to stay online. Using **Shamir's Secret Sharing**, the AES encryption key is split into N shares distributed across independent oracle nodes. After initial setup, the seller goes offline permanently. Buyers collect t-of-N shares from the oracle network, reconstruct the key, and decrypt — all automatically.

---

## What Changed from v2

| Aspect | v2 | v3 (Threshold) |
|--------|-----|----------------|
| Seller online? | **Must stay online** to deliver keys | **Goes offline permanently** after setup |
| Key management | Seller holds full AES key | Key split into Shamir shares |
| Key delivery | Seller watches events, calls `deliverKey()` | Oracle nodes serve shares on demand |
| Single point of failure | Seller's browser | **None** — any t-of-N oracles suffice |
| Per-sale gas (seller) | ~$0.007 for `deliverKey` tx | **$0** — oracle delivery is off-chain |
| Architecture | Seller SAP + Watcher → Contract → Buyer | Seller SAP (once) → Contract + Oracles → Buyer |

---

## Architecture

```
   SETUP (one-time)                           PURCHASE (automated, forever)
   ═════════════════                          ══════════════════════════════

┌──────────────┐                           ┌──────────────┐
│  seller.html │   ┌──────────────────┐    │  Buyer Page  │
│  (local,     │──▶│  Smart Contract  │◀───│  (IPFS)      │
│   one-time)  │   │  (L2 chain)      │    │              │
│              │   │                  │    │  • Pay        │
│  • Encrypt   │   │  • Price         │    │  • Collect    │
│  • Shamir    │   │  • Key commit    │    │    shares     │
│    split     │   │  • Share commits │    │  • Lagrange   │
│  • Deploy    │   │  • Oracle info   │    │    reconstruct│
│  • Pin IPFS  │   │  • Purchases     │    │  • Decrypt    │
│  • Register  │   └──────────────────┘    └──────┬───────┘
│    oracles   │            ▲                      │
└──────────────┘            │ verify               │ query
       │                    │ payment              │
       │ shares             │                      ▼
       ▼                ┌───┴──────────────────────────┐
┌──────────────┐        │       Oracle Network          │
│     IPFS     │        │  ┌─────┐ ┌─────┐ ┌─────┐    │
│  • enc file  │        │  │ O_1 │ │ O_2 │ │ O_3 │ .. │
│  • buyer pg  │        │  │share│ │share│ │share│    │
│  • enc shares│        │  └──┬──┘ └──┬──┘ └──┬──┘    │
└──────────────┘        │     │       │       │        │
                        │     └───────┴───────┘        │
                        │       any t suffice          │
                        └──────────────────────────────┘
```

## How It Works

### Seller Flow (One-Time Setup)
1. Open `seller.html` in your browser
2. Connect MetaMask
3. Select a file, choose L2 network, set price
4. Configure oracle network: set threshold (t) and total oracles (N), enter oracle addresses and endpoints
5. Click **Deploy** — the browser:
   - Generates a random AES-256 key
   - Encrypts the file with AES-256-GCM
   - Uploads encrypted file to IPFS
   - **Splits AES key into N Shamir shares** (threshold t)
   - Encrypts each share for its oracle node
   - Uploads encrypted shares to IPFS
   - Deploys `CryptoVendThreshold` smart contract on L2
   - Registers all oracles on-chain with share commitments
   - Generates buyer page HTML with embedded threshold logic
   - Pins buyer page to IPFS
6. **Close the page. You're done forever.** ✨

### Oracle Flow (Automated)
Each oracle node is a stateless HTTP endpoint (serverless function or browser page):
1. Receives a share request from a buyer
2. Verifies on-chain that the purchase is paid and valid
3. Loads its encrypted share from IPFS
4. Decrypts its share using its own Ethereum key
5. Re-encrypts the share with the buyer's ECIES public key
6. Returns the encrypted share

Oracle nodes don't need to "watch" or "poll" — they respond to buyer HTTP requests on demand.

### Buyer Flow (Fully Automated)
1. Visit the IPFS buyer page link
2. Click **Connect & Buy**
3. MetaMask pops up — approve the transaction
4. The page automatically contacts each oracle endpoint
5. Visual progress shows shares being collected (e.g., "3/5 shares collected")
6. Once t shares are collected, the page:
   - Reconstructs the AES key via Lagrange interpolation in GF(256)
   - Verifies the key against the on-chain commitment
   - Downloads the encrypted file from IPFS
   - Decrypts the file in-browser
7. File downloads automatically

**No seller needed. No watcher. No waiting.** Total time: ~15-30 seconds.

---

## Threshold Cryptography

### Shamir's Secret Sharing

The AES-256 key (32 bytes) is split into N shares using a (t, N) threshold scheme over GF(256):

- A random polynomial of degree t-1 is generated for each byte position
- The constant term is the secret byte
- Shares are evaluations at x = 1, 2, ..., N
- Any t shares reconstruct the secret via Lagrange interpolation
- Fewer than t shares reveal **zero information** (information-theoretic security)

### Security Properties

| Property | Guarantee |
|----------|-----------|
| Share secrecy | < t shares reveal nothing (information-theoretic) |
| Key integrity | On-chain commitment: `keccak256(AES_key)` |
| Share integrity | On-chain commitments: `keccak256(share_i)` per oracle |
| Transport security | ECIES/secp256k1 per-buyer encryption |
| Payment verification | On-chain smart contract state |
| Fault tolerance | Any t-of-N oracles suffice |

### Recommended Configurations

| Use Case | Threshold | Total | Tolerance |
|----------|-----------|-------|-----------|
| Testing | 2-of-3 | 3 | 1 offline |
| Personal | 3-of-5 | 5 | 2 offline |
| Professional | 5-of-9 | 9 | 4 offline |
| Enterprise | 7-of-13 | 13 | 6 offline |

---

## Idempotent State

All system state is derived from two immutable sources:

### On-Chain (Smart Contract)
- Price, key commitment, threshold, oracle count
- Oracle registry: addresses, share commitments, IPFS CIDs, endpoints
- Purchase records: buyer address, pubkey, payment, refund status

### IPFS (Content-Addressed)
- Encrypted file
- Buyer page HTML
- Encrypted shares (one per oracle)

### Recovery
- **Oracle loses state?** → Reload from IPFS using their Ethereum key
- **Buyer page lost?** → CID stored on-chain, fetch from any IPFS gateway
- **Contract address lost?** → Look up deployment in block explorer
- **No external databases. No mutable off-chain state.**

---

## Project Structure

```
CryptoVending2/
├── seller.html                    # Seller SAP — threshold setup
├── buyer_template.html            # Reference buyer page template
├── oracle.html                    # Oracle node interface (browser-based)
├── contracts/
│   ├── CryptoVendThreshold.sol    # v3 threshold contract
│   └── CryptoVendL2.sol           # v2 contract (reference)
├── research/
│   ├── threshold_design.md        # Full threshold design document
│   ├── oracle_notes.md            # v2 oracle council notes
│   ├── research_paper.md          # v2 research paper
│   └── scientific_american.md     # Popular science article
├── demo/
│   ├── demo_visual.html           # Interactive visual walkthrough
│   └── demo_script.md             # Demo presentation script
├── archive/
│   └── v2/                        # Archived v2 files for reference
│       ├── seller_v2.html
│       ├── buyer_template_v2.html
│       └── README_v2.md
└── README.md                      # This file
```

## Quick Start

### Prerequisites
- Chrome or Firefox with MetaMask
- Testnet ETH on Arbitrum Sepolia
- 3-5 oracle node operators (friends, team members, or your own serverless functions)

### Step 1: Compile the Contract
```bash
# Foundry
forge build contracts/CryptoVendThreshold.sol

# Or use Remix IDE: https://remix.ethereum.org
# Compile with Solidity 0.8.24, optimizer enabled
```

### Step 2: Set Up Oracle Nodes
Each oracle operator needs:
1. An Ethereum wallet address
2. An HTTP endpoint (serverless function or `oracle.html` in a browser)
3. Access to their wallet to sign transactions

### Step 3: Deploy as Seller
1. Open `seller.html`
2. Connect MetaMask
3. Select file, network, price
4. Enter oracle addresses and endpoints
5. Click Deploy
6. Share the buyer page IPFS link
7. **Close the page!** 🎉

### Step 4: Oracle Operators Start Serving
1. Open `oracle.html`
2. Connect MetaMask
3. Enter contract address and oracle index
4. Click "Load Share from IPFS"
5. Click "Start Serving" (or deploy as serverless function)

### Step 5: Buyers Purchase
1. Visit the IPFS buyer page
2. Click "Connect & Buy"
3. File downloads automatically after share collection

---

## Oracle Deployment Options

### Option 1: Browser-Based (Development)
Open `oracle.html`, connect wallet, start serving. Simple but requires keeping a tab open.

### Option 2: Serverless Functions (Production)
Deploy as Cloudflare Workers / AWS Lambda / Vercel Functions:
- The `oracle.html` page can export a ready-to-deploy serverless worker
- Stateless, pay-per-invocation
- Auto-scales, high availability
- Share loaded from IPFS on each invocation

### Option 3: Community Oracle Network (Future)
Multiple independent operators each run oracle nodes, incentivized by:
- Fees per share served
- Reputation systems
- Staking/slashing mechanics

---

## Cost Comparison (Base L2)

| Operation | v2 Cost | v3 Cost | Notes |
|-----------|---------|---------|-------|
| Deploy | ~$0.08 | ~$0.12 | Slightly larger contract |
| Oracle setup (one-time) | — | ~$0.02 × N | ~$0.10 for 5 oracles |
| Per sale (buyer) | ~$0.01 | ~$0.01 | Same |
| Per sale (seller/oracle) | ~$0.007 | **$0** | Off-chain delivery! |
| **Total per sale** | **$0.017** | **$0.01** | **41% cheaper per sale** |

After ~15 sales, v3's higher setup cost is recouped by lower per-sale costs.

---

## The Elephant Has Left the Room 🐘

In v2, the "elephant in the room" was the seller-online requirement. In v3, **the elephant is gone**:

- ~~Seller must keep tab open~~ → Seller goes offline after setup
- ~~Single point of failure~~ → Any t-of-N oracles suffice
- ~~Watcher pattern~~ → Pull-based oracle queries
- ~~Trust in seller~~ → Trust distributed across N independent oracles

The only remaining trust assumption is that at least t oracle nodes are honest and available. With appropriate threshold parameters (e.g., 3-of-5 with geographically distributed operators), this provides high availability and strong security.

---

## License

MIT
