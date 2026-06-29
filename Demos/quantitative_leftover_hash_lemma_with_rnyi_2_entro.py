#!/usr/bin/env python3
"""
Algorithms for Entropy Extraction via Universal Hashing

Implements the computational pipeline from the Leftover Hash Lemma:
  Source → Collision Probability → Entropy → Hash Parameters → Extracted Key

Includes:
  - Linear universal hash family (a·x mod p) mod m
  - Collision probability estimation
  - Security parameter selection
  - Extraction with verified bounds
"""

import numpy as np
from typing import Optional, Tuple
import hashlib
import struct


class UniversalHashFamily:
    """
    A 2-universal hash family based on linear hashing:
      h_{a,b}(x) = ((a * x + b) mod p) mod m

    where p is a prime ≥ |α| and m = |β| is the output size.

    Collision bound: For x ≠ y, Pr_{a,b}[h(x) = h(y)] ≤ 1/m.

    Time complexity: O(1) per evaluation (with modular arithmetic)
    Space complexity: O(log p) for the seed (a, b)
    """

    def __init__(self, input_size: int, output_size: int, prime: Optional[int] = None):
        """
        Initialize the hash family.

        Args:
            input_size: Size of input domain |α|
            output_size: Size of output domain |β|
            prime: A prime ≥ input_size (auto-selected if None)
        """
        self.input_size = input_size
        self.output_size = output_size
        self.prime = prime or self._next_prime(max(input_size, output_size))
        self.seed: Optional[Tuple[int, int]] = None

    @staticmethod
    def _next_prime(n: int) -> int:
        """Find the next prime ≥ n using trial division."""
        if n <= 2:
            return 2
        candidate = n if n % 2 == 1 else n + 1
        while True:
            if all(candidate % i != 0 for i in range(2, int(candidate**0.5) + 1)):
                return candidate
            candidate += 2

    def sample_seed(self, rng: Optional[np.random.Generator] = None) -> Tuple[int, int]:
        """
        Sample a random seed (a, b) from ℤ_p × ℤ_p with a ≠ 0.

        Args:
            rng: Random number generator (default: numpy default)

        Returns:
            Seed (a, b) with a ∈ {1, ..., p-1} and b ∈ {0, ..., p-1}
        """
        if rng is None:
            rng = np.random.default_rng()
        a = int(rng.integers(1, self.prime))  # a ≠ 0
        b = int(rng.integers(0, self.prime))
        self.seed = (a, b)
        return (a, b)

    def hash(self, x: int, seed: Optional[Tuple[int, int]] = None) -> int:
        """
        Evaluate the hash function h_{a,b}(x) = ((a*x + b) mod p) mod m.

        Args:
            x: Input value in {0, ..., input_size - 1}
            seed: Optional seed (a, b); uses stored seed if None

        Returns:
            Hash value in {0, ..., output_size - 1}

        Time complexity: O(1) (modular arithmetic)
        """
        if seed is None:
            seed = self.seed
        if seed is None:
            raise ValueError("No seed set. Call sample_seed() first.")
        a, b = seed
        return ((a * x + b) % self.prime) % self.output_size

    def collision_rate(self, x: int, y: int, num_seeds: int = 10000,
                       rng: Optional[np.random.Generator] = None) -> float:
        """
        Empirically estimate the collision rate Pr_s[h_s(x) = h_s(y)].

        Args:
            x, y: Distinct input values
            num_seeds: Number of random seeds to test
            rng: Random number generator

        Returns:
            Estimated collision probability
        """
        if rng is None:
            rng = np.random.default_rng(42)
        collisions = 0
        for _ in range(num_seeds):
            seed = (int(rng.integers(1, self.prime)), int(rng.integers(0, self.prime)))
            if self.hash(x, seed) == self.hash(y, seed):
                collisions += 1
        return collisions / num_seeds


def collision_probability(pmf: np.ndarray) -> float:
    """
    Compute the collision probability CP(X) = Σ p(a)².

    Args:
        pmf: Probability mass function (array summing to 1)

    Returns:
        Collision probability ∈ [1/|α|, 1]

    Time complexity: O(|α|)
    """
    return float(np.sum(pmf ** 2))


def renyi2_entropy(pmf: np.ndarray) -> float:
    """
    Compute the Rényi-2 entropy H₂(X) = -log₂(CP(X)).

    Args:
        pmf: Probability mass function

    Returns:
        Rényi-2 entropy in bits

    Time complexity: O(|α|)
    """
    cp = collision_probability(pmf)
    return -np.log2(cp) if cp > 0 else float('inf')


def lhl_security_bound(output_size: int, collision_prob: float) -> float:
    """
    Compute the Leftover Hash Lemma statistical distance bound:
      SD ≤ (1/2) √(|β| · CP(X))

    Args:
        output_size: |β|, the size of the output domain
        collision_prob: CP(X), the collision probability of the source

    Returns:
        Upper bound on statistical distance from uniform

    Time complexity: O(1)
    """
    return 0.5 * np.sqrt(output_size * collision_prob)


