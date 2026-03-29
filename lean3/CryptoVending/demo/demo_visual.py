#!/usr/bin/env python3
"""
demo_visual.py — Visual demonstration of the CryptoVending pipeline.

Displays an animated ASCII visualization of:
  1. File encryption
  2. IPFS upload
  3. Smart contract deployment
  4. Buyer purchase flow
  5. Key exchange
  6. File decryption

Run:  python demo/demo_visual.py
"""

import time
import sys
import os

# ── Colours ───────────────────────────────────────────────────────────
CYAN    = "\033[96m"
GREEN   = "\033[92m"
YELLOW  = "\033[93m"
MAGENTA = "\033[95m"
RED     = "\033[91m"
BOLD    = "\033[1m"
DIM     = "\033[2m"
RESET   = "\033[0m"
BLUE    = "\033[94m"


def slow_print(text, delay=0.02):
    """Print text character by character."""
    for ch in text:
        sys.stdout.write(ch)
        sys.stdout.flush()
        time.sleep(delay)
    print()


def section(title, color=CYAN):
    """Print a section header."""
    print()
    print(f"{color}{BOLD}{'═' * 60}{RESET}")
    print(f"{color}{BOLD}  {title}{RESET}")
    print(f"{color}{BOLD}{'═' * 60}{RESET}")
    print()
    time.sleep(0.5)


def step(number, description, delay=1.0):
    """Print a step indicator."""
    print(f"  {YELLOW}[{number}]{RESET} {description}")
    time.sleep(delay)


def arrow(direction="down"):
    """Print a flow arrow."""
    if direction == "down":
        print(f"       {DIM}│{RESET}")
        print(f"       {DIM}▼{RESET}")
    else:
        print(f"       {DIM}──────►{RESET}")
    time.sleep(0.3)


def box(lines, color=GREEN, width=52):
    """Print a bordered box."""
    print(f"  {color}┌{'─' * width}┐{RESET}")
    for line in lines:
        padded = line.ljust(width)[:width]
        print(f"  {color}│{RESET}{padded}{color}│{RESET}")
    print(f"  {color}└{'─' * width}┘{RESET}")


# ═══════════════════════════════════════════════════════════════════════
#  Main demo
# ═══════════════════════════════════════════════════════════════════════

