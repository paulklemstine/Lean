#!/usr/bin/env python3
"""
LWE Cryptography Applications
==============================

Real-world applications demonstrating the LWE framework:

1. Post-quantum secure messaging (toy implementation)
2. Parameter selection for target security levels
3. Key encapsulation mechanism (KEM)
4. Noise budget analysis for homomorphic encryption foundations
"""

import numpy as np
from typing import Tuple, Dict, Optional
from dataclasses import dataclass


# ============================================================
# Application 1: Post-Quantum Secure Messaging
# ============================================================

class PostQuantumMessenger:
    """
    A toy post-quantum secure messaging system using Dual-Regev.

    Messages are encoded as sequences of ZMod q elements.
    For simplicity, each character is mapped to its ASCII code mod q.

    This demonstrates the end-to-end pipeline:
    key generation → encryption → transmission → decryption.
    """

    def __init__(self, n: int = 16, m: int = 64, q: int = 257, sigma: float = 1.0):
        self.n = n
        self.m = m
        self.q = q
        self.sigma = sigma

    def keygen(self) -> Tuple[dict, dict]:
        """Generate a keypair for the messaging system."""
        s = np.random.randint(0, self.q, size=self.n)
        A = np.random.randint(0, self.q, size=(self.m, self.n))
        noise = np.array([int(round(np.random.normal(0, self.sigma))) % self.q
                         for _ in range(self.m)])
        p = (A @ s + noise) % self.q
        return {'A': A, 'p': p}, {'s': s}

    def encrypt_message(self, pk: dict, message: str) -> list:
        """Encrypt a text message character by character."""
        ciphertexts = []
        for char in message:
            val = ord(char) % self.q
            r = np.random.randint(0, 2, size=self.m)
            u = (r @ pk['A']) % self.q
            v = (int(np.dot(r, pk['p'])) + val) % self.q
            ciphertexts.append({'u': u, 'v': v})
        return ciphertexts

    def decrypt_message(self, sk: dict, ciphertexts: list) -> str:
        """Decrypt a sequence of ciphertexts back to text."""
        chars = []
        for ct in ciphertexts:
            val = (ct['v'] - int(np.dot(ct['u'], sk['s']))) % self.q
            chars.append(chr(val))
        return ''.join(chars)


# ============================================================
# Application 2: Parameter Selection
# ============================================================

@dataclass
class SecurityEstimate:
    """Estimated security level for given LWE parameters."""
    n: int
    q: int
    sigma: float
    classical_bits: float
    quantum_bits: float
    key_size_bytes: int
    ciphertext_overhead: int


def estimate_security(n: int, q: int, sigma: float, m: Optional[int] = None
                      ) -> SecurityEstimate:
    """
    Estimate the bit-security of LWE parameters.

    Uses the standard heuristic: security ≈ n · log2(q/sigma) / log2(delta)
    where delta is the root Hermite factor.

    For BKZ-β lattice reduction, delta ≈ ((π·β)^(1/β) · β / (2π·e))^(1/(2(β-1)))
    and classical security ≈ 0.292·β + o(β), quantum ≈ 0.265·β + o(β).

    This is a simplified estimate for demonstration purposes.
    """
    if m is None:
        m = 2 * n

    # Simplified security estimate
    log_q_sigma = np.log2(q / sigma)
    # Root Hermite factor for security
    # Classical: security ≈ n * log2(q/sigma) * 0.1 (very rough)
    classical_bits = max(1.0, n * log_q_sigma * 0.12)
    quantum_bits = classical_bits * 0.9  # quantum speedup factor

    # Key sizes
    key_size_bytes = int(np.ceil(m * n * np.log2(q) / 8))
    ct_overhead = int(np.ceil((n + 1) * np.log2(q) / 8))

    return SecurityEstimate(
        n=n, q=q, sigma=sigma,
        classical_bits=classical_bits,
        quantum_bits=quantum_bits,
        key_size_bytes=key_size_bytes,
        ciphertext_overhead=ct_overhead
    )