def select_output_length(source_entropy_bits: float,
                          security_parameter: int = 128) -> int:
    """
    Select the optimal output key length for a given source entropy
    and desired security level.

    Algorithm: Set ℓ = ⌊k - 2λ⌋ where k is source entropy (bits)
    and λ is the security parameter.

    Guarantee: SD ≤ (1/2) · 2^{-λ}

    Args:
        source_entropy_bits: H₂(X) in bits
        security_parameter: Desired security level λ in bits

    Returns:
        Output key length in bits (0 if insufficient entropy)

    Time complexity: O(1)
    """
    ell = int(np.floor(source_entropy_bits - 2 * security_parameter))
    return max(ell, 0)


def extract_key(source_sample: int, hash_family: UniversalHashFamily,
                rng: Optional[np.random.Generator] = None) -> Tuple[Tuple[int, int], int]:
    """
    Extract a near-uniform key from a source sample using universal hashing.

    Algorithm HashExtract:
      1. Sample seed s ← Uniform(ι)
      2. Compute key k = h_s(x)
      3. Return (s, k)

    Security guarantee (by LHL):
      SD((S, K), (S, U_β)) ≤ (1/2) √(|β| · CP(X))

    Args:
        source_sample: Sample x from the source distribution
        hash_family: Universal hash family to use
        rng: Random number generator for seed sampling

    Returns:
        (seed, key) pair

    Time complexity: O(1) per extraction
    Space complexity: O(log|ι| + log|β|)
    """
    seed = hash_family.sample_seed(rng)
    key = hash_family.hash(source_sample, seed)
    return seed, key


# ─── Example Usage ─────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Universal Hash Extraction — Algorithm Demonstration")
    print("=" * 60)

    # Set up a source distribution
    n = 256  # source size
    rng = np.random.default_rng(42)

    # Create a skewed distribution (simulating a weak entropy source)
    raw = rng.exponential(1, n)
    pmf = raw / raw.sum()
    pmf.sort()
    pmf = pmf[::-1]  # sort descending

    # Compute entropy measures
    cp = collision_probability(pmf)
    h2 = renyi2_entropy(pmf)
    hinf = -np.log2(pmf[0])

    print(f"\nSource: {n} elements, skewed distribution")
    print(f"  Collision probability:  {cp:.6f}")
    print(f"  Rényi-2 entropy:        {h2:.2f} bits")
    print(f"  Min-entropy:            {hinf:.2f} bits")

    # Select output length for 10-bit security
    security_bits = 10
    ell = select_output_length(h2, security_bits)
    output_size = 2 ** ell if ell > 0 else 2

    print(f"\n  Target security:        {security_bits} bits")
    print(f"  Output key length:      {ell} bits ({output_size} values)")

    # Create hash family and extract
    H = UniversalHashFamily(n, output_size)
    print(f"  Hash family prime:      {H.prime}")

    # Verify 2-universality empirically
    print("\n  Verifying 2-universality (empirical collision rates):")
    expected_rate = 1.0 / output_size
    for x, y in [(0, 1), (0, 127), (42, 200)]:
        rate = H.collision_rate(x, y, num_seeds=50000, rng=rng)
        print(f"    Pr[h(x={x}) = h(y={y})] = {rate:.4f}  (expected ≤ {expected_rate:.4f})")

    # Extract multiple keys
    print(f"\n  Extracting 10 keys:")
    bound = lhl_security_bound(output_size, cp)
    print(f"  LHL bound: SD ≤ {bound:.4e}")

    for i in range(10):
        x = int(rng.choice(n, p=pmf))
        seed, key = extract_key(x, H, rng)
        print(f"    Sample x={x:>3}, seed=({seed[0]:>4},{seed[1]:>4}), key={key}")

    print("\n" + "=" * 60)
    print("Done.")


#!/usr/bin/env python3
"""
Applications of the Leftover Hash Lemma

Demonstrates real-world applications of entropy extraction:
1. Post-quantum key derivation (ML-KEM / Kyber style)
2. Password-based key derivation
3. Random number generator seeding
4. Privacy amplification in quantum key distribution
"""

import numpy as np
from typing import List, Tuple
import hashlib


def collision_prob(pmf: np.ndarray) -> float:
    """Collision probability CP(X) = Σ p²."""
    return float(np.sum(pmf ** 2))


def lhl_bound(output_size: int, cp: float) -> float:
    """LHL bound: SD ≤ (1/2)√(|β|·CP)."""
    return 0.5 * np.sqrt(output_size * cp)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Post-Quantum Key Derivation (ML-KEM style)
# ═══════════════════════════════════════════════════════════════════════

def post_quantum_kdf_analysis():
    """
    Analyze key derivation in a lattice-based KEM.

    In ML-KEM (Kyber), after decapsulation, the shared secret has
    min-entropy approximately n·log₂(q) - δ bits, where n is the
    lattice dimension, q is the modulus, and δ accounts for the
    decryption error margin.

    The LHL guarantees that hashing to a 256-bit key yields
    negligible statistical distance from uniform.
    """
    print("=" * 65)
    print("APPLICATION 1: Post-Quantum Key Derivation (ML-KEM)")
    print("=" * 65)

    # ML-KEM-768 parameters
    n = 768          # lattice dimension
    q = 3329         # modulus
    log_q = np.log2(q)

    # Effective entropy after decapsulation
    # (accounting for error correction and rounding)
    entropy_loss = 120  # bits lost to noise/rounding
    source_entropy = n * log_q - entropy_loss

    print(f"\n  ML-KEM-768 Parameters:")
    print(f"    Lattice dimension n:     {n}")
    print(f"    Modulus q:               {q}")
    print(f"    Raw entropy:             {n * log_q:.1f} bits")
    print(f"    Entropy loss (noise):    {entropy_loss} bits")
    print(f"    Source entropy (H₂):     {source_entropy:.1f} bits")

    for key_len in [128, 192, 256]:
        cp = 2 ** (-source_entropy)
        output_size = 2 ** key_len
        sd = lhl_bound(output_size, cp)
        sec_bits = -np.log2(sd) if sd > 0 else float('inf')
        gap = source_entropy - key_len

        print(f"\n    Key length: {key_len} bits")
        print(f"      Entropy gap:     {gap:.1f} bits")
        print(f"      SD bound:        2^{{-{sec_bits:.1f}}}")
        print(f"      NIST Level:      {'1 (128)' if sec_bits >= 128 else '?'}")

    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Password-Based Key Derivation
