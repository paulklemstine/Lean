# Oracle Council Research Notes

## Consultation Record: Crypto Vending Machine Design

*Notes from the team of oracles — research, hypothesis, experiment, validate, iterate.*

---

## Session 1: Problem Definition

### Oracle of Commerce (Research Phase)
**Question:** What is the minimum viable trustless digital file sale?

**Findings:**
- A digital file sale reduces to: `pay(money) → receive(file)`
- Trust is needed for two things: (1) payment guarantee, (2) delivery guarantee
- Blockchain provides (1). Content-addressed storage provides (2).
- The missing link is the **atomic exchange** — how to bind payment to delivery

**Key Insight:** The decryption key IS the delivery mechanism. If you can make key release contingent on payment, you've solved it.

### Oracle of Cryptography (Research Phase)
**Question:** What encryption scheme supports this pattern?

**Findings:**
- Need: symmetric encryption (fast, handles arbitrary file sizes)
- Need: authenticated encryption (detect tampering)
- Need: browser-compatible decryption (no server)
- AES-256-GCM satisfies all three requirements
- WebCrypto API provides native browser support since 2015
- Key size (32 bytes) is small enough to store on-chain cheaply

**Decision:** AES-256-GCM with WebCrypto decryption. Unanimous.

---

## Session 2: Architecture Design

### Oracle of Distributed Systems (Hypothesis Phase)
**Hypothesis:** IPFS is sufficient for file storage in this system.

**Pros:**
- Content-addressed: CID = hash of content → tamper-evident
- Distributed: no single point of failure
- Free to upload (if running own node) or cheap (pinning services)
- Permanent addressing: CID never changes

**Cons:**
- Availability depends on pinning (files disappear if not pinned)
- Gateway reliability varies
- Large files (>1GB) can be slow on first download

**Validation:** Acceptable for MVP. Sellers should pin on 2+ services. Add Arweave as a permanent storage option for production.

### Oracle of Smart Contracts (Hypothesis Phase)
**Hypothesis:** A single-serving contract is superior to a marketplace contract.

**Arguments for single-serving:**
1. Simpler code = fewer bugs = less audit needed
2. Each buyer can read and verify the exact contract before paying
3. No shared state = no reentrancy or front-running between buyers
4. Natural unit of atomic deployment and abandonment
5. Composable: can build multi-buyer on top of single-serving

**Arguments against:**
1. Higher deployment gas (one contract per sale vs amortized)
2. More complex seller workflow (deploy per file)
3. No aggregation of sales analytics

**Decision:** Single-serving for MVP. Explore EIP-1167 minimal proxies for gas optimization.

---

## Session 3: Security Deep Dive

### Oracle of Adversarial Thinking (Experiment Phase)
**Experiment:** What can an adversary do to this system?

**Attack 1: Pre-purchase key extraction**
- The AES key is in contract storage (slot accessible via `eth_getStorageAt`)
- Any Ethereum node can read it
- Cost to attacker: running an archive node or using Etherscan API
- **Risk level:** MEDIUM for high-value files, LOW for typical use
- **Mitigation options:**
  a. Threshold encryption (split key across contracts)
  b. Commit-reveal (buyer commits, then key is revealed)
  c. Off-chain key exchange via asymmetric encryption
  d. Accept it — analogous to a physical vending machine visible through glass

