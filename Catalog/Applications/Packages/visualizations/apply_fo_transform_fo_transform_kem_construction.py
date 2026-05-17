#!/usr/bin/env python3
"""
Applications of Tropical ElGamal and FO-Transform Spreadness

Demonstrates real-world applications of the formal results:
1. Post-quantum KEM construction via FO transform
2. Tropical key encapsulation mechanism
3. Ciphertext indistinguishability analysis
4. Security parameter selection
"""

import numpy as np
import hashlib
from typing import Tuple, Dict, List
import math


class TropicalKEM:
    """
    A Key Encapsulation Mechanism (KEM) constructed from Tropical ElGamal
    via the Fujisaki-Okamoto transform.
    
    The FO transform converts a CPA-secure PKE with γ-spreadness into
    a CCA2-secure KEM. Our formal verification proves that Tropical ElGamal
    satisfies the spreadness precondition (γ = log|Rand|).
    
    Construction:
        Encaps(pk):
            1. Sample random message m
            2. Derive randomness r = H(m)  (deterministic from m)
            3. Compute ciphertext c = Enc(pk, m, r)
            4. Derive shared key K = H'(m, c)
            Return (c, K)
        
        Decaps(sk, c):
            1. Decrypt m' = Dec(sk, c)
            2. Re-derive r' = H(m')
            3. Re-encrypt c' = Enc(pk, m', r')
            4. If c' = c: return K = H'(m', c)
            5. Else: return ⊥ (reject)
    """
    
    def __init__(self, n: int, msg_space: int = 2**16):
        """
        Initialize the tropical KEM.
        
        Args:
            n: Dimension of key vectors.
            msg_space: Size of message space for encapsulation.
        """
        self.n = n
        self.msg_space = msg_space
        
        # Key generation
        self.g = np.random.randint(-100, 100, size=n)
        self.s = np.random.randint(-50, 50)
        self.h = self.g + self.s
    
    def _hash_to_randomness(self, m: int) -> np.ndarray:
        """Derive randomness from message using hash function H."""
        seed = int(hashlib.sha256(str(m).encode()).hexdigest(), 16) % (2**32)
        rng = np.random.RandomState(seed)
        return rng.randint(-100, 100, size=self.n)
    
    def _derive_key(self, m: int, c1: np.ndarray, c2: int) -> bytes:
        """Derive shared key K = H'(m, c)."""
        data = str(m) + str(list(c1)) + str(c2)
        return hashlib.sha256(data.encode()).digest()
    
    def _encrypt(self, msg: int, r: np.ndarray) -> Tuple[np.ndarray, int]:
        """Internal encryption."""
        c1 = self.g + r
        c2 = msg + int(np.min(self.h + r))
        return c1, c2
    
    def _decrypt(self, c1: np.ndarray, c2: int) -> int:
        """Internal decryption."""
        return c2 - int(np.min(c1 + self.s))
    
    def encaps(self) -> Tuple[Tuple[np.ndarray, int], bytes]:
        """
        Encapsulate: generate ciphertext and shared key.
        
        Returns:
            (ciphertext, shared_key)
        """
        # Sample random message
        m = np.random.randint(0, self.msg_space)
        
        # Derive randomness deterministically from m
        r = self._hash_to_randomness(m)
        
        # Encrypt
        c1, c2 = self._encrypt(m, r)
        
        # Derive shared key
        K = self._derive_key(m, c1, c2)
        
        return (c1, c2), K
    
    def decaps(self, c1: np.ndarray, c2: int) -> bytes:
        """
        Decapsulate: recover shared key from ciphertext.
        
        Returns:
            shared_key or None if verification fails.
        """
        # Decrypt
        m_prime = self._decrypt(c1, c2)
        
        # Re-derive randomness
        r_prime = self._hash_to_randomness(m_prime)
        
        # Re-encrypt
        c1_prime, c2_prime = self._encrypt(m_prime, r_prime)
        
        # Verify
        if np.array_equal(c1_prime, c1) and c2_prime == c2:
            return self._derive_key(m_prime, c1, c2)
        else:
            return None  # Reject: ciphertext invalid