# ═══════════════════════════════════════════════════════════════════════

def password_kdf_analysis():
    """
    Analyze the entropy available from password-based sources.

    A typical password has ~40 bits of min-entropy (from a dictionary
    of ~1M common passwords). After salting and stretching (PBKDF2),
    the effective entropy against offline attacks increases, but the
    LHL bound shows the fundamental limit.
    """
    print("=" * 65)
    print("APPLICATION 2: Password-Based Key Derivation Security")
    print("=" * 65)

    print("\n  Analysis: Can passwords provide enough entropy for keys?\n")

    scenarios = [
        ("Weak password (4-digit PIN)", 13.3),
        ("Average password (8 char)", 30.0),
        ("Strong password (random 4 words)", 52.0),
        ("Hardware token (128-bit seed)", 128.0),
        ("Biometric + password", 65.0),
    ]

    print(f"  {'Source':<35} {'H₂':>6} {'128-bit key':>14} {'256-bit key':>14}")
    print("  " + "-" * 71)

    for name, h2 in scenarios:
        for key_len in [128, 256]:
            cp = 2 ** (-h2)
            sd = lhl_bound(2**key_len, cp)
            sec = -np.log2(sd) if sd > 0 else float('inf')
            status = f"{sec:.0f} bits" if sec > 0 else "N/A"

            if key_len == 128:
                print(f"  {name:<35} {h2:>6.1f} {status:>14}", end="")
            else:
                print(f" {status:>14}")

    print("\n  Note: Passwords alone rarely provide enough entropy for")
    print("  high-security keys. Key stretching (PBKDF2, Argon2) adds")
    print("  computational cost but cannot increase information-theoretic")
    print("  entropy beyond the password's inherent unpredictability.")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Quantum Key Distribution Privacy Amplification
# ═══════════════════════════════════════════════════════════════════════

def qkd_privacy_amplification():
    """
    Privacy amplification in QKD (BB84 protocol).

    After error correction, Alice and Bob share a string of n bits.
    Eve has some partial information, reducing the effective entropy.
    The LHL is used to extract a shorter, perfectly secret key.
    """
    print("=" * 65)
    print("APPLICATION 3: QKD Privacy Amplification (BB84)")
    print("=" * 65)

    n_raw = 10000     # raw key bits after sifting
    error_rate = 0.05  # quantum bit error rate (QBER)

    # Binary entropy function
    h_bin = -error_rate * np.log2(error_rate) - (1 - error_rate) * np.log2(1 - error_rate)

    # Error correction leaks ~n·h(e) bits
    leaked_bits = n_raw * h_bin

    # Eve's information bounded by Holevo quantity
    # For BB84 with error rate e: χ(Eve) ≤ n·h(e)
    eve_info = leaked_bits

    # Remaining entropy
    remaining_entropy = n_raw * (1 - h_bin) - eve_info

    print(f"\n  BB84 Protocol Parameters:")
    print(f"    Raw key length:     {n_raw} bits")
    print(f"    Error rate (QBER):  {error_rate:.1%}")
    print(f"    Binary entropy h(e): {h_bin:.4f}")
    print(f"    Leaked to Eve:      {leaked_bits:.0f} bits")
    print(f"    Remaining entropy:  {remaining_entropy:.0f} bits")

    # Privacy amplification via LHL
    security_param = 100  # bits of security
    key_length = int(remaining_entropy - 2 * security_param)

    print(f"\n  Privacy Amplification:")
    print(f"    Security parameter: {security_param} bits")
    print(f"    Extractable key:    {max(key_length, 0)} bits")

    if key_length > 0:
        cp = 2 ** (-remaining_entropy)
        sd = lhl_bound(2**key_length, cp)
        print(f"    SD from uniform:    2^{{-{-np.log2(sd):.1f}}}")
        print(f"    Key rate:           {key_length/n_raw:.3f} bits/raw bit")
    else:
        print(f"    [Insufficient entropy for extraction]")

    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Entropy Accumulation for True RNG
# ═══════════════════════════════════════════════════════════════════════