**Attack 2: Front-running**
- Attacker sees purchase TX in mempool, extracts key, cancels their own TX
- Only works if attacker can use the key before buyer's TX confirms
- For file purchases, this is impractical (can't "undo" a file download)
- **Risk level:** LOW — the key is useful only after the file is downloaded
- **Mitigation:** Commit-reveal pattern eliminates this

**Attack 3: Seller fraud**
- Seller deploys contract with wrong key or points to wrong IPFS CID
- Buyer can't verify until after payment
- **Risk level:** MEDIUM
- **Mitigation:** Reputation system, escrow period, or verifiable encryption proofs

**Attack 4: IPFS censorship**
- If all pins are removed, encrypted file becomes unavailable
- Contract still has the key, but it's useless without the ciphertext
- **Risk level:** LOW if properly pinned
- **Mitigation:** Multiple pinning services, Arweave backup

### Oracle of Formal Verification (Validation Phase)
**Validation of contract correctness:**

Property 1: **Purchase atomicity**
- `purchase()` either reverts (no state change) or sets `purchased=true` AND emits key
- Verified: no intermediate state possible due to EVM transaction model ✅

Property 2: **Single purchase**
- `if (purchased) revert AlreadyPurchased()` prevents double-purchase
- Boolean flag set before any external interaction
- Verified: no reentrancy possible (no external calls in purchase) ✅

Property 3: **Correct withdrawal**
- Only `seller` can call `withdraw()`
- Only callable after `purchased` is true
- Only callable once (`withdrawn` flag)
- Uses low-level `call` instead of `transfer` (Istanbul gas changes compatible)
- Verified: follows checks-effects-interactions pattern ✅

Property 4: **Immutability**
- No `selfdestruct`, no proxy, no upgrade mechanism
- No admin functions to change key, price, or CID
- Verified: contract is immutable after deployment ✅

---

## Session 4: Implementation Decisions

### Oracle of Engineering (Update Phase)

**Decision Log:**

| Decision | Rationale |
|----------|-----------|
| Python CLI (not Node.js) | Lower barrier, data science ecosystem, pycryptodome |
| Single HTML file (not React) | IPFS-friendly, no build step, self-contained |
| ethers.js v6 from CDN | Most popular, well-documented, CDN = no bundling |
| AES-GCM nonce in file header | Standard practice, simplifies decryption |
| Filename as AAD | Binds ciphertext to context, prevents substitution |
| Inline ABI (not compiled) | Works without solc installed, simpler setup |
| Simulated CID fallback | Allows testing without IPFS daemon running |
| Multiple IPFS gateways | Fallback if primary gateway is slow/down |

### Oracle of User Experience (Update Phase)

**Frontend design principles:**
1. Dark theme (crypto-native aesthetic)
2. Monospace font (trust through transparency)
3. Gradient accents (modern, not sterile)
4. Progressive disclosure (connect → purchase → download)
5. Status messages at every step (reduce anxiety)
6. Multiple IPFS gateway fallback (reliability)
7. Single page, no navigation (vending machine metaphor)

---

## Session 5: Future Research

### All Oracles (Iteration Phase)

**Priority 1: Threshold Encryption**
- Split AES key using Shamir's Secret Sharing
- K-of-N shares stored in independent contracts
- Buyer collects shares after payment
- Eliminates single-point key extraction

**Priority 2: Zero-Knowledge File Proofs**
- Prove properties of the file without revealing it
- "This file contains a valid PDF" without decrypting
- ZK-SNARKs or ZK-STARKs for proof generation
- Would solve the seller-fraud problem

**Priority 3: Streaming Payments**
- Pay per chunk instead of all-at-once
- Superfluid or Sablier-style streaming
- Each chunk has its own key
- Reduces risk for large purchases

**Priority 4: Cross-Chain Interoperability**
- Deploy on L2s (Arbitrum, Base, Optimism) for lower gas
- Bridge contracts for cross-chain purchases
- Same IPFS CID, different payment chains

**Priority 5: Reputation System**
- On-chain reputation for sellers
- Aggregate purchase satisfaction signals
- Sybil-resistant via proof-of-purchase

---

## Conclusion

The oracle council unanimously endorses the single-serving vending machine pattern as a viable, minimal, and elegant solution for trustless digital file sales. The implementation is simple enough to audit, powerful enough to use, and extensible enough to evolve.

The key architectural insight — that a symmetric encryption key is small enough to store on-chain and powerful enough to gate access to arbitrarily large files — bridges the gap between blockchain's limited storage capacity and the real-world need to sell large digital assets.

*"Simplicity is the ultimate sophistication."* — The Oracle Council
