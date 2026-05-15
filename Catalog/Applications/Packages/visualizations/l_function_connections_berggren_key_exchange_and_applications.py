#!/usr/bin/env python3
"""
Applications of Berggren Orbit Dirichlet Series

1. Post-quantum key exchange protocol simulation
2. Pseudorandom triple generation
3. Orbit-based hash function
4. Convergence certification
"""

import numpy as np
import math
import hashlib
from typing import Tuple, List, Optional
from algorithms import (
    BERGGREN_GENERATORS, BERGGREN_ROOT, GEN_NAMES,
    enumerate_berggren_shell, convergence_threshold,
    estimate_height_growth_factor, collision_entropy,
    keyspace_size
)

GEN_NAMES = ['A', 'B', 'C']


# ═══════════════════════════════════════════════════════════════════════
# 1. BERGGREN KEY EXCHANGE PROTOCOL
# ═══════════════════════════════════════════════════════════════════════

class BerggrenKeyExchange:
    """
    Simulated Berggren-based key exchange protocol.

    Security parameter: word length d.
    Private key: random Berggren word of length d.
    Public key: resulting primitive Pythagorean triple.

    The protocol exploits:
    - Exponential orbit growth (large keyspace)
    - Low collision rate (high entropy)
    - Hardness of word recovery from triple (one-way property)
    """

    def __init__(self, word_length: int = 20,
                 public_base: np.ndarray = BERGGREN_ROOT):
        self.word_length = word_length
        self.public_base = public_base.copy()

    def generate_private_key(self, seed: Optional[int] = None) -> List[int]:
        """Generate a random Berggren word of length d."""
        rng = np.random.RandomState(seed)
        return [rng.randint(0, 3) for _ in range(self.word_length)]

    def compute_public_key(self, private_key: List[int]) -> np.ndarray:
        """Apply the Berggren word to the base triple."""
        v = self.public_base.copy()
        for gen_idx in reversed(private_key):
            v = BERGGREN_GENERATORS[gen_idx] @ v
        return v

    def word_to_string(self, word: List[int]) -> str:
        """Convert word to readable string."""
        return ''.join(GEN_NAMES[i] for i in word)

    def verify_pythagorean(self, triple: np.ndarray) -> bool:
        """Verify that the triple satisfies a² + b² = c²."""
        a, b, c = triple
        return a * a + b * b == c * c

    def verify_primitive(self, triple: np.ndarray) -> bool:
        """Verify the triple is primitive (gcd = 1)."""
        a, b, c = abs(triple[0]), abs(triple[1]), abs(triple[2])
        return math.gcd(math.gcd(a, b), c) == 1


def demo_key_exchange():
    """Demonstrate the Berggren key exchange protocol."""
    print("=" * 70)
    print("BERGGREN KEY EXCHANGE PROTOCOL DEMONSTRATION")
    print("=" * 70)

    for d in [5, 10, 15, 20]:
        kex = BerggrenKeyExchange(word_length=d)

        # Alice
        alice_private = kex.generate_private_key(seed=42)
        alice_public = kex.compute_public_key(alice_private)

        # Bob
        bob_private = kex.generate_private_key(seed=137)
        bob_public = kex.compute_public_key(bob_private)

        print(f"\nWord length d = {d}:")
        print(f"  Keyspace size: 3^{d} = {3**d}")
        print(f"  Alice's public triple: ({alice_public[0]}, {alice_public[1]}, {alice_public[2]})")
        print(f"  Hypotenuse: {alice_public[2]}")
        print(f"  Is Pythagorean: {kex.verify_pythagorean(alice_public)}")
        print(f"  Is primitive: {kex.verify_primitive(alice_public)}")
        print(f"  Bob's hypotenuse: {bob_public[2]}")
        print(f"  Log₂(hypotenuse): {math.log2(float(alice_public[2])):.1f}")


# ═══════════════════════════════════════════════════════════════════════
# 2. ORBIT-BASED HASH FUNCTION
# ═══════════════════════════════════════════════════════════════════════

