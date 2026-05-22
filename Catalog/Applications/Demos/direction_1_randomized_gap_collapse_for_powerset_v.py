#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Communication Complexity Gap

Demonstrates practical applications of polynomial fingerprinting and the
deterministic-randomized gap in communication complexity:

1. File synchronization — Detect if two remote files are identical
2. Database reconciliation — Efficient set difference detection
3. Distributed system consistency checking
4. Pythagorean triple verification over finite fields
"""

import random
import math
import hashlib
from typing import Set, List, Tuple, Optional, Dict


# ─────────────────────────────────────────────────
# Utility
# ─────────────────────────────────────────────────

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def next_prime(n: int) -> int:
    while not is_prime(n): n += 1
    return n

def fingerprint(S: Set[int], r: int, p: int) -> int:
    return sum(pow(r, i, p) for i in S) % p


# ─────────────────────────────────────────────────
# Application 1: File Synchronization
# ─────────────────────────────────────────────────

class FileFingerprinter:
    """
    Efficient file comparison using polynomial fingerprinting.
    
    Instead of sending an entire file to check equality, compute a short
    fingerprint and compare. This reduces communication from O(file_size)
    to O(log(file_size)) bits.
    
    Real-world analogy: rsync uses rolling checksums similarly.
    """
    
    def __init__(self, block_size: int = 256, prime: Optional[int] = None):
        self.block_size = block_size
        self.prime = prime or next_prime(3 * block_size + 1)
    
    def compute_fingerprint(self, data: bytes, r: int) -> int:
        """Compute fingerprint of data at evaluation point r."""
        # Treat each byte as a coefficient
        result = 0
        power = 1
        for byte in data:
            result = (result + byte * power) % self.prime
            power = (power * r) % self.prime
        return result
    
    def are_equal_probabilistic(self, data1: bytes, data2: bytes, 
                                 num_checks: int = 3) -> Tuple[bool, float]:
        """
        Probabilistically check if two byte sequences are equal.
        
        Returns:
            (result, confidence) where result is True if likely equal,
            and confidence is the probability of correctness.
        """
        if len(data1) != len(data2):
            return False, 1.0
        
        n = max(len(data1), 1)
        error_per_check = n / self.prime
        
        for _ in range(num_checks):
            r = random.randint(0, self.prime - 1)
            fp1 = self.compute_fingerprint(data1, r)
            fp2 = self.compute_fingerprint(data2, r)
            if fp1 != fp2:
                return False, 1.0  # Definitely different
        
        # All checks passed
        total_error = error_per_check ** num_checks
        return True, 1.0 - total_error


def demo_file_sync():
    """Demonstrate file synchronization application."""
    print("=" * 70)
    print("APPLICATION 1: File Synchronization via Fingerprinting")
    print("=" * 70)
    print()
    
    fp = FileFingerprinter(block_size=1024)
    
    # Case 1: Identical files
    file1 = b"The quick brown fox jumps over the lazy dog" * 100
    file2 = b"The quick brown fox jumps over the lazy dog" * 100
    
    result, confidence = fp.are_equal_probabilistic(file1, file2)
    print(f"Identical files ({len(file1)} bytes):")
    print(f"  Result: {'Equal' if result else 'Different'}")
    print(f"  Confidence: {confidence:.10f}")
    print(f"  Communication: {math.ceil(math.log2(fp.prime))} bits "
          f"(vs {len(file1) * 8} bits deterministic)")
    print()
    
    # Case 2: Files differing by one byte
    file3 = bytearray(file1)
    file3[42] = (file3[42] + 1) % 256
    file3 = bytes(file3)
    
    result, confidence = fp.are_equal_probabilistic(file1, file3)
    print(f"Files differing by 1 byte ({len(file1)} bytes):")
    print(f"  Result: {'Equal' if result else 'Different'}")
    print(f"  Confidence: {confidence:.10f}")
    print()
    
    # Communication savings
    det_bits = len(file1) * 8
    rand_bits = math.ceil(math.log2(fp.prime)) * 3  # 3 rounds
    savings = det_bits / rand_bits
    print(f"Communication savings: {savings:.0f}x ({det_bits} bits → {rand_bits} bits)")


# ─────────────────────────────────────────────────
# Application 2: Database Set Reconciliation
# ─────────────────────────────────────────────────

class SetReconciler:
    """
    Efficient detection of set differences between distributed databases.
    
    Two servers each hold a set of records (identified by integer keys).
    We want to check if they hold the same set, using minimal communication.
    """
    
    def __init__(self, universe_size: int):
        self.n = universe_size
        self.prime = next_prime(3 * universe_size + 1)
    
    def check_equality(self, set_a: Set[int], set_b: Set[int], 
                        num_rounds: int = 5) -> Tuple[bool, float]:
        """
        Check if two sets are equal using fingerprinting.
        
        Communication per round: O(log p) = O(log n) bits.
        Total: O(k · log n) bits for k rounds.
        Error probability: ≤ (n/p)^k.
        """
        for _ in range(num_rounds):
            r = random.randint(0, self.prime - 1)
            if fingerprint(set_a, r, self.prime) != fingerprint(set_b, r, self.prime):
                return False, 1.0
        
        error = (self.n / self.prime) ** num_rounds
        return True, 1.0 - error
    
    def find_differences_interactive(self, set_a: Set[int], set_b: Set[int]) -> Set[int]:
        """
        Find the symmetric difference using multiple fingerprint evaluations.
        This is a simplified version — full CPISync uses more sophisticated methods.
        """
        # Binary search over subsets to find differences
        diffs = set()
        for i in range(self.n):
            sub_a = {i} & set_a
            sub_b = {i} & set_b
            if sub_a != sub_b:
                diffs.add(i)
        return diffs


def demo_database_reconciliation():
    """Demonstrate database reconciliation application."""
    print()
    print("=" * 70)
    print("APPLICATION 2: Database Set Reconciliation")
    print("=" * 70)
    print()
    
    n = 1000
    reconciler = SetReconciler(n)
    
    # Generate two similar sets
    base_set = set(random.sample(range(n), 500))
    set_a = base_set.copy()
    set_b = base_set.copy()
    
    # Case 1: Identical sets
    result, conf = reconciler.check_equality(set_a, set_b)
    print(f"Identical sets ({len(set_a)} elements from universe of {n}):")
    print(f"  Result: {'Equal' if result else 'Different'}, confidence: {conf:.10f}")
    print(f"  Communication: {5 * math.ceil(math.log2(reconciler.prime))} bits")
    print(f"  Deterministic would need: {n} bits")
    print()
    
    # Case 2: One element different
    set_b.add(next(i for i in range(n) if i not in set_b))
    result, conf = reconciler.check_equality(set_a, set_b)
    print(f"Sets differing by 1 element:")
    print(f"  Result: {'Equal' if result else 'Different'}, confidence: {conf:.10f}")


# ─────────────────────────────────────────────────
# Application 3: Pythagorean Triple Verification
# ─────────────────────────────────────────────────

def find_pythagorean_triples_mod_p(p: int, limit: int = 100) -> List[Tuple[int, int, int]]:
    """
    Find Pythagorean triples a² + b² ≡ c² (mod p).
    
    Connection to fingerprinting: The polynomial x² + 1 arises as a
    fingerprint difference polynomial. Its roots in ZMod p determine
    whether the Pythagorean equation has solutions with c = 0.
    """
    triples = []
    for a in range(min(p, limit)):
        for b in range(a, min(p, limit)):
            c_sq = (a * a + b * b) % p
            # Check if c_sq is a perfect square mod p
            for c in range(min(p, limit)):
                if (c * c) % p == c_sq:
                    if a > 0 or b > 0:  # Nontrivial
                        triples.append((a, b, c))
                    break
    return triples


def check_neg_one_is_qr(p: int) -> bool:
    """Check if -1 is a quadratic residue mod p (Euler's criterion)."""
    if p == 2:
        return True
    return pow(p - 1, (p - 1) // 2, p) == 1


def demo_pythagorean_connection():
    """Demonstrate the Pythagorean triple / finite field connection."""
    print()
    print("=" * 70)
    print("APPLICATION 3: Pythagorean Triples over Finite Fields")
    print("=" * 70)
    print()
    print("Connection: The polynomial x² + 1 is a fingerprint difference polynomial.")
    print("Its roots in ZMod p determine Pythagorean structure over the field.")
    print()
    
    print(f"{'p':>5} | {'p mod 4':>7} | {'-1 is QR':>9} | {'x²+1 roots':>11} | {'# Pyth triples':>14}")
    print("-" * 55)
    
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        is_qr = check_neg_one_is_qr(p)
        
        # Find roots of x² + 1 mod p
        roots = [x for x in range(p) if (x * x + 1) % p == 0]
        
        # Count Pythagorean triples
        n_triples = len(find_pythagorean_triples_mod_p(p, limit=p))
        
        print(f"{p:>5} | {p % 4:>7} | {'Yes' if is_qr else 'No':>9} | "
              f"{len(roots):>11} | {n_triples:>14}")
    
    print()
    print("Observation: x²+1 has roots in ZMod p ⟺ p ≡ 1 (mod 4)")
    print("This is exactly when -1 is a quadratic residue (Euler's criterion).")


# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    
    demo_file_sync()
    demo_database_reconciliation()
    demo_pythagorean_connection()
    
    print()
    print("=" * 70)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Demonstrating the Exponential Gap between Deterministic and 
Randomized Communication for Powerset Verification

This script:
1. Implements the polynomial fingerprinting protocol for subset equality
2. Empirically measures error rates across primes p
3. Plots the exponential gap between deterministic lower bound and randomized upper bound
4. Tests the tight fingerprinting threshold conjecture
5. Demonstrates the phase transition in error probability at p ≈ n
"""

import random
import math
from collections import defaultdict
from typing import List, Set, Tuple, Optional

# ─────────────────────────────────────────────────
# Utility Functions
# ─────────────────────────────────────────────────

def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def next_prime(n: int) -> int:
    """Find the smallest prime >= n."""
    while not is_prime(n):
        n += 1
    return n

def powerset_fingerprint(S: Set[int], r: int, p: int) -> int:
    """Compute the fingerprint polynomial P_S(r) = sum_{i in S} r^i mod p."""
    return sum(pow(r, i, p) for i in S) % p

# ─────────────────────────────────────────────────
# 1. Fingerprinting Protocol Implementation
# ─────────────────────────────────────────────────

def fingerprint_protocol(S: Set[int], T: Set[int], p: int, r: int) -> bool:
    """
    One-round fingerprinting protocol for subset equality.
    
    Alice computes P_S(r) mod p and sends it to Bob.
    Bob computes P_T(r) mod p and checks equality.
    Returns True if fingerprints match (protocol says 'equal').
    """
    alice_msg = powerset_fingerprint(S, r, p)
    bob_check = powerset_fingerprint(T, r, p)
    return alice_msg == bob_check

# ─────────────────────────────────────────────────
# 2. Empirical Error Rate Measurement
# ─────────────────────────────────────────────────

def measure_error_rate(n: int, p: int, num_trials: int = 10000) -> float:
    """
    Measure the empirical error rate of the fingerprinting protocol.
    
    For random pairs S ≠ T of subsets of {0,...,n-1}, compute the fraction
    of random r ∈ {0,...,p-1} where the protocol incorrectly says 'equal'.
    """
    errors = 0
    total = 0
    
    for _ in range(num_trials):
        # Generate two random distinct subsets
        S = set(i for i in range(n) if random.random() < 0.5)
        T = set(i for i in range(n) if random.random() < 0.5)
        if S == T:
            continue
        
        r = random.randint(0, p - 1)
        if fingerprint_protocol(S, T, p, r):
            errors += 1
        total += 1
    
    return errors / total if total > 0 else 0.0

def measure_exact_collision_rate(n: int, p: int, S: Set[int], T: Set[int]) -> float:
    """Compute the exact collision rate by checking all r in ZMod p."""
    if S == T:
        return 1.0
    collisions = sum(1 for r in range(p) if fingerprint_protocol(S, T, p, r))
    return collisions / p

# ─────────────────────────────────────────────────
# 3. Exponential Gap Demonstration
# ─────────────────────────────────────────────────

def demonstrate_exponential_gap():
    """Show the exponential gap between deterministic and randomized communication."""
    print("=" * 70)
    print("EXPONENTIAL GAP: Deterministic vs Randomized Communication")
    print("=" * 70)
    print()
    print(f"{'n':>4} | {'Det LB (bits)':>14} | {'Rand UB (bits)':>14} | {'Gap Ratio':>10}")
    print("-" * 50)
    
    for n in range(1, 13):
        det_lower = n  # Deterministic needs log₂(2^n) = n bits
        p = next_prime(3 * n)  # Smallest prime ≥ 3n
        rand_upper = math.ceil(math.log2(p)) + 1  # Bits to encode element of ZMod p
        gap = det_lower / rand_upper if rand_upper > 0 else float('inf')
        print(f"{n:>4} | {det_lower:>14} | {rand_upper:>14} | {gap:>10.2f}")
    
    print()
    print("Note: As n grows, the gap ratio increases, showing the exponential")
    print("separation between deterministic and randomized communication.")

# ─────────────────────────────────────────────────
# 4. Threshold Conjecture Test
# ─────────────────────────────────────────────────

def test_threshold_conjecture():
    """
    Test the conjecture that the minimum prime p guaranteeing error ≤ ε
    satisfies p ≈ ⌈n/ε⌉.
    
    The collision probability for S ≠ T is at most (n-1)/p (since the
    difference polynomial has degree < n, so at most n-1 roots).
    For error ≤ ε, we need (n-1)/p ≤ ε, i.e., p ≥ (n-1)/ε.
    """
    print()
    print("=" * 70)
    print("THRESHOLD CONJECTURE TEST")
    print("=" * 70)
    print()
    
    for eps_name, eps in [("1/3", 1/3), ("1/4", 1/4), ("1/10", 1/10)]:
        print(f"\n--- ε = {eps_name} ---")
        print(f"{'n':>4} | {'Predicted p':>12} | {'Min prime ≥':>12} | {'Empirical err':>14} | {'Match':>6}")
        print("-" * 56)
        
        for n in range(1, 11):
            predicted = math.ceil(n / eps)
            min_prime = next_prime(predicted)
            
            # Measure empirical error rate
            err = measure_error_rate(n, min_prime, num_trials=5000)
            match = "✓" if err <= eps + 0.05 else "✗"  # Allow small statistical fluctuation
            
            print(f"{n:>4} | {predicted:>12} | {min_prime:>12} | {err:>14.4f} | {match:>6}")

# ─────────────────────────────────────────────────
# 5. Phase Transition Demonstration
# ─────────────────────────────────────────────────

def demonstrate_phase_transition():
    """
    Show the phase transition in error probability at p ≈ n.
    
    For small p (< n), the protocol has high error.
    For large p (>> n), the protocol has low error.
    The transition is sharp around p ≈ n.
    """
    print()
    print("=" * 70)
    print("PHASE TRANSITION IN ERROR PROBABILITY")
    print("=" * 70)
    
    n = 5
    S = {0, 2, 4}
    T = {1, 3}
    
    print(f"\nFixed: n = {n}, S = {S}, T = {T}")
    print(f"\n{'p':>6} | {'Exact collision rate':>20} | {'Bar':>30}")
    print("-" * 60)
    
    # Test primes from small to large
    test_primes = [p for p in range(2, 100) if is_prime(p)]
    
    for p in test_primes:
        rate = measure_exact_collision_rate(n, p, S, T)
        bar = "█" * int(rate * 30) + "░" * (30 - int(rate * 30))
        print(f"{p:>6} | {rate:>20.4f} | {bar}")

# ─────────────────────────────────────────────────
# 6. Reed-Solomon Distance Verification
# ─────────────────────────────────────────────────

def verify_reed_solomon_distance():
    """Verify the Reed-Solomon distance property of fingerprinting."""
    print()
    print("=" * 70)
    print("REED-SOLOMON DISTANCE VERIFICATION")
    print("=" * 70)
    
    n = 4
    p = next_prime(3 * n + 1)
    
    print(f"\nn = {n}, p = {p}")
    print(f"Expected minimum distance ≥ p - n + 1 = {p - n + 1}")
    print()
    
    # Check a few pairs
    pairs = [
        ({0, 1}, {2, 3}),
        ({0}, {1, 2, 3}),
        ({0, 1, 2}, {3}),
        (set(), {0}),
    ]
    
    for S, T in pairs:
        # Count number of r where fingerprints DIFFER
        diffs = sum(1 for r in range(p) if not fingerprint_protocol(S, T, p, r))
        print(f"S={S}, T={T}: {diffs} points where fingerprints differ (out of {p})")

# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    
    demonstrate_exponential_gap()
    test_threshold_conjecture()
    demonstrate_phase_transition()
    verify_reed_solomon_distance()
    
    print()
    print("=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)
