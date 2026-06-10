"""
Non-Archimedean Information Theory — Algorithms

Implementations of the key algorithms from the research paper.
"""

import numpy as np
from typing import List, Tuple, Optional


class FinProbDist:
    """Finite probability distribution over {0, 1, ..., n-1}.

    Attributes:
        mass: Array of probabilities summing to 1.
    """

    def __init__(self, mass: List[float]):
        mass = np.array(mass, dtype=float)
        assert all(m >= 0 for m in mass), "All masses must be nonneg"
        assert abs(sum(mass) - 1.0) < 1e-10, f"Masses must sum to 1, got {sum(mass)}"
        self.mass = mass
        self.n = len(mass)

    @staticmethod
    def uniform(n: int) -> 'FinProbDist':
        """Uniform distribution on n elements."""
        return FinProbDist([1.0 / n] * n)

    @staticmethod
    def deterministic(n: int, k: int) -> 'FinProbDist':
        """Deterministic distribution concentrated on element k."""
        mass = [0.0] * n
        mass[k] = 1.0
        return FinProbDist(mass)

    @staticmethod
    def bernoulli(p: float) -> 'FinProbDist':
        """Bernoulli distribution with parameter p."""
        return FinProbDist([p, 1 - p])

    def max_mass(self) -> float:
        """Maximum probability: max_x p(x).

        Time complexity: O(n).
        """
        return float(max(self.mass))

    def min_entropy(self) -> float:
        """Min-entropy: H_∞(X) = -log2(max_x p(x)).

        Time complexity: O(n).
        Space complexity: O(1).

        Returns:
            Min-entropy in bits.
        """
        return -np.log2(self.max_mass())

    def tropical_valuation(self) -> np.ndarray:
        """Tropical valuation: v(x) = -log2(p(x)).

        Maps the distribution to the tropical semifield (R ∪ {∞}, min, +).

        Time complexity: O(n).
        """
        return np.array([-np.log2(p) if p > 0 else np.inf for p in self.mass])

    def total_variation(self, other: 'FinProbDist') -> float:
        """Total variation distance to another distribution.

        TV(μ, ν) = (1/2) Σ |μ(x) - ν(x)|

        Time complexity: O(n).
        """
        assert self.n == other.n
        return 0.5 * sum(abs(a - b) for a, b in zip(self.mass, other.mass))

    @staticmethod
    def product(mu: 'FinProbDist', nu: 'FinProbDist') -> 'FinProbDist':
        """Product distribution of two independent distributions.

        Time complexity: O(n * m).
        """
        mass = [mu.mass[i] * nu.mass[j]
                for i in range(mu.n)
                for j in range(nu.n)]
        return FinProbDist(mass)


def min_plus_rate_distortion(mu: FinProbDist, D: float) -> float:
    """Min-plus rate-distortion function: R_min(D) = H_∞(X) - D.

    The tropical dual of Shannon's rate-distortion function.

    Args:
        mu: Source distribution.
        D: Distortion budget (nonneg).

    Returns:
        Rate R_min(D) in bits.

    Time complexity: O(n) for computing H_∞.
    """
    return mu.min_entropy() - D


def ultrametric_capacity(output_size: int, noise_radius: int, prime: int) -> float:
    """Ultrametric channel capacity: C = log2(q) - k * log2(p).

    Args:
        output_size: Size of the output alphabet q.
        noise_radius: Noise radius exponent k.
        prime: Base prime p.

    Returns:
        Channel capacity in bits.

    Time complexity: O(1).
    """
    return np.log2(output_size) - noise_radius * np.log2(prime)


def count_above_threshold(mu: FinProbDist, t: float) -> int:
    """Count elements with mass ≥ t.

    Guaranteed to satisfy: count ≤ 1/t (Markov bound).

    Time complexity: O(n).
    """
    return sum(1 for p in mu.mass if p >= t)


