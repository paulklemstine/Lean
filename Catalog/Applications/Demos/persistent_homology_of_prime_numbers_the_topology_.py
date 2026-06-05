#!/usr/bin/env python3
"""
Persistent Homology of Prime Numbers: Demonstration Script

Computes and visualizes the H₀ persistent homology of the prime point cloud.
Shows that the barcode is exactly the gap sequence, total persistence = diameter,
and that H₁ is trivially zero for 1D point clouds.
"""

import math
from collections import Counter


def sieve_of_eratosthenes(n: int) -> list[int]:
    """Return all primes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def gap_sequence(primes: list[int]) -> list[int]:
    """Compute the gap sequence (= H₀ barcode) of a sorted list."""
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def components_at_scale(gaps: list[int], epsilon: int) -> int:
    """Number of connected components at filtration parameter epsilon."""
    return 1 + sum(1 for g in gaps if g > epsilon)


def total_persistence(gaps: list[int]) -> int:
    """Total persistence = sum of all bar lengths."""
    return sum(gaps)


def gap_spectrum(gaps: list[int]) -> dict[int, int]:
    """Distribution of gap sizes (histogram of the barcode)."""
    return dict(Counter(gaps))


def persistence_landscape(gaps: list[int], epsilon: int) -> int:
    """Persistence landscape λ₁(ε): count of bars > ε."""
    return sum(1 for g in gaps if g > epsilon)


def betti_integral(gaps: list[int]) -> int:
    """Verify the Betti curve integral formula: ∑ λ₁(ε) = total persistence."""
    if not gaps:
        return 0
    max_gap = max(gaps)
    return sum(persistence_landscape(gaps, eps) for eps in range(max_gap))


def main():
    print("=" * 70)
    print("PERSISTENT HOMOLOGY OF PRIME NUMBERS")
    print("=" * 70)

    # Demo 1: Small example
    print("\n--- Demo 1: Primes up to 30 ---")
    primes = sieve_of_eratosthenes(30)
    gaps = gap_sequence(primes)
    print(f"Primes: {primes}")
    print(f"Gap sequence (= H₀ barcode): {gaps}")
    print(f"Total persistence: {total_persistence(gaps)}")
    print(f"Diameter (last - first): {primes[-1] - primes[0]}")
    print(f"✓ Total persistence = diameter: {total_persistence(gaps) == primes[-1] - primes[0]}")

    print(f"\nComponents at various scales:")
    for eps in [0, 1, 2, 4, 6]:
        print(f"  ε = {eps}: {components_at_scale(gaps, eps)} components")

    print(f"\nGap spectrum: {gap_spectrum(gaps)}")

    # Demo 2: Betti integral formula verification
    print("\n--- Demo 2: Betti Integral Formula ---")
    integral = betti_integral(gaps)
    total = total_persistence(gaps)
    print(f"∑ λ₁(ε) from ε=0 to max_gap-1 = {integral}")
    print(f"Total persistence = {total}")
    print(f"✓ Betti integral formula: {integral == total}")

    # Demo 3: Larger prime cloud
    print("\n--- Demo 3: Primes up to 1000 ---")
    primes = sieve_of_eratosthenes(1000)
    gaps = gap_sequence(primes)
    spectrum = gap_spectrum(gaps)
    print(f"Number of primes: {len(primes)}")
    print(f"Number of bars: {len(gaps)}")
    print(f"Total persistence: {total_persistence(gaps)} (= {primes[-1]} - {primes[0]})")
    print(f"Max gap (connectivity threshold): {max(gaps)}")
    print(f"Mean gap: {sum(gaps)/len(gaps):.2f}")
    print(f"Expected mean gap (log N): {math.log(1000):.2f}")

    print(f"\nGap spectrum (sorted):")
    for gap_size in sorted(spectrum.keys()):
        count = spectrum[gap_size]
        bar = "█" * count
        print(f"  gap {gap_size:3d}: {count:3d} {bar}")

    # Demo 4: Twin prime detection
    print("\n--- Demo 4: Twin Prime Detection ---")
    twin_count = spectrum.get(2, 0)
    print(f"Bars of length 2 (twin primes): {twin_count}")
    print(f"Bars of length 4 (cousin primes): {spectrum.get(4, 0)}")
    print(f"Bars of length 6 (sexy primes): {spectrum.get(6, 0)}")

    # Demo 5: Gap parity
    print("\n--- Demo 5: Gap Parity ---")
    odd_gaps = [g for g in gaps if g % 2 == 1]
    even_gaps = [g for g in gaps if g % 2 == 0]
    print(f"Odd gaps: {len(odd_gaps)} (should be exactly 1, which is gap 3-2=1)")
    print(f"Even gaps: {len(even_gaps)}")
    print(f"The unique odd gap: {odd_gaps}")
    print(f"✓ All gaps except first are even: {odd_gaps == [1]}")

    # Demo 6: H₁ triviality
    print("\n--- Demo 6: H₁ Triviality for 1D Point Clouds ---")
    print("For any 1D point cloud, the Rips complex at every scale is a")
    print("disjoint union of cliques (complete subgraphs).")
    print("Key property: if points[i] and points[k] are connected (i < k),")
    print("then ALL intermediate points[j] (i ≤ j ≤ k) are pairwise connected.")
    print("Cliques are contractible → H_k = 0 for all k ≥ 1.")
    print()
    print("DISPROOF: The conjecture that H₁ detects twin primes is FALSE.")
    print("Twin primes create H₀ bars of length 2, not H₁ features.")

    # Demo 7: Comparison with Poisson process
    print("\n--- Demo 7: Poisson Process Comparison ---")
    for N in [100, 1000, 10000, 100000]:
        primes_N = sieve_of_eratosthenes(N)
        if len(primes_N) < 2:
            continue
        gaps_N = gap_sequence(primes_N)
        mean_gap = sum(gaps_N) / len(gaps_N)
        log_N = math.log(N)
        print(f"  N={N:>7d}: mean gap = {mean_gap:.3f}, log(N) = {log_N:.3f}, "
              f"ratio = {mean_gap/log_N:.4f}")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Number Barcode and Betti Curve

Produces three subplots:
1. H₀ barcode of the prime point cloud
2. Betti curve β₀(ε)
3. Gap spectrum (histogram of bar lengths)
"""

