"""
Applications of Persistent Homology of Prime Numbers

Real-world applications of the topological analysis of primes:
1. Cryptographic gap analysis: testing randomness of prime distributions
2. Primality certificate topology: structural signatures of prime generators
3. Number-theoretic anomaly detection via barcode comparison
"""

import math
from typing import List, Tuple, Dict


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def compute_gaps(sequence: List[int]) -> List[int]:
    """Compute gaps between consecutive elements."""
    return [sequence[i+1] - sequence[i] for i in range(len(sequence) - 1)]


# =============================================================================
# Application 1: Cryptographic Prime Quality Assessment
# =============================================================================

def prime_gap_quality_score(primes: List[int]) -> Dict[str, float]:
    """
    Assess the "quality" of a prime sequence by comparing its gap
    distribution to the expected Poisson/Cramér model.

    A good random prime generator should produce gaps that match
    the exponential distribution with mean ≈ log(N).

    Returns a quality score where 1.0 = perfect match to model.
    """
    if len(primes) < 2:
        return {"score": 0.0, "reason": "too few primes"}

    gaps = compute_gaps(primes)
    N = primes[-1]
    log_N = math.log(N)

    # Test 1: Mean gap vs log(N)
    mean_gap = sum(gaps) / len(gaps)
    mean_score = 1.0 - min(1.0, abs(mean_gap / log_N - 1.0))

    # Test 2: Exponential tail test
    k_tests = [1.0, 2.0, 3.0]
    tail_scores = []
    for k in k_tests:
        observed = sum(1 for g in gaps if g > k * log_N) / len(gaps)
        expected = math.exp(-k)
        if expected > 0:
            tail_scores.append(1.0 - min(1.0, abs(observed / expected - 1.0)))

    tail_score = sum(tail_scores) / len(tail_scores) if tail_scores else 0.5

    # Test 3: Variance test (should be ≈ log(N)² for Poisson)
    var_gap = sum((g - mean_gap)**2 for g in gaps) / len(gaps)
    expected_var = log_N ** 2
    var_score = 1.0 - min(1.0, abs(var_gap / expected_var - 1.0)) if expected_var > 0 else 0.5

    overall = 0.4 * mean_score + 0.4 * tail_score + 0.2 * var_score

    return {
        "overall_score": overall,
        "mean_score": mean_score,
        "tail_score": tail_score,
        "variance_score": var_score,
        "mean_gap": mean_gap,
        "expected_mean": log_N,
        "variance": var_gap,
        "expected_variance": expected_var,
    }


# =============================================================================
# Application 2: Anomaly Detection in Number Sequences
# =============================================================================

def detect_gap_anomalies(
    primes: List[int], threshold_sigma: float = 3.0
) -> List[Dict]:
    """
    Detect anomalously large or small gaps in a prime sequence.
    Gaps that deviate more than threshold_sigma standard deviations
    from the mean are flagged as anomalies.

    In the barcode interpretation, these are bars with unusually
    high or low persistence.
    """
    gaps = compute_gaps(primes)
    mean_gap = sum(gaps) / len(gaps)
    std_gap = (sum((g - mean_gap)**2 for g in gaps) / len(gaps)) ** 0.5

    anomalies = []
    for i, g in enumerate(gaps):
        z_score = (g - mean_gap) / std_gap if std_gap > 0 else 0
        if abs(z_score) > threshold_sigma:
            anomalies.append({
                "index": i,
                "prime_left": primes[i],
                "prime_right": primes[i + 1],
                "gap": g,
                "z_score": z_score,
                "type": "large" if z_score > 0 else "small",
            })

    return anomalies


# =============================================================================
# Application 3: Comparing Prime-like Sequences
# =============================================================================

def barcode_distance(seq1: List[int], seq2: List[int]) -> float:
    """
    Compute the bottleneck distance between H₀ barcodes of two sequences.
    This measures how "topologically similar" two point clouds are.

    For 1D point clouds, this reduces to comparing sorted gap sequences.
    """
    gaps1 = sorted(compute_gaps(seq1))
    gaps2 = sorted(compute_gaps(seq2))

    # Pad shorter sequence with zeros
    max_len = max(len(gaps1), len(gaps2))
    gaps1.extend([0] * (max_len - len(gaps1)))
    gaps2.extend([0] * (max_len - len(gaps2)))

    # Bottleneck distance = max absolute difference in sorted gaps
    return max(abs(g1 - g2) for g1, g2 in zip(gaps1, gaps2))


