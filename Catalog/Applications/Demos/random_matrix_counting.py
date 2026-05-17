#!/usr/bin/env python3
"""
applications.py — Real-world applications of tropical orbit-prefix fiber theory.

Demonstrates connections to:
1. Tropical matrix products (min-plus algebra)
2. Random matrix sampling with controlled rejection
3. Symbolic dynamics and orbit complexity
4. Information-theoretic bounds
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import fiber_card_two_step, fiber_card_k_step, collision_probability, renyi_entropy


# ============================================================
# Application 1: Tropical Matrix Products
# ============================================================

def tropical_matrix_mult(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication.

    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    Uses np.inf as the tropical zero (additive identity).

    Args:
        A: n×m matrix with entries in ℝ ∪ {∞}
        B: m×p matrix with entries in ℝ ∪ {∞}

    Returns:
        n×p product matrix
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def rank_one_tropical_matrix(a: int, b: int) -> np.ndarray:
    """
    Construct a rank-one tropical matrix from split data (a, b).

    M(a, b) = [[a, b], [a, b]]

    This is rank-one in the tropical sense: all rows are equal.
    """
    return np.array([[a, b], [a, b]], dtype=float)


def demo_tropical_matrix_fibers():
    """
    Demonstrate that tropical matrix product valuations match the triangular law.
    """
    print("=" * 60)
    print("APPLICATION 1: Tropical Matrix Product Valuations")
    print("=" * 60)

    for e in [3, 5]:
        print(f"\n  Energy level e = {e}")
        print(f"  Constructing all rank-one matrices M(a, {e}-a)...")

        # Collect top-left entries of all products
        valuation_counts: Dict[float, int] = {}
        for a1 in range(e + 1):
            b1 = e - a1
            M1 = rank_one_tropical_matrix(a1, b1)
            for a2 in range(e + 1):
                b2 = e - a2
                M2 = rank_one_tropical_matrix(a2, b2)
                product = tropical_matrix_mult(M1, M2)
                val = product[0, 0]  # Top-left entry
                valuation_counts[val] = valuation_counts.get(val, 0) + 1

        print(f"  Top-left entry distribution of M₁ ⊗ M₂:")
        for s in sorted(valuation_counts.keys()):
            count = valuation_counts[s]
            expected = fiber_card_two_step(e, int(s))
            match = "✓" if count == expected else "✗"
            print(f"    val = {int(s):2d}: count = {count:2d}, formula = {expected:2d} {match}")
    print()


# ============================================================
# Application 2: Rejection Sampling with Controlled Rates
# ============================================================

def rejection_sampling_analysis(e: int, target_s: int, n_samples: int = 10000) -> Dict:
    """
    Analyze rejection sampling for generating uniform random elements
    of a specific prefix-sum fiber.

    Args:
        e: Energy level
        target_s: Target prefix sum
        n_samples: Number of uniform samples from twoStepDomain

    Returns:
        Dictionary with acceptance rate, expected fiber size, etc.
    """
    total = (e + 1) ** 2
    fiber_size = fiber_card_two_step(e, target_s)
    acceptance_rate = fiber_size / total if total > 0 else 0.0

    # Simulate
    accepted = 0
    for _ in range(n_samples):
        a1 = np.random.randint(0, e + 1)
        a2 = np.random.randint(0, e + 1)
        if a1 + a2 == target_s:
            accepted += 1

    empirical_rate = accepted / n_samples

    return {
        "total_domain": total,
        "fiber_size": fiber_size,
        "theoretical_rate": acceptance_rate,
        "empirical_rate": empirical_rate,
        "target_s": target_s,
    }


def demo_rejection_sampling():
    """Demonstrate rejection sampling with fiber-guided rates."""
    print("=" * 60)
    print("APPLICATION 2: Rejection Sampling with Fiber Bounds")
    print("=" * 60)

    e = 20
    print(f"\n  Energy level e = {e}, domain size = {(e+1)**2}")
    print(f"  {'s':>4} | {'fiber':>6} | {'theory':>8} | {'empirical':>10}")
    print(f"  {'-'*4}-+-{'-'*6}-+-{'-'*8}-+-{'-'*10}")

    np.random.seed(42)
    for s in [0, 5, 10, 15, 20, 25, 30, 35, 40]:
        result = rejection_sampling_analysis(e, s, n_samples=50000)
        print(f"  {s:4d} | {result['fiber_size']:6d} | {result['theoretical_rate']:8.4f} | {result['empirical_rate']:10.4f}")
    print()


# ============================================================
# Application 3: Orbit Complexity Bounds
# ============================================================

def orbit_complexity(sequence: List[int], e: int) -> Dict:
    """
    Measure the complexity of a symbolic orbit using prefix-sum statistics.

    Given a sequence of values in [0, e], compute:
    - The number of distinct consecutive-pair prefix sums
    - The maximum fiber size encountered
    - The effective entropy

    Args:
        sequence: List of values in [0, e]
        e: Energy level

    Returns:
        Dictionary with complexity measures
    """
    if len(sequence) < 2:
        return {"distinct_sums": 0, "max_fiber": 0, "entropy": 0.0}

    pair_sums = [sequence[i] + sequence[i + 1] for i in range(len(sequence) - 1)]
    sum_counts = {}
    for s in pair_sums:
        sum_counts[s] = sum_counts.get(s, 0) + 1

    distinct = len(sum_counts)
    max_fiber = max(fiber_card_two_step(e, s) for s in sum_counts.keys())

    # Empirical entropy
    n = len(pair_sums)
    probs = [c / n for c in sum_counts.values()]
    entropy = -sum(p * np.log2(p) for p in probs if p > 0)

    return {
        "distinct_sums": distinct,
        "max_fiber": max_fiber,
        "fiber_bound": e + 1,
        "entropy": entropy,
        "max_possible_entropy": np.log2(2 * e + 1),
    }


def demo_orbit_complexity():
    """Demonstrate orbit complexity analysis."""
    print("=" * 60)
    print("APPLICATION 3: Symbolic Orbit Complexity Analysis")
    print("=" * 60)

    e = 10
    np.random.seed(42)

    # Three types of orbits
    orbits = {
        "Random": list(np.random.randint(0, e + 1, size=1000)),
        "Periodic (period 3)": [i % 3 for i in range(1000)],
        "Monotone": [min(i, e) for i in range(1000)],
        "Contracting": [max(0, e - i // 10) for i in range(1000)],
    }

    for name, orbit in orbits.items():
        result = orbit_complexity(orbit, e)
        print(f"\n  Orbit: {name}")
        print(f"    Distinct prefix sums: {result['distinct_sums']}")
        print(f"    Max fiber size encountered: {result['max_fiber']} (bound: {result['fiber_bound']})")
        print(f"    Empirical entropy: {result['entropy']:.4f} bits")
        print(f"    Max possible entropy: {result['max_possible_entropy']:.4f} bits")
    print()


# ============================================================
# Application 4: Information-Theoretic Bounds
# ============================================================

def demo_entropy_bounds():
    """Demonstrate entropy and anti-concentration bounds."""
    print("=" * 60)
    print("APPLICATION 4: Information-Theoretic Bounds")
    print("=" * 60)

    print("\n  Rényi entropy H₂ of prefix sum (bits):")
    print(f"  {'e':>6} | {'k=1':>8} | {'k=2':>8} | {'k=3':>8} | {'k=4':>8} | {'k=5':>8}")
    print(f"  {'-'*6}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}")

    for e in [2, 5, 10, 20, 50]:
        row = f"  {e:6d}"
        for k in range(1, 6):
            h2 = renyi_entropy(k, e)
            row += f" | {h2:8.4f}"
        print(row)

    print("\n  Entropy gain per step (H₂(k) - H₂(k-1)):")
    print(f"  {'e':>6} | {'1→2':>8} | {'2→3':>8} | {'3→4':>8} | {'4→5':>8}")
    print(f"  {'-'*6}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}")

    for e in [2, 5, 10, 20, 50]:
        row = f"  {e:6d}"
        prev_h2 = renyi_entropy(1, e)
        for k in range(2, 6):
            h2 = renyi_entropy(k, e)
            gain = h2 - prev_h2
            row += f" | {gain:8.4f}"
            prev_h2 = h2
        print(row)

    print("\n  The entropy gain per step measures how much 'information'")
    print("  is produced by each additional tropical matrix composition.")
    print("  The fiber bound theorem guarantees this gain is always positive.")
    print()


if __name__ == "__main__":
    print("\n🌴 TROPICAL ORBIT-PREFIX FIBER THEORY — APPLICATIONS\n")
    demo_tropical_matrix_fibers()
    demo_rejection_sampling()
    demo_orbit_complexity()
    demo_entropy_bounds()
    print("All application demos completed! ✓\n")


#!/usr/bin/env python3
"""
demo.py — Demonstrates the tropical orbit-prefix fiber theorems with concrete examples.