def demo_kem():
    """Demonstrate the Tropical KEM construction."""
    print("=" * 60)
    print("APPLICATION 1: Tropical KEM via FO Transform")
    print("=" * 60)
    
    kem = TropicalKEM(n=4)
    
    print(f"\n  Key dimension: n = {kem.n}")
    print(f"  Generator: g = {kem.g}")
    print(f"  Public element: h = {kem.h}")
    
    # Encapsulate
    (c1, c2), K_sender = kem.encaps()
    print(f"\n  Encapsulation:")
    print(f"    c₁ = {c1}")
    print(f"    c₂ = {c2}")
    print(f"    K (sender) = {K_sender[:8].hex()}...")
    
    # Decapsulate
    K_receiver = kem.decaps(c1, c2)
    print(f"\n  Decapsulation:")
    print(f"    K (receiver) = {K_receiver[:8].hex()}...")
    print(f"    Keys match: {K_sender == K_receiver}")
    
    # Test with tampered ciphertext
    c2_tampered = c2 + 1
    K_tampered = kem.decaps(c1, c2_tampered)
    print(f"\n  Tampered ciphertext test:")
    print(f"    c₂ tampered: {c2} → {c2_tampered}")
    print(f"    Decaps result: {'Rejected ✓' if K_tampered is None else 'Accepted ✗'}")
    
    # Run multiple encapsulations
    successes = 0
    trials = 100
    for _ in range(trials):
        (c1, c2), K_s = kem.encaps()
        K_r = kem.decaps(c1, c2)
        if K_s == K_r:
            successes += 1
    
    print(f"\n  Batch test: {successes}/{trials} successful encaps/decaps")


def demo_security_parameter_selection():
    """Show how to select security parameters for the tropical KEM."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Security Parameter Selection")
    print("=" * 60)
    
    print("\n  The γ-spreadness theorem guarantees:")
    print("    γ = log|Rand| = n · log(2R+1)")
    print("  where n is the dimension and R is the randomness bound.")
    print("\n  For target security level λ bits, we need γ ≥ λ.")
    
    target_levels = [64, 128, 256]
    R_values = [100, 1000, 10000]
    
    print(f"\n  {'λ (bits)':>10} {'R':>8} {'n needed':>10} {'γ achieved':>12}")
    print("  " + "-" * 44)
    
    for lam in target_levels:
        for R in R_values:
            log_range = math.log2(2 * R + 1)
            n_needed = math.ceil(lam / log_range)
            gamma = n_needed * log_range
            print(f"  {lam:>10} {R:>8} {n_needed:>10} {gamma:>12.1f}")


def demo_ciphertext_indistinguishability():
    """Analyze ciphertext distribution properties."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Ciphertext Indistinguishability Analysis")
    print("=" * 60)
    
    n = 3
    kem = TropicalKEM(n=n)
    
    msg0, msg1 = 100, 200
    num_samples = 5000
    
    # Collect c₂ values for both messages
    c2_vals_m0 = []
    c2_vals_m1 = []
    
    for _ in range(num_samples):
        r = np.random.randint(-50, 50, size=n)
        _, c2_0 = kem._encrypt(msg0, r)
        c2_vals_m0.append(c2_0)
        
        r = np.random.randint(-50, 50, size=n)
        _, c2_1 = kem._encrypt(msg1, r)
        c2_vals_m1.append(c2_1)
    
    c2_m0 = np.array(c2_vals_m0)
    c2_m1 = np.array(c2_vals_m1)
    
    print(f"\n  Message 0 ciphertext c₂ statistics:")
    print(f"    Mean: {np.mean(c2_m0):.1f}, Std: {np.std(c2_m0):.1f}")
    print(f"    Range: [{np.min(c2_m0)}, {np.max(c2_m0)}]")
    
    print(f"\n  Message 1 ciphertext c₂ statistics:")
    print(f"    Mean: {np.mean(c2_m1):.1f}, Std: {np.std(c2_m1):.1f}")
    print(f"    Range: [{np.min(c2_m1)}, {np.max(c2_m1)}]")
    
    # The c₂ distributions for different messages are shifted by (msg1-msg0)
    shift = msg1 - msg0
    print(f"\n  Expected shift between distributions: {shift}")
    print(f"  Observed mean difference: {np.mean(c2_m1) - np.mean(c2_m0):.1f}")
    print(f"\n  Note: Without knowing r, the adversary cannot determine the shift.")
    print(f"  The FO transform derandomizes the scheme, making it CCA2-secure.")


if __name__ == "__main__":
    np.random.seed(42)
    demo_kem()
    demo_security_parameter_selection()
    demo_ciphertext_indistinguishability()
    
    print("\n" + "=" * 60)
    print("All application demos completed!")
    print("=" * 60)