def berggren_hash(data: bytes, output_bits: int = 256) -> str:
    """
    Orbit-based hash using Berggren tree walk.

    Maps input bytes to a Berggren word, evaluates it,
    and extracts hash from the resulting triple coordinates.

    This is a proof-of-concept — NOT cryptographically audited.
    """
    # Use SHA-256 to expand input to a Berggren word
    h = hashlib.sha256(data).digest()
    word_length = len(h) * 4  # ~128 generators

    word = []
    for byte in h:
        for shift in [6, 4, 2, 0]:
            gen = (byte >> shift) & 0x03
            if gen < 3:
                word.append(gen)
            else:
                word.append(0)  # Map 3 → 0

    # Apply word to root
    v = BERGGREN_ROOT.copy().astype(np.int64)
    for gen_idx in reversed(word):
        v = BERGGREN_GENERATORS[gen_idx] @ v

    # Extract hash from triple coordinates
    coord_bytes = b''
    for coord in v:
        coord_bytes += int(coord).to_bytes(max(1, (int(coord).bit_length() + 7) // 8),
                                            byteorder='big', signed=True)

    result = hashlib.sha256(coord_bytes).hexdigest()
    return result[:output_bits // 4]


def demo_hash():
    """Demonstrate the Berggren hash function."""
    print("\n" + "=" * 70)
    print("BERGGREN ORBIT HASH FUNCTION (PROOF OF CONCEPT)")
    print("=" * 70)

    test_inputs = [b"Hello, World!", b"Hello, World?", b"", b"Pythagorean"]
    for data in test_inputs:
        h = berggren_hash(data)
        print(f"  H({data.decode('utf-8', errors='replace'):20s}) = {h}")

    # Avalanche test
    print("\n  Avalanche test (single bit change):")
    for i in range(5):
        a = bytes([i])
        b = bytes([i ^ 1])
        ha = berggren_hash(a)
        hb = berggren_hash(b)
        diff_bits = bin(int(ha, 16) ^ int(hb, 16)).count('1')
        print(f"    {a.hex()} → {ha[:16]}...  vs  {b.hex()} → {hb[:16]}...  "
              f"({diff_bits}/{len(ha)*4} bits differ)")


# ═══════════════════════════════════════════════════════════════════════
# 3. CONVERGENCE CERTIFICATION
# ═══════════════════════════════════════════════════════════════════════

def certify_convergence(s: float, max_depth: int = 10) -> dict:
    """
    Produce a convergence certificate for the Berggren Dirichlet series.

    Returns a dictionary with:
    - growth_factor: empirical α
    - threshold: σ₀ = log(3)/log(α)
    - converges: whether s > σ₀
    - partial_sum: computed partial sum
    - tail_bound: geometric tail bound
    """
    alpha = estimate_height_growth_factor(min(max_depth, 6))
    sigma0 = convergence_threshold(3, alpha)
    converges = s > sigma0

    # Compute partial sum
    from algorithms import dirichlet_partial_sum
    partial = dirichlet_partial_sum(s, max_depth)

    # Tail bound: Σ_{d>D} (3·α^{-s})^d = r^{D+1}/(1-r) where r = 3·α^{-s}
    r = 3 * alpha ** (-s)
    if r < 1:
        tail = r ** (max_depth + 1) / (1 - r)
    else:
        tail = float('inf')

    return {
        's': s,
        'growth_factor': alpha,
        'threshold': sigma0,
        'converges': converges,
        'partial_sum': partial,
        'tail_bound': tail,
        'total_bound': partial + tail if tail != float('inf') else float('inf'),
    }


def demo_certification():
    """Demonstrate convergence certification."""
    print("\n" + "=" * 70)
    print("CONVERGENCE CERTIFICATION")
    print("=" * 70)

    for s in [1.0, 1.5, 2.0, 3.0, 5.0]:
        cert = certify_convergence(s, max_depth=8)
        status = "CONVERGES ✓" if cert['converges'] else "DIVERGES ✗"
        print(f"\n  s = {s:.1f}: {status}")
        print(f"    Growth factor α = {cert['growth_factor']:.4f}")
        print(f"    Threshold σ₀ = {cert['threshold']:.4f}")
        print(f"    Partial sum (D=8) = {cert['partial_sum']:.8f}")
        if cert['tail_bound'] != float('inf'):
            print(f"    Tail bound = {cert['tail_bound']:.2e}")
            print(f"    Total bound = {cert['total_bound']:.8f}")


# ═══════════════════════════════════════════════════════════════════════
# 4. ENTROPY ANALYSIS FOR SECURITY PARAMETERS
# ═══════════════════════════════════════════════════════════════════════

def security_parameter_analysis():
    """Recommend security parameters for Berggren key exchange."""
    print("\n" + "=" * 70)
    print("SECURITY PARAMETER RECOMMENDATIONS")
    print("=" * 70)

    print(f"\n{'Depth d':>8} | {'Keyspace':>12} | {'log₂(keys)':>10} | "
          f"{'H₂ (bits)':>10} | {'Security':>10}")
    print("-" * 65)

    for d in range(1, 12):
        total, distinct, max_fib = keyspace_size(d)
        H2 = collision_entropy(d)
        log2_keys = math.log2(distinct) if distinct > 0 else 0
        security = "128-bit" if H2 >= 128 else (
            "80-bit" if H2 >= 80 else f"{H2:.0f}-bit"
        )
        print(f"{d:8d} | {distinct:12d} | {log2_keys:10.1f} | "
              f"{H2:10.1f} | {security:>10}")


# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    demo_key_exchange()
    demo_hash()
    demo_certification()
    security_parameter_analysis()