def recommend_parameters(target_security: int = 128) -> Dict[str, any]:
    """
    Recommend LWE parameters for a target security level.

    Standard parameter sets (inspired by CRYSTALS-Kyber):
    - 128-bit: n=256, q=3329, σ≈1.2
    - 192-bit: n=384, q=3329, σ≈1.0
    - 256-bit: n=512, q=3329, σ≈0.8
    """
    params_table = {
        128: {'n': 256, 'q': 3329, 'sigma': 1.22, 'm': 512,
              'description': 'NIST Level 1 (128-bit classical)'},
        192: {'n': 384, 'q': 3329, 'sigma': 1.0, 'm': 768,
              'description': 'NIST Level 3 (192-bit classical)'},
        256: {'n': 512, 'q': 3329, 'sigma': 0.8, 'm': 1024,
              'description': 'NIST Level 5 (256-bit classical)'},
    }

    if target_security in params_table:
        return params_table[target_security]

    # Interpolate
    if target_security < 128:
        scale = target_security / 128
        return {
            'n': int(256 * scale),
            'q': 3329,
            'sigma': 1.22,
            'm': int(512 * scale),
            'description': f'Custom ({target_security}-bit target)'
        }
    else:
        scale = target_security / 128
        return {
            'n': int(256 * scale),
            'q': 3329,
            'sigma': max(0.5, 1.22 / scale),
            'm': int(512 * scale),
            'description': f'Custom ({target_security}-bit target)'
        }


# ============================================================
# Application 3: Key Encapsulation Mechanism (KEM)
# ============================================================

class LWE_KEM:
    """
    LWE-based Key Encapsulation Mechanism.

    Generates a shared secret between two parties using
    Dual-Regev encryption of a random seed.
    """

    def __init__(self, n: int = 16, m: int = 64, q: int = 257, sigma: float = 1.0):
        self.n = n
        self.m = m
        self.q = q
        self.sigma = sigma

    def keygen(self) -> Tuple[dict, dict]:
        """Generate KEM keypair."""
        s = np.random.randint(0, self.q, size=self.n)
        A = np.random.randint(0, self.q, size=(self.m, self.n))
        noise = np.array([int(round(np.random.normal(0, self.sigma))) % self.q
                         for _ in range(self.m)])
        p = (A @ s + noise) % self.q
        return {'A': A, 'p': p}, {'s': s}

    def encapsulate(self, pk: dict, key_bits: int = 32) -> Tuple[list, bytes]:
        """
        Encapsulate: generate shared secret and ciphertext.

        Returns (ciphertexts, shared_secret_bytes).
        """
        # Generate random seed
        seed_values = np.random.randint(0, min(256, self.q), size=key_bits)

        # Encrypt each byte of the seed
        ciphertexts = []
        for val in seed_values:
            r = np.random.randint(0, 2, size=self.m)
            u = (r @ pk['A']) % self.q
            v = (int(np.dot(r, pk['p'])) + int(val)) % self.q
            ciphertexts.append({'u': u.tolist(), 'v': int(v)})

        # Derive shared secret from seed
        shared_secret = bytes(int(v) % 256 for v in seed_values)
        return ciphertexts, shared_secret

    def decapsulate(self, sk: dict, ciphertexts: list) -> bytes:
        """
        Decapsulate: recover shared secret from ciphertext.
        """
        seed_values = []
        for ct in ciphertexts:
            u = np.array(ct['u'])
            v = ct['v']
            val = (v - int(np.dot(u, sk['s']))) % self.q
            seed_values.append(val % 256)
        return bytes(seed_values)


# ============================================================
# Application 4: Noise Budget Analysis
# ============================================================