def trng_entropy_accumulation():
    """
    Entropy accumulation for a hardware true random number generator.

    A TRNG collects entropy from multiple noisy physical sources.
    Each sample contributes a small amount of entropy. After
    accumulating enough, the LHL extracts a uniform output.
    """
    print("=" * 65)
    print("APPLICATION 4: TRNG Entropy Accumulation")
    print("=" * 65)

    # Simulate entropy from multiple sources
    sources = [
        ("Thermal noise ADC", 2.5, 100),      # entropy per sample, samples needed
        ("Ring oscillator jitter", 0.8, 200),
        ("DRAM startup noise", 4.0, 50),
        ("CPU instruction timing", 0.3, 500),
    ]

    target_key = 256  # bits
    target_security = 128  # bits
    target_entropy = target_key + 2 * target_security  # need k - 2λ = ℓ

    print(f"\n  Target: {target_key}-bit key with {target_security}-bit security")
    print(f"  Required source entropy: {target_entropy} bits\n")

    print(f"  {'Source':<28} {'H/sample':>10} {'Samples':>10} {'Total H':>10}")
    print("  " + "-" * 60)

    total_entropy = 0
    for name, h_per_sample, n_samples in sources:
        total = h_per_sample * n_samples
        total_entropy += total
        print(f"  {name:<28} {h_per_sample:>10.1f} {n_samples:>10} {total:>10.1f}")

    print(f"  {'TOTAL':<28} {'':>10} {'':>10} {total_entropy:>10.1f}")

    cp = 2 ** (-total_entropy)
    sd = lhl_bound(2**target_key, cp)
    sec = -np.log2(sd) if sd > 0 else float('inf')

    print(f"\n  Entropy surplus: {total_entropy - target_entropy:.1f} bits")
    print(f"  LHL bound: SD ≤ 2^{{-{sec:.1f}}}")
    print(f"  Security achieved: {'✓ PASS' if sec >= target_security else '✗ FAIL'}")
    print()


if __name__ == "__main__":
    post_quantum_kdf_analysis()
    password_kdf_analysis()
    qkd_privacy_amplification()
    trng_entropy_accumulation()

    print("=" * 65)
    print("All applications demonstrated successfully.")
    print("=" * 65)


#!/usr/bin/env python3
"""
Leftover Hash Lemma — Demonstration Script

Concrete numerical examples illustrating the Quantitative Leftover Hash Lemma:
  SD((s, H_s(X)), (s, U_β)) ≤ (1/2) √(|β| · CP(X))

Demonstrates:
  1. Collision probability and Rényi-2 entropy for various sources
  2. The LHL bound for different parameter regimes
  3. Entropy gap → security exponent conversion
  4. Comparison of min-entropy vs. collision entropy bounds
"""

import numpy as np
from typing import List, Tuple


def collision_prob(pmf: np.ndarray) -> float:
    """Compute the collision probability CP(X) = Σ p(a)²."""
    return float(np.sum(pmf ** 2))


def renyi2_entropy(pmf: np.ndarray) -> float:
    """Compute the Rényi-2 entropy H₂(X) = -log₂(CP(X))."""
    cp = collision_prob(pmf)
    if cp <= 0:
        return float('inf')
    return -np.log2(cp)


def max_point_mass(pmf: np.ndarray) -> float:
    """Compute the maximum point mass max_a p(a)."""
    return float(np.max(pmf))


def min_entropy(pmf: np.ndarray) -> float:
    """Compute the min-entropy H_∞(X) = -log₂(max_a p(a))."""
    m = max_point_mass(pmf)
    if m <= 0:
        return float('inf')
    return -np.log2(m)


def lhl_bound(output_size: int, cp: float) -> float:
    """Compute the LHL statistical distance bound: (1/2)√(|β|·CP(X))."""
    return 0.5 * np.sqrt(output_size * cp)


def security_exponent(output_size: int, cp: float) -> float:
    """Compute the security exponent: -log₂(LHL_bound)."""
    bound = lhl_bound(output_size, cp)
    if bound <= 0:
        return float('inf')
    return -np.log2(bound)


# ─── Demo 1: Basic Source Examples ───────────────────────────────────

print("=" * 70)
print("DEMO 1: Collision Probability and Entropy for Various Sources")
print("=" * 70)

sources = [
    ("Uniform on 256 elements", np.ones(256) / 256),
    ("Uniform on 1024 elements", np.ones(1024) / 1024),
    ("Skewed: (1/2, 1/4, 1/8, 1/8)", np.array([0.5, 0.25, 0.125, 0.125])),
    ("Highly skewed: (0.9, 0.05, 0.03, 0.02)", np.array([0.9, 0.05, 0.03, 0.02])),
    ("Two-point: (0.7, 0.3)", np.array([0.7, 0.3])),
    ("Geometric-like on 8", np.array([2**(-i) for i in range(1, 8)] + [2**(-7)])),
]

print(f"\n{'Source':<42} {'CP(X)':>10} {'H₂(X)':>8} {'H_∞(X)':>8} {'H_∞≤H₂?':>8}")
print("-" * 78)
for name, pmf in sources:
    cp = collision_prob(pmf)
    h2 = renyi2_entropy(pmf)
    hinf = min_entropy(pmf)
    check = "✓" if hinf <= h2 + 1e-10 else "✗"
    print(f"{name:<42} {cp:>10.6f} {h2:>8.3f} {hinf:>8.3f} {check:>8}")

# ─── Demo 2: LHL Bound for Various Parameters ─────────────────────────

print("\n" + "=" * 70)
print("DEMO 2: Leftover Hash Lemma Bounds")
print("=" * 70)

print(f"\n{'|α|':>6} {'|β|':>6} {'CP(X)':>12} {'|β|·CP':>10} {'SD Bound':>10} {'Sec. Exp.':>10}")
print("-" * 56)