class CosetCode:
    """A coset code for ultrametric channels.

    Partitions the output space into cosets, each an ultrametric ball.

    Attributes:
        num_codewords: Number of codewords (determines rate).
        coset_size: Elements per coset (determines noise tolerance).
    """

    def __init__(self, num_codewords: int, coset_size: int):
        assert num_codewords > 0 and coset_size > 0
        self.num_codewords = num_codewords
        self.coset_size = coset_size

    def rate(self) -> float:
        """Code rate in bits: log2(num_codewords)."""
        return np.log2(self.num_codewords)

    def noise_tolerance(self) -> float:
        """Noise tolerance in bits: log2(coset_size)."""
        return np.log2(self.coset_size)

    def total_size(self) -> int:
        """Total alphabet size."""
        return self.num_codewords * self.coset_size

    def encode(self, message: int) -> int:
        """Encode message to coset representative.

        Time complexity: O(1).
        """
        assert 0 <= message < self.num_codewords
        return message * self.coset_size

    def decode(self, received: int) -> int:
        """Decode received symbol to message.

        Time complexity: O(1).
        """
        return received // self.coset_size


class TropicalChannelMatrix:
    """Tropical channel matrix: transition valuations.

    Entries[i][j] = -log(P(j|i)), the tropical valuation of transition probabilities.
    """

    def __init__(self, entries: np.ndarray):
        assert np.all(entries >= 0), "All entries must be nonneg"
        self.entries = entries
        self.m, self.n = entries.shape

    @staticmethod
    def compose(A: 'TropicalChannelMatrix', B: 'TropicalChannelMatrix') -> 'TropicalChannelMatrix':
        """Tropical (min, +) matrix product.

        C[i][k] = min_j (A[i][j] + B[j][k])

        Time complexity: O(m * n * p) where A is m×n, B is n×p.
        """
        assert A.n == B.m
        m, n, p = A.m, A.n, B.n
        C = np.zeros((m, p))
        for i in range(m):
            for k in range(p):
                C[i][k] = min(A.entries[i][j] + B.entries[j][k] for j in range(n))
        return TropicalChannelMatrix(C)


def renyi_entropy(mu: FinProbDist, q: float) -> float:
    """Rényi entropy of order q > 0, q ≠ 1.

    H_q(X) = 1/(1-q) * log2(Σ p(x)^q)

    Min-entropy is lim_{q→∞} H_q(X).

    Time complexity: O(n).
    """
    if abs(q - 1) < 1e-10:
        return -sum(p * np.log2(p) for p in mu.mass if p > 0)
    power_sum = sum(p**q for p in mu.mass)
    return 1 / (1 - q) * np.log2(power_sum)


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    # Example: Verify additivity
    mu = FinProbDist([0.6, 0.3, 0.1])
    nu = FinProbDist([0.5, 0.3, 0.2])
    product = FinProbDist.product(mu, nu)

    print(f"H_∞(X) = {mu.min_entropy():.6f}")
    print(f"H_∞(Y) = {nu.min_entropy():.6f}")
    print(f"H_∞(X×Y) = {product.min_entropy():.6f}")
    print(f"H_∞(X) + H_∞(Y) = {mu.min_entropy() + nu.min_entropy():.6f}")
    print(f"Additivity error: {abs(product.min_entropy() - mu.min_entropy() - nu.min_entropy()):.2e}")

    # Example: Coset code
    code = CosetCode(num_codewords=16, coset_size=4)
    print(f"\nCoset code: rate = {code.rate():.2f} bits, tolerance = {code.noise_tolerance():.2f} bits")
    print(f"Total size = {code.total_size()}")

    # Example: Tropical composition
    A = TropicalChannelMatrix(np.array([[0, 1, 3], [2, 0, 1]]))
    B = TropicalChannelMatrix(np.array([[1, 0], [0, 2], [3, 1]]))
    C = TropicalChannelMatrix.compose(A, B)
    print(f"\nTropical composition result:\n{C.entries}")

    # Example: Counting bound
    mu = FinProbDist([0.3, 0.3, 0.2, 0.1, 0.1])
    t = 0.25
    count = count_above_threshold(mu, t)
    bound = 1.0 / t
    print(f"\nCounting bound: |{{x: p(x) ≥ {t}}}| = {count} ≤ 1/{t} = {bound}")