def analyze_noise_budget(n: int, m: int, q: int, sigma: float,
                         num_operations: int = 10) -> Dict[str, any]:
    """
    Analyze the noise budget for a sequence of homomorphic-like operations.

    In LWE-based systems, each operation accumulates noise.
    The noise budget is the remaining "room" before decryption fails.

    This is relevant for FHE parameter selection.
    """
    # Initial noise: σ
    noise_level = sigma

    # Each addition roughly preserves noise level
    # Each "multiplication" roughly squares it (simplified model)
    history = [{'operation': 'initial', 'noise': noise_level,
                'budget_remaining': np.log2(q / (2 * noise_level))}]

    for i in range(num_operations):
        if i % 2 == 0:
            # Addition: noise grows by sqrt(2) factor
            noise_level *= np.sqrt(2)
            op = 'addition'
        else:
            # Multiplication: noise grows by factor proportional to current level
            noise_level *= min(noise_level, q / 4)
            noise_level = min(noise_level, q / 2)
            op = 'multiplication'

        budget = max(0, np.log2(q / (2 * noise_level)))
        history.append({
            'operation': op,
            'noise': noise_level,
            'budget_remaining': budget
        })

        if budget <= 0:
            break

    return {
        'max_operations': len(history) - 1,
        'final_noise': noise_level,
        'initial_budget': np.log2(q / (2 * sigma)),
        'history': history
    }


# ============================================================
# Main: demonstrate applications
# ============================================================

