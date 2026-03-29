#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║  DEMO 5: Visual Protocol Flow — The Complete Journey of a Secret           ║
║                                                                            ║
║  Animated ASCII visualization showing:                                     ║
║  • The lifecycle of information through the vending machine                ║
║  • Money flow with fee splitting                                           ║
║  • Token minting and delivery                                              ║
║  • Side-by-side comparison: Traditional vs. Alice                          ║
║                                                                            ║
║  No external dependencies — runs with Python 3.8+ standard library.       ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import sys
import time

# ═══════════════════════════════════════════════════════════════════════════════
#  COLORS
# ═══════════════════════════════════════════════════════════════════════════════

class C:
    RESET   = '\033[0m'
    BOLD    = '\033[1m'
    DIM     = '\033[2m'
    RED     = '\033[91m'
    GREEN   = '\033[92m'
    YELLOW  = '\033[93m'
    BLUE    = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN    = '\033[96m'
    WHITE   = '\033[97m'

PAUSE = 0.5

def pause(seconds=PAUSE):
    time.sleep(seconds)

def header(text):
    print(f"\n{C.BOLD}{C.YELLOW}{'═' * 72}")
    print(f"  {text}")
    print(f"{'═' * 72}{C.RESET}\n")


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUALIZATION 1: THE TRUST PROBLEM
# ═══════════════════════════════════════════════════════════════════════════════

def show_trust_problem():
    header("THE FUNDAMENTAL PROBLEM: Who Goes First?")

    print(f"""  {C.WHITE}The ancient dilemma of information commerce:{C.RESET}

  {C.RED}Scenario A: Buyer pays first{C.RESET}
  ┌─────────────┐                    ┌─────────────┐
  │   SELLER     │ ◄── $$$$ ──────── │    BUYER     │
  │   Has secret │                    │   Has money  │
  │              │ ──── 🗑️  ──────► │              │
  │  (sends junk)│                    │ (loses money)│
  └─────────────┘                    └─────────────┘
  Result: Buyer vulnerable to fraud 😞

  {C.RED}Scenario B: Seller reveals first{C.RESET}
  ┌─────────────┐                    ┌─────────────┐
  │   SELLER     │ ──── 📄 ────────► │    BUYER     │
  │   Has secret │                    │   Has money  │
  │ (loses value)│ ◄── nothing ───── │ (keeps money)│
  │              │                    │  (has secret)│
  └─────────────┘                    └─────────────┘
  Result: Seller gives away their secret for free 😞

  {C.GREEN}{C.BOLD}Scenario C: Alice (atomic exchange){C.RESET}
  ┌─────────────┐    ┌─────────┐    ┌─────────────┐
  │   SELLER     │    │  ALICE  │    │    BUYER     │
  │   Has secret │    │  🏪     │    │   Has money  │
  │              │    │         │    │              │
  │ ─ key hash ─────► │ escrow │ ◄──── ETH ────── │
  │              │    │         │    │              │
  │ ─ reveal K ─────► │verify! │ ─── token+key ──► │
  │ ◄── ETH ─────── │  done   │    │              │
  │              │    │         │    │ (decrypts!)  │
  │ (gets paid!) │    │         │    │ (has secret!)│
  └─────────────┘    └─────────┘    └─────────────┘
  Result: Both parties satisfied. Trust replaced by math. 😊
""")


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUALIZATION 2: THE VENDING MACHINE LIFECYCLE
# ═══════════════════════════════════════════════════════════════════════════════