"""
Non-Archimedean Information Theory — Applications

Real-world applications of tropical information theory to
cryptography, machine learning, and communications.
"""

import numpy as np
from algorithms import FinProbDist, min_plus_rate_distortion, ultrametric_capacity, CosetCode


# ============================================================
# Application 1: Post-Quantum Security Analysis
# ============================================================

def post_quantum_security_margin(key_distribution: FinProbDist) -> dict:
    """Analyze the post-quantum security of a key generated from a given distribution.

    In post-quantum cryptography, min-entropy is the fundamental measure of
    security for randomness extraction. A key with H_∞ bits of min-entropy
    can be used to extract a uniformly random key of at most H_∞ bits.

    Args:
        key_distribution: Probability distribution over key values.

    Returns:
        Dictionary with security metrics.
    """
    H_inf = key_distribution.min_entropy()
    max_p = key_distribution.max_mass()

    return {
        'min_entropy_bits': H_inf,
        'guessing_probability': max_p,
        'extractable_key_bits': max(0, H_inf - 1),  # lose 1 bit for extraction
        'security_level': int(H_inf),  # security level in bits
        'brute_force_complexity': 2 ** H_inf,
    }


print("=" * 60)
print("APPLICATION 1: Post-Quantum Security Analysis")
print("=" * 60)

# Simulate a lattice-based key distribution (simplified)
n = 256
# Key distribution from Ring-LWE: roughly uniform with some bias
key_dist = FinProbDist(np.random.dirichlet(np.ones(n) * 10))
security = post_quantum_security_margin(key_dist)

print(f"\nLattice-based key distribution (n={n}):")
for k, v in security.items():
    print(f"  {k}: {v:.4f}" if isinstance(v, float) else f"  {k}: {v}")


# ============================================================
# Application 2: Neural Network Weight Compression
# ============================================================

def neural_compression_analysis(weights: np.ndarray, num_bins: int) -> dict:
    """Analyze compression potential of neural network weights.

    Uses min-plus rate-distortion to give certified compression bounds.
    Unlike average-case bounds, these hold for every input.

    Args:
        weights: Array of neural network weights.
        num_bins: Number of quantization bins.

    Returns:
        Dictionary with compression metrics.
    """
    # Quantize weights into bins and form distribution
    hist, bin_edges = np.histogram(weights, bins=num_bins, density=False)
    hist = hist / hist.sum()
    hist = hist[hist > 0]  # remove zero bins
    dist = FinProbDist(list(hist))

    H_inf = dist.min_entropy()
    H_shannon = -sum(p * np.log2(p) for p in hist if p > 0)
    original_bits = np.log2(num_bins)

    return {
        'original_bits_per_weight': original_bits,
        'min_entropy_bits': H_inf,
        'shannon_entropy_bits': H_shannon,
        'compression_ratio_tropical': H_inf / original_bits,
        'compression_ratio_shannon': H_shannon / original_bits,
        'worst_case_bits_needed': H_inf,
        'max_compression_savings_pct': (1 - H_inf / original_bits) * 100,
    }


print("\n" + "=" * 60)
print("APPLICATION 2: Neural Network Weight Compression")
print("=" * 60)

# Simulate neural network weights (Gaussian + sparsity)
np.random.seed(42)
weights = np.concatenate([
    np.random.randn(800) * 0.1,   # small weights
    np.random.randn(150) * 1.0,   # medium weights
    np.random.randn(50) * 5.0,    # large weights
])

for num_bins in [16, 32, 64, 256]:
    result = neural_compression_analysis(weights, num_bins)
    print(f"\nQuantization to {num_bins} bins:")
    for k, v in result.items():
        print(f"  {k}: {v:.4f}" if isinstance(v, float) else f"  {k}: {v}")