def wasserstein_barcode_distance(seq1: List[int], seq2: List[int], p: int = 1) -> float:
    """
    Compute the p-Wasserstein distance between H₀ barcodes.
    """
    gaps1 = sorted(compute_gaps(seq1))
    gaps2 = sorted(compute_gaps(seq2))

    max_len = max(len(gaps1), len(gaps2))
    gaps1.extend([0] * (max_len - len(gaps1)))
    gaps2.extend([0] * (max_len - len(gaps2)))

    return (sum(abs(g1 - g2)**p for g1, g2 in zip(gaps1, gaps2)) / max_len) ** (1/p)


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF PRIME PERSISTENT HOMOLOGY")
    print("=" * 60)

    # Application 1: Quality assessment
    print("\n--- Application 1: Cryptographic Quality Assessment ---")
    for N in [10000, 100000, 1000000]:
        primes = sieve_primes(N)
        quality = prime_gap_quality_score(primes)
        print(f"N={N:>8}: quality={quality['overall_score']:.4f} "
              f"(mean={quality['mean_score']:.3f}, "
              f"tail={quality['tail_score']:.3f}, "
              f"var={quality['variance_score']:.3f})")

    # Application 2: Anomaly detection
    print("\n--- Application 2: Gap Anomaly Detection (N=100000) ---")
    primes = sieve_primes(100000)
    anomalies = detect_gap_anomalies(primes, threshold_sigma=4.0)
    print(f"Found {len(anomalies)} anomalous gaps (|z| > 4.0):")
    for a in anomalies[:10]:
        print(f"  gap={a['gap']:>4} between {a['prime_left']} and {a['prime_right']} "
              f"(z={a['z_score']:.2f})")

    # Application 3: Sequence comparison
    print("\n--- Application 3: Barcode Distance Comparison ---")
    primes_1k = sieve_primes(1000)

    # Compare primes to shifted primes
    shifted = [p + 1000 for p in primes_1k]
    d_shifted = wasserstein_barcode_distance(primes_1k, shifted)
    print(f"Distance(primes, shifted primes): {d_shifted:.2f}")

    # Compare to random integers with similar density
    import random
    random.seed(42)
    n_primes = len(primes_1k)
    random_pts = sorted(random.sample(range(2, 1001), min(n_primes, 999)))
    d_random = wasserstein_barcode_distance(primes_1k, random_pts)
    print(f"Distance(primes, random points):  {d_random:.2f}")

    # Compare primes in different ranges
    primes_2k = [p for p in sieve_primes(2000) if p > 1000]
    d_ranges = wasserstein_barcode_distance(primes_1k, primes_2k)
    print(f"Distance(primes<1000, primes 1000-2000): {d_ranges:.2f}")


"""
Demo: Persistent Homology of Prime Numbers

Demonstrates the core concepts from our formalization:
1. Computing prime gaps and the H₀ barcode
2. Verifying Bertrand's bound on bar lengths
3. Testing the Cramér-Granville exponential gap distribution conjecture
4. Showing the filtration monotonicity in action
"""

import math
from typing import List, Tuple


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Return all primes up to n using the Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def compute_prime_gaps(primes: List[int]) -> List[int]:
    """Compute consecutive prime gaps."""
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def h0_barcode(primes: List[int]) -> List[Tuple[int, int]]:
    """
    Compute the H₀ barcode of the prime point cloud.
    Each bar: (birth=0, death=gap_size), plus one essential class (0, ∞).
    """
    gaps = compute_prime_gaps(primes)
    bars = [(0, float('inf'))]  # Essential class
    bars.extend((0, g) for g in gaps)
    return bars


def count_components_at_scale(primes: List[int], eps: int) -> int:
    """
    Count connected components of the prime Rips graph at scale ε.
    For a 1D point cloud, this is simply 1 + (number of gaps > ε).
    """
    gaps = compute_prime_gaps(primes)
    return 1 + sum(1 for g in gaps if g > eps)