def show_lifecycle():
    header("THE LIFECYCLE: From Secret to Sale")

    stages = [
        (C.CYAN, "STAGE 1: CREATION", """
  Seller has a valuable secret (research data, vulnerability report, etc.)

  ┌────────────────────────────────────────────────────────────────┐
  │                                                                │
  │  🧑‍🔬 SELLER                                                    │
  │                                                                │
  │  Secret:  "Quantum error correction achieves 99.99%..."        │
  │                                                                │
  │  Step 1: Generate random 256-bit key                           │
  │          K = 0x7a3f...b291                                     │
  │                                                                │
  │  Step 2: Encrypt secret with key                               │
  │          C = AES-256-GCM(K, Secret)                            │
  │          C = 0x8b4c...encrypted...noise...                     │
  │                                                                │
  │  Step 3: Compute commitment                                    │
  │          H = keccak256(K) = 0x1d5e...                          │
  │                                                                │
  │  Step 4: Upload C to IPFS                                      │
  │          CID = ipfs://QmResearch123...                         │
  │                                                                │
  └────────────────────────────────────────────────────────────────┘"""),

        (C.YELLOW, "STAGE 2: LOADING", """
  Seller loads the slot into Alice (the vending machine contract)

  ┌─────────────────────────────────────────────────────────────────┐
  │                                                                 │
  │  🧑‍🔬 SELLER ──── loadSlotInstant(                               │
  │                    keyHash:  0x1d5e...,                         │
  │                    content:  0x9f2a...,   ────────► 🏪 ALICE   │
  │                    uri:      "ipfs://Qm...",                    │
  │                    title:    "Quantum Research",                 │
  │                    price:    0.5 ETH,                            │
  │                    key:      0x7a3f...b291                      │
  │                  )                                               │
  │                                                                 │
  │  Alice verifies: keccak256(key) == keyHash ✅                    │
  │  Alice stores: slot loaded, awaiting customers                  │
  │                                                                 │
  │  Gas cost: ~120,000 gas ($10.80 on L1, $0.25 on L2)            │
  │                                                                 │
  └─────────────────────────────────────────────────────────────────┘"""),

        (C.GREEN, "STAGE 3: PURCHASE", """
  Buyer selects a slot and inserts ETH

  ┌─────────────────────────────────────────────────────────────────┐
  │                                                                 │
  │  🛒 BUYER ──── purchase(slotId=0) ────► 🏪 ALICE               │
  │             {value: 0.5 ETH}                                    │
  │                                                                 │
  │  Alice processes:                                               │
  │  ┌──────────────────────────────────────────────────────┐       │
  │  │ ✅ Slot 0 is loaded                                  │       │
  │  │ ✅ Payment = 0.5 ETH (matches price)                 │       │
  │  │ ✅ Buyer hasn't purchased this slot before            │       │
  │  │ ✅ Supply not exhausted                               │       │
  │  │                                                      │       │
  │  │ 💰 Fee: 0.0125 ETH (2.5%) → Platform                │       │
  │  │ 💰 Net: 0.4875 ETH → Seller                         │       │
  │  │                                                      │       │
  │  │ 🎫 Mint DecryptionToken #0 → Buyer                   │       │
  │  │ 📢 Emit InstantKeyRevealed(key=0x7a3f...)            │       │
  │  └──────────────────────────────────────────────────────┘       │
  │                                                                 │
  │  All in ONE atomic transaction (~95,000 gas)                    │
  │                                                                 │
  └─────────────────────────────────────────────────────────────────┘"""),

        (C.MAGENTA, "STAGE 4: DECRYPTION", """
  Token holder uses their token to decrypt the payload

  ┌─────────────────────────────────────────────────────────────────┐
  │                                                                 │
  │  🛒 BUYER (now TOKEN HOLDER)                                    │
  │                                                                 │
  │  Step 1: Read key from InstantKeyRevealed event                 │
  │          K = 0x7a3f...b291                                      │
  │                                                                 │
  │  Step 2: Download ciphertext from IPFS                          │
  │          C = fetch("ipfs://QmResearch123...")                    │
  │                                                                 │
  │  Step 3: Decrypt                                                │
  │          Plaintext = AES-256-GCM.decrypt(K, C)                  │
  │                                                                 │
  │  Step 4: Verify content hash                                    │
  │          keccak256(Plaintext) == contentHash ✅                  │
  │                                                                 │
  │  ┌──────────────────────────────────────────────────────┐       │
  │  │  📄 DECRYPTED:                                       │       │
  │  │  "Quantum error correction achieves 99.99%..."       │       │
  │  │                                                      │       │
  │  │  Content verified! This is exactly what the seller    │       │
  │  │  committed to before any payment was made.            │       │
  │  └──────────────────────────────────────────────────────┘       │
  │                                                                 │
  │  The token remains as proof of purchase (transferable NFT).     │
  │                                                                 │
  └─────────────────────────────────────────────────────────────────┘"""),
    ]

    for color, title, content in stages:
        print(f"  {color}{C.BOLD}{title}{C.RESET}")
        print(content)
        print()
        pause(0.3)


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUALIZATION 3: MONEY FLOW
# ═══════════════════════════════════════════════════════════════════════════════

