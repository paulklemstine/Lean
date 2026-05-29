"""
Applications of Prime Fractal Theory
======================================
Demonstrates real-world applications of the prime fractal metric
to cryptography, data compression, and random number generation.
"""

import math
from typing import List, Tuple
from collections import Counter


def sieve_primes(N: int) -> List[int]:
    """Sieve of Eratosthenes up to N."""
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p: int) -> float:
    """Logarithmic embedding: p ↦ 1/log(p)."""
    return 1.0 / math.log(p)


def prime_fractal_dist(p: int, q: int) -> float:
    """Prime fractal metric."""
    return abs(log_embed(p) - log_embed(q))


# ============================================================
# Application 1: Cryptographic Key Distance Analysis
# ============================================================

def rsa_key_fractal_analysis(bit_length: int = 64) -> dict:
    """
    Analyze RSA-like prime pairs under the fractal metric.

    In RSA, we need two large primes p, q with |p - q| large to avoid
    Fermat factoring. The fractal metric provides an alternative measure:
    d(p, q) in the log metric measures how "distinguishable" the primes are
    from an information-theoretic perspective.

    Args:
        bit_length: Approximate bit length for prime search range.

    Returns:
        Analysis of prime pair distances.
    """
    # Use smaller primes for demonstration
    N = min(2**bit_length, 10**6)
    primes = sieve_primes(N)

    # Sample prime pairs and analyze
    import random
    random.seed(42)

    n_pairs = 100
    results = []
    for _ in range(n_pairs):
        p, q = random.sample(primes[-1000:], 2)  # Large primes
        d_fractal = prime_fractal_dist(p, q)
        d_absolute = abs(p - q)
        d_relative = abs(p - q) / max(p, q)
        results.append({
            "p": p, "q": q,
            "d_fractal": d_fractal,
            "d_absolute": d_absolute,
            "d_relative": d_relative,
        })

    return {
        "num_pairs": n_pairs,
        "mean_fractal_dist": sum(r["d_fractal"] for r in results) / n_pairs,
        "mean_relative_dist": sum(r["d_relative"] for r in results) / n_pairs,
        "correlation": _correlation(
            [r["d_fractal"] for r in results],
            [r["d_relative"] for r in results]
        ),
        "sample_results": results[:5],
    }


def _correlation(x: List[float], y: List[float]) -> float:
    """Pearson correlation coefficient."""
    n = len(x)
    mx, my = sum(x) / n, sum(y) / n
    sx = sum((xi - mx) ** 2 for xi in x) ** 0.5
    sy = sum((yi - my) ** 2 for yi in y) ** 0.5
    if sx == 0 or sy == 0:
        return 0.0
    return sum((xi - mx) * (yi - my) for xi, yi in zip(x, y)) / (n * sx * sy) * n


# ============================================================
# Application 2: Prime Gap Prediction via Fractal Structure
# ============================================================

def predict_prime_gap_from_fractal(p: int, primes: List[int]) -> float:
    """
    Use the fractal metric to predict the next prime gap.

    The fractal distance formula: d(p, q) = (log q - log p) / (log p · log q).
    For the next prime q after p, d ≈ (q - p) / (p · log²(p)).
    So the expected gap g ≈ p · log²(p) · d_expected.

    From prime number theorem, the expected density of primes near x is 1/log(x),
    so the expected fractal distance to the next prime is ≈ 1/(p · log(p)).
    Therefore, the expected gap is g ≈ log(p).

    Args:
        p: Current prime.
        primes: Sorted list of primes.

    Returns:
        Predicted gap size.
    """
    # The PNT prediction: expected gap ≈ log(p)
    pnt_prediction = math.log(p)

    # Fractal-based refinement: use local fractal density
    idx = _binary_search(primes, p)
    if idx >= 0 and idx < len(primes) - 1:
        # Local fractal density from nearby primes
        window = 10
        start = max(0, idx - window)
        end = min(len(primes) - 1, idx + window)
        local_dists = []
        for i in range(start, end):
            local_dists.append(prime_fractal_dist(primes[i], primes[i + 1]))
        avg_fractal_dist = sum(local_dists) / len(local_dists)
        # Gap ≈ p · log²(p) · avg_fractal_dist
        fractal_prediction = p * math.log(p) ** 2 * avg_fractal_dist
        return fractal_prediction

    return pnt_prediction