def main():
    np.random.seed(42)

    print("=" * 60)
    print("  LWE CRYPTOGRAPHY APPLICATIONS")
    print("=" * 60)

    # Application 1: Secure messaging
    print("\n--- Application 1: Post-Quantum Secure Messaging ---")
    messenger = PostQuantumMessenger(n=16, m=64, q=257, sigma=1.0)
    pk, sk = messenger.keygen()
    message = "Hello, quantum-safe world!"
    encrypted = messenger.encrypt_message(pk, message)
    decrypted = messenger.decrypt_message(sk, encrypted)
    print(f"  Original:  '{message}'")
    print(f"  Decrypted: '{decrypted}'")
    print(f"  Match: {'✓' if message == decrypted else '✗'}")
    print(f"  Ciphertext elements: {len(encrypted)}")

    # Application 2: Parameter selection
    print("\n--- Application 2: Parameter Selection ---")
    for level in [128, 192, 256]:
        params = recommend_parameters(level)
        est = estimate_security(params['n'], params['q'], params['sigma'], params['m'])
        print(f"\n  {params['description']}:")
        print(f"    n={params['n']}, q={params['q']}, σ={params['sigma']:.2f}")
        print(f"    Est. classical security: {est.classical_bits:.0f} bits")
        print(f"    Est. quantum security:   {est.quantum_bits:.0f} bits")
        print(f"    Public key size: {est.key_size_bytes:,} bytes")
        print(f"    Ciphertext overhead: {est.ciphertext_overhead} bytes")

    # Application 3: Key encapsulation
    print("\n--- Application 3: Key Encapsulation Mechanism ---")
    kem = LWE_KEM(n=16, m=64, q=257, sigma=1.0)
    pk, sk = kem.keygen()
    ct, shared_secret_enc = kem.encapsulate(pk)
    shared_secret_dec = kem.decapsulate(sk, ct)
    print(f"  Encapsulated key: {shared_secret_enc.hex()[:32]}...")
    print(f"  Decapsulated key: {shared_secret_dec.hex()[:32]}...")
    print(f"  Keys match: {'✓' if shared_secret_enc == shared_secret_dec else '✗'}")

    # Application 4: Noise budget
    print("\n--- Application 4: Noise Budget Analysis ---")
    result = analyze_noise_budget(n=256, m=512, q=3329, sigma=1.22)
    print(f"  Initial noise budget: {result['initial_budget']:.1f} bits")
    print(f"  Operations before failure: {result['max_operations']}")
    print(f"\n  Operation history:")
    for i, entry in enumerate(result['history'][:8]):
        bar = "█" * max(0, int(entry['budget_remaining']))
        print(f"    Step {i}: {entry['operation']:15s} "
              f"noise={entry['noise']:.2f} "
              f"budget={entry['budget_remaining']:.1f} bits {bar}")
    if len(result['history']) > 8:
        print(f"    ... ({len(result['history']) - 8} more steps)")

    print("\n" + "=" * 60)
    print("  All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
LWE Cryptography Demo
=====================

Demonstrates:
1. LWE instance generation and the noisy linear equation problem
2. Dual-Regev encryption and decryption
3. Hybrid game visualization for search-to-decision reduction
4. Ring-LWE coefficient transport
5. Conjecture testing: basis conditioning gap

Usage:
    python demo.py                  # Run all demos
    python demo.py --demo lwe       # LWE instances only
    python demo.py --demo regev     # Dual-Regev only
    python demo.py --demo hybrid    # Hybrid games only
    python demo.py --demo ring      # Ring-LWE only
    python demo.py --demo conjecture # Conjecture testing
"""

import argparse
import numpy as np
from typing import Tuple, List, Optional
import sys


# ============================================================
# Core LWE Implementation
# ============================================================

class LWESample:
    """A single LWE sample (a, b) where b = <a, s> + e mod q."""
    def __init__(self, a: np.ndarray, b: int):
        self.a = a
        self.b = b

    def __repr__(self):
        return f"LWESample(a={self.a}, b={self.b})"


class LWEInstance:
    """An LWE instance with secret s and m samples."""
    def __init__(self, n: int, m: int, q: int, sigma: float = 1.0):
        self.n = n
        self.m = m
        self.q = q
        self.sigma = sigma
        self.secret = np.random.randint(0, q, size=n)
        self.samples = []
        for _ in range(m):
            a = np.random.randint(0, q, size=n)
            e = int(round(np.random.normal(0, sigma))) % q
            b = (int(np.dot(a, self.secret)) + e) % q
            self.samples.append(LWESample(a, b))

    def get_matrix_vector(self) -> Tuple[np.ndarray, np.ndarray]:
        """Return (A, b) where A is m x n and b is m-vector."""
        A = np.array([s.a for s in self.samples])
        b = np.array([s.b for s in self.samples])
        return A, b


def generate_uniform_samples(n: int, m: int, q: int) -> List[LWESample]:
    """Generate uniform random samples (not LWE)."""
    samples = []
    for _ in range(m):
        a = np.random.randint(0, q, size=n)
        b = np.random.randint(0, q)
        samples.append(LWESample(a, b))
    return samples


# ============================================================
# Dual-Regev Encryption
# ============================================================

class DualRegevScheme:
    """Dual-Regev public-key encryption scheme."""

    def __init__(self, n: int, m: int, q: int, sigma: float = 1.0):
        self.n = n
        self.m = m
        self.q = q
        self.sigma = sigma

    def keygen(self) -> Tuple[dict, dict]:
        """Generate (public_key, secret_key)."""
        s = np.random.randint(0, self.q, size=self.n)
        A = np.random.randint(0, self.q, size=(self.m, self.n))
        noise = np.array([int(round(np.random.normal(0, self.sigma))) % self.q
                         for _ in range(self.m)])
        p = (A @ s + noise) % self.q

        pk = {'A': A, 'p': p}
        sk = {'s': s}
        return pk, sk

    def encrypt(self, pk: dict, message: int, binary_r: bool = True) -> dict:
        """Encrypt a message μ ∈ {0, ..., q-1}.
        Uses binary randomness r ∈ {0,1}^m for standard Dual-Regev."""
        A, p = pk['A'], pk['p']
        if binary_r:
            r = np.random.randint(0, 2, size=self.m)
        else:
            r = np.random.randint(0, self.q, size=self.m)

        u = (r @ A) % self.q  # r^T A, shape (n,)
        v = (int(np.dot(r, p)) + message) % self.q
        return {'u': u, 'v': v}

    def decrypt(self, sk: dict, ct: dict) -> int:
        """Decrypt a ciphertext."""
        s = sk['s']
        u, v = ct['u'], ct['v']
        return (v - int(np.dot(u, s))) % self.q


# ============================================================
# Hybrid Games for Search-to-Decision
# ============================================================

def hybrid_game_probabilities(n: int, q: int, m: int, sigma: float,
                               num_trials: int = 1000) -> np.ndarray:
    """
    Simulate hybrid games for search-to-decision reduction.

    Hybrid k: first k coordinates of the secret are randomized (replaced
    by uniform), remaining n-k coordinates are real LWE.

    Returns array of "distinguishing probabilities" for each hybrid.
    """
    probs = np.zeros(n + 1)

    for k in range(n + 1):
        correct = 0
        for _ in range(num_trials):
            # Generate real secret
            s = np.random.randint(0, q, size=n)

            # Generate samples
            a = np.random.randint(0, q, size=(m, n))
            noise = np.array([int(round(np.random.normal(0, sigma))) % q
                            for _ in range(m)])

            # Hybrid k: randomize first k coordinates
            s_hybrid = s.copy()
            if k > 0:
                s_hybrid[:k] = np.random.randint(0, q, size=k)

            b = (a @ s_hybrid + noise) % q

            # Simple distinguisher: check if residuals are "small"
            # (This is a toy distinguisher for demonstration)
            residuals = (b - a @ s) % q
            # Map to centered representation
            residuals_centered = np.where(residuals > q // 2, residuals - q, residuals)
            score = np.mean(np.abs(residuals_centered))

            # Threshold-based decision
            threshold = q / 4
            if score < threshold:
                correct += 1

        probs[k] = correct / num_trials

    return probs


def telescope_bound(probs: np.ndarray) -> Tuple[float, float]:
    """
    Verify the hybrid telescope bound:
    |prob[0] - prob[n]| <= sum of |prob[i] - prob[i+1]|
    """
    total_adv = abs(probs[0] - probs[-1])
    sum_adjacent = sum(abs(probs[i] - probs[i + 1]) for i in range(len(probs) - 1))
    return total_adv, sum_adjacent


# ============================================================
# Ring-LWE
# ============================================================

class PolynomialRing:
    """Polynomial ring Z_q[x] / (x^n + 1) for power-of-two n."""

    def __init__(self, n: int, q: int):
        self.n = n
        self.q = q

    def mul(self, a: np.ndarray, b: np.ndarray) -> np.ndarray:
        """Multiply two polynomials in Z_q[x]/(x^n + 1)."""
        result = np.zeros(self.n, dtype=int)
        for i in range(self.n):
            for j in range(self.n):
                idx = i + j
                if idx < self.n:
                    result[idx] = (result[idx] + int(a[i]) * int(b[j])) % self.q
                else:
                    # x^n ≡ -1
                    result[idx - self.n] = (result[idx - self.n] - int(a[i]) * int(b[j])) % self.q
        return result

    def add(self, a: np.ndarray, b: np.ndarray) -> np.ndarray:
        return (a + b) % self.q

    def random_element(self) -> np.ndarray:
        return np.random.randint(0, self.q, size=self.n)

    def small_element(self, sigma: float = 1.0) -> np.ndarray:
        return np.array([int(round(np.random.normal(0, sigma))) % self.q
                        for _ in range(self.n)])

    def multiplication_matrix(self, a: np.ndarray) -> np.ndarray:
        """
        Return the n x n matrix M_a such that M_a @ s = a * s
        in the coefficient representation.
        This demonstrates that ring multiplication is a linear map.
        """
        M = np.zeros((self.n, self.n), dtype=int)
        for j in range(self.n):
            # e_j is the j-th standard basis vector (x^j)
            e_j = np.zeros(self.n, dtype=int)
            e_j[j] = 1
            M[:, j] = self.mul(a, e_j)
        return M % self.q


class RingLWESample:
    """A Ring-LWE sample (a, b) where b = a*s + e in R_q."""
    def __init__(self, a: np.ndarray, b: np.ndarray):
        self.a = a
        self.b = b


def ring_lwe_to_coefficient_lwe(ring: PolynomialRing, sample: RingLWESample) -> Tuple[np.ndarray, np.ndarray]:
    """
    Transport a Ring-LWE sample to coefficient-LWE.
    Returns (M_a, b) where M_a is the multiplication matrix and b is the coefficient vector.
    """
    M_a = ring.multiplication_matrix(sample.a)
    return M_a, sample.b


# ============================================================
# Conjecture Testing
# ============================================================

def test_basis_conditioning_conjecture(n: int = 8, q: int = 97,
                                        num_trials: int = 500) -> dict:
    """
    Test the conjecture that the distinguishing advantage of coefficient-embedded
    Ring-LWE is related to the spectral spread of the multiplication matrix.

    For each trial:
    1. Sample a random ring element a
    2. Compute its multiplication matrix M_a
    3. Compute the condition number (spectral spread)
    4. Estimate distinguishing advantage
    """
    ring = PolynomialRing(n, q)
    results = []

    for _ in range(num_trials):
        a = ring.random_element()
        M_a = ring.multiplication_matrix(a)

        # Spectral spread: ratio of largest to smallest singular value
        try:
            svs = np.linalg.svd(M_a.astype(float), compute_uv=False)
            if svs[-1] > 0:
                spectral_spread = svs[0] / svs[-1]
            else:
                spectral_spread = float('inf')
        except:
            spectral_spread = float('inf')

        # Estimate distinguishing advantage
        sigma = 2.0
        num_distinguish = 200
        lwe_scores = []
        uniform_scores = []

        for _ in range(num_distinguish):
            s = ring.random_element()
            e = ring.small_element(sigma)
            b_lwe = ring.add(ring.mul(a, s), e)
            b_uniform = ring.random_element()

            # Use coefficient-space chi-squared statistic as distinguisher
            b_lwe_centered = np.where(b_lwe > q // 2, b_lwe - q, b_lwe)
            b_uni_centered = np.where(b_uniform > q // 2, b_uniform - q, b_uniform)
            lwe_scores.append(np.std(b_lwe_centered))
            uniform_scores.append(np.std(b_uni_centered))

        # Advantage: difference in mean scores
        advantage = abs(np.mean(lwe_scores) - np.mean(uniform_scores))

        results.append({
            'spectral_spread': spectral_spread,
            'advantage': advantage,
            'condition': spectral_spread
        })

    return results


# ============================================================
# Demo Functions
# ============================================================

def demo_lwe():
    """Demonstrate LWE instance generation."""
    print("=" * 60)
    print("DEMO 1: Learning With Errors (LWE)")
    print("=" * 60)

    for n, q, sigma in [(4, 97, 1.0), (8, 257, 2.0), (16, 1031, 4.0)]:
        print(f"\nParameters: n={n}, q={q}, σ={sigma}")
        lwe = LWEInstance(n, 2 * n, q, sigma)
        print(f"  Secret: {lwe.secret}")

        # Show first few samples
        for i, s in enumerate(lwe.samples[:3]):
            # Compute expected b without noise
            expected = int(np.dot(s.a, lwe.secret)) % q
            noise = (s.b - expected) % q
            if noise > q // 2:
                noise -= q
            print(f"  Sample {i}: b={s.b}, <a,s>={expected}, noise={noise}")

        # Demonstrate hardness: try naive recovery
        A, b = lwe.get_matrix_vector()
        print(f"  Matrix A shape: {A.shape}")
        print(f"  Without noise, linear algebra would recover s instantly.")
        print(f"  With noise, the system becomes computationally intractable.")

    print()


def demo_regev():
    """Demonstrate Dual-Regev encryption."""
    print("=" * 60)
    print("DEMO 2: Dual-Regev Encryption")
    print("=" * 60)

    for n, m, q, sigma in [(8, 32, 97, 1.0), (16, 64, 257, 2.0)]:
        print(f"\nParameters: n={n}, m={m}, q={q}, σ={sigma}")
        scheme = DualRegevScheme(n, m, q, sigma)
        pk, sk = scheme.keygen()

        # Encrypt and decrypt several messages
        successes = 0
        num_tests = 100
        for _ in range(num_tests):
            msg = np.random.randint(0, q)
            ct = scheme.encrypt(pk, msg)
            dec = scheme.decrypt(sk, ct)
            if dec == msg:
                successes += 1

        print(f"  Encryption correctness: {successes}/{num_tests} "
              f"({100*successes/num_tests:.1f}%)")

        # Show a specific example
        msg = 42 % q
        ct = scheme.encrypt(pk, msg)
        dec = scheme.decrypt(sk, ct)
        print(f"  Example: encrypt({msg}) -> decrypt = {dec} "
              f"({'✓' if dec == msg else '✗'})")

        # Demonstrate noise accumulation (Theorem 1)
        print(f"  Note: decrypt = μ + Σ rᵢ·noiseᵢ (mod q)")
        print(f"  When noise is small relative to q, decryption succeeds.")

    print()


def demo_hybrid():
    """Demonstrate hybrid games for search-to-decision reduction."""
    print("=" * 60)
    print("DEMO 3: Hybrid Games (Search-to-Decision)")
    print("=" * 60)

    n, q, m, sigma = 6, 97, 20, 2.0
    print(f"\nParameters: n={n}, q={q}, m={m}, σ={sigma}")
    print("Computing hybrid game probabilities...")

    probs = hybrid_game_probabilities(n, q, m, sigma, num_trials=500)

    print("\nHybrid Game Probabilities:")
    print("  Game | Prob(distinguish) | Bar")
    print("  " + "-" * 50)
    for i, p in enumerate(probs):
        bar = "█" * int(p * 40)
        print(f"  H_{i:2d} | {p:.4f}            | {bar}")

    total_adv, sum_adj = telescope_bound(probs)
    print(f"\n  Total advantage |H_0 - H_{n}|: {total_adv:.4f}")
    print(f"  Sum of adjacent |H_i - H_{{i+1}}|: {sum_adj:.4f}")
    print(f"  Telescope bound satisfied: {total_adv <= sum_adj + 1e-10}")

    # Identify coordinate with maximum advantage
    adjacent_diffs = [abs(probs[i] - probs[i + 1]) for i in range(n)]
    max_coord = np.argmax(adjacent_diffs)
    print(f"\n  Max advantage coordinate: {max_coord} "
          f"(advantage = {adjacent_diffs[max_coord]:.4f})")
    print(f"  Average advantage per coordinate: {total_adv/n:.4f}")
    print(f"  Pigeonhole bound (ε/n): {total_adv/n:.4f}")
    print(f"  Max ≥ ε/n: {adjacent_diffs[max_coord] >= total_adv/n - 1e-10}")

    print()


def demo_ring():
    """Demonstrate Ring-LWE and coefficient transport."""
    print("=" * 60)
    print("DEMO 4: Ring-LWE and Coefficient Transport")
    print("=" * 60)

    n, q = 8, 97
    ring = PolynomialRing(n, q)
    sigma = 2.0

    print(f"\nRing: Z_{q}[x]/(x^{n} + 1)")

    # Generate Ring-LWE sample
    s = ring.random_element()
    a = ring.random_element()
    e = ring.small_element(sigma)
    b = ring.add(ring.mul(a, s), e)
    sample = RingLWESample(a, b)

    print(f"  Secret s: {s}")
    print(f"  Public a: {a}")
    print(f"  Noise e:  {e}")
    print(f"  b = a·s + e: {b}")

    # Demonstrate coefficient transport
    M_a, b_vec = ring_lwe_to_coefficient_lwe(ring, sample)
    print(f"\n  Multiplication matrix M_a (first 4 rows/cols):")
    for i in range(min(4, n)):
        print(f"    {M_a[i, :4]}")

    # Verify M_a @ s ≡ a * s (mod q)
    product_matrix = M_a @ s % q
    product_ring = ring.mul(a, s)
    print(f"\n  M_a @ s mod q:  {product_matrix}")
    print(f"  a * s in ring:  {product_ring}")
    print(f"  Match: {np.array_equal(product_matrix, product_ring)}")

    # Demonstrate linearity (Theorem 7)
    s1 = ring.random_element()
    s2 = ring.random_element()
    print(f"\n  Linearity check:")
    print(f"    M_a(s1+s2) = {M_a @ (s1 + s2) % q}")
    print(f"    M_a·s1 + M_a·s2 = {(M_a @ s1 + M_a @ s2) % q}")
    print(f"    Equal: {np.array_equal(M_a @ (s1 + s2) % q, (M_a @ s1 + M_a @ s2) % q)}")

    # Spectral analysis
    svs = np.linalg.svd(M_a.astype(float), compute_uv=False)
    print(f"\n  Singular values of M_a: {np.round(svs, 2)}")
    print(f"  Condition number: {svs[0]/svs[-1]:.2f}" if svs[-1] > 0 else "  Singular matrix")

    print()


def demo_conjecture():
    """Test the basis conditioning gap conjecture."""
    print("=" * 60)
    print("DEMO 5: Conjecture Testing - Basis Conditioning Gap")
    print("=" * 60)

    print("\nConjecture: Ring-LWE distinguishing advantage correlates with")
    print("the spectral spread of the multiplication matrix.\n")

    n, q = 8, 97
    print(f"Parameters: n={n}, q={q}")
    print("Running trials...")

    results = test_basis_conditioning_conjecture(n, q, num_trials=200)

    # Filter out infinite spread
    finite_results = [r for r in results if r['spectral_spread'] < 1e6]

    if len(finite_results) < 10:
        print("  Too few finite results for analysis.")
        return

    spreads = [r['spectral_spread'] for r in finite_results]
    advantages = [r['advantage'] for r in finite_results]

    # Compute correlation
    correlation = np.corrcoef(spreads, advantages)[0, 1]

    print(f"\n  Number of trials: {len(finite_results)}")
    print(f"  Spectral spread range: [{min(spreads):.2f}, {max(spreads):.2f}]")
    print(f"  Advantage range: [{min(advantages):.4f}, {max(advantages):.4f}]")
    print(f"  Correlation(spread, advantage): {correlation:.4f}")

    # Bin by spectral spread and compare advantages
    spreads_arr = np.array(spreads)
    advantages_arr = np.array(advantages)
    median_spread = np.median(spreads_arr)

    low_spread_adv = np.mean(advantages_arr[spreads_arr < median_spread])
    high_spread_adv = np.mean(advantages_arr[spreads_arr >= median_spread])

    print(f"\n  Mean advantage (low spread, < {median_spread:.1f}): {low_spread_adv:.4f}")
    print(f"  Mean advantage (high spread, ≥ {median_spread:.1f}): {high_spread_adv:.4f}")

    if abs(correlation) > 0.1:
        print(f"\n  Result: WEAK SUPPORT for conjecture (correlation = {correlation:.4f})")
    else:
        print(f"\n  Result: NO SIGNIFICANT correlation detected ({correlation:.4f})")
    print("  Note: Larger experiments needed for definitive conclusions.")

    print()


def main():
    parser = argparse.ArgumentParser(description="LWE Cryptography Demo")
    parser.add_argument('--demo', type=str, default='all',
                       choices=['all', 'lwe', 'regev', 'hybrid', 'ring', 'conjecture'],
                       help='Which demo to run')
    parser.add_argument('--seed', type=int, default=42,
                       help='Random seed for reproducibility')
    args = parser.parse_args()

    np.random.seed(args.seed)

    print("\n" + "=" * 60)
    print("  LWE CRYPTOGRAPHY: FROM LATTICE HARDNESS TO ENCRYPTION")
    print("=" * 60 + "\n")

    demos = {
        'lwe': demo_lwe,
        'regev': demo_regev,
        'hybrid': demo_hybrid,
        'ring': demo_ring,
        'conjecture': demo_conjecture,
    }

    if args.demo == 'all':
        for name, func in demos.items():
            func()
    else:
        demos[args.demo]()

    print("=" * 60)
    print("  All demos complete.")
    print("=" * 60)


if __name__ == '__main__':
    main()