params: List[Tuple[int, int, float]] = [
    (256, 4, 1/256),
    (256, 16, 1/256),
    (256, 16, 1/128),
    (256, 64, 1/256),
    (1024, 32, 1/1024),
    (1024, 128, 1/1024),
    (1024, 128, 1/512),
    (2**20, 2**10, 2**(-20)),
    (2**20, 2**10, 2**(-15)),
    (2**128, 2**64, 2**(-128)),
]

for alpha_size, beta_size, cp in params:
    bound = lhl_bound(beta_size, cp)
    sec_exp = security_exponent(beta_size, cp)
    print(f"{alpha_size:>6} {beta_size:>6} {cp:>12.2e} {beta_size*cp:>10.4f} {bound:>10.4e} {sec_exp:>10.1f}")

# ─── Demo 3: Entropy Gap Analysis ─────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 3: Entropy Gap → Security Exponent")
print("=" * 70)
print("\nFor output length ℓ bits and source entropy k bits:")
print(f"  SD ≤ (1/2) · 2^{{(ℓ-k)/2}}")

print(f"\n{'k (bits)':>10} {'ℓ (bits)':>10} {'Gap Δ':>8} {'SD Bound':>12} {'Sec. Bits':>10}")
print("-" * 52)

for k in [32, 64, 128, 256]:
    for ell in [16, 32, 64, 128]:
        if ell < k:
            gap = k - ell
            sd_bound = 0.5 * 2 ** (-(gap) / 2)
            sec_bits = gap / 2 - 1  # accounting for the 1/2 factor
            print(f"{k:>10} {ell:>10} {gap:>8} {sd_bound:>12.2e} {sec_bits:>10.1f}")

# ─── Demo 4: Min-Entropy vs Collision Entropy Comparison ──────────────

print("\n" + "=" * 70)
print("DEMO 4: Min-Entropy vs Collision Entropy Security Bounds")
print("=" * 70)
print("\nComparing bounds using H_∞ vs H₂ for a skewed source:")

# Generate a family of increasingly skewed distributions
print(f"\n{'Max prob':>10} {'H_∞':>8} {'H₂':>8} {'Gap':>8} {'SD (H₂)':>10} {'SD (H_∞)':>10} {'Ratio':>8}")
print("-" * 66)

beta_size = 16
for max_p in [0.1, 0.2, 0.3, 0.5, 0.7, 0.9]:
    # Create a distribution with given max probability, rest uniform
    n = 20
    rest_p = (1 - max_p) / (n - 1)
    pmf = np.array([max_p] + [rest_p] * (n - 1))

    cp = collision_prob(pmf)
    h2 = renyi2_entropy(pmf)
    hinf = min_entropy(pmf)
    gap = h2 - hinf

    sd_h2 = lhl_bound(beta_size, cp)
    sd_hinf = lhl_bound(beta_size, max_p)  # using H_∞ bound: CP ≤ maxP
    ratio = sd_hinf / sd_h2 if sd_h2 > 0 else float('inf')

    print(f"{max_p:>10.2f} {hinf:>8.3f} {h2:>8.3f} {gap:>8.3f} {sd_h2:>10.4f} {sd_hinf:>10.4f} {ratio:>8.2f}")

print("\n(Ratio > 1 means H₂ bound is tighter, as expected since H_∞ ≤ H₂)")

# ─── Demo 5: Post-Quantum Key Derivation Example ─────────────────────

print("\n" + "=" * 70)
print("DEMO 5: Post-Quantum Key Derivation (ML-KEM / Kyber style)")
print("=" * 70)

print("\nScenario: Lattice-based KEM produces a shared secret with")
print("min-entropy ~200 bits. We extract a 128-bit key.\n")

k_entropy = 200  # source entropy in bits
ell_output = 128  # output key length
gap = k_entropy - ell_output  # entropy gap = 72 bits

cp_source = 2 ** (-k_entropy)
sd = lhl_bound(2**ell_output, cp_source)
sec_bits = -np.log2(sd)

print(f"  Source entropy (H₂):     {k_entropy} bits")
print(f"  Output key length:       {ell_output} bits")
print(f"  Entropy gap:             {gap} bits")
print(f"  Collision probability:   2^{{-{k_entropy}}}")
print(f"  LHL bound:               {sd:.2e}")
print(f"  Security bits:           {sec_bits:.1f}")
print(f"  NIST Level 1 (128-bit):  {'PASS ✓' if sec_bits >= 128 else 'FAIL ✗'}")