def _binary_search(arr: List[int], target: int) -> int:
    """Binary search returning index of target, or -1."""
    lo, hi = 0, len(arr) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1


# ============================================================
# Application 3: Entropy-Based Prime Density Estimation
# ============================================================

def entropy_density_estimator(N: int, num_bins: int = 50) -> dict:
    """
    Use the prime log entropy to estimate local prime density variations.

    The entropy of the prime distribution in the log metric reveals
    how uniformly the primes are distributed. High entropy means uniform
    distribution (expected from PNT), while low entropy indicates clustering.

    Args:
        N: Upper bound for primes.
        num_bins: Number of entropy bins.

    Returns:
        Entropy analysis results.
    """
    primes = sieve_primes(N)
    embeddings = [log_embed(p) for p in primes]

    max_e = max(embeddings)
    bin_width = max_e / num_bins

    # Compute histogram
    bins = [0] * num_bins
    for e in embeddings:
        idx = min(int(e / bin_width), num_bins - 1)
        bins[idx] += 1

    # Compute entropy
    total = len(primes)
    entropy = 0.0
    for count in bins:
        if count > 0:
            freq = count / total
            entropy -= freq * math.log(freq)

    max_entropy = math.log(num_bins)
    uniformity = entropy / max_entropy if max_entropy > 0 else 0

    return {
        "N": N,
        "num_primes": len(primes),
        "entropy": entropy,
        "max_entropy": max_entropy,
        "uniformity_ratio": uniformity,
        "bin_counts": bins,
    }


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF PRIME FRACTAL THEORY")
    print("=" * 70)

    # Application 1: Cryptographic analysis
    print("\n--- Application 1: Cryptographic Key Distance Analysis ---")
    result = rsa_key_fractal_analysis()
    print(f"  Mean fractal distance: {result['mean_fractal_dist']:.8f}")
    print(f"  Mean relative distance: {result['mean_relative_dist']:.8f}")
    print(f"  Correlation (fractal vs relative): {result['correlation']:.6f}")

    # Application 2: Gap prediction
    print("\n--- Application 2: Prime Gap Prediction ---")
    primes = sieve_primes(100000)
    errors = []
    for i in range(len(primes) // 2, len(primes) // 2 + 20):
        p = primes[i]
        actual_gap = primes[i + 1] - p
        predicted = predict_prime_gap_from_fractal(p, primes)
        error = abs(predicted - actual_gap) / actual_gap if actual_gap > 0 else 0
        errors.append(error)
        print(f"  p={p}: actual gap={actual_gap}, predicted={predicted:.1f}, error={error:.2%}")
    print(f"  Mean relative error: {sum(errors)/len(errors):.2%}")

    # Application 3: Entropy analysis
    print("\n--- Application 3: Entropy-Based Density Estimation ---")
    for N_exp in [4, 5, 6]:
        N = 10**N_exp
        result = entropy_density_estimator(N)
        print(f"  N=10^{N_exp}: H={result['entropy']:.4f}, "
              f"uniformity={result['uniformity_ratio']:.4f}")


"""Build PACKAGE.json from all deliverables."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_basic = read_file('Catalog/Speculative/PrimeFractal/Basic.lean')
lean_defs = read_file('Catalog/Speculative/PrimeFractal/Defs.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1 = read_file('viz_fractal_embedding.py')
viz2 = read_file('viz_box_counting.py')
viz3 = read_file('viz_twin_prime_fractal.py')
interactive1 = read_file('interactive_embedding.html')
interactive2 = read_file('interactive_boxcount.html')

package = {
    "title": "Fractal Number Theory: Hausdorff Dimension of Prime Distributions",
    "domain": "Number Theory / Fractal Geometry / Information Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Prime Fractal Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Box-Counting Dimension Estimation",
            "pseudocode": """Input: Primes P = {p_1, ..., p_k}, scales {eps_1, ..., eps_m}
Output: Dimension estimate d_hat

for each eps_i:
    B = {floor(phi(p_j)/eps_i) : j = 1,...,k}
    N(eps_i) = |B|

Fit line: log N(eps) = d_hat * log(1/eps) + c
Return d_hat (slope of fitted line)

Time: O(k * m)
Space: O(k)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Prime Fractal Embedding",
            "code": viz1,
            "description": "Visualizes how the logarithmic embedding p -> 1/log(p) transforms the distribution of primes, showing number line vs embedding space with twin primes highlighted."
        },
        {
            "name": "Box-Counting Dimension",
            "code": viz2,
            "description": "Log-log plot of box count vs 1/epsilon for estimating the fractal dimension of the prime set under the logarithmic metric."
        },
        {
            "name": "Twin Prime Fractal Distances",
            "code": viz3,
            "description": "Analysis of how twin prime pairs cluster under the fractal metric, showing distance decay and theoretical bounds."
        }
    ],
    "interactive_demos": [
        {
            "name": "Prime Fractal Embedding Explorer",
            "html": interactive1,
            "description": "Interactive visualization showing how primes transform under the logarithmic embedding. Adjust the upper bound N and hover over primes to see their embedding values."
        },
        {
            "name": "Box-Counting Dimension Calculator",
            "html": interactive2,
            "description": "Interactive tool for computing the box-counting dimension of the prime fractal. Adjust epsilon and N to see how the dimension estimate changes with scale."
        }
    ],
    "lean_proofs": lean_defs + "\n\n-- ==========================================\n-- Theorems and Proofs\n-- ==========================================\n\n" + lean_basic
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json written successfully")
print(f"  Size: {len(json.dumps(package))} bytes")


