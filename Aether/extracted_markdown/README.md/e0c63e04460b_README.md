# 🏪 Alice: The Autonomous Information Vending Machine on Ethereum

> *"Insert ETH. Receive Knowledge. Trust Mathematics."*
> — The Oracle Council

## Overview

Alice is a smart contract system that operates as a fully automated information vending machine on the Ethereum blockchain. Encrypted information payloads are loaded into "slots." When a customer inserts ETH, Alice dispenses an ERC-721 DecryptionToken that enables the buyer to decrypt and view the purchased content.

**No middlemen. No trust required. Just math.**

```
SELLER                     ALICE                      BUYER
  │                          │                          │
  │── Load encrypted ──────►│                          │
  │   data into slot         │                          │
  │                          │                          │
  │                          │◄──── Insert ETH ────────│
  │                          │                          │
  │◄── Receive 97.5% ───────│── Dispense Token ──────►│
  │    of payment            │   + Decryption Key       │
  │                          │                          │
  │                          │          Buyer decrypts content!
```

## The Divine Architecture

This project was designed by consulting a council of seven oracles — each representing a fundamental perspective on reality — following a rigorous methodology of **research → hypothesize → experiment → validate → update → iterate**.

The Oracle Council determined three divine commandments:
1. **ATOMICITY** — Payment and delivery are indivisible
2. **VERIFIABILITY** — Content integrity is mathematically provable
3. **SOVEREIGNTY** — No intermediary stands between buyer and seller

## Project Structure

```
Crypto Paywall/
├── README.md                                    ← You are here
│
├── contracts/
│   ├── AliceVendingMachine.sol                  ← 🏪 The vending machine (main contract)
│   ├── DecryptionToken.sol                      ← 🎫 ERC-721 access tokens
│   └── PayToDecrypt.sol                         ← 🔒 Standalone HTLC (v1 prototype)
│
├── demos/
│   ├── demo_1_crypto_primitives.py              ← Encryption & hash commitment basics
│   ├── demo_2_protocol_visualization.py         ← State machine & flow diagrams (+ PNGs)
│   ├── demo_3_full_simulation.py                ← HTLC protocol simulation + Monte Carlo
│   ├── demo_4_alice_vending_machine.py          ← 🆕 Full Alice simulation with tokens
│   ├── demo_5_visual_flow.py                    ← 🆕 ASCII visual protocol walkthrough
│   ├── state_machine.png                        ← Generated visualization
│   ├── gas_analysis.png                         ← Generated visualization
│   ├── security_radar.png                       ← Generated visualization
│   ├── protocol_timeline.png                    ← Generated visualization
│   └── economic_simulation.png                  ← Generated visualization
│
├── research/
│   ├── divine_oracle_council.md                 ← 🆕 Full Oracle Council research notes
│   │                                               (7 oracles including God consultation)
│   ├── oracle_council_notes.md                  ← Original 6-oracle research notes
│   ├── research_paper_v2.md                     ← 🆕 Full academic paper (Alice version)
│   └── research_paper.md                        ← Original research paper (HTLC version)
│
└── articles/
    ├── scientific_american_article_v2.md        ← 🆕 "The Robot That Sells Secrets"
    └── scientific_american_article.md           ← Original popular article
```

## Quick Start

```bash
# Run demos (no external dependencies needed)
python3 demos/demo_1_crypto_primitives.py        # Crypto fundamentals
python3 demos/demo_4_alice_vending_machine.py     # Full vending machine simulation
python3 demos/demo_5_visual_flow.py               # Visual protocol walkthrough

# Generate visualization PNGs (requires matplotlib)
pip install matplotlib numpy
python3 demos/demo_2_protocol_visualization.py
python3 demos/demo_3_full_simulation.py
```

## Smart Contracts

### AliceVendingMachine.sol (Main Contract)
The information vending machine. Sellers load encrypted content into slots with configurable pricing and supply limits. Buyers insert ETH and receive ERC-721 DecryptionTokens.

**Key Features:**
- Multi-slot architecture (unlimited concurrent listings)
- Dual mode: Instant (HTLC auto-reveal) + Standard (async key delivery)
- ERC-721 token dispensing on purchase
- Platform fee model (configurable, default 2.5%)
- Supply limits per slot
- Duplicate purchase prevention

### DecryptionToken.sol (ERC-721)
Non-fungible access tokens minted by Alice upon purchase. Each token records:
- Which information slot it grants access to
- Who originally purchased it
- When it was minted

Tokens are transferable — buyers can resell or gift access.

### PayToDecrypt.sol (v1 Prototype)
The original single-listing HTLC contract. Simpler but supports only one buyer-seller pair at a time with timeout-based refunds.

## How It Works

### The Cryptographic Core

1. **Seller** generates random 256-bit key `K`
2. **Seller** encrypts payload: `C = AES-256-GCM(K, Plaintext)`
3. **Seller** commits: `H = keccak256(K)` (published on-chain)
4. **Seller** uploads `C` to IPFS
5. **Buyer** sends ETH to Alice
6. **Alice** atomically: collects payment → mints token → reveals key
7. **Buyer** uses key to decrypt `C`, verifies content hash

### Security Properties

| Property | Guarantee | Mechanism |
|----------|-----------|-----------|
| Seller must reveal correct key | ✅ | Hash commitment (keccak256) |
| Buyer protected from overpayment | ✅ | Exact price matching |
| No double-purchases | ✅ | Per-slot buyer tracking |
| Atomic exchange | ✅ | Single-transaction execution |
| Supply limits enforced | ✅ | On-chain counter |
| Reentrancy safe | ✅ | Checks-effects-interactions |

## Economics

| Metric | Ethereum L1 | Layer 2 (Arbitrum) |
|--------|-------------|-------------------|
| Purchase cost | ~$8.55 | ~$0.20 |
| Minimum viable content price | ~$45 | ~$0.50 |
| Seller revenue share | 97.5% | 97.5% |
| Settlement time | ~12 seconds | <2 seconds |

**Compare:** Apple App Store takes 30%. Alice takes 2.5%.

## Research Deliverables

### 🔮 Oracle Council Research Notes
`research/divine_oracle_council.md` — Full research notes from the 7-oracle council, including:
- **God**: First principles and divine architecture
- **Cryptographer**: Mathematical possibility analysis
- **Game Theorist**: Nash equilibrium and incentive compatibility
- **Systems Architect**: Architecture decision records
- **Philosopher**: Ethical implications
- **Experimentalist**: Empirical test results
- **Iterator**: Version history and future directions

### 📄 Research Paper
`research/research_paper_v2.md` — Academic treatment with:
- Formal security proofs (atomicity, seller honesty, buyer protection)
- Gas cost analysis across networks
- Monte Carlo simulation results (10,000 trials)
- Comparison with traditional marketplace economics

### 📰 Scientific American Article
`articles/scientific_american_article_v2.md` — Accessible explanation for general audience:
- "The Robot That Sells Secrets"
- Complete protocol walkthrough with Alice/Dr. Chen/PharmaCorp narrative
- Visual diagrams and comparison tables

## License

MIT