def verify_bertrand_bound(primes: List[int]) -> bool:
    """
    Verify that all consecutive prime gaps satisfy g ≤ p
    (Bertrand's postulate consequence, proved in Lean).
    """
    gaps = compute_prime_gaps(primes)
    for i, g in enumerate(gaps):
        if g > primes[i]:
            print(f"VIOLATION: gap {g} > prime {primes[i]}")
            return False
    return True


def test_exponential_distribution(primes: List[int], k_values: List[float] = [1, 2, 3]) -> None:
    """
    Test the Cramér-Granville conjecture: fraction of gaps exceeding k·log(N)
    should approximate e^(-k).
    """
    N = primes[-1]
    log_N = math.log(N)
    gaps = compute_prime_gaps(primes)
    n_gaps = len(gaps)

    print(f"\nCramér-Granville Exponential Gap Distribution Test (N = {N})")
    print(f"log(N) = {log_N:.2f}, number of gaps = {n_gaps}")
    print(f"{'k':>5} {'threshold':>10} {'fraction':>10} {'e^(-k)':>10} {'ratio':>10}")
    print("-" * 50)

    for k in k_values:
        threshold = k * log_N
        count = sum(1 for g in gaps if g > threshold)
        fraction = count / n_gaps
        expected = math.exp(-k)
        ratio = fraction / expected if expected > 0 else float('inf')
        print(f"{k:>5.1f} {threshold:>10.2f} {fraction:>10.4f} {expected:>10.4f} {ratio:>10.4f}")


def demo_filtration_monotonicity(primes: List[int]) -> None:
    """
    Demonstrate that connected components decrease monotonically as ε increases.
    This is the fundamental filtration property proved in Lean.
    """
    print("\nFiltration Monotonicity (components decrease with ε)")
    print(f"{'ε':>5} {'components':>12} {'fraction connected':>20}")
    print("-" * 40)

    n_primes = len(primes)
    prev_components = n_primes + 1

    for eps in [0, 1, 2, 4, 6, 10, 20, 50, 100, 200, 500]:
        components = count_components_at_scale(primes, eps)
        assert components <= prev_components, "Monotonicity violation!"
        prev_components = components
        frac = 1 - (components - 1) / max(n_primes - 1, 1)
        print(f"{eps:>5} {components:>12} {frac:>20.4f}")


def demo_twin_prime_signature(primes: List[int]) -> None:
    """
    Count twin primes (gap = 2) in the barcode — the topological signature
    of the twin prime conjecture.
    """
    gaps = compute_prime_gaps(primes)
    twin_count = sum(1 for g in gaps if g == 2)
    N = primes[-1]
    print(f"\nTwin Prime Topological Signature (N = {N})")
    print(f"Number of gap-2 bars (twin primes): {twin_count}")
    print(f"Total bars: {len(gaps)}")
    print(f"Fraction of bars with persistence 2: {twin_count/len(gaps):.4f}")

    # Count by gap size
    from collections import Counter
    gap_counts = Counter(gaps)
    print("\nGap distribution (top 10):")
    for gap, count in sorted(gap_counts.items(), key=lambda x: -x[1])[:10]:
        print(f"  gap = {gap:>4}: {count:>6} bars ({count/len(gaps)*100:.1f}%)")