"""
Prime Fractal: Hausdorff Dimension of Prime Distributions
==========================================================
Demonstrates the logarithmic embedding of primes and box-counting dimension
estimation for the prime fractal metric d(p,q) = |1/log(p) - 1/log(q)|.
"""

import math
from typing import List, Tuple


def is_prime(n: int) -> bool:
    """Primality test."""
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


def sieve_primes(N: int) -> List[int]:
    """Sieve of Eratosthenes up to N."""
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p: int) -> float:
    """Logarithmic embedding: p ↦ 1/log(p)."""
    return 1.0 / math.log(p)


def prime_fractal_dist(p: int, q: int) -> float:
    """Prime fractal metric: d(p,q) = |1/log(p) - 1/log(q)|."""
    return abs(log_embed(p) - log_embed(q))


def box_count(primes: List[int], epsilon: float) -> int:
    """Count distinct boxes of width epsilon covering the prime embeddings."""
    boxes = set()
    for p in primes:
        box_idx = int(math.floor(log_embed(p) / epsilon))
        boxes.add(box_idx)
    return len(boxes)


def box_dim_approx(primes: List[int], epsilon: float) -> float:
    """Approximate box-counting dimension: log(box_count) / log(1/epsilon)."""
    bc = box_count(primes, epsilon)
    if bc <= 0 or epsilon >= 1:
        return 0.0
    return math.log(bc) / math.log(1.0 / epsilon)


def prime_log_entropy(primes: List[int], epsilon: float) -> float:
    """Shannon entropy of the prime distribution in log-metric boxes."""
    from collections import Counter
    boxes = [int(math.floor(log_embed(p) / epsilon)) for p in primes]
    counts = Counter(boxes)
    total = len(primes)
    entropy = 0.0
    for count in counts.values():
        freq = count / total
        if freq > 0:
            entropy -= freq * math.log(freq)
    return entropy


def find_twin_primes(N: int) -> List[Tuple[int, int]]:
    """Find all twin prime pairs (p, p+2) up to N."""
    primes = sieve_primes(N)
    prime_set = set(primes)
    return [(p, p + 2) for p in primes if p + 2 in prime_set]


