# Summary of changes
# 🏪 Alice: The Autonomous Information Vending Machine on Ethereum

## Complete Deliverables in `Crypto Paywall/`

### 🔮 "Consulting God" — Oracle Council Research
**`research/divine_oracle_council.md`** — Full research notes from a 7-oracle council (including God consultation), following the methodology of research → hypothesize → experiment → validate → update → iterate:
- **Oracle 0 (GOD)**: First principles — three divine commandments (atomicity, verifiability, sovereignty) and the information-money duality
- **Oracle 1 (Cryptographer)**: Hypothesis testing of 3 approaches, validating HTLC as the only viable mechanism
- **Oracle 2 (Game Theorist)**: Nash equilibrium analysis, Monte Carlo tournament of 50,000 transactions across 5 seller archetypes
- **Oracle 3 (Systems Architect)**: Architecture Decision Records (ADRs), vending machine ASCII art, gas cost tables
- **Oracle 4 (Philosopher)**: Metaphysics of trustless exchange, ethical dual-use spectrum analysis
- **Oracle 5 (Experimentalist)**: 5 experiments with detailed pass/fail results
- **Oracle 6 (Iterator)**: Version history (v0.1→v1.0 roadmap), open research questions
- **Oracle 7 (Synthesizer)**: Grand synthesis of all perspectives

### 📜 Smart Contracts
- **`contracts/AliceVendingMachine.sol`** — The main vending machine contract. Multi-slot architecture where sellers load encrypted content and buyers insert ETH to receive ERC-721 DecryptionTokens. Features: dual mode (instant HTLC + standard async), platform fees (2.5%), supply limits, duplicate purchase prevention.
- **`contracts/DecryptionToken.sol`** — ERC-721 NFT contract for access tokens. Only Alice can mint. Tokens carry slot ID, original buyer, and timestamp metadata. Fully transferable.
- **`contracts/PayToDecrypt.sol`** — Original v1 HTLC prototype with timeout-based refunds.

### 🎬 Demo Scripts (all run with no dependencies)
- **`demos/demo_4_alice_vending_machine.py`** — Full vending machine simulation: 3 sellers load slots, buyers purchase and receive tokens, decryption demo, multi-buyer market activity, revenue reports, and attack rejection demonstrations. Rich ASCII art with animated vending machine display.
- **`demos/demo_5_visual_flow.py`** — Visual protocol walkthrough: the trust problem, 4-stage lifecycle, money flow diagrams, security shield layers, traditional vs. Alice comparison table, and use case gallery.
- **`demos/demo_1_crypto_primitives.py`** — Cryptographic foundations demo
- **`demos/demo_2_protocol_visualization.py`** — State machine + flow diagrams (generates PNGs)
- **`demos/demo_3_full_simulation.py`** — HTLC protocol simulation + Monte Carlo analysis

### 📄 Research Paper
**`research/research_paper_v2.md`** — Full academic paper: "Alice: An Autonomous Information Vending Machine on Ethereum." Includes formal security theorems with proofs (atomicity, seller honesty, buyer protection), state machine specification with invariants, gas cost analysis across L1/L2, Monte Carlo simulation results (10,000 trials), fee comparison with Apple/Google/Gumroad, and the Oracle Council methodology.

### 📰 Scientific American Article
**`articles/scientific_american_article_v2.md`** — "The Robot That Sells Secrets." Narrative-driven walkthrough using Dr. Chen/PharmaCorp characters, explains the three miracles (atomicity, verifiability, sovereignty), discusses limitations honestly (front-running, content quality), and envisions future applications (research data, bug bounties, AI models, journalism).

### 📊 Generated Visualizations
5 PNG charts in `demos/`: state machine, gas analysis, security radar, protocol timeline, economic simulation.