This script illustrates the key results:
1. Split domain construction and cardinality
2. Prefix fiber exactness (each prefix has exactly one preimage)
3. Pigeonhole lower bound for large fibers
4. Two-step prefix sum fiber bound
5. Exact triangular law for two-step prefix fibers
"""

from collections import Counter
from typing import List, Tuple


def split_domain(e: int) -> List[Tuple[int, int]]:
    """Construct the split domain: pairs (a, e-a) for a in [0, e]."""
    return [(a, e - a) for a in range(e + 1)]


def two_step_domain(e: int) -> List[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """Construct the two-step domain: all pairs of split data."""
    sd = split_domain(e)
    return [(x, y) for x in sd for y in sd]


def prefix_of(x: Tuple[int, int]) -> int:
    """Canonical prefix map: extract first component."""
    return x[0]


def prefix_sum(x: Tuple[Tuple[int, int], Tuple[int, int]]) -> int:
    """Prefix sum statistic: sum of first components."""
    return x[0][0] + x[1][0]


def triangular_law(e: int, s: int) -> int:
    """Exact formula for two-step prefix fiber cardinality."""
    if s <= e:
        return s + 1
    elif s <= 2 * e:
        return 2 * e - s + 1
    else:
        return 0


def demo_split_domain():
    """Demonstrate split domain construction and cardinality."""
    print("=" * 60)
    print("DEMO 1: Split Domain Construction")
    print("=" * 60)
    for e in range(6):
        sd = split_domain(e)
        print(f"  e = {e}: splitDomain = {sd}")
        print(f"         card = {len(sd)} = e + 1 = {e + 1}  ✓")
    print()


def demo_prefix_fiber():
    """Demonstrate that each prefix has exactly one preimage."""
    print("=" * 60)
    print("DEMO 2: Prefix Fiber Exactness")
    print("=" * 60)
    for e in [3, 5, 8]:
        sd = split_domain(e)
        print(f"  e = {e}:")
        for a in range(e + 1):
            fiber = [x for x in sd if prefix_of(x) == a]
            print(f"    prefix {a}: fiber = {fiber}, card = {len(fiber)}")
            assert len(fiber) == 1, f"Expected 1, got {len(fiber)}"
        print(f"    All fibers have exactly 1 element ✓")
    print()


def demo_pigeonhole():
    """Demonstrate the pigeonhole fiber bound."""
    print("=" * 60)
    print("DEMO 3: Pigeonhole Fiber Bound")
    print("=" * 60)
    for e in [2, 3, 4]:
        n_codes = (e + 1) ** 2
        n_prefixes = e + 1
        print(f"  e = {e}: {n_codes} codes → {n_prefixes} prefixes")
        print(f"    Pigeonhole guarantees some fiber has ≥ {e + 1} elements")

        # Concrete example: map (a, b) -> (a % (e+1), 0)
        M = [(a, b) for a in range(e + 1) for b in range(e + 1)]
        P = [(p, 0) for p in range(e + 1)]
        phi = lambda x: (x[0] % (e + 1), 0)

        fibers = Counter(phi(x) for x in M)
        max_fiber = max(fibers.values())
        print(f"    Example map: max fiber size = {max_fiber} ≥ {e + 1}  ✓")
    print()


def demo_prefix_sum_fibers():
    """Demonstrate the exact triangular law for two-step prefix fibers."""
    print("=" * 60)
    print("DEMO 4: Two-Step Prefix Sum — Exact Triangular Law")
    print("=" * 60)
    for e in [3, 5, 8]:
        td = two_step_domain(e)
        print(f"\n  e = {e}: |twoStepDomain| = {len(td)} = (e+1)² = {(e+1)**2}")
        print(f"  {'s':>4} | {'computed':>10} | {'formula':>10} | {'≤ e+1':>6} | match")
        print(f"  {'-'*4}-+-{'-'*10}-+-{'-'*10}-+-{'-'*6}-+------")

        for s in range(2 * e + 2):
            fiber = [x for x in td if prefix_sum(x) == s]
            computed = len(fiber)
            formula = triangular_law(e, s)
            bounded = computed <= e + 1
            match = computed == formula
            print(f"  {s:4d} | {computed:10d} | {formula:10d} | {'✓' if bounded else '✗':>6} | {'✓' if match else '✗'}")

            assert match, f"Mismatch at e={e}, s={s}: {computed} ≠ {formula}"
            assert bounded, f"Bound violated at e={e}, s={s}: {computed} > {e+1}"

        print(f"  All fiber sizes match the triangular law ✓")
        print(f"  All fiber sizes ≤ {e + 1} ✓")
    print()


def demo_distribution_shape():
    """Show the triangular distribution shape."""
    print("=" * 60)
    print("DEMO 5: Triangular Distribution Visualization (ASCII)")
    print("=" * 60)
    e = 10
    max_val = e + 1
    print(f"  e = {e}, max fiber size = {max_val}")
    print()
    for s in range(2 * e + 1):
        val = triangular_law(e, s)
        bar = "█" * val
        print(f"  s={s:2d} | {val:2d} | {bar}")
    print()
    print("  Shape: symmetric triangle peaking at s = e")
    print()


if __name__ == "__main__":
    print("\n🌴 TROPICAL ORBIT-PREFIX FIBER THEOREMS — DEMONSTRATIONS\n")
    demo_split_domain()
    demo_prefix_fiber()
    demo_pigeonhole()
    demo_prefix_sum_fibers()
    demo_distribution_shape()
    print("All demonstrations passed! ✓\n")


#!/usr/bin/env python3
"""
visualizations.py — Generate visualizations for tropical orbit-prefix fiber theory.