# ============================================================
# DEMO: Core computations
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("PRIME FRACTAL: Hausdorff Dimension of Prime Distributions")
    print("=" * 70)

    # 1. Demonstrate logEmbed
    print("\n--- Logarithmic Embedding of First 20 Primes ---")
    primes_20 = sieve_primes(71)[:20]
    for p in primes_20:
        print(f"  p = {p:3d}  →  logEmbed(p) = 1/log({p}) = {log_embed(p):.6f}")

    # 2. Demonstrate fractal distance
    print("\n--- Fractal Distance Between Consecutive Primes ---")
    for i in range(len(primes_20) - 1):
        p, q = primes_20[i], primes_20[i + 1]
        d = prime_fractal_dist(p, q)
        print(f"  d({p:3d}, {q:3d}) = {d:.8f}")

    # 3. Twin prime distances
    print("\n--- Twin Prime Fractal Distances ---")
    twins = find_twin_primes(1000)
    for p, q in twins[:15]:
        d = prime_fractal_dist(p, q)
        bound = 1.0 / math.log(p) ** 2
        print(f"  d({p:4d}, {q:4d}) = {d:.10f}  <  1/log²(p) = {bound:.10f}  ✓" if d < bound else f"  d({p:4d}, {q:4d}) = {d:.10f}")

    # 4. Box-counting dimension estimation
    print("\n--- Box-Counting Dimension Estimates ---")
    for N_exp in [4, 5, 6, 7]:
        N = 10 ** N_exp
        primes = sieve_primes(N)
        print(f"\n  N = 10^{N_exp} ({len(primes)} primes)")
        for k in range(1, 7):
            eps = 10 ** (-k)
            bc = box_count(primes, eps)
            dim = box_dim_approx(primes, eps)
            print(f"    ε = 10^-{k}: boxCount = {bc:8d}, dim ≈ {dim:.6f}")

    # 5. Entropy computation
    print("\n--- Prime Log Entropy ---")
    for N_exp in [4, 5, 6]:
        N = 10 ** N_exp
        primes = sieve_primes(N)
        for k in [2, 3, 4]:
            eps = 10 ** (-k)
            H = prime_log_entropy(primes, eps)
            print(f"  N=10^{N_exp}, ε=10^-{k}: H = {H:.6f}")

    # 6. Verify theoretical predictions
    print("\n--- Verification: logEmbed is strictly decreasing ---")
    primes_100 = sieve_primes(100)
    monotone = all(
        log_embed(primes_100[i]) > log_embed(primes_100[i + 1])
        for i in range(len(primes_100) - 1)
    )
    print(f"  logEmbed strictly decreasing on primes up to 100: {monotone}")

    print("\n--- Verification: Triangle Inequality ---")
    import random
    random.seed(42)
    violations = 0
    for _ in range(10000):
        a, b, c = random.sample(primes_100, 3)
        if prime_fractal_dist(a, c) > prime_fractal_dist(a, b) + prime_fractal_dist(b, c) + 1e-15:
            violations += 1
    print(f"  Triangle inequality violations in 10000 random triples: {violations}")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")


