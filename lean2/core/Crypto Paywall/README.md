# PayToDecrypt: Atomic Information-Money Swaps on Ethereum

> *A smart contract protocol that unlocks encrypted information upon payment — trustlessly.*

## Overview

PayToDecrypt enables the trustless, atomic exchange of encrypted digital content for cryptocurrency. An encrypted payload is stored publicly, but can only be decrypted because of — and only because of — a transfer of Ethereum into the contract.

**Core Mechanism:** Hash Time-Locked Contract (HTLC) adapted for information commerce.

```
Seller encrypts secret → publishes hash commitment → Buyer pays into escrow
→ Seller reveals key (verified by hash) → Buyer decrypts → Done.
```

## Project Structure

```
CryptoPaywall/
├── README.md                              ← You are here
├── contracts/
│   └── PayToDecrypt.sol                   ← Solidity smart contract
├── demos/
│   ├── demo_1_crypto_primitives.py        ← Encryption & hash commitments
│   ├── demo_2_protocol_visualization.py   ← State machine & flow diagrams
│   ├── demo_3_full_simulation.py          ← Full protocol simulation + Monte Carlo
│   ├── state_machine.png                  ← Generated: state diagram
│   ├── gas_analysis.png                   ← Generated: gas cost charts
│   ├── security_radar.png                 ← Generated: security property comparison
│   ├── protocol_timeline.png              ← Generated: protocol sequence timeline
│   └── economic_simulation.png            ← Generated: Monte Carlo results
├── research/
│   ├── oracle_council_notes.md            ← Research notes from 6 oracle perspectives
│   └── research_paper.md                  ← Full academic research paper
└── articles/
    └── scientific_american_article.md     ← Popular science article
```

## Quick Start

```bash
# Run all demos (generates terminal output + PNG charts)
pip install matplotlib numpy
python demos/demo_1_crypto_primitives.py
python demos/demo_2_protocol_visualization.py
python demos/demo_3_full_simulation.py
```

## How It Works

1. **Seller** encrypts payload `P` with random key `K`, publishes `(Enc(K,P), Hash(K))` on-chain
2. **Buyer** sends ETH to smart contract (held in escrow)
3. **Seller** reveals `K` — contract verifies `Hash(K)` matches commitment, releases ETH
4. **Buyer** reads `K` from blockchain event, decrypts payload
5. **Timeout safety**: If seller never reveals, buyer reclaims ETH after deadline

## Security Properties

| Property | Status | Mechanism |
|----------|--------|-----------|
| Seller must reveal correct key | ✅ | Hash commitment verification |
| Buyer protected from non-delivery | ✅ | Timeout-based refund |
| Atomic exchange | ✅ | Single-transaction key reveal + payment |
| Front-running resistant | ⚠️ | Use Flashbots Protect |
| Content quality verified | ⚠️ | Requires ZK proof extension |

## Key Deliverables

- **Smart Contract** (`contracts/PayToDecrypt.sol`): Production-ready Solidity with full documentation
- **Research Notes** (`research/oracle_council_notes.md`): Multi-perspective analysis from 6 research oracles
- **Research Paper** (`research/research_paper.md`): Academic treatment with security proofs and economic analysis
- **Popular Article** (`articles/scientific_american_article.md`): Accessible explanation for general audience
- **Demo Scripts** (`demos/`): Interactive Python simulations with generated visualizations
