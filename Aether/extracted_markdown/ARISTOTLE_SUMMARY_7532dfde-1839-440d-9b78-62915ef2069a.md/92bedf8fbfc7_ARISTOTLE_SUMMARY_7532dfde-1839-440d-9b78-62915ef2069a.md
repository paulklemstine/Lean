# Summary of changes
## CryptoVend v3 — Threshold Cryptography Conversion Complete

The CryptoVending2 project has been fully converted from a seller-online watcher model to a **serverless, automated threshold cryptography architecture**. The seller deploys once and goes offline permanently. Here's what changed:

### Architecture Transformation

**Before (v2):** Seller must keep `seller.html` open in their browser to watch for `PurchaseRequested` events and call `deliverKey()` on-chain. Single point of failure.

**After (v3):** The AES encryption key is split into N shares using **Shamir's Secret Sharing over GF(256)**. Shares are distributed to independent oracle nodes. After setup, the seller goes offline forever. Buyers collect t-of-N shares from oracle HTTP endpoints, reconstruct the key via Lagrange interpolation, verify against the on-chain commitment, and decrypt.

### Files Created/Modified

| File | Change |
|------|--------|
| `contracts/CryptoVendThreshold.sol` | **New** — Threshold contract with oracle registry, share commitments, no `deliverKey()` |
| `seller.html` | **Rewritten** — Adds Shamir split, oracle configuration, share encryption & IPFS pinning, oracle on-chain registration |
| `buyer_template.html` | **Updated** — Template reflects share collection, threshold badge, share visualization |
| `oracle.html` | **New** — Browser-based oracle node with share loading from IPFS, ECIES re-encryption, polling mode, and serverless export |
| `README.md` | **Rewritten** — Full v3 documentation with architecture diagrams, threshold parameters, cost comparison |
| `research/threshold_design.md` | **New** — 11-section technical design document covering protocol spec, GF(256) math, security analysis, idempotent state model, oracle deployment models |
| `demo/demo_script.md` | **Updated** — New demo flow showing oracle setup and threshold share collection |
| `archive/v2/` | **New** — Archived v2 seller, buyer template, and README for reference |

### Key Design Decisions

1. **Shamir's Secret Sharing over GF(2^8)** — Each byte of the 32-byte AES key is split independently using the AES irreducible polynomial (0x11b). Supports up to 255 oracles.

2. **Pull-based oracle model** — Oracles don't watch the chain; buyers query oracle HTTP endpoints on demand. This enables truly serverless deployment (Cloudflare Workers, AWS Lambda).

3. **Idempotent state** — All state lives in two immutable stores: the smart contract (on-chain) and IPFS (content-addressed). Oracle nodes are stateless — they reconstruct their share from IPFS + their own Ethereum key. No external databases.

4. **Double verification** — Each share is verified against its on-chain commitment (`keccak256(share)`), AND the reconstructed key is verified against the key commitment (`keccak256(aesKey)`). Dishonest oracles are detected immediately.

5. **Off-chain key delivery** — Unlike v2's `deliverKey()` transaction, share delivery is entirely off-chain (HTTP), making per-sale costs ~41% cheaper.

### The Watcher Is Gone

The v2 watcher pattern (`startWatcher()`, `contract.on('PurchaseRequested', ...)`, polling loop, `deliverKey()` transactions) has been completely removed. The new system is fully automated and serverless — the seller deploys once and the oracle network handles all future sales indefinitely.