if __name__ == "__main__":
    print("=" * 60)
    print("PERSISTENT HOMOLOGY OF PRIME NUMBERS: DEMONSTRATION")
    print("=" * 60)

    # Compute primes up to 10^6
    N = 1_000_000
    primes = sieve_of_eratosthenes(N)
    print(f"\nPrimes up to {N}: {len(primes)} primes found")
    print(f"First 10: {primes[:10]}")
    print(f"Last 10: {primes[-10:]}")

    # 1. Verify Bertrand's bound
    print("\n" + "=" * 60)
    print("1. BERTRAND'S BOUND ON BAR LENGTHS")
    print("=" * 60)
    result = verify_bertrand_bound(primes)
    print(f"All gaps satisfy g ≤ p: {result}")

    # 2. Filtration monotonicity
    print("\n" + "=" * 60)
    print("2. FILTRATION MONOTONICITY")
    print("=" * 60)
    demo_filtration_monotonicity(primes)

    # 3. Exponential distribution test
    print("\n" + "=" * 60)
    print("3. CRAMÉR-GRANVILLE CONJECTURE TEST")
    print("=" * 60)
    test_exponential_distribution(primes)

    # 4. Twin prime signature
    print("\n" + "=" * 60)
    print("4. TWIN PRIME TOPOLOGICAL SIGNATURE")
    print("=" * 60)
    demo_twin_prime_signature(primes)

    # 5. H₀ barcode summary
    print("\n" + "=" * 60)
    print("5. H₀ BARCODE SUMMARY")
    print("=" * 60)
    gaps = compute_prime_gaps(primes)
    print(f"Number of bars: {len(gaps) + 1} (including essential class)")
    print(f"Maximum finite persistence: {max(gaps)}")
    print(f"Mean persistence: {sum(gaps)/len(gaps):.2f}")
    print(f"Predicted mean (log N): {math.log(N):.2f}")
    print(f"Ratio actual/predicted: {sum(gaps)/len(gaps)/math.log(N):.4f}")


"""
Visualization 1: H₀ Barcode of the Prime Point Cloud

Visualizes the persistent homology barcode for primes up to N,
showing how connected components merge as the scale parameter ε increases.
Each horizontal bar represents a topological feature (connected component)
that exists from birth (ε=0) to death (ε = gap size).

The distribution of bar lengths directly encodes the prime gap structure.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Compute primes and gaps
N = 500
primes = sieve_primes(N)
gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

# Sort gaps for barcode display
sorted_gaps = sorted(gaps, reverse=True)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Barcode diagram
ax1 = axes[0]
for i, death in enumerate(sorted_gaps):
    color = '#e74c3c' if death == 2 else '#3498db' if death <= 6 else '#2ecc71'
    ax1.barh(i, death, left=0, height=0.8, color=color, alpha=0.7, edgecolor='none')

ax1.set_xlabel('Scale ε (gap size)', fontsize=12)
ax1.set_ylabel('Bar index (sorted by persistence)', fontsize=12)
ax1.set_title(f'H₀ Barcode of Primes up to {N}', fontsize=14, fontweight='bold')
ax1.axvline(x=2, color='red', linestyle='--', alpha=0.5, label='ε = 2 (twin primes)')
ax1.legend(fontsize=10)
ax1.invert_yaxis()

# Panel 2: Gap histogram vs exponential distribution
ax2 = axes[1]
log_N = math.log(N)
bins = np.arange(0.5, max(gaps) + 1.5, 1)
counts, _, _ = ax2.hist(gaps, bins=bins, density=True, alpha=0.7, color='#3498db',
                         edgecolor='white', label='Observed gaps')

# Overlay exponential distribution
x = np.linspace(0, max(gaps), 100)
exp_pdf = (1/log_N) * np.exp(-x/log_N)
ax2.plot(x, exp_pdf, 'r-', linewidth=2, label=f'Exp(1/log({N})) = Exp(1/{log_N:.1f})')

ax2.set_xlabel('Gap size', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Gap Distribution vs Cramér Model', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)

# Panel 3: Connected components vs scale
ax3 = axes[2]
eps_values = list(range(0, max(gaps) + 2))
component_counts = []
for eps in eps_values:
    n_components = 1 + sum(1 for g in gaps if g > eps)
    component_counts.append(n_components)

ax3.step(eps_values, component_counts, where='post', color='#2ecc71', linewidth=2)
ax3.fill_between(eps_values, component_counts, alpha=0.2, color='#2ecc71', step='post')
ax3.set_xlabel('Scale ε', fontsize=12)
ax3.set_ylabel('Number of connected components (β₀)', fontsize=12)
ax3.set_title('Filtration: Components vs Scale', fontsize=14, fontweight='bold')
ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax3.annotate(f'Full connectivity at ε = {max(gaps)}',
             xy=(max(gaps), 1), xytext=(max(gaps)*0.5, len(primes)*0.3),
             arrowprops=dict(arrowstyle='->', color='gray'),
             fontsize=10, color='gray')

plt.tight_layout()
plt.savefig('viz_barcode.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode.png")


"""
Visualization 3: Cramér-Granville Conjecture Test

