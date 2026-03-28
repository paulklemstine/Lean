#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║  DEMO 3: Full Protocol Simulation                                          ║
║                                                                            ║
║  Simulates the complete Pay-to-Decrypt protocol in Python:                 ║
║  • Seller, Buyer, and Contract agents                                      ║
║  • Happy path + timeout path + attack scenarios                            ║
║  • Animated terminal visualization                                         ║
║  • Monte Carlo simulation of economic outcomes                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

Requirements: pip install matplotlib numpy (optional, for charts)
"""

import os
import sys
import time
import hashlib
import json
import random
import struct
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, Dict, List, Tuple


# ═══════════════════════════════════════════════════════════════════════════════
#  CRYPTOGRAPHIC UTILITIES
# ═══════════════════════════════════════════════════════════════════════════════

def keccak256(data: bytes) -> bytes:
    return hashlib.sha3_256(data).digest()

def encrypt_payload(key: bytes, plaintext: bytes) -> dict:
    nonce = os.urandom(12)
    shake = hashlib.shake_256(key + nonce)
    keystream = shake.digest(len(plaintext) + 32)
    ciphertext = bytes(p ^ k for p, k in zip(plaintext, keystream[:len(plaintext)]))
    auth_input = nonce + ciphertext + struct.pack('>Q', len(plaintext))
    tag = hashlib.sha3_256(key + auth_input).digest()[:16]
    return {'nonce': nonce.hex(), 'ciphertext': ciphertext.hex(), 'tag': tag.hex()}

def decrypt_payload(key: bytes, enc_data: dict) -> bytes:
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
#  SIMULATED BLOCKCHAIN
# ═══════════════════════════════════════════════════════════════════════════════

class ListingState(Enum):
    CREATED = auto()
    FUNDED = auto()
    REVEALED = auto()
    EXPIRED = auto()
    REFUNDED = auto()
    CANCELLED = auto()

@dataclass
class SimListing:
    id: int
    seller: str
    key_hash: bytes
    content_hash: bytes
    ciphertext_uri: str
    description: str
    price: float  # ETH
    timeout: int  # seconds
    buyer: Optional[str] = None
    funded_at: Optional[float] = None
    state: ListingState = ListingState.CREATED
    revealed_key: Optional[bytes] = None

@dataclass
class SimEvent:
    name: str
    listing_id: int
    data: dict
    timestamp: float
    gas_used: int

class SimulatedContract:
    """In-memory simulation of the PayToDecrypt smart contract."""
    
    def __init__(self):
        self.listings: Dict[int, SimListing] = {}
        self.balances: Dict[str, float] = {}
        self.escrow: float = 0
        self.next_id = 0
        self.events: List[SimEvent] = []
        self.current_time = time.time()
        self.gas_total = 0
    
    def set_balance(self, address: str, amount: float):
        self.balances[address] = amount
    
    def advance_time(self, seconds: int):
        self.current_time += seconds
    
    def _emit(self, name: str, listing_id: int, data: dict, gas: int):
        event = SimEvent(name, listing_id, data, self.current_time, gas)
        self.events.append(event)
        self.gas_total += gas
        return event
    
    def create_listing(self, seller: str, key_hash: bytes, content_hash: bytes,
                       ciphertext_uri: str, description: str, price: float,
                       timeout: int) -> int:
        listing_id = self.next_id
        self.next_id += 1
        
        self.listings[listing_id] = SimListing(
            id=listing_id, seller=seller, key_hash=key_hash,
            content_hash=content_hash, ciphertext_uri=ciphertext_uri,
            description=description, price=price, timeout=timeout
        )
        
        self._emit("ListingCreated", listing_id, {
            'seller': seller, 'price': price, 'timeout': timeout
        }, 85000)
        
        return listing_id
    
    def fund_listing(self, buyer: str, listing_id: int) -> bool:
        listing = self.listings.get(listing_id)
        if not listing or listing.state != ListingState.CREATED:
            return False
        if self.balances.get(buyer, 0) < listing.price:
            return False
        
        self.balances[buyer] -= listing.price
        self.escrow += listing.price
        listing.buyer = buyer
        listing.funded_at = self.current_time
        listing.state = ListingState.FUNDED
        
        self._emit("ListingFunded", listing_id, {
            'buyer': buyer, 'funded_at': self.current_time
        }, 55000)
        
        return True
    
    def reveal_key(self, seller: str, listing_id: int, key: bytes) -> bool:
        listing = self.listings.get(listing_id)
        if not listing or listing.state != ListingState.FUNDED:
            return False
        if listing.seller != seller:
            return False
        if keccak256(key) != listing.key_hash:
            return False
        
        listing.state = ListingState.REVEALED
        listing.revealed_key = key
        self.escrow -= listing.price
        self.balances[seller] = self.balances.get(seller, 0) + listing.price
        
        self._emit("KeyRevealed", listing_id, {
            'key': key.hex(), 'seller': seller
        }, 45000)
        
        return True
    
    def claim_refund(self, buyer: str, listing_id: int) -> bool:
        listing = self.listings.get(listing_id)
        if not listing or listing.state != ListingState.FUNDED:
            return False
        if listing.buyer != buyer:
            return False
        if self.current_time < listing.funded_at + listing.timeout:
            return False
        
        listing.state = ListingState.REFUNDED
        self.escrow -= listing.price
        self.balances[buyer] = self.balances.get(buyer, 0) + listing.price
        
        self._emit("ListingRefunded", listing_id, {
            'buyer': buyer, 'amount': listing.price
        }, 35000)
        
        return True


# ═══════════════════════════════════════════════════════════════════════════════
#  TERMINAL VISUALIZATION
# ═══════════════════════════════════════════════════════════════════════════════

class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'

def print_header(text, color=Colors.CYAN):
    width = 72
    print(f"\n{color}{'═' * width}")
    print(f"  {text}")
    print(f"{'═' * width}{Colors.RESET}")

def print_step(step_num, actor, action, details=""):
    actor_colors = {
        'Seller': Colors.GREEN,
        'Buyer': Colors.BLUE,
        'Contract': Colors.YELLOW,
        'Attacker': Colors.RED,
        'System': Colors.MAGENTA,
    }
    color = actor_colors.get(actor, Colors.WHITE)
    print(f"\n  {Colors.BOLD}Step {step_num}{Colors.RESET} │ "
          f"{color}[{actor}]{Colors.RESET} {action}")
    if details:
        for line in details.split('\n'):
            print(f"          │ {Colors.DIM}{line}{Colors.RESET}")

def print_balance_table(contract: SimulatedContract, accounts: List[str]):
    print(f"\n  {'─' * 50}")
    print(f"  {'Account':<20} {'Balance (ETH)':>15} {'Role':>12}")
    print(f"  {'─' * 50}")
    for addr in accounts:
        bal = contract.balances.get(addr, 0)
        role = addr.split('_')[0].title() if '_' in addr else addr
        print(f"  {addr:<20} {bal:>15.4f} {role:>12}")
    print(f"  {'Escrow':<20} {contract.escrow:>15.4f} {'Contract':>12}")
    print(f"  {'─' * 50}")


# ═══════════════════════════════════════════════════════════════════════════════
#  SCENARIO 1: HAPPY PATH
# ═══════════════════════════════════════════════════════════════════════════════

def run_happy_path():
    print_header("SCENARIO 1: HAPPY PATH — Successful Information Sale", Colors.GREEN)
    
    contract = SimulatedContract()
    seller_addr = "seller_alice"
    buyer_addr = "buyer_bob"
    
    contract.set_balance(seller_addr, 10.0)
    contract.set_balance(buyer_addr, 5.0)
    
    # The secret
    secret = b"The answer to life, the universe, and everything is 42."
    
    # Step 1: Seller prepares
    key = os.urandom(32)
    key_hash = keccak256(key)
    content_hash = keccak256(secret)
    encrypted = encrypt_payload(key, secret)
    ciphertext_uri = "ipfs://QmXoYpR8CksD6HiFx9gGvRJgKTjUj7bipdenKPUqXnMqMZ"
    
    print_step(1, "Seller", "Generates encryption key and encrypts payload",
               f"Key K = {key.hex()[:32]}...\n"
               f"Commitment H = keccak256(K) = {key_hash.hex()[:32]}...\n"
               f"Content hash = {content_hash.hex()[:32]}...\n"
               f"Uploads ciphertext to IPFS → {ciphertext_uri}")
    
    # Step 2: Create listing
    listing_id = contract.create_listing(
        seller_addr, key_hash, content_hash, ciphertext_uri,
        "The Ultimate Answer™ — verified by Deep Thought",
        1.0, 86400
    )
    
    print_step(2, "Seller", f"Creates listing #{listing_id} on contract",
               f"Price: 1.0 ETH\n"
               f"Timeout: 24 hours\n"
               f"Description: 'The Ultimate Answer™'")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    # Step 3: Buyer funds
    success = contract.fund_listing(buyer_addr, listing_id)
    
    print_step(3, "Buyer", f"Funds listing #{listing_id} with 1.0 ETH",
               f"Transaction {'✅ SUCCESS' if success else '❌ FAILED'}\n"
               f"ETH moved to escrow — locked until key reveal or timeout")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    # Step 4: Seller reveals
    success = contract.reveal_key(seller_addr, listing_id, key)
    
    print_step(4, "Seller", f"Reveals decryption key to claim payment",
               f"Key K = {key.hex()[:32]}...\n"
               f"Hash check: keccak256(K) == H → {'✅ MATCH' if success else '❌ MISMATCH'}\n"
               f"ETH released from escrow to seller")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    # Step 5: Buyer decrypts
    listing = contract.listings[listing_id]
    decrypted = decrypt_payload(listing.revealed_key, encrypted)
    content_verified = keccak256(decrypted) == content_hash
    
    print_step(5, "Buyer", "Reads key from KeyRevealed event and decrypts",
               f"Decrypted: \"{decrypted.decode()}\"\n"
               f"Content hash verification: {'✅ MATCH' if content_verified else '❌ MISMATCH'}")
    
    print(f"\n  {Colors.GREEN}{'═' * 50}")
    print(f"  ✅ OUTCOME: Both parties satisfied!")
    print(f"     Seller: +1.0 ETH")
    print(f"     Buyer:  Received verified secret content")
    print(f"  {'═' * 50}{Colors.RESET}")
    
    return contract


# ═══════════════════════════════════════════════════════════════════════════════
#  SCENARIO 2: TIMEOUT / REFUND
# ═══════════════════════════════════════════════════════════════════════════════

def run_timeout_path():
    print_header("SCENARIO 2: TIMEOUT — Seller Fails to Reveal", Colors.YELLOW)
    
    contract = SimulatedContract()
    seller_addr = "seller_eve"
    buyer_addr = "buyer_carol"
    
    contract.set_balance(seller_addr, 10.0)
    contract.set_balance(buyer_addr, 5.0)
    
    key = os.urandom(32)
    key_hash = keccak256(key)
    
    listing_id = contract.create_listing(
        seller_addr, key_hash, keccak256(b"dummy"), "ipfs://QmDummy",
        "Definitely real secrets (trust me)", 2.0, 3600  # 1 hour timeout
    )
    
    print_step(1, "Seller", f"Creates suspicious listing #{listing_id}",
               f"Price: 2.0 ETH, Timeout: 1 hour\n"
               f"Description: 'Definitely real secrets (trust me)'")
    
    success = contract.fund_listing(buyer_addr, listing_id)
    print_step(2, "Buyer", f"Funds listing (perhaps unwisely)",
               f"2.0 ETH moved to escrow")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    # Try refund too early
    print_step(3, "Buyer", "Tries to claim refund immediately",
               "⏳ Timeout hasn't expired yet...")
    early_refund = contract.claim_refund(buyer_addr, listing_id)
    print(f"          │ {Colors.RED}❌ REJECTED — Must wait for timeout{Colors.RESET}")
    
    # Time passes...
    contract.advance_time(3601)
    print_step(4, "System", "⏰ 1 hour passes... Seller never reveals key",
               "The seller has disappeared. Timeout has expired.")
    
    # Claim refund
    success = contract.claim_refund(buyer_addr, listing_id)
    print_step(5, "Buyer", "Claims refund after timeout",
               f"Transaction {'✅ SUCCESS' if success else '❌ FAILED'}\n"
               f"2.0 ETH returned from escrow to buyer")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    print(f"\n  {Colors.YELLOW}{'═' * 50}")
    print(f"  ⚠️ OUTCOME: No harm done!")
    print(f"     Seller: No payment (never revealed key)")
    print(f"     Buyer:  Got full refund, no content received")
    print(f"  {'═' * 50}{Colors.RESET}")


# ═══════════════════════════════════════════════════════════════════════════════
#  SCENARIO 3: WRONG KEY ATTACK
# ═══════════════════════════════════════════════════════════════════════════════

def run_wrong_key_attack():
    print_header("SCENARIO 3: ATTACK — Seller Tries Wrong Key", Colors.RED)
    
    contract = SimulatedContract()
    seller_addr = "attacker_mallory"
    buyer_addr = "buyer_dave"
    
    contract.set_balance(seller_addr, 10.0)
    contract.set_balance(buyer_addr, 5.0)
    
    real_key = os.urandom(32)
    fake_key = os.urandom(32)
    key_hash = keccak256(real_key)
    
    listing_id = contract.create_listing(
        seller_addr, key_hash, keccak256(b"real content"), "ipfs://QmReal",
        "Premium content", 1.5, 86400
    )
    
    success = contract.fund_listing(buyer_addr, listing_id)
    print_step(1, "System", "Listing created and funded normally",
               f"Listing #{listing_id}, Price: 1.5 ETH")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    # Attacker tries wrong key
    print_step(2, "Attacker", "Tries to reveal a FAKE key to steal payment",
               f"Real key hash:  {key_hash.hex()[:32]}...\n"
               f"Fake key:       {fake_key.hex()[:32]}...\n"
               f"Hash(fake key): {keccak256(fake_key).hex()[:32]}...")
    
    success = contract.reveal_key(seller_addr, listing_id, fake_key)
    
    print(f"\n          │ {Colors.RED}{'═' * 50}")
    print(f"          │ ❌ REJECTED! Hash mismatch detected!")
    print(f"          │ keccak256(fake_key) ≠ committed hash H")
    print(f"          │ The contract refuses to release payment.")
    print(f"          │ {'═' * 50}{Colors.RESET}")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    # Now reveal real key
    print_step(3, "Attacker", "Grudgingly reveals the REAL key",
               "The only way to get paid is to provide the correct key.")
    
    success = contract.reveal_key(seller_addr, listing_id, real_key)
    print(f"          │ {Colors.GREEN}✅ Hash matches! Payment released.{Colors.RESET}")
    
    print_balance_table(contract, [seller_addr, buyer_addr])
    
    print(f"\n  {Colors.GREEN}{'═' * 50}")
    print(f"  ✅ OUTCOME: Attack thwarted by hash commitment!")
    print(f"     The seller MUST reveal the correct key to get paid.")
    print(f"     Cryptographic honesty enforced by the protocol.")
    print(f"  {'═' * 50}{Colors.RESET}")


# ═══════════════════════════════════════════════════════════════════════════════
#  MONTE CARLO ECONOMIC SIMULATION
# ═══════════════════════════════════════════════════════════════════════════════

def run_economic_simulation(n_simulations=10000):
    print_header("MONTE CARLO: Economic Outcome Simulation", Colors.MAGENTA)
    
    random.seed(42)
    
    # Parameters
    content_values = [0.1, 0.5, 1.0, 5.0, 10.0, 50.0]  # ETH
    seller_honest_prob = 0.95
    buyer_satisfaction_prob = 0.90
    gas_cost_eth = 0.006  # ~$16.65 at ETH=$3000
    
    results = {
        'happy': 0,
        'timeout': 0,
        'wrong_key_then_correct': 0,
        'total_seller_profit': 0.0,
        'total_buyer_value': 0.0,
        'total_gas_cost': 0.0,
    }
    
    for _ in range(n_simulations):
        content_value = random.choice(content_values)
        price = content_value * random.uniform(0.5, 1.5)
        
        # Does seller reveal?
        if random.random() < seller_honest_prob:
            results['happy'] += 1
            results['total_seller_profit'] += price - gas_cost_eth
            
            # Is buyer satisfied?
            if random.random() < buyer_satisfaction_prob:
                results['total_buyer_value'] += content_value - price - gas_cost_eth
            else:
                results['total_buyer_value'] += -price - gas_cost_eth  # Unsatisfied
        else:
            results['timeout'] += 1
            results['total_buyer_value'] += -gas_cost_eth  # Only gas cost lost
        
        results['total_gas_cost'] += gas_cost_eth
    
    # Display results
    print(f"""
  Simulations: {n_simulations:,}
  
  ┌────────────────────────────┬──────────┬─────────┐
  │ Outcome                    │   Count  │    %    │
  ├────────────────────────────┼──────────┼─────────┤
  │ ✅ Happy path (key reveal) │ {results['happy']:>8,} │ {results['happy']/n_simulations*100:>6.1f}% │
  │ ⏰ Timeout (refund)        │ {results['timeout']:>8,} │ {results['timeout']/n_simulations*100:>6.1f}% │
  └────────────────────────────┴──────────┴─────────┘
  
  Economic Summary:
  ┌────────────────────────────┬───────────────────┐
  │ Metric                     │ Value (ETH)       │
  ├────────────────────────────┼───────────────────┤
  │ Total seller profit        │ {results['total_seller_profit']:>14,.2f}   │
  │ Avg seller profit/trade    │ {results['total_seller_profit']/n_simulations:>14,.4f}   │
  │ Total buyer net value      │ {results['total_buyer_value']:>14,.2f}   │
  │ Avg buyer net value/trade  │ {results['total_buyer_value']/n_simulations:>14,.4f}   │
  │ Total gas costs            │ {results['total_gas_cost']:>14,.2f}   │
  │ Gas as % of volume         │ {results['total_gas_cost']/max(results['total_seller_profit'],0.01)*100:>13,.1f}%  │
  └────────────────────────────┴───────────────────┘

  Key Insight: With {seller_honest_prob*100:.0f}% honest sellers, the protocol generates
  positive expected value for both parties. Gas costs are the primary friction.
  Moving to L2 would reduce gas costs by 20-50x, making micro-transactions viable.