def show_money_flow():
    header("MONEY FLOW: Where Does the ETH Go?")

    print(f"""
  {C.WHITE}When a buyer purchases from Alice, the ETH is split atomically:{C.RESET}

                         0.5000 ETH
  {C.CYAN}🛒 BUYER{C.RESET} ═══════════════════════════► {C.YELLOW}🏪 ALICE{C.RESET}
                                            │
                                            │ Alice splits the payment:
                                            │
                         0.4875 ETH         │
  {C.GREEN}🧑‍🔬 SELLER{C.RESET} ◄════════════════════════════╡ (97.5%)
                                            │
                         0.0125 ETH         │
  {C.MAGENTA}🏛️ PLATFORM{C.RESET} ◄══════════════════════════╡ (2.5%)
                                            │
                         Token #42          │
  {C.CYAN}🛒 BUYER{C.RESET} ◄════════════════════════════╡ (ERC-721)
                                            │
                         Key (event)        │
  {C.CYAN}🛒 BUYER{C.RESET} ◄════════════════════════════╯ (in same tx)


  {C.YELLOW}Financial Summary for 100 sales at 0.5 ETH:{C.RESET}

  ┌───────────────────────────────────────────────────┐
  │                                                   │
  │  Total Volume:           50.0000 ETH              │
  │  Seller Revenue:         48.7500 ETH (97.5%)      │
  │  Platform Fees:           1.2500 ETH (2.5%)       │
  │  Buyer Gas Costs:        ~0.9500 ETH (~$2,850)    │
  │  Seller Gas Costs:       ~1.0800 ETH (~$3,240)    │
  │                                                   │
  │  Effective Seller Take:  95.3% of gross volume    │
  │  Effective Buyer Cost:   51.9% over list price    │
  │                                                   │
  │  {C.GREEN}Compare: App Store takes 30%. Alice takes 2.5%.{C.RESET}{C.YELLOW}   │
  │                                                   │
  └───────────────────────────────────────────────────┘
""")


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUALIZATION 4: SECURITY SHIELD
# ═══════════════════════════════════════════════════════════════════════════════

def show_security():
    header("SECURITY SHIELD: How Alice Protects Everyone")

    print(f"""
  {C.GREEN}╔═══════════════════════════════════════════════════════════════════╗
  ║                    ALICE'S SECURITY LAYERS                      ║
  ╠═══════════════════════════════════════════════════════════════════╣
  ║                                                                 ║
  ║  Layer 1: HASH COMMITMENT (Seller Honesty)                      ║
  ║  ┌─────────────────────────────────────────────────────────┐    ║
  ║  │ Seller commits H = keccak256(K) BEFORE buyer pays.     │    ║
  ║  │ → Seller cannot change the key after seeing payment     │    ║
  ║  │ → Finding a fake key requires breaking keccak256        │    ║
  ║  │ → Security: 2^256 brute force (heat death of universe)  │    ║
  ║  └─────────────────────────────────────────────────────────┘    ║
  ║                                                                 ║
  ║  Layer 2: PAYMENT VERIFICATION (Buyer Protection)               ║
  ║  ┌─────────────────────────────────────────────────────────┐    ║
  ║  │ Contract checks msg.value == price exactly.             │    ║
  ║  │ → Underpayment rejected, overpayment rejected           │    ║
  ║  │ → Duplicate purchases prevented                         │    ║
  ║  │ → Supply limits enforced                                │    ║
  ║  └─────────────────────────────────────────────────────────┘    ║
  ║                                                                 ║
  ║  Layer 3: ATOMIC EXECUTION (Fair Exchange)                      ║
  ║  ┌─────────────────────────────────────────────────────────┐    ║
  ║  │ Token minting + ETH transfer + key reveal = ONE tx.     │    ║
  ║  │ → Either all three happen, or none happen               │    ║
  ║  │ → No intermediate state where one party loses           │    ║
  ║  │ → Reentrancy prevented by checks-effects-interactions   │    ║
  ║  └─────────────────────────────────────────────────────────┘    ║
  ║                                                                 ║
  ║  Layer 4: CONTENT VERIFICATION (Post-Purchase)                  ║
  ║  ┌─────────────────────────────────────────────────────────┐    ║
  ║  │ Content hash H_P = keccak256(plaintext) stored on-chain │    ║
  ║  │ → Buyer can verify decrypted content matches commitment │    ║
  ║  │ → Seller cannot swap content after listing creation     │    ║
  ║  └─────────────────────────────────────────────────────────┘    ║
  ║                                                                 ║
  ╠═══════════════════════════════════════════════════════════════════╣
  ║                                                                 ║
  ║  {C.RED}KNOWN LIMITATION: Front-Running in Instant Mode{C.GREEN}              ║
  ║  ┌─────────────────────────────────────────────────────────┐    ║
  ║  │ In instant mode, the key appears in the transaction     │    ║
  ║  │ before mining. Mitigation: Use Flashbots Protect for    │    ║
  ║  │ private transaction submission.                         │    ║
  ║  └─────────────────────────────────────────────────────────┘    ║
  ║                                                                 ║
  ╚═══════════════════════════════════════════════════════════════════╝{C.RESET}
""")


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUALIZATION 5: COMPARISON TABLE
# ═══════════════════════════════════════════════════════════════════════════════