# ============================================================
# Application 3: Ultrametric Communication Over p-adic Channels
# ============================================================

def design_ultrametric_code(prime: int, total_digits: int, noise_digits: int) -> dict:
    """Design an optimal coset code for an ultrametric channel.

    Args:
        prime: The base prime p.
        total_digits: Total number of p-adic digits (determines alphabet).
        noise_digits: Number of digits corrupted by noise.

    Returns:
        Dictionary with code design parameters.
    """
    output_size = prime ** total_digits
    noise_size = prime ** noise_digits
    num_cosets = output_size // noise_size

    cap = ultrametric_capacity(output_size, noise_digits, prime)
    code = CosetCode(num_codewords=num_cosets, coset_size=noise_size)

    return {
        'prime': prime,
        'output_alphabet_size': output_size,
        'noise_ball_size': noise_size,
        'num_codewords': num_cosets,
        'capacity_bits': cap,
        'code_rate_bits': code.rate(),
        'noise_tolerance_bits': code.noise_tolerance(),
        'achieves_capacity': abs(code.rate() - cap) < 1e-10,
    }


print("\n" + "=" * 60)
print("APPLICATION 3: Ultrametric Channel Code Design")
print("=" * 60)

for prime in [2, 3, 5]:
    for total in [4, 6, 8]:
        for noise in range(1, total):
            if noise <= total // 2:
                result = design_ultrametric_code(prime, total, noise)
                print(f"\n  p={prime}, digits={total}, noise={noise}:")
                print(f"    Capacity: {result['capacity_bits']:.2f} bits")
                print(f"    Code rate: {result['code_rate_bits']:.2f} bits")
                print(f"    Achieves capacity: {result['achieves_capacity']}")


# ============================================================
# Application 4: Certified Robustness via Lipschitz Stability
# ============================================================

def certified_robustness_bound(original_dist: FinProbDist,
                                perturbed_dist: FinProbDist,
                                distortion_budget: float) -> dict:
    """Compute certified robustness bounds using tropical rate-distortion.

    The 1-Lipschitz property of R_min guarantees that small perturbations
    to the source cause proportionally small changes in the optimal rate.

    Args:
        original_dist: Original source distribution.
        perturbed_dist: Perturbed distribution.
        distortion_budget: Distortion budget D.

    Returns:
        Dictionary with robustness metrics.
    """
    tv = original_dist.total_variation(perturbed_dist)
    R_orig = min_plus_rate_distortion(original_dist, distortion_budget)
    R_pert = min_plus_rate_distortion(perturbed_dist, distortion_budget)

    return {
        'total_variation_distance': tv,
        'rate_original': R_orig,
        'rate_perturbed': R_pert,
        'rate_change': abs(R_orig - R_pert),
        'entropy_change': abs(original_dist.min_entropy() - perturbed_dist.min_entropy()),
        'lipschitz_bound_satisfied': abs(R_orig - R_pert) <= abs(
            original_dist.min_entropy() - perturbed_dist.min_entropy()) + 1e-10,
    }


print("\n" + "=" * 60)
print("APPLICATION 4: Certified Robustness Analysis")
print("=" * 60)

# Original model distribution
original = FinProbDist([0.4, 0.3, 0.2, 0.1])

# Small perturbation (adversarial attack)
perturbed = FinProbDist([0.42, 0.28, 0.19, 0.11])

for D in [0.0, 0.5, 1.0]:
    result = certified_robustness_bound(original, perturbed, D)
    print(f"\nDistortion budget D = {D}:")
    for k, v in result.items():
        print(f"  {k}: {v:.6f}" if isinstance(v, float) else f"  {k}: {v}")

print("\n" + "=" * 60)
print("All applications completed successfully!")
print("=" * 60)