import math


def sieve(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def gap_sequence(pts):
    return [pts[i+1] - pts[i] for i in range(len(pts) - 1)]


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    N = 200
    primes = sieve(N)
    gaps = gap_sequence(primes)

    fig, axes = plt.subplots(3, 1, figsize=(14, 12))

    # Plot 1: Barcode
    ax1 = axes[0]
    colors_map = {1: '#e74c3c', 2: '#2ecc71', 4: '#3498db', 6: '#9b59b6'}
    for idx, g in enumerate(gaps):
        color = colors_map.get(g, '#95a5a6')
        ax1.barh(idx, g, left=0, height=0.8, color=color, alpha=0.8)

    patches = [
        mpatches.Patch(color='#e74c3c', label='Gap 1 (2→3, unique odd)'),
        mpatches.Patch(color='#2ecc71', label='Gap 2 (twin primes)'),
        mpatches.Patch(color='#3498db', label='Gap 4 (cousin primes)'),
        mpatches.Patch(color='#9b59b6', label='Gap 6 (sexy primes)'),
        mpatches.Patch(color='#95a5a6', label='Other gaps'),
    ]
    ax1.legend(handles=patches, loc='upper right', fontsize=8)
    ax1.set_xlabel('Bar length (= prime gap)')
    ax1.set_ylabel('Bar index')
    ax1.set_title(f'H₀ Barcode of Prime Point Cloud (primes up to {N})')

    # Plot 2: Betti curve
    ax2 = axes[1]
    max_gap = max(gaps)
    epsilons = list(range(max_gap + 2))
    betti = [1 + sum(1 for g in gaps if g > eps) for eps in epsilons]
    ax2.step(epsilons, betti, where='post', color='#2c3e50', linewidth=2)
    ax2.fill_between(epsilons, betti, step='post', alpha=0.15, color='#3498db')
    ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Single component')
    ax2.set_xlabel('Scale ε')
    ax2.set_ylabel('β₀(ε) = # components')
    ax2.set_title('Betti Curve: Connected Components vs. Scale')
    ax2.legend()

    # Annotate key scales
    ax2.annotate('Twin primes\nmerge at ε=2', xy=(2, betti[2]),
                xytext=(4, betti[2] + 5),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=8, color='green')

    # Plot 3: Gap spectrum
    ax3 = axes[2]
    from collections import Counter
    spectrum = Counter(gaps)
    gap_sizes = sorted(spectrum.keys())
    counts = [spectrum[g] for g in gap_sizes]
    colors = [colors_map.get(g, '#95a5a6') for g in gap_sizes]
    ax3.bar(gap_sizes, counts, color=colors, edgecolor='black', linewidth=0.5)
    ax3.set_xlabel('Gap size')
    ax3.set_ylabel('Count')
    ax3.set_title('Gap Spectrum (Histogram of H₀ Barcode)')

    # Mark even/odd
    ax3.annotate('Unique odd gap', xy=(1, spectrum.get(1, 0)),
                xytext=(3, spectrum.get(1, 0) + 1),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=8, color='red')

    plt.tight_layout()
    plt.savefig('prime_barcode.png', dpi=150, bbox_inches='tight')
    print(f"Saved prime_barcode.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Persistence Landscape and Poisson Comparison

1. Persistence landscape λ₁(ε) showing the integral = total persistence
2. Comparison of prime gap distribution with exponential (Poisson) model
"""

import math


def sieve(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def gap_sequence(pts):
    return [pts[i+1] - pts[i] for i in range(len(pts) - 1)]


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping visualization")
        return

    N = 10000
    primes = sieve(N)
    gaps = gap_sequence(primes)

    fig, axes = plt.subplots(2, 1, figsize=(14, 10))

    # Plot 1: Persistence landscape with integral shading
    ax1 = axes[0]
    max_gap = max(gaps)
    epsilons = list(range(max_gap + 1))
    landscape = [sum(1 for g in gaps if g > eps) for eps in epsilons]

    ax1.step(epsilons, landscape, where='post', color='#2c3e50', linewidth=2)
    ax1.fill_between(epsilons, landscape, step='post', alpha=0.2, color='#e74c3c')

    total = sum(gaps)
    integral = sum(landscape[:max_gap])
    ax1.set_xlabel('Scale ε')
    ax1.set_ylabel('λ₁(ε) = # bars > ε')
    ax1.set_title(f'Persistence Landscape (primes up to {N})\n'
                  f'Shaded area = ∑λ₁(ε) = {integral} = total persistence = {total}')
    ax1.annotate(f'Betti Integral Formula:\n∑λ₁(ε) = ∑bars = {total}',
                xy=(max_gap//2, max(landscape)//2),
                fontsize=12, ha='center',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Plot 2: Gap distribution vs exponential (Cramer's model)
    ax2 = axes[1]
    from collections import Counter
    spectrum = Counter(gaps)

    # Normalize gaps by log(N) for comparison with exponential
    log_N = math.log(N)
    normalized_gaps = [g / log_N for g in gaps]

    # Histogram of normalized gaps
    bins = np.linspace(0, max(normalized_gaps) + 0.5, 30)
    ax2.hist(normalized_gaps, bins=bins, density=True, alpha=0.7,
             color='#3498db', edgecolor='black', linewidth=0.5,
             label='Prime gaps / log(N)')

    # Exponential distribution (Cramer's model prediction)
    x = np.linspace(0, max(normalized_gaps) + 0.5, 200)
    exp_pdf = np.exp(-x)
    ax2.plot(x, exp_pdf, 'r-', linewidth=2,
             label=f'Exp(1) density (Cramér model)')

    ax2.set_xlabel('Normalized gap g / log(N)')
    ax2.set_ylabel('Density')
    ax2.set_title(f'Prime Gap Distribution vs. Poisson Prediction (N = {N})')
    ax2.legend()

    mean_norm = np.mean(normalized_gaps)
    ax2.annotate(f'Mean normalized gap: {mean_norm:.3f}\n(Cramér predicts: 1.000)',
                xy=(2, 0.5), fontsize=10,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

    plt.tight_layout()
    plt.savefig('persistence_landscape.png', dpi=150, bbox_inches='tight')
    print(f"Saved persistence_landscape.png")


if __name__ == "__main__":
    main()