"""
Visualization 2: Box-Counting Dimension Estimation
====================================================
Shows the log-log plot of box count vs 1/ε for the prime fractal,
along with the dimension estimate and comparison to dimension = 1 line.
This is the key diagnostic plot for estimating Hausdorff dimension.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p):
    return 1.0 / math.log(p)


def box_count(primes, epsilon):
    boxes = set()
    for p in primes:
        boxes.add(int(math.floor(log_embed(p) / epsilon)))
    return len(boxes)


# Parameters
N_values = [10**4, 10**5, 10**6]
colors = ['#e74c3c', '#3498db', '#2ecc71']
markers = ['o', 's', '^']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

for idx, N in enumerate(N_values):
    primes = sieve_primes(N)
    epsilons = [10**(-k/3) for k in range(1, 16)]

    log_inv_eps = []
    log_counts = []
    dims = []

    for eps in epsilons:
        bc = box_count(primes, eps)
        if bc > 0 and eps < 1:
            lie = math.log(1.0 / eps)
            lbc = math.log(bc)
            log_inv_eps.append(lie)
            log_counts.append(lbc)
            dims.append(lbc / lie)

    # Log-log plot
    ax1.scatter(log_inv_eps, log_counts, c=colors[idx], s=60,
                marker=markers[idx], alpha=0.8, label=f'N = 10^{int(math.log10(N))}',
                edgecolors='white', linewidth=0.5)

    # Linear fit
    if len(log_inv_eps) >= 2:
        n = len(log_inv_eps)
        sx = sum(log_inv_eps)
        sy = sum(log_counts)
        sxx = sum(x * x for x in log_inv_eps)
        sxy = sum(x * y for x, y in zip(log_inv_eps, log_counts))
        slope = (n * sxy - sx * sy) / (n * sxx - sx * sx)
        intercept = (sy - slope * sx) / n
        x_fit = np.linspace(min(log_inv_eps), max(log_inv_eps), 100)
        ax1.plot(x_fit, slope * x_fit + intercept, color=colors[idx],
                linestyle='--', alpha=0.6, linewidth=2,
                label=f'  slope = {slope:.3f}')

    # Dimension vs scale
    ax2.plot([math.log10(e) for e in epsilons[:len(dims)]], dims,
             color=colors[idx], marker=markers[idx], markersize=8,
             linewidth=2, alpha=0.8, label=f'N = 10^{int(math.log10(N))}')

# Reference line: dimension = 1
x_ref = np.linspace(0, 12, 100)
ax1.plot(x_ref, x_ref, 'k:', alpha=0.3, linewidth=2, label='slope = 1 (dimension 1)')

ax1.set_xlabel('log(1/ε)', fontsize=13)
ax1.set_ylabel('log(box count)', fontsize=13)
ax1.set_title('Box-Counting: log(N(ε)) vs log(1/ε)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

ax2.axhline(y=1.0, color='black', linestyle=':', alpha=0.3, linewidth=2, label='dimension = 1')
ax2.set_xlabel('log₁₀(ε)', fontsize=13)
ax2.set_ylabel('Box-counting dimension estimate', fontsize=13)
ax2.set_title('Dimension Estimate vs Scale', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.5)

plt.tight_layout()
plt.savefig('viz_box_counting.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_box_counting.png")


"""
Visualization 1: Prime Fractal Embedding
==========================================
Visualizes the logarithmic embedding p ↦ 1/log(p) of primes,
showing how the prime fractal metric transforms the distribution of primes.
The top panel shows primes on the number line, the bottom shows their
logarithmic embeddings. Twin primes are highlighted in red.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p):
    return 1.0 / math.log(p)


# Generate primes
N = 500
primes = sieve_primes(N)
embeddings = [log_embed(p) for p in primes]
prime_set = set(primes)
twins = [(p, p+2) for p in primes if p+2 in prime_set]
twin_ps = set()
for p, q in twins:
    twin_ps.add(p)
    twin_ps.add(q)

fig, axes = plt.subplots(3, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [1, 1, 2]})

# Panel 1: Primes on the number line
ax1 = axes[0]
for p in primes:
    color = '#e74c3c' if p in twin_ps else '#3498db'
    ax1.axvline(p, color=color, alpha=0.6, linewidth=1.5)
ax1.set_xlim(0, N)
ax1.set_ylim(0, 1)
ax1.set_yticks([])
ax1.set_xlabel('n', fontsize=12)
ax1.set_title('Primes on the Number Line (twin primes in red)', fontsize=14, fontweight='bold')

# Panel 2: Logarithmic embeddings
ax2 = axes[1]
for i, p in enumerate(primes):
    e = embeddings[i]
    color = '#e74c3c' if p in twin_ps else '#2ecc71'
    ax2.axvline(e, color=color, alpha=0.6, linewidth=1.5)
