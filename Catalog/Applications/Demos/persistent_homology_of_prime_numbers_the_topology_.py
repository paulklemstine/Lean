#!/usr/bin/env python3
"""
demo.py — Persistent Homology of Prime Numbers

Demonstrates the key concepts from the paper:
1. Computing the H_0 barcode (= prime gaps)
2. The 1D Rips Component Theorem in action
3. Component derivative showing gap counts
4. Comparison with exponential distribution (Cramér model)
"""

import math
from collections import Counter


def sieve_of_eratosthenes(limit: int) -> list[int]:
    """Return all primes up to `limit`."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i, p in enumerate(is_prime) if p]


def prime_gaps(primes: list[int]) -> list[int]:
    """Compute consecutive prime gaps."""
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def rips_components(gaps: list[int], epsilon: int) -> int:
    """Number of connected components at scale epsilon.
    By the 1D Rips Component Theorem: components = #{gaps > eps} + 1."""
    return sum(1 for g in gaps if g > epsilon) + 1


def component_derivative(gaps: list[int], k: int) -> int:
    """Components at scale k minus components at scale k+1.
    Equals the number of gaps equal to k+1."""
    return sum(1 for g in gaps if g == k + 1)


def barcode_statistics(gaps: list[int]) -> dict:
    """Compute statistics of the H_0 barcode."""
    n = len(gaps)
    if n == 0:
        return {}
    total = sum(gaps)
    mean = total / n
    max_gap = max(gaps)
    gap_counts = Counter(gaps)
    return {
        "num_bars": n,
        "total_bar_length": total,
        "mean_bar_length": mean,
        "max_bar_length": max_gap,
        "gap_distribution": dict(sorted(gap_counts.items())),
    }