def main():
    os.system("clear" if os.name == "posix" else "cls")

    print(f"""
{MAGENTA}{BOLD}
   ╔═══════════════════════════════════════════════════════╗
   ║                                                       ║
   ║     🗄️  CryptoVending — Visual Demo                   ║
   ║     Decentralised File Sales via Ethereum + IPFS      ║
   ║                                                       ║
   ╚═══════════════════════════════════════════════════════╝
{RESET}""")
    time.sleep(1)

    # ── Phase 1: Seller Setup ─────────────────────────────────────────
    section("PHASE 1: SELLER — File Encryption & Upload", CYAN)

    step("1.1", "Seller has a file to sell…")
    box([
        "  📄 secret_recipe.txt (1.2 KB)              ",
        "  ─────────────────────────────────────────── ",
        "  Grandma's Famous Cookie Recipe              ",
        "  2 cups flour, 1 cup butter ...              ",
    ], BLUE)

    arrow()
    step("1.2", "Generate AES-256 encryption key…")
    print(f"       {DIM}Key: a7f3b2c1...e8d4f5a6 (256 bits){RESET}")

    arrow()
    step("1.3", "Encrypt file with AES-256-GCM…")
    box([
        "  🔒 secret_recipe.txt.enc (1.3 KB)           ",
        "  ─────────────────────────────────────────── ",
        "  x9€§∆˚≈∫µ∂ƒ©˙∆˚¬...≈ç√∫˜µ≤≥÷             ",
        "  (Authenticated encryption — tamper-proof)   ",
    ], RED)

    arrow()
    step("1.4", "Upload encrypted file to IPFS…")
    slow_print(f"       {GREEN}✓ CID: QmX7b3kP...R9v2{RESET}", 0.03)
    print(f"       {DIM}File is now content-addressed & immutable{RESET}")

    # ── Phase 2: Contract Deployment ──────────────────────────────────
    section("PHASE 2: SELLER — Smart Contract Deployment", YELLOW)

    step("2.1", "Compile Solidity contract…")
    box([
        "  FileVendingMachine.sol                      ",
        "  ─────────────────────────────────────────── ",
        "  • Stores IPFS CID                           ",
        "  • Price: 0.01 ETH                           ",
        "  • Key commitment: keccak256(AES_KEY)        ",
        "  • Single-serving mode                       ",
    ], YELLOW)

    arrow()
    step("2.2", "Deploy to Ethereum…")
    slow_print(f"       {GREEN}✓ Contract: 0x71C7...F3a8{RESET}", 0.03)
    slow_print(f"       {DIM}Gas used: 847,231 · Block: 18,294,001{RESET}", 0.03)

    arrow()
    step("2.3", "Build buyer page & upload to IPFS…")
    slow_print(f"       {GREEN}✓ Buyer page CID: QmY8c4...K2w7{RESET}", 0.03)
    print(f"       {DIM}→ https://ipfs.io/ipfs/QmY8c4...K2w7{RESET}")

    arrow()
    step("2.4", "Start key-delivery watcher…")
    print(f"       {GREEN}⚡ Watcher running — polling every 5s{RESET}")

    # ── Phase 3: Buyer Flow ───────────────────────────────────────────
    section("PHASE 3: BUYER — Purchase & Decrypt", GREEN)

    step("3.1", "Buyer opens IPFS-hosted page in browser…")
    box([
        "  🌐 Browser: ipfs.io/ipfs/QmY8c4...K2w7     ",
        "  ─────────────────────────────────────────── ",
        "  ┌─────────────────────────────────┐         ",
        "  │  🗄️ File Vending Machine         │         ",
        "  │  Price: 0.01 ETH                │         ",
        "  │  [Connect Wallet & Buy]         │         ",
        "  └─────────────────────────────────┘         ",
    ], GREEN)

    arrow()
    step("3.2", "Connect MetaMask wallet…")
    print(f"       {GREEN}🦊 MetaMask connected: 0xBuyer...1234{RESET}")

    arrow()
    step("3.3", "Generate ECIES keypair (in browser)…")
    print(f"       {DIM}Private: kept in browser memory{RESET}")
    print(f"       {DIM}Public:  04a1b2c3... (65 bytes, secp256k1){RESET}")

    arrow()
    step("3.4", "Send 0.01 ETH + public key to contract…")
    box([
        "  📤 Transaction                               ",
        "  ─────────────────────────────────────────── ",
        "  To:     0x71C7...F3a8 (contract)            ",
        "  Value:  0.01 ETH                            ",
        "  Data:   purchase(0x04a1b2c3...)             ",
    ], YELLOW)
    time.sleep(0.5)
    slow_print(f"       {GREEN}✓ Tx confirmed · Gas: 95,420{RESET}", 0.03)

    # ── Phase 4: Key Exchange ─────────────────────────────────────────
    section("PHASE 4: KEY EXCHANGE (Automated)", MAGENTA)

    step("4.1", "Watcher detects PurchaseInitiated event…")
    print(f"       {MAGENTA}📡 Purchase #0 from 0xBuyer...1234{RESET}")

    arrow()
    step("4.2", "Watcher encrypts AES key with buyer's public key (ECIES)…")
    print(f"       {DIM}ECIES(buyer_pubkey, AES_KEY) → encrypted_key{RESET}")

    arrow()
    step("4.3", "Watcher calls deliverKey() on contract…")
    slow_print(f"       {GREEN}✓ Key delivered on-chain{RESET}", 0.03)

    # ── Phase 5: Buyer Decrypts ───────────────────────────────────────
    section("PHASE 5: BUYER — Decrypt & Download", GREEN)

    step("5.1", "Buyer's page detects KeyDelivered event…")
    print(f"       {GREEN}📡 Encrypted key received{RESET}")

    arrow()
    step("5.2", "Decrypt AES key with ECIES private key (in browser)…")
    print(f"       {DIM}ECIES_decrypt(private_key, encrypted_key) → AES_KEY{RESET}")

    arrow()
    step("5.3", "Download encrypted file from IPFS…")
    slow_print(f"       {CYAN}⬇ Fetching QmX7b3kP...R9v2 (1.3 KB){RESET}", 0.03)

    arrow()
    step("5.4", "Decrypt file with AES-256-GCM…")
    box([
        "  📄 secret_recipe.txt (decrypted!)           ",
        "  ─────────────────────────────────────────── ",
        "  Grandma's Famous Cookie Recipe              ",
        "  2 cups flour, 1 cup butter ...              ",
        "  ─────────────────────────────────────────── ",
        "  ✅ Integrity verified (GCM auth tag OK)     ",
    ], GREEN)

    step("5.5", "File saved to buyer's downloads! 🎉")

    # ── Summary ───────────────────────────────────────────────────────
    section("SECURITY PROPERTIES", BLUE)
    properties = [
        ("Confidentiality", "AES key never appears in cleartext on-chain"),
        ("Integrity",       "AES-GCM provides authenticated encryption"),
        ("Atomicity",       "Payment is on-chain; no chargebacks"),
        ("Decentralisation", "File on IPFS, logic on Ethereum"),
        ("Privacy",         "ECIES ensures only buyer can decrypt key"),
        ("Immutability",    "IPFS CID guarantees file hasn't changed"),
    ]
    for prop, desc in properties:
        print(f"  {GREEN}✓{RESET} {BOLD}{prop:18s}{RESET} {desc}")
        time.sleep(0.3)

    print(f"""
{MAGENTA}{BOLD}
   ╔═══════════════════════════════════════════════════════╗
   ║                                                       ║
   ║     ✅  Demo Complete!                                ║
   ║                                                       ║
   ║     The decrypted AES key never touches the           ║
   ║     blockchain. The buyer's private key never          ║
   ║     leaves their browser. The file is immutably        ║
   ║     stored on IPFS. Trustless commerce. ⚡             ║
   ║                                                       ║
   ╚═══════════════════════════════════════════════════════╝
{RESET}""")


if __name__ == "__main__":
    main()