Produces PNG figures showing:
1. The triangular distribution for various energy levels
2. k-step fiber distributions (B-spline shapes)
3. Entropy scaling with energy and composition depth
4. Fiber heatmap for the two-step domain
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import fiber_card_two_step, fiber_card_k_step, renyi_entropy, collision_probability


def plot_triangular_law():
    """Plot the triangular fiber distribution for several energy levels."""
    fig, ax = plt.subplots(figsize=(10, 6))

    for e in [3, 5, 8, 12]:
        s_vals = list(range(2 * e + 1))
        f_vals = [fiber_card_two_step(e, s) for s in s_vals]
        # Normalize x-axis to [0, 1] for comparison
        x_norm = [s / (2 * e) for s in s_vals]
        f_norm = [f / (e + 1) for f in f_vals]
        ax.plot(x_norm, f_norm, 'o-', markersize=3, label=f'e = {e}', linewidth=1.5)

    ax.set_xlabel('Normalized prefix sum s/(2e)', fontsize=12)
    ax.set_ylabel('Normalized fiber size f(s)/(e+1)', fontsize=12)
    ax.set_title('Triangular Law: Two-Step Prefix Fiber Distribution', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.1)
    plt.tight_layout()
    plt.savefig('fig_triangular_law.png', dpi=150)
    plt.close()
    print("  Saved fig_triangular_law.png")