def show_comparison():
    header("COMPARISON: Traditional Marketplace vs. Alice")

    print(f"""
  {C.WHITE}┌────────────────────┬──────────────────────┬──────────────────────┐
  │                    │  TRADITIONAL         │  ALICE               │
  │    Feature         │  (App Store, etc.)   │  (Smart Contract)    │
  ├────────────────────┼──────────────────────┼──────────────────────┤
  │ Trust model        │  Trust the platform  │  Trust math only     │
  │ Fee                │  15-30%              │  2.5% (configurable) │
  │ Settlement time    │  30-90 days          │  ~12 seconds         │
  │ Intermediary       │  Required            │  None                │
  │ Censorship         │  Platform can censor │  Uncensorable        │
  │ Availability       │  Platform uptime     │  Ethereum uptime     │
  │ Content verified   │  No (trust seller)   │  Hash commitment     │
  │ Payment reversals  │  Yes (chargebacks)   │  No (atomic)         │
  │ Global access      │  Restricted by region│  Borderless          │
  │ Identity required  │  Usually yes         │  No (pseudonymous)   │
  │ Seller lockout     │  Platform can ban    │  Impossible          │
  │ Revenue share      │  70-85% to seller    │  97.5% to seller     │
  └────────────────────┴──────────────────────┴──────────────────────┘{C.RESET}

  {C.GREEN}{C.BOLD}Alice gives sellers 97.5% of revenue with 12-second settlement,
  zero intermediaries, and mathematical guarantees of fair exchange.{C.RESET}
""")


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUALIZATION 6: USE CASES
# ═══════════════════════════════════════════════════════════════════════════════

def show_use_cases():
    header("USE CASES: What Can Alice Sell?")

    print(f"""
  {C.CYAN}┌──────────────────────────────────────────────────────────────────┐
  │                                                                │
  │  🔬 RESEARCH DATA                                              │
  │  Scientists sell proprietary datasets with verifiable          │
  │  statistical properties. Buyers confirm data quality           │
  │  via content hash before purchasing.                           │
  │                                                                │
  │  🛡️ BUG BOUNTIES                                               │
  │  Security researchers sell vulnerability reports to affected   │
  │  companies. Payment guarantees fair compensation;              │
  │  hash commitment proves the report exists before payment.      │
  │                                                                │
  │  📰 INVESTIGATIVE JOURNALISM                                   │
  │  Sources sell evidence to journalists with the payment         │
  │  serving as insurance — cryptographic proof of transaction.    │
  │                                                                │
  │  🧠 AI MODEL WEIGHTS                                           │
  │  Researchers sell fine-tuned model weights. Content hash       │
  │  verifies the model is exactly what was advertised.            │
  │                                                                │
  │  📊 FINANCIAL DATA                                             │
  │  Proprietary trading signals, datasets, or analyses sold       │
  │  with mathematical proof of delivery.                          │
  │                                                                │
  │  🎨 DIGITAL ART (Limited Editions)                             │
  │  Artists sell limited-edition digital works. Max supply         │
  │  enforced by smart contract — verifiable scarcity.             │
  │                                                                │
  │  🔐 ACCESS CREDENTIALS                                        │
  │  One-time passwords, API keys, or access tokens sold           │
  │  atomically. Buyer gets the credential only upon payment.      │
  │                                                                │
  └──────────────────────────────────────────────────────────────────┘{C.RESET}
""")


# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print(f"\n{C.BOLD}{C.YELLOW}")
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║                                                            ║")
    print("  ║   🎬 VISUAL PROTOCOL FLOW                                  ║")
    print("  ║   The Complete Journey of a Secret Through Alice           ║")
    print("  ║                                                            ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")
    print(C.RESET)

    show_trust_problem()
    show_lifecycle()
    show_money_flow()
    show_security()
    show_comparison()
    show_use_cases()

    print(f"\n{C.BOLD}{C.GREEN}")
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║  Visual flow complete. Alice is ready to serve.            ║")
    print("  ║  Run demo_4_alice_vending_machine.py for live simulation.  ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")
    print(C.RESET)


if __name__ == '__main__':
    main()