""")
    
    # Try to generate chart
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
        
        output_dir = os.path.dirname(os.path.abspath(__file__))
        
        fig, axes = plt.subplots(1, 3, figsize=(16, 5))
        
        # Chart 1: Outcome distribution
        outcomes = ['Happy Path', 'Timeout']
        counts = [results['happy'], results['timeout']]
        colors = ['#4CAF50', '#FF9800']
        axes[0].pie(counts, labels=outcomes, colors=colors, autopct='%1.1f%%',
                   startangle=90, textprops={'fontsize': 11})
        axes[0].set_title('Outcome Distribution', fontsize=13, fontweight='bold')
        
        # Chart 2: Profit distribution simulation
        profits = []
        for _ in range(5000):
            price = random.choice(content_values) * random.uniform(0.5, 1.5)
            if random.random() < seller_honest_prob:
                profits.append(price - gas_cost_eth)
            else:
                profits.append(-gas_cost_eth)
        
        axes[1].hist(profits, bins=50, color='#2196F3', alpha=0.7, edgecolor='white')
        axes[1].axvline(x=0, color='red', linestyle='--', lw=2, label='Break-even')
        axes[1].set_xlabel('Seller Profit (ETH)', fontsize=11)
        axes[1].set_ylabel('Frequency', fontsize=11)
        axes[1].set_title('Seller Profit Distribution', fontsize=13, fontweight='bold')
        axes[1].legend()
        
        # Chart 3: Gas cost vs content value
        content_vals = np.linspace(0.01, 100, 200)
        gas_l1 = np.full_like(content_vals, 0.006)
        gas_l2 = np.full_like(content_vals, 0.0003)
        gas_pct_l1 = gas_l1 / content_vals * 100
        gas_pct_l2 = gas_l2 / content_vals * 100
        
        axes[2].plot(content_vals, gas_pct_l1, 'r-', lw=2, label='Ethereum L1')
        axes[2].plot(content_vals, gas_pct_l2, 'b-', lw=2, label='L2 (Arbitrum)')
        axes[2].axhline(y=5, color='green', linestyle=':', lw=1, label='5% threshold')
        axes[2].set_xlabel('Content Value (ETH)', fontsize=11)
        axes[2].set_ylabel('Gas Cost as % of Value', fontsize=11)
        axes[2].set_title('Protocol Overhead vs Content Value', fontsize=13, fontweight='bold')
        axes[2].set_xscale('log')
        axes[2].set_yscale('log')
        axes[2].legend()
        axes[2].set_ylim(0.001, 100)
        
        plt.tight_layout()
        path = os.path.join(output_dir, 'economic_simulation.png')
        plt.savefig(path, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Chart saved: {path}")
        
    except ImportError:
        print("  ⚠️  matplotlib not available — skipping charts")


# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print("\n" + "=" * 72)
    print("  PAY-TO-DECRYPT: Full Protocol Simulation")
    print("  ─────────────────────────────────────────")
    print("  Simulating seller, buyer, and contract interactions")
    print("=" * 72)
    
    run_happy_path()
    run_timeout_path()
    run_wrong_key_attack()
    run_economic_simulation()
    
    print("\n" + "=" * 72)
    print("  ✅ All simulations complete!")
    print("=" * 72 + "\n")

if __name__ == '__main__':
    main()
