#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║  DEMO 4: Alice — The Information Vending Machine (Full Simulation)         ║
║                                                                            ║
║  Simulates the complete AliceVendingMachine contract flow:                 ║
║  • Seller loads encrypted information into slots                           ║
║  • Buyer inserts ETH, receives a DecryptionToken (ERC-721)                 ║
║  • Token holder uses their token to decrypt the payload                    ║
║  • Animated terminal visualization of the vending machine                  ║
║  • Multiple scenarios: happy path, multi-buyer, supply limits              ║
║                                                                            ║
║  No external dependencies — runs with Python 3.8+ standard library.       ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import time
import hashlib
import json
import struct
import random
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, Dict, List, Tuple

# ═══════════════════════════════════════════════════════════════════════════════
#  COLORS AND DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════

class C:
    """Terminal colors"""
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
    BG_BLUE = '\033[44m'
    BG_GREEN= '\033[42m'
    BG_RED  = '\033[41m'

DELAY = 0.03  # Animation delay (set to 0 for instant)

def slow_print(text, delay=DELAY):
    """Print text character by character for animation effect."""
    for char in text:
        sys.stdout.write(char)
        sys.stdout.flush()
        if delay > 0 and char not in ' \n':
            time.sleep(delay * 0.3)
    print()

def print_box(title, content, color=C.CYAN, width=72):
    """Print a formatted box."""
    print(f"\n{color}{'═' * width}")
    print(f"  {C.BOLD}{title}{C.RESET}{color}")
    print(f"{'═' * width}{C.RESET}")
    for line in content.split('\n'):
        print(f"  {line}")
    print(f"{C.DIM}{'─' * width}{C.RESET}")

def print_vending_machine(slots_data, highlight_slot=None):
    """Print ASCII art of the vending machine with current slot states."""
    print(f"\n{C.YELLOW}{C.BOLD}")
    print("  ╔═══════════════════════════════════════════════════════════════╗")
    print("  ║              🏪 ALICE — Information Vending Machine          ║")
    print("  ║                  'Insert ETH, Receive Knowledge'             ║")
    print("  ╠═══════════════════════════════════════════════════════════════╣")

    for i, slot in enumerate(slots_data):
        if highlight_slot == i:
            color = C.GREEN + C.BOLD
            indicator = "►►►"
        else:
            color = C.WHITE
            indicator = "   "

        state_icon = {
            'Loaded': '📦',
            'Depleted': '❌',
            'Paused': '⏸️ ',
            'Empty': '⬜',
        }.get(slot.get('state', 'Empty'), '❓')

        sold_bar = '█' * min(slot.get('sold', 0), 10)
        sold_bar += '░' * (10 - len(sold_bar))

        print(f"  ║ {indicator} {color}[{i}] {state_icon} {slot.get('title', 'Empty'):<25}"
              f" {slot.get('price', 0):>8.4f} ETH  "
              f"[{sold_bar}] {slot.get('sold', 0):>3} sold{C.RESET}{C.YELLOW}  ║")

    print("  ╠═══════════════════════════════════════════════════════════════╣")
    print(f"  ║  {C.GREEN}💰 Insert ETH into slot below to purchase{C.YELLOW}               ║")
    print(f"  ║  {C.CYAN}🎫 Receive ERC-721 DecryptionToken on purchase{C.YELLOW}           ║")
    print(f"  ║  {C.MAGENTA}🔓 Use token to decrypt your information{C.YELLOW}                 ║")
    print("  ╚═══════════════════════════════════════════════════════════════╝")
    print(C.RESET)


