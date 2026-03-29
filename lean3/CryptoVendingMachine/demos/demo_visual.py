#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════╗
║     DEMO 3: Visual Architecture & Flow Diagrams                       ║
║                                                                        ║
║     Generates ASCII art diagrams showing the system architecture,      ║
║     data flow, and security model of the Crypto Vending Machine.       ║
╚══════════════════════════════════════════════════════════════════════════╝
"""


def print_architecture():
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║                    CRYPTO VENDING MACHINE — Architecture                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║   ┌─────────────┐          ┌──────────────┐          ┌────────────────┐     ║
║   │             │  encrypt │              │  upload   │                │     ║
║   │  Original   │────────▶│  Encrypted   │─────────▶│     IPFS       │     ║
║   │  File       │  AES-256│  File        │  CID     │  (permanent    │     ║
║   │             │  -GCM   │  (.enc)      │          │   storage)     │     ║
║   └─────────────┘         └──────────────┘          └───────┬────────┘     ║
║                                                              │              ║
║         ┌────────────────────────────────────────────────────┘              ║
║         │  CID                                                              ║
║         ▼                                                                   ║
║   ┌───────────────────────────────────────────┐                             ║
║   │         Ethereum Smart Contract            │                             ║
║   │  ┌─────────────────────────────────────┐  │                             ║
║   │  │  ipfsCID:       "Qm..."            │  │                             ║
║   │  │  price:         10000000000000000   │  │                             ║
║   │  │  encryptionKey: 0xABCD...          │  │                             ║
║   │  │  seller:        0x1234...          │  │                             ║
║   │  │  purchased:     false              │  │                             ║
║   │  │  buyer:         0x0000...          │  │                             ║
║   │  └─────────────────────────────────────┘  │                             ║
║   │                                            │                             ║
║   │  purchase() ─▶ emit Purchased(key)        │                             ║
║   │  withdraw() ─▶ send ETH to seller         │                             ║
║   └───────────────────────────────────────────┘                             ║
║         │                                                                    ║
║         │  contract address + ABI                                           ║
║         ▼                                                                    ║
║   ┌───────────────────────────────────────────┐          ┌──────────────┐   ║
║   │         IPFS-Hosted Frontend               │  upload │              │   ║
║   │  ┌─────────────────────────────────────┐  │────────▶│    IPFS      │   ║
║   │  │  • MetaMask connection              │  │  CID    │  (frontend)  │   ║
║   │  │  • Purchase button                  │  │         │              │   ║
║   │  │  • In-browser AES-GCM decrypt       │  │         └──────────────┘   ║
║   │  │  • File download                    │  │                             ║
║   │  └─────────────────────────────────────┘  │                             ║
║   └───────────────────────────────────────────┘                             ║
║                                                                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)


def print_data_flow():
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║                        DATA FLOW — Seller to Buyer                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║   SELLER                           BLOCKCHAIN              BUYER           ║
║   ══════                           ══════════              ═════           ║
║                                                                             ║
║   ┌──────────┐                                                              ║
║   │ 1. File  │                                                              ║
║   └────┬─────┘                                                              ║
║        │                                                                    ║
║        ▼                                                                    ║
║   ┌──────────┐                                                              ║
║   │ 2. Gen   │──key──┐                                                     ║
║   │    Key   │       │                                                      ║
║   └────┬─────┘       │                                                      ║
║        │              │                                                      ║
║        ▼              │                                                      ║
║   ┌──────────┐       │                                                      ║
║   │ 3. AES   │       │                                                      ║
║   │ Encrypt  │       │                                                      ║
║   └────┬─────┘       │                                                      ║
║        │              │                                                      ║
║        ▼              │                                                      ║
║   ┌──────────┐       │                                                      ║
║   │ 4. IPFS  │       │                                                      ║
║   │ Upload   │       │                                                      ║
║   └────┬─────┘       │                                                      ║
║        │ CID         │                                                      ║
║        ▼              ▼                                                      ║
║   ┌──────────┐  ┌──────────┐                                                ║
║   │ 5. Deploy│  │ Contract │                                                ║
║   │ Contract ├─▶│ (on-     │                                                ║
║   └──────────┘  │  chain)  │◀───── 7. purchase() ────┌──────────┐          ║
║                 │          │         + ETH            │ 6. Visit │          ║
║                 │ key,CID, │                          │ Frontend │          ║
║                 │ price    │──── 8. emit key ────────▶│          │          ║
║                 └──────────┘                          └────┬─────┘          ║
║                                                            │                ║
║                                                            ▼                ║
║                                                       ┌──────────┐         ║
║                                                       │ 9. Fetch │         ║
║                                                       │ from IPFS│         ║
║                                                       └────┬─────┘         ║
║                                                            │                ║
║                                                            ▼                ║
║                                                       ┌──────────┐         ║
║                                                       │10. AES   │         ║
║                                                       │ Decrypt  │         ║
║                                                       └────┬─────┘         ║
║                                                            │                ║
║                                                            ▼                ║
║                                                       ┌──────────┐         ║
║                                                       │11. File! │         ║
║                                                       │    📄    │         ║
║                                                       └──────────┘         ║
║                                                                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)


def print_security_model():
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║                          SECURITY MODEL                                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║   ENCRYPTION LAYER (AES-256-GCM)                                           ║
║   ┌────────────────────────────────────────────────────────────┐            ║
║   │  • 256-bit random key  →  2^256 brute-force resistance    │            ║
║   │  • 96-bit random nonce →  unique per encryption           │            ║
║   │  • GCM mode            →  authenticated encryption        │            ║
║   │  • AAD (filename)      →  binds ciphertext to context     │            ║
║   │                                                            │            ║
║   │  Threat: Key extraction from blockchain after purchase     │            ║
║   │  Mitigation: Key is revealed only after payment confirmed  │            ║
║   │  Note: Post-purchase, key is public (single-buyer model)   │            ║
║   └────────────────────────────────────────────────────────────┘            ║
║                                                                             ║
║   STORAGE LAYER (IPFS)                                                      ║
║   ┌────────────────────────────────────────────────────────────┐            ║
║   │  • Content-addressed  →  tamper-evident (CID = hash)      │            ║
║   │  • Distributed        →  censorship resistant              │            ║
║   │  • Immutable          →  file cannot be modified           │            ║
║   │  • Encrypted at rest  →  IPFS nodes see only ciphertext   │            ║
║   └────────────────────────────────────────────────────────────┘            ║
║                                                                             ║
║   PAYMENT LAYER (Ethereum)                                                  ║
║   ┌────────────────────────────────────────────────────────────┐            ║
║   │  • Atomic exchange     →  payment ↔ key reveal            │            ║
║   │  • Immutable contract  →  seller can't change terms       │            ║
║   │  • Single-serving      →  one buyer, then locked          │            ║
║   │  • Verifiable          →  anyone can audit the contract    │            ║
║   │  • Non-custodial       →  no intermediary holds funds     │            ║
║   └────────────────────────────────────────────────────────────┘            ║
║                                                                             ║
║   KNOWN LIMITATIONS                                                         ║
║   ┌────────────────────────────────────────────────────────────┐            ║
║   │  ⚠ Key visible on-chain post-purchase (by design)         │            ║
║   │  ⚠ No refund mechanism (add time-lock for production)     │            ║
║   │  ⚠ Front-running risk (use commit-reveal for high-value)  │            ║
║   │  ⚠ IPFS pinning required for file availability           │            ║
║   │  ⚠ Gas costs for deployment (~$2-10 at current prices)    │            ║
║   └────────────────────────────────────────────────────────────┘            ║
║                                                                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)


def print_comparison():
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║                 COMPARISON WITH EXISTING SOLUTIONS                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                             ║
║  Feature              │ Gumroad  │ Patreon │  Our System  │ Traditional    ║
║  ─────────────────────┼──────────┼─────────┼──────────────┼────────────    ║
║  Decentralized        │    ✗     │    ✗    │     ✅       │     ✗          ║
║  No intermediary      │    ✗     │    ✗    │     ✅       │     ✗          ║
║  Censorship resistant │    ✗     │    ✗    │     ✅       │     ✗          ║
║  Crypto payments      │    ✗     │    ✗    │     ✅       │     ✗          ║
║  Verifiable terms     │    ✗     │    ✗    │     ✅       │     ✗          ║
║  No platform fee      │    ✗     │    ✗    │     ✅*      │     ✗          ║
║  Self-hosted          │    ✗     │    ✗    │     ✅       │    ✅          ║
║  Fiat payments        │   ✅     │   ✅    │     ✗        │    ✅          ║
║  Customer support     │   ✅     │   ✅    │     ✗        │    ✅          ║
║  Refunds              │   ✅     │   ✅    │     ✗**      │    ✅          ║
║  File size limit      │  varies  │ varies  │    IPFS      │   server      ║
║  Analytics            │   ✅     │   ✅    │   on-chain   │    varies     ║
║                                                                             ║
║  * Gas fees apply  ** Can be added with time-locked contracts               ║
║                                                                             ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)


def main():
    print("\n" + "═" * 70)
    print("  CRYPTO VENDING MACHINE — Visual Architecture Guide")
    print("═" * 70)

    print_architecture()
    input("  Press Enter to see the data flow diagram...")

    print_data_flow()
    input("  Press Enter to see the security model...")

    print_security_model()
    input("  Press Enter to see the comparison table...")

    print_comparison()

    print("\n  ✅ All diagrams displayed. See research/ for the full paper.\n")


if __name__ == "__main__":
    # Non-interactive mode if piped
    import sys
    if not sys.stdin.isatty():
        print_architecture()
        print_data_flow()
        print_security_model()
        print_comparison()
    else:
        main()