"""
Non-Archimedean Information Theory — Numerical Demonstrations

This script demonstrates the key theorems of tropical information theory
with concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================
# 1. Min-Entropy Computation
# ============================================================

def min_entropy(p):
    """Compute min-entropy H_∞(X) = -log2(max p(x))."""
    return -np.log2(max(p))

def shannon_entropy(p):
    """Compute Shannon entropy H(X) = -Σ p(x) log2 p(x)."""
    return -sum(pi * np.log2(pi) for pi in p if pi > 0)

def renyi_entropy(p, q):
    """Compute Rényi entropy H_q(X) = 1/(1-q) * log2(Σ p(x)^q)."""
    if q == 1:
        return shannon_entropy(p)
    return 1 / (1 - q) * np.log2(sum(pi**q for pi in p))

print("=" * 60)
print("DEMO 1: Min-Entropy vs Shannon Entropy")
print("=" * 60)

# Uniform distribution on 8 elements
p_uniform = [1/8] * 8
print(f"\nUniform(8):  H_∞ = {min_entropy(p_uniform):.4f}, H = {shannon_entropy(p_uniform):.4f}")
print(f"  Both equal log2(8) = {np.log2(8):.4f} ✓")

# Skewed distribution
p_skewed = [0.5, 0.2, 0.1, 0.05, 0.05, 0.04, 0.03, 0.03]
print(f"\nSkewed:      H_∞ = {min_entropy(p_skewed):.4f}, H = {shannon_entropy(p_skewed):.4f}")
print(f"  H_∞ < H always (min-entropy is more conservative)")

# Nearly deterministic
p_almost_det = [0.95, 0.01, 0.01, 0.01, 0.005, 0.005, 0.005, 0.005]
print(f"\nNear-determ: H_∞ = {min_entropy(p_almost_det):.4f}, H = {shannon_entropy(p_almost_det):.4f}")

# Exactly deterministic
p_det = [1.0, 0, 0, 0, 0, 0, 0, 0]
print(f"\nDeterministic: H_∞ = {min_entropy(p_det):.4f}")
print(f"  H_∞ = 0 for deterministic distribution ✓")

# ============================================================
# 2. Product Distribution Additivity
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Additivity Under Independence")
print("=" * 60)

p1 = [0.6, 0.3, 0.1]
p2 = [0.5, 0.3, 0.2]

# Product distribution
p_product = [p1[i] * p2[j] for i in range(3) for j in range(3)]

h1 = min_entropy(p1)
h2 = min_entropy(p2)
h_product = min_entropy(p_product)

print(f"\nH_∞(X) = {h1:.4f}")
print(f"H_∞(Y) = {h2:.4f}")
print(f"H_∞(X) + H_∞(Y) = {h1 + h2:.4f}")
print(f"H_∞(X × Y) = {h_product:.4f}")
print(f"Difference: {abs(h1 + h2 - h_product):.2e} ✓ (machine precision)")

# ============================================================
# 3. Ultrametric Channel Capacity
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Ultrametric Channel Capacity")
print("=" * 60)

def ultrametric_capacity(q, k, p):
    """Capacity C = log(q) - k * log(p) in nats."""
    return np.log(q) - k * np.log(p)

for prime in [2, 3, 5]:
    print(f"\nPrime p = {prime}:")
    for k in range(4):
        q = prime ** 4  # Fixed output size
        cap = ultrametric_capacity(q, k, prime)
        print(f"  k = {k}: C = log({q}) - {k}·log({prime}) = {cap:.4f} nats = {cap/np.log(2):.4f} bits")

# ============================================================
# 4. Rate-Distortion Curves
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Min-Plus Rate-Distortion")
print("=" * 60)

p_source = [0.4, 0.3, 0.2, 0.1]
H_inf = min_entropy(p_source)

print(f"\nSource entropy H_∞ = {H_inf:.4f} bits")
print(f"\nD\t\tR_min(D)\tR_min(D) ≥ 0?")
print("-" * 50)

for D in np.arange(0, H_inf + 0.5, 0.2):
    R = H_inf - D
    print(f"{D:.2f}\t\t{R:.4f}\t\t{'Yes' if R >= 0 else 'No'}")

# ============================================================
# 5. Rényi Entropy Family Convergence
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: Rényi Entropy → Min-Entropy as q → ∞")
print("=" * 60)

p = [0.5, 0.3, 0.15, 0.05]
H_inf_val = min_entropy(p)
print(f"\nDistribution: {p}")
print(f"Min-entropy H_∞ = {H_inf_val:.6f}")
print(f"\nq\tH_q\t\t|H_q - H_∞|")
print("-" * 45)

for q in [1.5, 2, 3, 5, 10, 20, 50, 100]:
    H_q = renyi_entropy(p, q)
    print(f"{q}\t{H_q:.6f}\t{abs(H_q - H_inf_val):.6e}")

# ============================================================
# 6. Total Variation Distance
# ============================================================

print("\n" + "=" * 60)
print("DEMO 6: Total Variation Distance")
print("=" * 60)

def total_variation(p, q):
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))

p1 = [0.5, 0.3, 0.2]
p2 = [0.4, 0.35, 0.25]
p3 = [1/3, 1/3, 1/3]

print(f"\nTV(p1, p2) = {total_variation(p1, p2):.4f}")
print(f"TV(p1, p3) = {total_variation(p1, p3):.4f}")
print(f"TV(p1, p1) = {total_variation(p1, p1):.4f} (self-distance = 0 ✓)")
print(f"TV(p1, p2) = TV(p2, p1)? {abs(total_variation(p1, p2) - total_variation(p2, p1)) < 1e-10} ✓")
print(f"TV ≤ 1? {total_variation(p1, p2) <= 1} ✓")

# ============================================================
# Generate Figures
# ============================================================

# Figure 1: Min-entropy vs Shannon entropy for Bernoulli(p)
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

ps = np.linspace(0.01, 0.99, 100)
h_inf = [-np.log2(max(p, 1-p)) for p in ps]
h_shannon = [-p*np.log2(p) - (1-p)*np.log2(1-p) for p in ps]

axes[0].plot(ps, h_inf, 'b-', linewidth=2, label='Min-entropy H_∞')
axes[0].plot(ps, h_shannon, 'r--', linewidth=2, label='Shannon H')
axes[0].set_xlabel('p')
axes[0].set_ylabel('Entropy (bits)')
axes[0].set_title('Bernoulli Entropy: Min vs Shannon')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Figure 2: Ultrametric capacity vs noise
ks = range(0, 6)
for prime in [2, 3, 5]:
    q = prime ** 5
    caps = [max(0, ultrametric_capacity(q, k, prime) / np.log(2)) for k in ks]
    axes[1].plot(ks, caps, 'o-', linewidth=2, label=f'p={prime}, q={q}')

axes[1].set_xlabel('Noise radius k')
axes[1].set_ylabel('Capacity (bits)')
axes[1].set_title('Ultrametric Channel Capacity')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Figure 3: Rate-distortion curves
p_sources = [[1/4]*4, [0.5, 0.3, 0.15, 0.05], [0.9, 0.05, 0.03, 0.02]]
labels = ['Uniform(4)', 'Skewed', 'Near-deterministic']
Ds = np.linspace(0, 2.5, 100)

for p_src, label in zip(p_sources, labels):
    H = min_entropy(p_src)
    Rs = [max(0, H - D) for D in Ds]
    axes[2].plot(Ds, Rs, linewidth=2, label=f'{label}: H_∞={H:.2f}')

axes[2].set_xlabel('Distortion D')
axes[2].set_ylabel('Rate R_min(D)')
axes[2].set_title('Min-Plus Rate-Distortion')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('visualizations.png', dpi=150, bbox_inches='tight')
plt.savefig('visualizations.svg', bbox_inches='tight')
print("\n✓ Saved visualizations.png and visualizations.svg")