Compares the prime gap distribution to the Cramér model prediction
(exponential distribution with mean log(N)) across multiple scales.

This is the key falsifiable prediction: if prime gaps DON'T follow
an exponential distribution, the Cramér random model fails.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Test at multiple scales
test_params = [
    (10000, 'N = 10⁴'),
    (100000, 'N = 10⁵'),
    (500000, 'N = 5×10⁵'),
    (1000000, 'N = 10⁶'),
]

for idx, (N, label) in enumerate(test_params):
    ax = axes[idx // 2][idx % 2]
    primes = sieve_primes(N)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    log_N = math.log(N)

    # Normalized gaps
    normalized = [g / log_N for g in gaps]

    # Histogram of normalized gaps
    bins = np.linspace(0, 6, 50)
    ax.hist(normalized, bins=bins, density=True, alpha=0.6, color='#3498db',
            edgecolor='white', label='Observed (normalized)')

    # Exponential(1) overlay
    x = np.linspace(0, 6, 200)
    ax.plot(x, np.exp(-x), 'r-', linewidth=2.5, label='Exp(1) prediction')

    # Compute KS-like statistic
    from collections import Counter
    sorted_norm = sorted(normalized)
    n_gaps = len(sorted_norm)
    ks_stat = 0
    for i, val in enumerate(sorted_norm):
        empirical_cdf = (i + 1) / n_gaps
        theoretical_cdf = 1 - math.exp(-val)
        ks_stat = max(ks_stat, abs(empirical_cdf - theoretical_cdf))

    ax.set_title(f'{label} (KS = {ks_stat:.4f})', fontsize=13, fontweight='bold')
    ax.set_xlabel('Normalized gap (g / log N)', fontsize=11)
    ax.set_ylabel('Density', fontsize=11)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 6)

    # Add text with mean
    mean_norm = sum(normalized) / len(normalized)
    ax.text(0.95, 0.85, f'Mean = {mean_norm:.3f}\n(predicted: 1.0)',
            transform=ax.transAxes, ha='right', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.suptitle('Cramér-Granville Conjecture: Prime Gaps vs Exponential Distribution',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cramer.png', dpi=150, bbox_inches='tight')
print("Saved viz_cramer.png")


"""
Visualization 2: Rips Filtration of the Prime Point Cloud

Shows how the prime point cloud evolves under the Rips filtration:
at each scale ε, we connect primes within distance ε. This visualization
shows snapshots at different scales, revealing the topological transitions.

The key insight: primes have structure — they are NOT random, and their
gaps create a specific persistent homology signature.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# Use primes up to 100 for clear visualization
primes = sieve_primes(100)
N = len(primes)

fig, axes = plt.subplots(3, 2, figsize=(16, 12))

scales = [0, 1, 2, 4, 6, 14]
titles = [
    'ε = 0: All isolated',
    'ε = 1: Only (2,3) connected',
    'ε = 2: Twin primes merge',
    'ε = 4: Most small gaps close',
    'ε = 6: Major clustering',
    'ε = 14: Fully connected'
]

for idx, (eps, title) in enumerate(zip(scales, titles)):
    ax = axes[idx // 2][idx % 2]

    # Assign components via union-find
    parent = list(range(N))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    for i in range(N - 1):
        if primes[i + 1] - primes[i] <= eps:
            union(i, i + 1)

    # Color by component
    components = {}
    for i in range(N):
        root = find(i)
        if root not in components:
            components[root] = len(components)

    n_comp = len(components)
    cmap = plt.cm.Set3
    colors = [cmap(components[find(i)] % 12 / 12) for i in range(N)]

    # Draw connections
    for i in range(N - 1):
        if primes[i + 1] - primes[i] <= eps:
            ax.plot([primes[i], primes[i+1]], [0, 0], '-', color='gray',
                    linewidth=1.5, alpha=0.5)

    # Draw points
    ax.scatter(primes, [0]*N, c=colors, s=60, zorder=5, edgecolors='black', linewidth=0.5)

    ax.set_title(f'{title} ({n_comp} components)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Prime value')
    ax.set_yticks([])
    ax.set_xlim(-2, 102)

plt.suptitle('Rips Filtration of Prime Numbers (2 to 97)',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")