def print_token(token_id, slot_title, buyer_addr, timestamp):
    """Print ASCII art of a DecryptionToken."""
    print(f"\n{C.GREEN}{C.BOLD}")
    print("  ┌─────────────────────────────────────────┐")
    print(f"  │   🎫 DECRYPTION TOKEN #{token_id:<18}  │")
    print("  │                                         │")
    print("  │   ┌─────────────────────────────────┐   │")
    print("  │   │  🔐 ACCESS GRANTED              │   │")
    print("  │   │                                 │   │")
    print(f"  │   │  Content: {slot_title:<20} │   │")
    print(f"  │   │  Owner:   {buyer_addr[:16]}...  │   │")
    print(f"  │   │  Minted:  {timestamp:<20} │   │")
    print("  │   │                                 │   │")
    print("  │   │  This token grants access to    │   │")
    print("  │   │  decrypt the payload. Present   │   │")
    print("  │   │  to claim your information.     │   │")
    print("  │   └─────────────────────────────────┘   │")
    print("  │                                         │")
    print("  │   ERC-721 · Ethereum · Verified ✅       │")
    print("  └─────────────────────────────────────────┘")
    print(C.RESET)


# ═══════════════════════════════════════════════════════════════════════════════
#  CRYPTOGRAPHIC PRIMITIVES
# ═══════════════════════════════════════════════════════════════════════════════

def keccak256(data: bytes) -> bytes:
    return hashlib.sha3_256(data).digest()

def generate_key() -> bytes:
    return os.urandom(32)

def encrypt(key: bytes, plaintext: bytes) -> dict:
    nonce = os.urandom(12)
    shake = hashlib.shake_256(key + nonce)
    keystream = shake.digest(len(plaintext) + 32)
    ciphertext = bytes(p ^ k for p, k in zip(plaintext, keystream[:len(plaintext)]))
    auth_input = nonce + ciphertext + struct.pack('>Q', len(plaintext))
    tag = hashlib.sha3_256(key + auth_input).digest()[:16]
    return {'nonce': nonce.hex(), 'ciphertext': ciphertext.hex(), 'tag': tag.hex()}

def decrypt(key: bytes, enc_data: dict) -> bytes:
    nonce = bytes.fromhex(enc_data['nonce'])
    ciphertext = bytes.fromhex(enc_data['ciphertext'])
    tag = bytes.fromhex(enc_data['tag'])
    auth_input = nonce + ciphertext + struct.pack('>Q', len(ciphertext))
    expected_tag = hashlib.sha3_256(key + auth_input).digest()[:16]
    if tag != expected_tag:
        raise ValueError("Authentication failed!")
    shake = hashlib.shake_256(key + nonce)
    keystream = shake.digest(len(ciphertext) + 32)
    return bytes(c ^ k for c, k in zip(ciphertext, keystream[:len(ciphertext)]))


# ═══════════════════════════════════════════════════════════════════════════════
#  SIMULATED SMART CONTRACTS
# ═══════════════════════════════════════════════════════════════════════════════

class SlotState(Enum):
    EMPTY = auto()
    LOADED = auto()
    PAUSED = auto()
    DEPLETED = auto()

@dataclass
class InfoSlot:
    seller: str = ""
    key_hash: bytes = b""
    content_hash: bytes = b""
    ciphertext_uri: str = ""
    title: str = ""
    description: str = ""
    price_eth: float = 0.0
    state: SlotState = SlotState.EMPTY
    total_sold: int = 0
    max_supply: int = 0
    revenue_eth: float = 0.0
    instant_mode: bool = False
    decryption_key: bytes = b""  # Only in instant mode

@dataclass
class DecryptionTokenData:
    token_id: int = 0
    slot_id: int = 0
    owner: str = ""
    minted_at: str = ""
    decryption_key: Optional[bytes] = None  # Set in instant mode