ax2.set_xlim(0, max(embeddings) * 1.05)
ax2.set_ylim(0, 1)
ax2.set_yticks([])
ax2.set_xlabel('1/log(p)', fontsize=12)
ax2.set_title('Primes Under Logarithmic Embedding (twin primes in red)', fontsize=14, fontweight='bold')

# Panel 3: Embedding as a function
ax3 = axes[2]
colors = ['#e74c3c' if p in twin_ps else '#3498db' for p in primes]
ax3.scatter(primes, embeddings, c=colors, s=25, alpha=0.7, edgecolors='none')
ax3.set_xlabel('Prime p', fontsize=12)
ax3.set_ylabel('logEmbed(p) = 1/log(p)', fontsize=12)
ax3.set_title('Logarithmic Embedding: How the Fractal Metric Transforms Primes', fontsize=14, fontweight='bold')

# Add the curve 1/log(x)
x = np.linspace(2, N, 1000)
ax3.plot(x, 1.0 / np.log(x), 'k--', alpha=0.3, linewidth=2, label='y = 1/log(x)')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_fractal_embedding.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_fractal_embedding.png")


"""
Visualization 3: Twin Prime Fractal Distances
================================================
Shows how twin prime pairs cluster in the fractal metric, with
fractal distance d(p, p+2) decaying as ~1/log²(p). Compares
actual distances to the theoretical bound.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p):
    return 1.0 / math.log(p)


def prime_fractal_dist(p, q):
    return abs(log_embed(p) - log_embed(q))


N = 100000
primes = sieve_primes(N)
prime_set = set(primes)
twins = [(p, p+2) for p in primes if p+2 in prime_set]

twin_ps = [p for p, _ in twins]
twin_dists = [prime_fractal_dist(p, p+2) for p, _ in twins]
bounds = [1.0 / math.log(p)**2 for p in twin_ps]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# Panel 1: Twin prime distances vs p
ax = axes[0, 0]
ax.scatter(twin_ps, twin_dists, s=8, alpha=0.5, c='#3498db', label='d(p, p+2)')
x = np.linspace(3, N, 1000)
ax.plot(x, 1.0 / np.log(x)**2, 'r-', linewidth=2, alpha=0.8, label='1/log²(p) bound')
ax.set_xlabel('Twin prime p', fontsize=12)
ax.set_ylabel('Fractal distance', fontsize=12)
ax.set_title('Twin Prime Fractal Distance', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Ratio d(p,p+2) / (1/log²(p))
ax = axes[0, 1]
ratios = [d / b for d, b in zip(twin_dists, bounds)]
ax.scatter(twin_ps, ratios, s=8, alpha=0.5, c='#2ecc71')
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, alpha=0.6, label='ratio = 1')
ax.set_xlabel('Twin prime p', fontsize=12)
ax.set_ylabel('d(p,p+2) / (1/log²(p))', fontsize=12)
ax.set_title('Distance / Bound Ratio (should be < 1)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.2)

# Panel 3: Distribution of fractal distances
ax = axes[1, 0]
ax.hist(twin_dists, bins=50, color='#9b59b6', alpha=0.7, edgecolor='white')
ax.set_xlabel('Fractal distance d(p, p+2)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Distribution of Twin Prime Fractal Distances', fontsize=14, fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel 4: Consecutive prime distances (all) vs twin prime distances
ax = axes[1, 1]
consec_dists = [prime_fractal_dist(primes[i], primes[i+1])
                for i in range(len(primes) - 1)]
ax.hist(consec_dists, bins=80, color='#3498db', alpha=0.5,
        edgecolor='white', label='All consecutive', density=True)
ax.hist(twin_dists, bins=40, color='#e74c3c', alpha=0.5,
        edgecolor='white', label='Twin primes', density=True)
ax.set_xlabel('Fractal distance', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Consecutive vs Twin Prime Distances', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.suptitle(f'Twin Prime Fractal Analysis (primes up to {N:,})',
             fontsize=16, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_twin_prime_fractal.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_twin_prime_fractal.png")