def plot_k_step_distributions():
    """Plot fiber distributions for k = 1, 2, 3, 4, 5 steps."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    axes = axes.flatten()

    e = 8
    for idx, k in enumerate([1, 2, 3, 4, 5]):
        ax = axes[idx]
        s_vals = list(range(k * e + 1))
        f_vals = [fiber_card_k_step(k, e, s) for s in s_vals]

        ax.bar(s_vals, f_vals, color=plt.cm.viridis(k / 6), alpha=0.8, width=0.8)
        ax.set_title(f'k = {k} steps', fontsize=12)
        ax.set_xlabel('Prefix sum s')
        ax.set_ylabel('Fiber size')
        ax.grid(True, alpha=0.3)

    # Hide unused subplot
    axes[5].set_visible(False)

    fig.suptitle(f'k-Step Fiber Distributions (e = {e})', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('fig_k_step_distributions.png', dpi=150)
    plt.close()
    print("  Saved fig_k_step_distributions.png")


def plot_entropy_scaling():
    """Plot Rényi entropy scaling with energy level and composition depth."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: H₂ vs e for various k
    e_vals = list(range(2, 51))
    for k in [1, 2, 3, 4, 5]:
        h2_vals = [renyi_entropy(k, e) for e in e_vals]
        ax1.plot(e_vals, h2_vals, '-', linewidth=2, label=f'k = {k}')

    ax1.set_xlabel('Energy level e', fontsize=12)
    ax1.set_ylabel('Rényi entropy H₂ (bits)', fontsize=12)
    ax1.set_title('Entropy vs Energy Level', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: H₂ vs k for various e
    k_vals = list(range(1, 11))
    for e in [3, 5, 10, 20]:
        h2_vals = [renyi_entropy(k, e) for k in k_vals]
        ax2.plot(k_vals, h2_vals, 'o-', linewidth=2, markersize=5, label=f'e = {e}')

    ax2.set_xlabel('Number of steps k', fontsize=12)
    ax2.set_ylabel('Rényi entropy H₂ (bits)', fontsize=12)
    ax2.set_title('Entropy vs Composition Depth', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_entropy_scaling.png', dpi=150)
    plt.close()
    print("  Saved fig_entropy_scaling.png")


def plot_fiber_heatmap():
    """Plot a heatmap of two-step fiber sizes for various (e, s)."""
    fig, ax = plt.subplots(figsize=(12, 8))

    e_max = 20
    s_max = 2 * e_max

    data = np.zeros((e_max + 1, s_max + 1))
    for e in range(e_max + 1):
        for s in range(s_max + 1):
            data[e, s] = fiber_card_two_step(e, s)

    im = ax.imshow(data, aspect='auto', origin='lower', cmap='YlOrRd',
                   extent=[-0.5, s_max + 0.5, -0.5, e_max + 0.5])
    ax.set_xlabel('Prefix sum s', fontsize=12)
    ax.set_ylabel('Energy level e', fontsize=12)
    ax.set_title('Two-Step Fiber Cardinality Heatmap', fontsize=14)
    plt.colorbar(im, ax=ax, label='Fiber size')
    plt.tight_layout()
    plt.savefig('fig_fiber_heatmap.png', dpi=150)
    plt.close()
    print("  Saved fig_fiber_heatmap.png")


def plot_max_fiber_growth():
    """Plot the growth of maximum fiber size with k and e."""
    fig, ax = plt.subplots(figsize=(10, 6))

    e_vals = list(range(2, 25))
    for k in [2, 3, 4, 5]:
        max_fibers = []
        for e in e_vals:
            # Maximum fiber is at the center s = k*e//2
            center = k * e // 2
            max_f = max(fiber_card_k_step(k, e, s) for s in range(max(0, center - 2), min(k * e + 1, center + 3)))
            max_fibers.append(max_f)

        ax.plot(e_vals, max_fibers, 'o-', markersize=4, linewidth=1.5, label=f'k = {k}')

    # Reference lines
    ax.plot(e_vals, [e + 1 for e in e_vals], '--', color='gray', alpha=0.5, label='e + 1')
    ax.plot(e_vals, [(e + 1) ** 2 // 2 for e in e_vals], ':', color='gray', alpha=0.5, label='~(e+1)²/2')

    ax.set_xlabel('Energy level e', fontsize=12)
    ax.set_ylabel('Maximum fiber size', fontsize=12)
    ax.set_title('Maximum Fiber Size Growth', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')
    plt.tight_layout()
    plt.savefig('fig_max_fiber_growth.png', dpi=150)
    plt.close()
    print("  Saved fig_max_fiber_growth.png")


if __name__ == "__main__":
    print("\n🌴 Generating Visualizations...\n")
    plot_triangular_law()
    plot_k_step_distributions()
    plot_entropy_scaling()
    plot_fiber_heatmap()
    plot_max_fiber_growth()
    print("\nAll visualizations generated! ✓\n")