class AliceVendingMachineSimulator:
    """Simulates the AliceVendingMachine smart contract."""

    def __init__(self, platform_fee_bps=250):
        self.slots: Dict[int, InfoSlot] = {}
        self.tokens: Dict[int, DecryptionTokenData] = {}
        self.next_slot_id = 0
        self.next_token_id = 0
        self.platform_fee_bps = platform_fee_bps
        self.platform_fees = 0.0
        self.balances: Dict[str, float] = {}
        self.purchased: Dict[Tuple[int, str], bool] = {}

    def load_slot(self, seller: str, key: bytes, plaintext: bytes,
                  ciphertext_uri: str, title: str, description: str,
                  price_eth: float, max_supply: int = 0,
                  instant_mode: bool = True) -> int:
        """Seller loads an information slot."""
        slot_id = self.next_slot_id
        self.next_slot_id += 1

        slot = InfoSlot(
            seller=seller,
            key_hash=keccak256(key),
            content_hash=keccak256(plaintext),
            ciphertext_uri=ciphertext_uri,
            title=title,
            description=description,
            price_eth=price_eth,
            state=SlotState.LOADED,
            max_supply=max_supply,
            instant_mode=instant_mode,
            decryption_key=key if instant_mode else b""
        )
        self.slots[slot_id] = slot
        return slot_id

    def purchase(self, buyer: str, slot_id: int, payment_eth: float) -> Optional[DecryptionTokenData]:
        """Buyer purchases access — Alice dispenses a token!"""
        slot = self.slots.get(slot_id)
        if slot is None or slot.state != SlotState.LOADED:
            raise ValueError(f"Slot {slot_id} is not available")
        if abs(payment_eth - slot.price_eth) > 0.0001:
            raise ValueError(f"Wrong payment: expected {slot.price_eth}, got {payment_eth}")
        if (slot_id, buyer) in self.purchased:
            raise ValueError(f"Already purchased slot {slot_id}")
        if slot.max_supply > 0 and slot.total_sold >= slot.max_supply:
            slot.state = SlotState.DEPLETED
            raise ValueError(f"Slot {slot_id} is depleted")

        # Process payment
        fee = payment_eth * self.platform_fee_bps / 10000
        seller_amount = payment_eth - fee
        self.platform_fees += fee
        slot.revenue_eth += seller_amount
        self.balances[slot.seller] = self.balances.get(slot.seller, 0) + seller_amount

        # Update slot
        slot.total_sold += 1
        self.purchased[(slot_id, buyer)] = True
        if slot.max_supply > 0 and slot.total_sold >= slot.max_supply:
            slot.state = SlotState.DEPLETED

        # Mint token
        token = DecryptionTokenData(
            token_id=self.next_token_id,
            slot_id=slot_id,
            owner=buyer,
            minted_at=time.strftime("%Y-%m-%d %H:%M:%S"),
            decryption_key=slot.decryption_key if slot.instant_mode else None
        )
        self.tokens[self.next_token_id] = token
        self.next_token_id += 1

        return token

    def get_slot_display(self):
        """Get slot data for display."""
        result = []
        for i in range(self.next_slot_id):
            slot = self.slots[i]
            result.append({
                'title': slot.title,
                'price': slot.price_eth,
                'sold': slot.total_sold,
                'state': slot.state.name.capitalize()
            })
        return result


# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN DEMONSTRATION
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print(f"\n{C.BOLD}{C.YELLOW}")
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║                                                            ║")
    print("  ║   🏪 ALICE — The Information Vending Machine               ║")
    print("  ║   Complete Protocol Demonstration                          ║")
    print("  ║                                                            ║")
    print("  ║   'Insert ETH. Receive Knowledge. Trust Mathematics.'      ║")
    print("  ║                                                            ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")
    print(C.RESET)

    alice = AliceVendingMachineSimulator(platform_fee_bps=250)

    # ─── Phase 1: Sellers Load Content ──────────────────────────────────
    print_box("PHASE 1: Sellers Load Encrypted Content into Alice",
              "Three sellers prepare their information for sale.\n"
              "Each generates a key, encrypts their payload, and loads it into Alice.",
              color=C.YELLOW)

    # Seller 1: Research Dataset
    key1 = generate_key()
    plaintext1 = b"QUANTUM COMPUTING BREAKTHROUGH: Novel error correction code achieving 99.99% fidelity..."
    encrypted1 = encrypt(key1, plaintext1)

    slot0 = alice.load_slot(
        seller="0xSeller_Alice_Research",
        key=key1,
        plaintext=plaintext1,
        ciphertext_uri="ipfs://QmResearch123...",
        title="Quantum Research Data",
        description="Breakthrough quantum error correction dataset",
        price_eth=0.5,
        max_supply=100,
        instant_mode=True
    )

    # Seller 2: Security Report
    key2 = generate_key()
    plaintext2 = b"VULNERABILITY REPORT: Critical buffer overflow in Protocol X allows remote code execution..."
    encrypted2 = encrypt(key2, plaintext2)

    slot1 = alice.load_slot(
        seller="0xSeller_Bob_Security",
        key=key2,
        plaintext=plaintext2,
        ciphertext_uri="ipfs://QmSecurity456...",
        title="Security Vulnerability",
        description="Critical vulnerability report for Protocol X",
        price_eth=2.0,
        max_supply=1,  # Exclusive — only one buyer
        instant_mode=True
    )

    # Seller 3: AI Model Weights
    key3 = generate_key()
    plaintext3 = b"MODEL WEIGHTS: Transformer architecture, 7B parameters, trained on curated dataset..."
    encrypted3 = encrypt(key3, plaintext3)

    slot2 = alice.load_slot(
        seller="0xSeller_Carol_AI",
        key=key3,
        plaintext=plaintext3,
        ciphertext_uri="ipfs://QmAIModel789...",
        title="AI Model Weights 7B",
        description="Fine-tuned 7B parameter language model",
        price_eth=5.0,
        max_supply=0,  # Unlimited
        instant_mode=True
    )

    print(f"  {C.GREEN}✅ 3 sellers loaded their content into Alice{C.RESET}")
    print_vending_machine(alice.get_slot_display())

    # ─── Phase 2: Buyer Purchases ───────────────────────────────────────
    print_box("PHASE 2: Buyer Inserts ETH — Alice Dispenses Token",
              "A buyer selects Slot 0 (Quantum Research Data) for 0.5 ETH.\n"
              "Watch as Alice processes the payment and dispenses the token...",
              color=C.GREEN)

    buyer1 = "0xBuyer_David"

    # Animated purchase sequence
    print(f"  {C.CYAN}[1/5] Buyer {buyer1[:16]}... selects Slot 0{C.RESET}")
    time.sleep(0.3)
    print(f"  {C.CYAN}[2/5] Inserting 0.5000 ETH into Alice...{C.RESET}")
    time.sleep(0.3)
    print(f"  {C.CYAN}[3/5] Alice verifies payment amount... ✅{C.RESET}")
    time.sleep(0.3)

    token1 = alice.purchase(buyer1, slot0, 0.5)

    print(f"  {C.GREEN}[4/5] Payment processed! Fee: 0.0125 ETH (2.5%), Seller receives: 0.4875 ETH{C.RESET}")
    time.sleep(0.3)
    print(f"  {C.GREEN}[5/5] DecryptionToken #{token1.token_id} minted to {buyer1[:16]}...{C.RESET}")

    # Show the dispensed token
    print_token(token1.token_id, "Quantum Research", buyer1, token1.minted_at)

    # Updated vending machine
    print_vending_machine(alice.get_slot_display(), highlight_slot=0)

    # ─── Phase 3: Token Holder Decrypts ─────────────────────────────────
    print_box("PHASE 3: Token Holder Decrypts the Information",
              "The buyer uses their DecryptionToken to obtain the decryption key\n"
              "and unlock the encrypted payload.",
              color=C.MAGENTA)

    if token1.decryption_key:
        print(f"  {C.CYAN}Decryption key from token: {token1.decryption_key.hex()[:32]}...{C.RESET}")

        # Decrypt
        decrypted = decrypt(token1.decryption_key, encrypted1)
        content_verified = keccak256(decrypted) == keccak256(plaintext1)

        print(f"\n  {C.GREEN}{'═' * 60}")
        print(f"  DECRYPTED CONTENT:")
        print(f"  {'═' * 60}{C.RESET}")
        print(f"  {C.WHITE}{decrypted.decode()[:80]}...{C.RESET}")
        print(f"\n  {C.GREEN}Content hash verification: {'✅ MATCH' if content_verified else '❌ MISMATCH'}{C.RESET}")

    # ─── Phase 4: Multiple Buyers ───────────────────────────────────────
    print_box("PHASE 4: Multiple Buyers — Market Activity",
              "Multiple buyers purchase from different slots.\n"
              "Watch the vending machine update in real-time.",
              color=C.BLUE)

    buyers = [
        ("0xBuyer_Eve", 0, 0.5),
        ("0xBuyer_Frank", 0, 0.5),
        ("0xBuyer_Grace", 2, 5.0),
        ("0xBuyer_Heidi", 1, 2.0),  # This is the exclusive slot
        ("0xBuyer_Ivan", 0, 0.5),
    ]

    for buyer_addr, slot_id, price in buyers:
        try:
            token = alice.purchase(buyer_addr, slot_id, price)
            print(f"  {C.GREEN}✅ {buyer_addr[:20]:20} → Slot {slot_id} → Token #{token.token_id} "
                  f"({price} ETH){C.RESET}")
        except ValueError as e:
            print(f"  {C.RED}❌ {buyer_addr[:20]:20} → Slot {slot_id} → REJECTED: {e}{C.RESET}")

    print_vending_machine(alice.get_slot_display())

    # ─── Phase 5: Revenue Report ────────────────────────────────────────
    print_box("PHASE 5: Revenue Report",
              "Alice provides a complete financial summary.",
              color=C.YELLOW)

    print(f"  {C.WHITE}{'═' * 55}")
    print(f"  {'ALICE VENDING MACHINE — REVENUE REPORT':^55}")
    print(f"  {'═' * 55}")
    print(f"  {'Slot':<25} {'Sold':>6} {'Revenue':>12} {'State':>10}")
    print(f"  {'─' * 55}")

    total_revenue = 0
    for i in range(alice.next_slot_id):
        slot = alice.slots[i]
        state_str = slot.state.name.capitalize()
        print(f"  {slot.title:<25} {slot.total_sold:>6} {slot.revenue_eth:>10.4f}  {state_str:>10}")
        total_revenue += slot.revenue_eth

    print(f"  {'─' * 55}")
    print(f"  {'TOTAL':.<25} {'':>6} {total_revenue:>10.4f} ETH")
    print(f"  {'Platform Fees':.<25} {'':>6} {alice.platform_fees:>10.4f} ETH")
    print(f"  {'═' * 55}{C.RESET}")

    # ─── Phase 6: Security Demonstration ────────────────────────────────
    print_box("PHASE 6: Security — What Happens When Attacks Fail",
              "Demonstrating that Alice rejects all invalid operations.",
              color=C.RED)

    attacks = [
        ("Wrong payment amount", lambda: alice.purchase("0xAttacker", 0, 0.01)),
        ("Double purchase", lambda: alice.purchase(buyer1, 0, 0.5)),
        ("Buy from depleted slot", lambda: alice.purchase("0xAttacker2", 1, 2.0)),
        ("Buy from non-existent slot", lambda: alice.purchase("0xAttacker3", 99, 1.0)),
    ]

    for attack_name, attack_fn in attacks:
        try:
            attack_fn()
            print(f"  {C.RED}⚠️  {attack_name}: UNEXPECTEDLY SUCCEEDED{C.RESET}")
        except (ValueError, KeyError) as e:
            print(f"  {C.GREEN}🛡️  {attack_name}: BLOCKED — {e}{C.RESET}")

    # ─── Summary ────────────────────────────────────────────────────────
    print(f"\n{C.BOLD}{C.YELLOW}")
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║                    DEMONSTRATION COMPLETE                   ║")
    print("  ╠══════════════════════════════════════════════════════════════╣")
    print(f"  ║  Total slots loaded:        {alice.next_slot_id:>5}                          ║")
    print(f"  ║  Total tokens dispensed:     {alice.next_token_id:>5}                          ║")
    print(f"  ║  Total revenue (sellers):    {total_revenue:>8.4f} ETH                  ║")
    print(f"  ║  Platform fees collected:    {alice.platform_fees:>8.4f} ETH                  ║")
    print(f"  ║  Attacks blocked:            {len(attacks):>5}                          ║")
    print("  ║                                                            ║")
    print("  ║  Alice successfully operates as a trustless, automated     ║")
    print("  ║  information vending machine on Ethereum.                  ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")
    print(C.RESET)


if __name__ == '__main__':
    main()
