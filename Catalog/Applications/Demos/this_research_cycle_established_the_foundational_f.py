#!/usr/bin/env python3
"""
Applications of Prime Persistent Homology

Shows real-world applications of the theoretical framework:
1. Prime gap prediction via barcode statistics
2. Cryptographic key size estimation from persistence
3. Random number quality testing via persistence entropy
4. Signal detection in number sequences
"""

from math import log, log2, sqrt, pi
from collections import defaultdict
from typing import List, Tuple, Dict


def sieve_primes(N: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


# --- Application 1: Gap Prediction ---

def predict_next_gap(primes: List[int], window: int = 50) -> float:
    """Predict the next prime gap using barcode persistence statistics.

    Uses the moving average of recent bar persistences (gaps) weighted
    by the log-density prediction from the Prime Number Theorem.

    The PNT suggests average gap near p ~ ln(p), so we blend the
    empirical barcode statistics with the theoretical prediction.
    """
    if len(primes) < window + 1:
        window = len(primes) - 1

    recent_gaps = [primes[-i] - primes[-i - 1] for i in range(1, window + 1)]
    empirical_avg = sum(recent_gaps) / len(recent_gaps)

    p = primes[-1]
    theoretical_avg = log(p) if p > 1 else 1.0

    # Blend with theoretical prediction (70% empirical, 30% theoretical)
    prediction = 0.7 * empirical_avg + 0.3 * theoretical_avg
    return prediction


def gap_prediction_accuracy(N: int) -> Dict[str, float]:
    """Evaluate gap prediction accuracy up to N."""
    primes = sieve_primes(N)

    errors_barcode = []
    errors_pnt = []

    for i in range(100, len(primes) - 1):
        actual_gap = primes[i + 1] - primes[i]

        # Barcode-based prediction
        pred_barcode = predict_next_gap(primes[:i + 1])
        errors_barcode.append(abs(actual_gap - pred_barcode))

        # Pure PNT prediction
        pred_pnt = log(primes[i])
        errors_pnt.append(abs(actual_gap - pred_pnt))

    return {
        "barcode_mae": sum(errors_barcode) / len(errors_barcode),
        "pnt_mae": sum(errors_pnt) / len(errors_pnt),
        "improvement": 1 - sum(errors_barcode) / sum(errors_pnt),
    }


# --- Application 2: Cryptographic Key Size ---

def estimate_key_strength(bit_length: int) -> Dict[str, float]:
    """Estimate RSA key strength using barcode persistence statistics.

    The security of RSA relies on the difficulty of factoring N = pq.
    The distribution of prime gaps (bar persistences) affects the
    density of primes near a given size, which impacts:
    - Expected time to find a prime of the given bit length
    - Expected gap between candidate prime and actual prime

    Returns security metrics based on persistence analysis.
    """
    # Approximate the largest prime of this bit length
    p_approx = 2 ** bit_length

    # Expected gap from PNT: ~ln(p) ~ bit_length * ln(2)
    expected_gap = bit_length * log(2)

    # Expected number of candidates to test
    expected_candidates = expected_gap / 2  # Only test odd numbers

    # Bertrand bound: gap < p, so worst case is bounded
    bertrand_bound = p_approx  # Our theorem guarantees this

    # Persistence entropy estimate (how "spread out" the gaps are)
    # Higher entropy = more uniform = harder to predict
    estimated_entropy = log2(expected_gap) if expected_gap > 1 else 0

    return {
        "bit_length": bit_length,
        "expected_gap": expected_gap,
        "expected_candidates_to_test": expected_candidates,
        "bertrand_worst_case_gap": bertrand_bound,
        "gap_entropy_estimate": estimated_entropy,
        "security_bits": bit_length // 2,  # Factoring complexity
    }


# --- Application 3: Randomness Quality Testing ---

def persistence_randomness_test(sequence: List[int]) -> Dict[str, float]:
    """Test the quality of a pseudo-random number sequence using
    persistence homology concepts.

    A truly random sequence of integers should have gap distributions
    that differ significantly from prime gaps. We measure:
    - Persistence entropy (should be higher for random)
    - Gap uniformity (random should be more uniform)
    - Bertrand ratio (meaningless for random, informative for primes)
    """
    if len(sequence) < 3:
        return {"error": "sequence too short"}

    sorted_seq = sorted(set(sequence))
    gaps = [sorted_seq[i + 1] - sorted_seq[i] for i in range(len(sorted_seq) - 1)]

    if not gaps:
        return {"error": "no gaps"}

    total = sum(gaps)

    # Persistence entropy
    entropy = 0.0
    for g in gaps:
        if g > 0 and total > 0:
            p = g / total
            entropy -= p * log2(p)

    # Gap uniformity (coefficient of variation)
    mean_gap = total / len(gaps)
    variance = sum((g - mean_gap) ** 2 for g in gaps) / len(gaps)
    cv = sqrt(variance) / mean_gap if mean_gap > 0 else 0

    # Max gap ratio
    max_ratio = max(gaps) / mean_gap if mean_gap > 0 else 0

    return {
        "entropy": entropy,
        "coefficient_of_variation": cv,
        "max_gap_ratio": max_ratio,
        "mean_gap": mean_gap,
        "num_distinct_gaps": len(set(gaps)),
    }


# --- Application 4: Signal Detection ---

def detect_prime_like_structure(sequence: List[int], N: int = 1000) -> float:
    """Detect whether a sequence has prime-like gap structure.

    Compares the persistence entropy and gap distribution of the input
    sequence against the prime barcode. Returns a similarity score
    in [0, 1] where 1 = identical to primes.

    Application: detecting structured patterns in noisy data.
    """
    primes = sieve_primes(N)

    # Compute prime gap statistics
    prime_gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
    prime_stats = persistence_randomness_test(primes)

    # Compute sequence statistics
    seq_stats = persistence_randomness_test(sequence)

    if "error" in seq_stats or "error" in prime_stats:
        return 0.0

    # Compare entropy
    entropy_diff = abs(prime_stats["entropy"] - seq_stats["entropy"])
    entropy_score = max(0, 1 - entropy_diff / max(prime_stats["entropy"], 0.01))

    # Compare coefficient of variation
    cv_diff = abs(prime_stats["coefficient_of_variation"] - seq_stats["coefficient_of_variation"])
    cv_score = max(0, 1 - cv_diff / max(prime_stats["coefficient_of_variation"], 0.01))

    # Weighted similarity
    similarity = 0.5 * entropy_score + 0.5 * cv_score
    return similarity


def main():
    print("=" * 60)
    print("APPLICATIONS OF PRIME PERSISTENT HOMOLOGY")
    print("=" * 60)

    # Application 1: Gap Prediction
    print("\n--- Application 1: Prime Gap Prediction ---")
    for N in [10000, 100000]:
        results = gap_prediction_accuracy(N)
        print(f"  N={N}:")
        print(f"    Barcode MAE: {results['barcode_mae']:.3f}")
        print(f"    PNT MAE:     {results['pnt_mae']:.3f}")
        print(f"    Improvement: {results['improvement']*100:.1f}%")

    # Application 2: Crypto Key Estimation
    print("\n--- Application 2: Cryptographic Key Analysis ---")
    for bits in [1024, 2048, 4096]:
        metrics = estimate_key_strength(bits)
        print(f"  {bits}-bit RSA:")
        print(f"    Expected gap: {metrics['expected_gap']:.1f}")
        print(f"    Candidates to test: {metrics['expected_candidates_to_test']:.1f}")
        print(f"    Gap entropy: {metrics['gap_entropy_estimate']:.2f} bits")

    # Application 3: Randomness Testing
    print("\n--- Application 3: Randomness Quality ---")
    import random
    random.seed(42)

    primes_100 = sieve_primes(1000)
    random_seq = sorted(random.sample(range(2, 1001), len(primes_100)))

    prime_quality = persistence_randomness_test(primes_100)
    random_quality = persistence_randomness_test(random_seq)

    print(f"  Prime sequence:  entropy={prime_quality['entropy']:.3f}, "
          f"CV={prime_quality['coefficient_of_variation']:.3f}")
    print(f"  Random sequence: entropy={random_quality['entropy']:.3f}, "
          f"CV={random_quality['coefficient_of_variation']:.3f}")

    # Application 4: Signal Detection
    print("\n--- Application 4: Structure Detection ---")
    primes_500 = sieve_primes(500)
    random_500 = sorted(random.sample(range(2, 501), min(len(primes_500), 95)))
    # Semi-structured: every other prime
    semi = primes_500[::2]

    print(f"  Prime similarity to primes: {detect_prime_like_structure(primes_500):.3f}")
    print(f"  Random similarity to primes: {detect_prime_like_structure(random_500):.3f}")
    print(f"  Semi-structured similarity: {detect_prime_like_structure(semi):.3f}")

    print("\n" + "=" * 60)
    print("All applications demonstrated.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Persistent Homology of Prime Numbers

Demonstrates the core mathematical results:
1. Prime gap computation and barcode construction
2. Bertrand bar length bound verification
3. Gap-death correspondence
4. Twin prime bar counting
5. Filtration connectivity
"""

from typing import List, Tuple
from math import isqrt


def sieve_primes(N: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(N) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


def prime_gaps(N: int) -> List[Tuple[int, int, int]]:
    """Compute prime gaps up to N.
    Returns list of (p_n, p_{n+1}, gap) tuples."""
    primes = sieve_primes(N)
    gaps = []
    for i in range(len(primes) - 1):
        gaps.append((primes[i], primes[i + 1], primes[i + 1] - primes[i]))
    return gaps


def persistence_barcode(N: int) -> List[Tuple[int, int]]:
    """Construct the H₀ persistence barcode for primes up to N.
    Each bar is (birth, death) = (p_n, p_{n+1}).
    The persistence is death - birth = prime gap."""
    primes = sieve_primes(N)
    bars = [(primes[i], primes[i + 1]) for i in range(len(primes) - 1)]
    return bars


def verify_bertrand_bound(N: int) -> bool:
    """Verify the Bertrand bar length bound: gap < birth for all bars.
    This is our formalized theorem bertrand_bar_length_bound."""
    bars = persistence_barcode(N)
    for birth, death in bars:
        gap = death - birth
        if gap >= birth:
            print(f"VIOLATION: gap={gap} >= birth={birth} at ({birth}, {death})")
            return False
    print(f"Bertrand bound verified for all {len(bars)} bars up to N={N}")
    return True


def count_twin_prime_bars(N: int) -> int:
    """Count bars with persistence exactly 2 (twin prime pairs)."""
    bars = persistence_barcode(N)
    twin_count = sum(1 for b, d in bars if d - b == 2)
    return twin_count


def gap_distribution(N: int) -> dict:
    """Compute the distribution of prime gaps (bar persistences)."""
    gaps = prime_gaps(N)
    dist = {}
    for _, _, g in gaps:
        dist[g] = dist.get(g, 0) + 1
    return dict(sorted(dist.items()))


def filtration_components(N: int, epsilon: int) -> List[List[int]]:
    """Compute connected components of the Rips graph at scale epsilon.
    Primes are connected if their gap is ≤ epsilon."""
    primes = sieve_primes(N)
    # Union-Find
    parent = {p: p for p in primes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(len(primes) - 1):
        if primes[i + 1] - primes[i] <= epsilon:
            union(primes[i], primes[i + 1])

    components = {}
    for p in primes:
        root = find(p)
        components.setdefault(root, []).append(p)

    return list(components.values())


def demo_main():
    print("=" * 60)
    print("PERSISTENT HOMOLOGY OF PRIME NUMBERS — DEMO")
    print("=" * 60)

    # 1. Prime gaps and barcode
    print("\n--- 1. Prime Gaps (first 20) ---")
    gaps = prime_gaps(100)
    for p1, p2, g in gaps[:20]:
        print(f"  p={p1:3d} → p'={p2:3d}  gap={g}  bar=[{p1}, {p2})")

    # 2. Bertrand bound verification
    print("\n--- 2. Bertrand Bar Length Bound ---")
    for N in [100, 1000, 10000, 100000]:
        verify_bertrand_bound(N)

    # 3. Twin prime bars
    print("\n--- 3. Twin Prime Bar Count ---")
    for N in [100, 1000, 10000, 100000, 1000000]:
        count = count_twin_prime_bars(N)
        total = len(persistence_barcode(N))
        print(f"  N={N:>8d}: {count:>5d} twin bars out of {total:>6d} total "
              f"({100*count/total:.1f}%)")

    # 4. Gap distribution
    print("\n--- 4. Gap Distribution (N=10000) ---")
    dist = gap_distribution(10000)
    for gap, count in list(dist.items())[:15]:
        bar = "█" * (count // 5)
        print(f"  gap={gap:3d}: {count:4d} {bar}")

    # 5. Filtration components
    print("\n--- 5. Filtration Components (N=50) ---")
    for eps in [1, 2, 4, 6, 10, 50]:
        comps = filtration_components(50, eps)
        print(f"  ε={eps:2d}: {len(comps)} components "
              f"(sizes: {sorted([len(c) for c in comps], reverse=True)[:5]})")

    # 6. Gap-death correspondence
    print("\n--- 6. Gap-Death Correspondence ---")
    print("  Each prime gap corresponds exactly to a bar death:")
    gaps_100 = prime_gaps(50)
    for p1, p2, g in gaps_100:
        print(f"  Gap [{p1},{p2}] of size {g} → bar dies at ε={g}")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    demo_main()


#!/usr/bin/env python3
"""
Visualization 1: H₀ Persistence Barcode of the Prime Point Cloud

This visualizes the persistence barcode for the Rips filtration on primes.
Each horizontal bar represents a connected component, with birth at the
prime value and death when it merges with a neighbor. The Bertrand bar
length bound (gap < birth) is shown as a diagonal boundary.

What this visualizes: The core mathematical object — the prime barcode —
showing how prime gaps translate into topological persistence.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


def main():
    N = 200
    primes = sieve_primes(N)

    fig, axes = plt.subplots(2, 1, figsize=(14, 10), height_ratios=[2, 1])

    # --- Top: Barcode diagram ---
    ax = axes[0]
    colors = []
    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        if gap == 2:
            colors.append('#e74c3c')  # Twin primes: red
        elif gap == 4:
            colors.append('#f39c12')  # Cousin primes: orange
        elif gap == 6:
            colors.append('#2ecc71')  # Sexy primes: green
        else:
            colors.append('#3498db')  # Other: blue

    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        ax.barh(i, gap, left=primes[i], height=0.7, color=colors[i],
                alpha=0.8, edgecolor='white', linewidth=0.3)

    ax.set_xlabel('Prime Value', fontsize=12)
    ax.set_ylabel('Bar Index', fontsize=12)
    ax.set_title(f'H₀ Persistence Barcode of Primes ≤ {N}\n'
                 'Each bar represents a connected component; color = gap type',
                 fontsize=14, fontweight='bold')

    # Legend
    patches = [
        mpatches.Patch(color='#e74c3c', label='Gap 2 (twin primes)'),
        mpatches.Patch(color='#f39c12', label='Gap 4 (cousin primes)'),
        mpatches.Patch(color='#2ecc71', label='Gap 6 (sexy primes)'),
        mpatches.Patch(color='#3498db', label='Other gaps'),
    ]
    ax.legend(handles=patches, loc='lower right', fontsize=10)

    # --- Bottom: Gap distribution ---
    ax2 = axes[1]
    gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
    unique_gaps = sorted(set(gaps))
    gap_counts = [gaps.count(g) for g in unique_gaps]

    bar_colors = []
    for g in unique_gaps:
        if g == 2:
            bar_colors.append('#e74c3c')
        elif g == 4:
            bar_colors.append('#f39c12')
        elif g == 6:
            bar_colors.append('#2ecc71')
        else:
            bar_colors.append('#3498db')

    ax2.bar(unique_gaps, gap_counts, color=bar_colors, edgecolor='white',
            width=1.5, alpha=0.85)
    ax2.set_xlabel('Gap Size (Bar Persistence)', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Bar Persistences (Gap Sizes)', fontsize=13)

    plt.tight_layout()
    plt.savefig('viz_barcode.png', dpi=150, bbox_inches='tight')
    print("Saved viz_barcode.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Persistence Entropy Growth of the Prime Barcode

Shows how persistence entropy H(N) grows with N, compared to log(log(N)).
This connects prime distribution (number theory) to information theory
via the barcode formalism — a cross-domain bridge.

What this visualizes: The information-theoretic complexity of the prime
gap distribution, suggesting deep connections between entropy and the
Prime Number Theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import log2, log


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


def persistence_entropy(primes):
    if len(primes) <= 1:
        return 0.0
    gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
    total = sum(gaps)
    if total == 0:
        return 0.0
    entropy = 0.0
    for g in gaps:
        if g > 0:
            p = g / total
            entropy -= p * log2(p)
    return entropy


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Compute entropy for various N
    all_primes = sieve_primes(100000)
    N_values = list(range(50, 100001, 100))
    entropies = []
    for N in N_values:
        primes_N = [p for p in all_primes if p <= N]
        entropies.append(persistence_entropy(primes_N))

    # --- Left: Entropy growth ---
    ax = axes[0]
    ax.plot(N_values, entropies, color='#2c3e50', linewidth=1.5, label='H(N)')

    # Theoretical comparison: c * log(log(N))
    log_log = [1.8 * log(log(N)) / log(2) if N > 2 else 0 for N in N_values]
    ax.plot(N_values, log_log, color='#e74c3c', linewidth=2, linestyle='--',
            label='c · log₂(log N)', alpha=0.7)

    ax.set_xlabel('N', fontsize=13)
    ax.set_ylabel('Persistence Entropy H(N) [bits]', fontsize=13)
    ax.set_title('Persistence Entropy Growth\nof the Prime Barcode',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # --- Middle: Entropy vs π(N) ---
    ax = axes[1]
    prime_counts = []
    for N in N_values:
        prime_counts.append(len([p for p in all_primes if p <= N]))

    ax.scatter(prime_counts, entropies, s=3, alpha=0.5, color='#3498db')
    ax.set_xlabel('π(N) = Number of Primes ≤ N', fontsize=13)
    ax.set_ylabel('Persistence Entropy H(N) [bits]', fontsize=13)
    ax.set_title('Entropy vs Prime Count\nCross-Domain: Number Theory ↔ Information Theory',
                 fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)

    # Fit line
    log_pc = [log2(pc) if pc > 0 else 0 for pc in prime_counts]
    valid = [(lp, e) for lp, e in zip(log_pc, entropies) if lp > 0]
    if valid:
        x_fit = np.array([v[0] for v in valid])
        y_fit = np.array([v[1] for v in valid])
        coeffs = np.polyfit(x_fit, y_fit, 1)
        x_line = np.linspace(min(x_fit), max(x_fit), 100)
        ax.plot(np.power(2, x_line), np.polyval(coeffs, x_line),
                color='#e74c3c', linewidth=2, linestyle='--',
                label=f'Fit: H ≈ {coeffs[0]:.2f}·log₂(π(N)) + {coeffs[1]:.2f}')
        ax.legend(fontsize=10)

    # --- Right: Comparison with random ---
    ax = axes[2]

    # Prime entropy
    ax.plot(N_values[::5], entropies[::5], 'o-', color='#2c3e50',
            markersize=3, linewidth=1, label='Prime barcode entropy')

    # Random: entropy of uniform gaps
    np.random.seed(42)
    random_entropies = []
    for N in N_values[::5]:
        n_points = len([p for p in all_primes if p <= N])
        if n_points <= 1:
            random_entropies.append(0)
            continue
        random_points = sorted(np.random.choice(range(2, N + 1), size=n_points, replace=False))
        random_gaps = [random_points[i + 1] - random_points[i] for i in range(len(random_points) - 1)]
        total = sum(random_gaps)
        if total == 0:
            random_entropies.append(0)
            continue
        ent = 0
        for g in random_gaps:
            if g > 0:
                p = g / total
                ent -= p * log2(p)
        random_entropies.append(ent)

    ax.plot(N_values[::5], random_entropies, 's-', color='#e74c3c',
            markersize=3, linewidth=1, label='Random point cloud entropy')

    # Maximum possible entropy
    max_ent = [log2(len([p for p in all_primes if p <= N]) - 1)
               if len([p for p in all_primes if p <= N]) > 1 else 0
               for N in N_values[::5]]
    ax.plot(N_values[::5], max_ent, '--', color='#27ae60',
            linewidth=1.5, label='Max entropy (uniform)')

    ax.set_xlabel('N', fontsize=13)
    ax.set_ylabel('Entropy [bits]', fontsize=13)
    ax.set_title('Prime vs Random Entropy\nPrimes have lower entropy → more structure',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved viz_entropy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: Rips Filtration on the Prime Point Cloud

Shows how connected components evolve as the scale parameter ε increases.
The Betti number β₀(ε) tracks the number of components. This visualizes
the filtration monotonicity theorem (epsChain_monotone) and the
completeness theorem (rips_connected_at_N).

What this visualizes: The topology of the prime point cloud changing with
scale, demonstrating the fundamental filtration monotonicity.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


class UnionFind:
    def __init__(self, elements):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}
        self.n_components = len(elements)

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.n_components -= 1
        return True

    def components(self):
        comps = defaultdict(list)
        for x in self.parent:
            comps[self.find(x)].append(x)
        return list(comps.values())


def main():
    N = 100
    primes = sieve_primes(N)

    fig, axes = plt.subplots(2, 2, figsize=(16, 12))

    # Compute Betti curve
    gaps = sorted(set(primes[i + 1] - primes[i] for i in range(len(primes) - 1)))
    edges_by_gap = defaultdict(list)
    for i in range(len(primes) - 1):
        g = primes[i + 1] - primes[i]
        edges_by_gap[g].append((primes[i], primes[i + 1]))

    betti_eps = [0]
    betti_val = [len(primes)]
    uf_global = UnionFind(primes)

    for gap in gaps:
        for p, q in edges_by_gap[gap]:
            uf_global.union(p, q)
        betti_eps.append(gap)
        betti_val.append(uf_global.n_components)

    # --- Top left: Betti curve ---
    ax = axes[0][0]
    ax.step(betti_eps, betti_val, where='post', color='#2c3e50', linewidth=2.5)
    ax.fill_between(betti_eps, betti_val, step='post', alpha=0.15, color='#3498db')
    ax.set_xlabel('Scale parameter ε', fontsize=12)
    ax.set_ylabel('β₀(ε) = # Components', fontsize=12)
    ax.set_title('Betti Number Function β₀(ε)\nMonotone Decreasing (epsChain_monotone)',
                 fontsize=13, fontweight='bold')
    ax.axhline(y=1, color='#e74c3c', linestyle='--', alpha=0.5, label='Fully connected')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # --- Top right: Point cloud at different scales ---
    ax = axes[0][1]
    epsilon_values = [1, 2, 6, 14]
    y_offsets = [3, 2, 1, 0]

    for eps_val, y_off in zip(epsilon_values, y_offsets):
        uf = UnionFind(primes)
        for i in range(len(primes) - 1):
            if primes[i + 1] - primes[i] <= eps_val:
                uf.union(primes[i], primes[i + 1])

        comps = uf.components()
        comp_colors = plt.cm.Set3(np.linspace(0, 1, max(len(comps), 1)))

        for idx, comp in enumerate(comps):
            color = comp_colors[idx % len(comp_colors)]
            ax.scatter(comp, [y_off] * len(comp), c=[color], s=30,
                      edgecolors='black', linewidths=0.3, zorder=5)
            if len(comp) > 1:
                ax.plot([min(comp), max(comp)], [y_off, y_off],
                       color=color, alpha=0.5, linewidth=2)

    ax.set_yticks(y_offsets)
    ax.set_yticklabels([f'ε={e}' for e in epsilon_values])
    ax.set_xlabel('Prime Value', fontsize=12)
    ax.set_title('Connected Components at Different Scales\n'
                 'Colors show clusters', fontsize=13, fontweight='bold')

    # --- Bottom left: Bertrand ratio plot ---
    ax = axes[1][0]
    N_large = 10000
    primes_large = sieve_primes(N_large)
    ratios = [(primes_large[i + 1] - primes_large[i]) / primes_large[i]
              for i in range(len(primes_large) - 1)]

    ax.scatter(primes_large[:-1], ratios, s=1, alpha=0.3, color='#3498db')
    ax.axhline(y=1, color='#e74c3c', linewidth=2, linestyle='--',
               label='Bertrand bound (gap/birth < 1)')

    # Running max
    running_max = []
    curr_max = 0
    for r in ratios:
        curr_max = max(curr_max, r)
        running_max.append(curr_max)
    ax.plot(primes_large[:-1], running_max, color='#e74c3c', alpha=0.7,
            linewidth=1, label='Running maximum')

    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Gap / p', fontsize=12)
    ax.set_title(f'Bertrand Bar Length Bound (N={N_large})\n'
                 'All ratios < 1 (formally verified)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.3)

    # --- Bottom right: Deaths per scale ---
    ax = axes[1][1]
    N_deaths = 1000
    primes_d = sieve_primes(N_deaths)
    gap_counts = defaultdict(int)
    for i in range(len(primes_d) - 1):
        g = primes_d[i + 1] - primes_d[i]
        gap_counts[g] += 1

    gap_vals = sorted(gap_counts.keys())
    counts = [gap_counts[g] for g in gap_vals]

    ax.bar(gap_vals, counts, color='#9b59b6', edgecolor='white', alpha=0.85)
    ax.set_xlabel('Gap Size ε (Filtration Death Scale)', fontsize=12)
    ax.set_ylabel('Number of Deaths', fontsize=12)
    ax.set_title(f'Gap-Death Correspondence (N={N_deaths})\n'
                 'Each gap = exactly one bar death', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
    print("Saved viz_filtration.png")


if __name__ == "__main__":
    main()