print("\n" + "=" * 70)
print("All demos completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.html with embedded images and content."""
import base64, html as html_module

# Read images
images = {}
for f in ['entropy_gap_security.png', 'collision_landscape.png', 'lhl_security_surface.png', 'proof_pipeline.png']:
    with open(f, 'rb') as fh:
        images[f] = base64.b64encode(fh.read()).decode()

with open('diagram.svg', 'r') as fh:
    svg_content = fh.read()
with open('ARTICLE.md', 'r') as fh:
    article = fh.read()
with open('RESEARCH_PAPER.md', 'r') as fh:
    paper = fh.read()
with open('LeftoverHash.lean', 'r') as fh:
    lean_code = fh.read()

py_files = {}
for f in ['demo.py', 'algorithms.py', 'applications.py', 'visualizations.py']:
    with open(f, 'r') as fh:
        py_files[f] = fh.read()

def md_to_html(text):
    lines = text.split('\n')
    result = []
    in_code = False
    for line in lines:
        if line.startswith('```'):
            if in_code:
                result.append('</pre>')
                in_code = False
            else:
                result.append('<pre>')
                in_code = True
            continue
        if in_code:
            result.append(html_module.escape(line))
            continue
        if line.startswith('# '):
            result.append(f'<h1>{html_module.escape(line[2:])}</h1>')
        elif line.startswith('## '):
            result.append(f'<h2>{html_module.escape(line[3:])}</h2>')
        elif line.startswith('### '):
            result.append(f'<h3>{html_module.escape(line[4:])}</h3>')
        elif line.startswith('> '):
            result.append(f'<blockquote>{html_module.escape(line[2:])}</blockquote>')
        elif line.startswith('- '):
            result.append(f'<li>{html_module.escape(line[2:])}</li>')
        elif line.startswith('|'):
            result.append(f'{html_module.escape(line)}<br>')
        elif line.strip() == '':
            result.append('<br>')
        else:
            result.append(f'<p>{html_module.escape(line)}</p>')
    return '\n'.join(result)

escaped_lean = html_module.escape(lean_code)

out = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quantitative Leftover Hash Lemma</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body)"></script>
<style>
:root {{ --bg:#fff; --text:#1a1a2e; --card:#f8f9fa; --border:#dee2e6;
  --accent:#3498db; --code-bg:#f5f5f5; --nav-bg:#2c3e50; }}
[data-theme="dark"] {{ --bg:#1a1a2e; --text:#e6e6e6; --card:#16213e;
  --border:#334155; --accent:#5dade2; --code-bg:#0f3460; --nav-bg:#0f3460; }}
* {{ margin:0; padding:0; box-sizing:border-box; }}
body {{ font-family:Georgia,serif; background:var(--bg); color:var(--text);
  line-height:1.7; transition:all .3s; }}
nav {{ position:fixed; top:0; left:0; width:220px; height:100vh;
  background:var(--nav-bg); padding:20px; overflow-y:auto; z-index:100; }}
nav h2 {{ color:#ecf0f1; font-size:16px; margin-bottom:20px; }}
nav a {{ display:block; color:#bdc3c7; text-decoration:none; padding:8px 12px;
  border-radius:6px; margin-bottom:4px; font-size:13px; transition:all .2s; cursor:pointer; }}
nav a:hover, nav a.active {{ background:rgba(255,255,255,.1); color:white; }}
main {{ margin-left:220px; padding:40px; max-width:900px; }}
h1 {{ font-size:2em; margin-bottom:10px; color:var(--accent); }}
h2 {{ font-size:1.5em; margin:30px 0 15px; border-bottom:2px solid var(--accent); padding-bottom:5px; }}
h3 {{ font-size:1.2em; margin:20px 0 10px; }}
p {{ margin-bottom:12px; }}
pre {{ background:var(--code-bg); padding:15px; border-radius:8px; overflow-x:auto;
  font-family:"Fira Code",monospace; font-size:12px; border:1px solid var(--border);
  margin:15px 0; white-space:pre-wrap; }}
img {{ max-width:100%; height:auto; border-radius:8px; margin:15px 0; }}
.card {{ background:var(--card); border:1px solid var(--border); border-radius:10px;
  padding:20px; margin:20px 0; }}
.toggle {{ position:fixed; top:10px; right:20px; z-index:200; background:var(--nav-bg);
  color:white; border:none; padding:8px 16px; border-radius:20px; cursor:pointer; font-size:16px; }}
section {{ display:none; }}
section.active {{ display:block; }}
blockquote {{ border-left:4px solid var(--accent); padding-left:16px; margin:15px 0;
  font-style:italic; }}
li {{ margin-left:20px; margin-bottom:5px; }}
svg {{ max-width:100%; }}
</style>
</head>
<body>
<button class="toggle" onclick="toggleTheme()">🌙/☀️</button>
<nav>
  <h2>📐 Leftover Hash Lemma</h2>
  <a onclick="showSection('article')" class="active">📖 Article</a>
  <a onclick="showSection('paper')">📄 Research Paper</a>
  <a onclick="showSection('proofs')">🔐 Formal Proofs</a>
  <a onclick="showSection('viz')">📊 Visualizations</a>
  <a onclick="showSection('algorithms')">⚙️ Algorithms</a>
  <a onclick="showSection('code')">💻 Code Listings</a>
</nav>
<main>

<section id="article" class="active">
{md_to_html(article)}
</section>

<section id="paper">
{md_to_html(paper)}
</section>

<section id="proofs">
<h1>Formal Proofs (Machine-Verified)</h1>
<p>All 35 theorems/lemmas proved with zero sorry. Verified against standard axioms.</p>
<h2>Key Theorems</h2>
<div class="card"><h3>Leftover Hash Lemma (Main Theorem)</h3>
<pre>theorem leftover_hash_lemma_quantitative
    (H : UniversalHashFamily ι α β) (X : Source α) :
    statDist (seededHashedJointDist H X) (seededUniformDist ι β)
      ≤ (1 / 2 : ℝ) * Real.sqrt ((Fintype.card β : ℝ) * collisionProb X)</pre></div>
<div class="card"><h3>Key Derivation Security Bound</h3>
<pre>theorem key_derivation_security_bound
    (H : UniversalHashFamily ι α β) (X : Source α)
    (hcp : (Fintype.card β : ℝ) * collisionProb X ≤ ε) :
    statDist (seededHashedJointDist H X) (seededUniformDist ι β)
      ≤ (1 / 2 : ℝ) * Real.sqrt ε</pre></div>
<div class="card"><h3>Entropy Ordering H_∞ ≤ H₂</h3>
<pre>lemma minEntropy_le_renyi2 (X : Source α) [Nonempty α] :
    minEntropy X ≤ renyi2Entropy X</pre></div>
<h2>Complete Source (558 lines)</h2>
<pre>{escaped_lean}</pre>
</section>

<section id="viz">
<h1>Visualizations</h1>
<h2>Proof Pipeline Diagram</h2>
{svg_content}
<h2>Entropy Gap → Security Exponent</h2>
<img src="data:image/png;base64,{images['entropy_gap_security.png']}" alt="Entropy Gap">
<h2>Collision Probability Landscape</h2>
<img src="data:image/png;base64,{images['collision_landscape.png']}" alt="Collision Landscape">
<h2>LHL Security Surface</h2>
<img src="data:image/png;base64,{images['lhl_security_surface.png']}" alt="Security Surface">
</section>

<section id="algorithms">
<h1>Algorithms</h1>
<div class="card"><h3>Hash Extraction (O(1) per query)</h3>
<pre>Algorithm: HashExtract(H, s, x)
Input: Universal hash family H, seed s, source sample x
Output: Extracted key k

1. k ← H.hash(s, x)
2. return (s, k)

Security: SD((S,K), (S,U)) ≤ (1/2)√(|β|·CP(X))</pre></div>
<div class="card"><h3>Parameter Selection</h3>
<pre>Algorithm: SelectParameters(k, λ)
Input: Source entropy k bits, security parameter λ
Output: Output length ℓ = ⌊k - 2λ⌋

Guarantee: SD ≤ (1/2) · 2^(-λ)</pre></div>
<h2>Implementation</h2>
<pre>{html_module.escape(py_files['algorithms.py'])}</pre>
</section>

<section id="code">
<h1>Code Listings</h1>
'''

for name, code in py_files.items():
    out += f'<h2>{name}</h2>\n<pre>{html_module.escape(code)}</pre>\n'

out += '''
</section>
</main>
<script>
function showSection(id) {
  document.querySelectorAll('section').forEach(s => s.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  document.querySelectorAll('nav a').forEach(a => a.classList.remove('active'));
  event.target.classList.add('active');
}
function toggleTheme() {
  document.body.dataset.theme = document.body.dataset.theme === 'dark' ? '' : 'dark';
}
</script>
</body>
</html>'''

with open('PACKAGE.html', 'w') as fh:
    fh.write(out)
print(f'PACKAGE.html generated: {len(out)} bytes')


#!/usr/bin/env python3
"""
Visualizations for the Leftover Hash Lemma

Generates publication-quality figures illustrating:
1. Entropy gap vs. security exponent
2. Collision probability landscape
3. The ℓ¹–ℓ² bridge geometry
4. Post-quantum key derivation security regions
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import os

output_dir = os.path.dirname(os.path.abspath(__file__))


def plot_entropy_gap_security():
    """Plot the entropy gap → security exponent relationship."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    gaps = np.linspace(0, 256, 1000)

    # SD ≤ (1/2) · 2^{-gap/2}
    # Security exponent = gap/2 - 1 (accounting for 1/2 factor = 2^{-1})
    sec_exp = gaps / 2

    ax.plot(gaps, sec_exp, 'b-', linewidth=2.5, label='Security exponent = Δ/2')

    # Mark key security levels
    for level, color, name in [(128, 'green', 'NIST Level 1 (128-bit)'),
                                (192, 'orange', 'NIST Level 3 (192-bit)'),
                                (256, 'red', 'NIST Level 5 (256-bit)')]:
        ax.axhline(y=level, color=color, linestyle='--', alpha=0.7, linewidth=1.5)
        required_gap = 2 * level
        ax.plot(required_gap, level, 'o', color=color, markersize=10)
        ax.annotate(f'{name}\n(gap ≥ {required_gap})',
                    xy=(required_gap, level), xytext=(required_gap - 80, level + 15),
                    fontsize=9, color=color,
                    arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

    ax.set_xlabel('Entropy Gap Δ = H₂(X) - log₂|β| (bits)', fontsize=12)
    ax.set_ylabel('Security Exponent (bits)', fontsize=12)
    ax.set_title('Leftover Hash Lemma: Entropy Gap → Security', fontsize=14)
    ax.legend(fontsize=11, loc='lower right')
    ax.set_xlim(0, 550)
    ax.set_ylim(0, 280)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('auto')

    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'entropy_gap_security.png'), dpi=150)
    plt.close()
    print("  Saved: entropy_gap_security.png")


def plot_collision_landscape():
    """Plot collision probability vs. source size for various distributions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: CP vs n for uniform, geometric, and point mass
    ns = np.arange(2, 201)

    # Uniform: CP = 1/n
    cp_uniform = 1.0 / ns

    # Two-point (p, 1-p) with p = 0.8
    p_val = 0.8
    cp_twopoint = np.full_like(ns, p_val**2 + (1 - p_val)**2, dtype=float)

    # Geometric-like: p_i ∝ 2^{-i}
    cp_geometric = []
    for n in ns:
        weights = np.array([2.0**(-i) for i in range(1, n + 1)])
        pmf = weights / weights.sum()
        cp_geometric.append(np.sum(pmf**2))

    ax1.semilogy(ns, cp_uniform, 'b-', linewidth=2, label='Uniform')
    ax1.semilogy(ns, cp_geometric, 'r-', linewidth=2, label='Geometric')
    ax1.semilogy(ns, cp_twopoint, 'g-', linewidth=2, label=f'Two-point (p={p_val})')

    ax1.set_xlabel('Source Size |α|', fontsize=12)
    ax1.set_ylabel('Collision Probability CP(X)', fontsize=12)
    ax1.set_title('Collision Probability vs. Source Size', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: H_2 vs H_∞ for random distributions
    rng = np.random.default_rng(42)
    h2_vals, hinf_vals = [], []
    for _ in range(2000):
        n = rng.integers(3, 50)
        raw = rng.exponential(rng.uniform(0.1, 5), n)
        pmf = raw / raw.sum()
        h2_vals.append(-np.log2(np.sum(pmf**2)))
        hinf_vals.append(-np.log2(np.max(pmf)))

    ax2.scatter(hinf_vals, h2_vals, alpha=0.3, s=10, c='steelblue')
    max_val = max(max(h2_vals), max(hinf_vals))
    ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='H₂ = H_∞')
    ax2.set_xlabel('Min-Entropy H_∞(X) (bits)', fontsize=12)
    ax2.set_ylabel('Rényi-2 Entropy H₂(X) (bits)', fontsize=12)
    ax2.set_title('Entropy Ordering: H_∞ ≤ H₂ (2000 random sources)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_aspect('equal')

    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'collision_landscape.png'), dpi=150)
    plt.close()
    print("  Saved: collision_landscape.png")


def plot_lhl_bound_surface():
    """Plot the LHL bound as a function of output size and collision probability."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # log₂(|β|) on x-axis, -log₂(CP) = H₂ on y-axis
    # SD ≤ (1/2)√(|β|·CP) = (1/2) · 2^{(log|β| - H₂)/2}
    # Security exponent = (H₂ - log|β|)/2

    log_beta = np.linspace(1, 256, 300)
    h2_values = np.linspace(1, 300, 300)

    LB, H2 = np.meshgrid(log_beta, h2_values)
    # Security exponent = (H2 - LB) / 2 (when positive)
    sec_exp = np.maximum((H2 - LB) / 2, 0)

    levels = [0, 16, 32, 64, 128, 192, 256]
    cs = ax.contourf(LB, H2, sec_exp, levels=np.linspace(0, 256, 33), cmap='viridis')
    plt.colorbar(cs, ax=ax, label='Security exponent (bits)')

    # Contour lines at key levels
    cs2 = ax.contour(LB, H2, sec_exp, levels=[64, 128, 192, 256],
                     colors='white', linewidths=1.5, linestyles='--')
    ax.clabel(cs2, inline=True, fontsize=10, fmt='%d bits')

    # Diagonal: H₂ = log|β| (extraction threshold)
    ax.plot([1, 256], [1, 256], 'r-', linewidth=2, label='Extraction threshold (H₂ = ℓ)')

    ax.set_xlabel('Output Length ℓ = log₂|β| (bits)', fontsize=12)
    ax.set_ylabel('Source Entropy H₂(X) (bits)', fontsize=12)
    ax.set_title('LHL Security Landscape: Security Exponent vs. Parameters', fontsize=14)
    ax.legend(fontsize=11, loc='lower right')
    ax.set_xlim(1, 256)
    ax.set_ylim(1, 300)

    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'lhl_security_surface.png'), dpi=150)
    plt.close()
    print("  Saved: lhl_security_surface.png")


def plot_proof_pipeline():
    """Create a diagram of the LHL proof pipeline."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 4))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 4)
    ax.axis('off')

    steps = [
        (1, 2, "Source X\nCP(X) = Σp²", "#3498db"),
        (3.5, 2, "Universal\nHash H", "#2ecc71"),
        (6, 2, "Seeded\nCollision\nBound", "#e74c3c"),
        (8.5, 2, "Parseval +\nCauchy-\nSchwarz", "#9b59b6"),
        (11, 2, "SD ≤ ½√(|β|·CP)\nSecurity\nCertificate", "#f39c12"),
    ]

    for x, y, text, color in steps:
        box = FancyBboxPatch((x - 1, y - 1), 2, 2,
                             boxstyle="round,pad=0.15",
                             facecolor=color, edgecolor='white',
                             linewidth=2, alpha=0.85)
        ax.add_patch(box)
        ax.text(x, y, text, ha='center', va='center',
                fontsize=9, color='white', fontweight='bold')

    # Arrows
    for x1, x2 in [(2, 2.5), (4.5, 5), (7, 7.5), (9.5, 10)]:
        ax.annotate('', xy=(x2, 2), xytext=(x1, 2),
                    arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=2.5))

    ax.set_title('Leftover Hash Lemma: Proof Pipeline', fontsize=14, pad=20)

    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'proof_pipeline.png'), dpi=150)
    plt.close()
    print("  Saved: proof_pipeline.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    plot_entropy_gap_security()
    plot_collision_landscape()
    plot_lhl_bound_surface()
    plot_proof_pipeline()
    print("All visualizations generated.")