def main():
    print("=" * 70)
    print("PERSISTENT HOMOLOGY OF PRIME NUMBERS")
    print("=" * 70)

    # Compute primes
    LIMIT = 1_000_000
    primes = sieve_of_eratosthenes(LIMIT)
    gaps = prime_gaps(primes)
    n_primes = len(primes)

    print(f"\nPrimes up to {LIMIT:,}: {n_primes:,} primes")
    print(f"Last prime: {primes[-1]:,}")
    print(f"Number of gaps: {len(gaps):,}")

    # --- Barcode Statistics ---
    print("\n" + "-" * 70)
    print("H_0 BARCODE STATISTICS (bar lengths = prime gaps)")
    print("-" * 70)
    stats = barcode_statistics(gaps)
    print(f"  Number of bars: {stats['num_bars']:,}")
    print(f"  Total bar length: {stats['total_bar_length']:,}")
    print(f"  Telescoping check: p_n - p_1 = {primes[-1] - primes[0]:,}")
    print(f"  Mean bar length: {stats['mean_bar_length']:.4f}")
    print(f"  log(p_n) = {math.log(primes[-1]):.4f}  (PNT prediction for mean)")
    print(f"  Max bar length: {stats['max_bar_length']}")
    print(f"  (log p_n)^2 = {math.log(primes[-1])**2:.2f}  (Cramér prediction for max)")

    # --- 1D Rips Component Theorem ---
    print("\n" + "-" * 70)
    print("1D RIPS COMPONENT THEOREM: C(ε) = #{gaps > ε} + 1")
    print("-" * 70)
    test_epsilons = [1, 2, 4, 6, 10, 20, 50, 100, 200]
    for eps in test_epsilons:
        c = rips_components(gaps, eps)
        print(f"  ε = {eps:>4}: {c:>6,} components")

    # --- Component Derivative (gap counting) ---
    print("\n" + "-" * 70)
    print("COMPONENT DERIVATIVE: C(k) - C(k+1) = #{gaps = k+1}")
    print("-" * 70)
    for k in [0, 1, 3, 5, 7, 9, 11, 17, 23, 29]:
        drop = component_derivative(gaps, k)
        print(f"  k = {k:>3}: drop = {drop:>5,}  (number of gaps of size {k + 1})")

    # Twin prime count
    twin_count = sum(1 for g in gaps if g == 2)
    print(f"\n  Twin prime pairs (gap=2): {twin_count:,}")
    print(f"  Cousin prime pairs (gap=4): {sum(1 for g in gaps if g == 4):,}")
    print(f"  Sexy prime pairs (gap=6): {sum(1 for g in gaps if g == 6):,}")

    # --- Exponential Distribution Test ---
    print("\n" + "-" * 70)
    print("CRAMÉR MODEL TEST: Are normalized gaps exponentially distributed?")
    print("-" * 70)

    # Normalize gaps by local log(p)
    normalized_gaps = []
    for i, g in enumerate(gaps):
        p = primes[i]
        if p >= 10:
            normalized_gaps.append(g / math.log(p))

    # Compute empirical quantiles
    sorted_ng = sorted(normalized_gaps)
    n_ng = len(sorted_ng)
    quantiles = [0.25, 0.50, 0.75, 0.90, 0.95, 0.99]
    print("  Quantile | Empirical | Exp(1) Theory")
    print("  " + "-" * 40)
    for q in quantiles:
        idx = int(q * n_ng)
        empirical = sorted_ng[min(idx, n_ng - 1)]
        theory = -math.log(1 - q)
        print(f"   {q:.2f}    |  {empirical:.4f}   |  {theory:.4f}")

    # KS statistic (simplified)
    max_diff = 0
    for i, x in enumerate(sorted_ng):
        ecdf = (i + 1) / n_ng
        tcdf = 1 - math.exp(-x)
        max_diff = max(max_diff, abs(ecdf - tcdf))
    print(f"\n  KS statistic: {max_diff:.6f}")
    print(f"  Critical value (α=0.05): {1.36 / math.sqrt(n_ng):.6f}")
    if max_diff < 1.36 / math.sqrt(n_ng):
        print("  Result: CANNOT REJECT exponential fit (consistent with Cramér model)")
    else:
        print("  Result: REJECT exponential fit (deviates from Cramér model)")

    # --- Connectivity Scale ---
    print("\n" + "-" * 70)
    print("CONNECTIVITY SCALE (min ε for single component)")
    print("-" * 70)
    max_gap = max(gaps)
    max_gap_idx = gaps.index(max_gap)
    print(f"  Max gap: {max_gap} (between p_{max_gap_idx+1} = {primes[max_gap_idx]} "
          f"and p_{max_gap_idx+2} = {primes[max_gap_idx+1]})")
    print(f"  Connectivity scale = {max_gap}")
    print(f"  (log {primes[max_gap_idx]})^2 = {math.log(primes[max_gap_idx])**2:.2f}")

    print("\n" + "=" * 70)
    print("DEMO COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
viz_barcode.py — Visualize the H_0 barcode of prime numbers.

Produces a barcode diagram showing prime gaps as horizontal bars,
color-coded by gap size.
"""
import math


def sieve_primes(limit):
    sieve = bytearray(b'\x01') * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i, v in enumerate(sieve) if v]


def compute_gaps(primes):
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib.cm as cm
        import numpy as np
    except ImportError:
        print("matplotlib and numpy required. Install with: pip install matplotlib numpy")
        return

    primes = sieve_primes(500)
    gaps = compute_gaps(primes)

    # Sort bars by length for visual clarity
    sorted_gaps = sorted(enumerate(gaps), key=lambda x: x[1])

    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left: Barcode diagram
    ax = axes[0]
    max_gap = max(gaps)
    colors = cm.viridis(np.array([g / max_gap for _, g in sorted_gaps]))

    for rank, ((idx, gap), color) in enumerate(zip(sorted_gaps, colors)):
        ax.barh(rank, gap, left=0, height=0.8, color=color, edgecolor='none')

    ax.set_xlabel('Scale ε (bar length = prime gap)', fontsize=12)
    ax.set_ylabel('Bar index (sorted by length)', fontsize=12)
    ax.set_title(f'H₀ Barcode of Primes up to {primes[-1]}', fontsize=14)
    ax.axvline(x=2, color='red', linestyle='--', alpha=0.7, label='Twin prime scale (ε=2)')
    ax.axvline(x=6, color='orange', linestyle='--', alpha=0.7, label='Sexy prime scale (ε=6)')
    ax.legend(fontsize=10)

    # Right: Filtration curve (components vs epsilon)
    ax2 = axes[1]
    epsilons = range(max_gap + 2)
    components = [sum(1 for g in gaps if g > eps) + 1 for eps in epsilons]

    ax2.step(list(epsilons), components, where='post', color='steelblue', linewidth=2)
    ax2.set_xlabel('Scale ε', fontsize=12)
    ax2.set_ylabel('Number of connected components', fontsize=12)
    ax2.set_title('Rips Filtration: Components vs Scale', fontsize=14)
    ax2.axvline(x=2, color='red', linestyle='--', alpha=0.7, label='Twin prime scale')
    ax2.set_yscale('log')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('barcode_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: barcode_visualization.png")
    plt.show()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
viz_filtration.py — Animate the Rips filtration on a small set of primes.

Shows how connected components merge as the scale ε increases.
"""
import math


def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib.patches as patches
        import numpy as np
    except ImportError:
        print("matplotlib and numpy required.")
        return

    # Use a small set of primes for visualization
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

    scales = [0, 1, 2, 4, 6, 8]
    fig, axes = plt.subplots(2, 3, figsize=(18, 8))

    for idx, eps in enumerate(scales):
        ax = axes[idx // 3][idx % 3]

        # Determine connected components at this scale
        # Two adjacent primes are connected if gap <= eps
        components = []
        current = [primes[0]]
        for i in range(len(gaps)):
            if gaps[i] <= eps:
                current.append(primes[i + 1])
            else:
                components.append(current)
                current = [primes[i + 1]]
        components.append(current)

        # Draw
        colors = plt.cm.Set3(np.linspace(0, 1, len(components)))
        for comp_idx, comp in enumerate(components):
            color = colors[comp_idx]
            for p in comp:
                ax.plot(p, 0, 'o', color=color, markersize=12, zorder=5)
                ax.annotate(str(p), (p, 0.15), ha='center', fontsize=8)
            # Draw connections within component
            if len(comp) > 1:
                ax.plot([comp[0] - 0.3, comp[-1] + 0.3], [0, 0],
                       color=color, linewidth=4, alpha=0.4, zorder=3)

        # Draw epsilon neighborhoods
        for p in primes:
            circle = patches.FancyBboxPatch(
                (p - eps/2, -0.3), eps, 0.6,
                boxstyle="round,pad=0.1",
                alpha=0.1, facecolor='gray', edgecolor='none'
            )
            ax.add_patch(circle)

        ax.set_xlim(-1, 34)
        ax.set_ylim(-0.6, 0.6)
        ax.set_title(f'ε = {eps}: {len(components)} components', fontsize=13, fontweight='bold')
        ax.axhline(y=0, color='gray', linewidth=0.5, alpha=0.3)
        ax.set_yticks([])
        ax.set_xlabel('Prime number line')

    plt.suptitle('Rips Filtration on First 11 Primes', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('filtration_animation.png', dpi=150, bbox_inches='tight')
    print("Saved: filtration_animation.png")
    plt.show()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
viz_gap_distribution.py — Compare prime gap distribution with exponential.

Tests the Cramér model prediction: normalized prime gaps should follow Exp(1).
"""
import math


def sieve_primes(limit):
    sieve = bytearray(b'\x01') * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i, v in enumerate(sieve) if v]


def compute_gaps(primes):
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib and numpy required.")
        return

    primes = sieve_primes(100_000)
    gaps = compute_gaps(primes)

    # Normalize gaps by log(p)
    normalized = [g / math.log(primes[i]) for i, g in enumerate(gaps) if primes[i] >= 10]

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # 1. Histogram vs exponential
    ax = axes[0]
    ax.hist(normalized, bins=50, density=True, alpha=0.7, color='steelblue', label='Normalized prime gaps')
    x = np.linspace(0, 6, 200)
    ax.plot(x, np.exp(-x), 'r-', linewidth=2, label='Exp(1) density')
    ax.set_xlabel('Normalized gap g/log(p)', fontsize=11)
    ax.set_ylabel('Density', fontsize=11)
    ax.set_title('Prime Gaps vs Exponential Distribution', fontsize=13)
    ax.legend(fontsize=10)

    # 2. Q-Q plot
    ax2 = axes[1]
    sorted_ng = sorted(normalized)
    n = len(sorted_ng)
    theoretical = [-math.log(1 - (i + 0.5) / n) for i in range(n)]
    ax2.scatter(theoretical[::100], sorted_ng[::100], s=3, alpha=0.5, color='steelblue')
    max_val = max(max(theoretical), max(sorted_ng))
    ax2.plot([0, max_val], [0, max_val], 'r-', linewidth=1, label='Perfect fit')
    ax2.set_xlabel('Theoretical Exp(1) quantiles', fontsize=11)
    ax2.set_ylabel('Empirical quantiles', fontsize=11)
    ax2.set_title('Q-Q Plot: Gaps vs Exp(1)', fontsize=13)
    ax2.legend(fontsize=10)

    # 3. Gap size histogram (raw)
    ax3 = axes[2]
    from collections import Counter
    gap_counts = Counter(gaps)
    gap_sizes = sorted(gap_counts.keys())
    counts = [gap_counts[g] for g in gap_sizes]
    ax3.bar(gap_sizes, counts, color='steelblue', alpha=0.7)
    ax3.set_xlabel('Gap size', fontsize=11)
    ax3.set_ylabel('Count', fontsize=11)
    ax3.set_title(f'Raw Gap Distribution (primes < {primes[-1]:,})', fontsize=13)
    ax3.set_yscale('log')

    plt.tight_layout()
    plt.savefig('gap_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved: gap_distribution.png")
    plt.show()


if __name__ == "__main__":
    main()
