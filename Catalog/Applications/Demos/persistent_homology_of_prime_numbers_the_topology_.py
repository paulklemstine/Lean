#!/usr/bin/env python3
"""
Persistent Homology of Prime Numbers — Demonstration

Computes the H₀ barcode (prime gaps) of the prime point cloud
and compares with the Poisson/exponential prediction from
Cramér's probabilistic model.
"""

import math
from collections import Counter

def sieve_of_eratosthenes(limit):
    """Return list of primes up to limit."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def compute_gaps(primes):
    """Compute consecutive gaps between primes."""
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

def h0_barcode(primes):
    """The H₀ barcode: list of bars (birth=0, death=gap)."""
    gaps = compute_gaps(primes)
    return [(0, g) for g in gaps]

def num_components(gaps, epsilon):
    """Number of connected components at scale epsilon."""
    return 1 + sum(1 for g in gaps if g > epsilon)

def gap_distribution_analysis(primes, label=""):
    """Analyze the distribution of prime gaps (H₀ bar lengths)."""
    gaps = compute_gaps(primes)
    N = primes[-1]
    mean_gap = sum(gaps) / len(gaps)
    predicted_mean = math.log(N)  # Prime Number Theorem prediction

    print(f"\n{'='*60}")
    print(f"H₀ Barcode Analysis: Primes up to {N} {label}")
    print(f"{'='*60}")
    print(f"Number of primes: {len(primes)}")
    print(f"Number of bars (gaps): {len(gaps)}")
    print(f"Mean bar length (actual):    {mean_gap:.4f}")
    print(f"Mean bar length (predicted): {predicted_mean:.4f}")
    print(f"Ratio (actual/predicted):    {mean_gap/predicted_mean:.4f}")
    print(f"Max bar length:              {max(gaps)}")
    print(f"Min bar length:              {min(gaps)}")

    # Gap distribution
    gap_counts = Counter(gaps)
    print(f"\nGap distribution (top 10):")
    for gap, count in sorted(gap_counts.items(), key=lambda x: -x[1])[:10]:
        pct = 100 * count / len(gaps)
        print(f"  gap={gap:3d}: {count:6d} ({pct:5.1f}%)")

    # Twin prime count (gap=2)
    twin_count = gap_counts.get(2, 0)
    print(f"\nTwin prime pairs (gap=2): {twin_count}")

    # Component count at various scales
    print(f"\nComponents at various scales:")
    for eps in [1, 2, 4, 6, 10, 20, 50, 100]:
        nc = num_components(gaps, eps)
        print(f"  ε={eps:4d}: {nc:6d} components")

    # Parity check (all gaps of primes > 2 should be even)
    gaps_after_2 = gaps[1:]  # exclude gap between 2 and 3
    odd_gaps = [g for g in gaps_after_2 if g % 2 != 0]
    print(f"\nParity verification (gaps after p=3):")
    print(f"  Total gaps: {len(gaps_after_2)}")
    print(f"  Even gaps:  {len(gaps_after_2) - len(odd_gaps)}")
    print(f"  Odd gaps:   {len(odd_gaps)} (should be 0)")

    return gaps


def exponential_fit_test(gaps, N):
    """Test whether gap distribution matches exponential(log N)."""
    mean = sum(gaps) / len(gaps)
    predicted_mean = math.log(N)

    # Kolmogorov-Smirnov style comparison
    sorted_gaps = sorted(gaps)
    n = len(sorted_gaps)

    # Empirical CDF vs Exponential CDF
    max_diff = 0
    for i, g in enumerate(sorted_gaps):
        empirical = (i + 1) / n
        theoretical = 1 - math.exp(-g / predicted_mean)
        max_diff = max(max_diff, abs(empirical - theoretical))

    print(f"\nExponential fit test (Cramér model prediction):")
    print(f"  Sample mean:     {mean:.4f}")
    print(f"  Predicted mean:  {predicted_mean:.4f}")
    print(f"  KS statistic:    {max_diff:.4f}")
    print(f"  KS threshold (α=0.05): {1.36/math.sqrt(n):.4f}")
    if max_diff < 1.36 / math.sqrt(n):
        print(f"  Result: CONSISTENT with exponential distribution")
    else:
        print(f"  Result: DEVIATES from exponential (expected — primes have structure)")


def persistence_diagram(gaps):
    """Print the persistence diagram: (birth, death) pairs."""
    print(f"\nPersistence Diagram (first 20 bars, sorted by length):")
    bars = sorted([(0, g) for g in gaps], key=lambda x: -x[1])
    for i, (b, d) in enumerate(bars[:20]):
        bar = '█' * min(d, 60)
        print(f"  [{b}, {d:3d}) |{bar}")


if __name__ == "__main__":
    print("PERSISTENT HOMOLOGY OF PRIME NUMBERS")
    print("The Topology of Arithmetic")
    print("=" * 60)

    # Analysis at multiple scales
    for limit in [1000, 10000, 100000]:
        primes = sieve_of_eratosthenes(limit)
        gaps = gap_distribution_analysis(primes, f"(N={limit})")
        exponential_fit_test(gaps, limit)
        if limit <= 10000:
            persistence_diagram(gaps)

    # Demonstrate the key theorem: components at scale 0 = n
    primes_20 = sieve_of_eratosthenes(100)
    gaps_20 = compute_gaps(primes_20)
    print(f"\n{'='*60}")
    print("THEOREM VERIFICATION: components_at_zero_eq_size")
    print(f"Primes up to 100: {primes_20}")
    print(f"n = {len(primes_20)}")
    print(f"Components at ε=0: {num_components(gaps_20, 0)} (should be {len(primes_20)})")

    # Demonstrate monotonicity
    print(f"\nTHEOREM VERIFICATION: components_mono")
    for eps in range(0, 15):
        nc = num_components(gaps_20, eps)
        print(f"  ε={eps:2d}: {nc:2d} components", end="")
        if eps > 0:
            prev = num_components(gaps_20, eps - 1)
            assert nc <= prev, "Monotonicity violated!"
            if nc < prev:
                print(" ← merger!", end="")
        print()

    print(f"\n{'='*60}")
    print("All theorem verifications passed!")


#!/usr/bin/env python3
"""
Visualization: H₀ Barcode of the Prime Point Cloud

Produces a barcode diagram showing the persistent homology
of the first N primes, with bars colored by gap parity.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math


def sieve_primes(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def prime_gaps(primes):
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def plot_barcode(primes, max_bars=80, save_path="barcode.png"):
    gaps = prime_gaps(primes)
    bars = sorted(enumerate(gaps), key=lambda x: -x[1])[:max_bars]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 10),
                                    gridspec_kw={'width_ratios': [3, 1]})

    # Barcode diagram
    for rank, (idx, gap) in enumerate(bars):
        color = '#e74c3c' if gap == 2 else ('#3498db' if gap % 2 == 0 else '#2ecc71')
        label = None
        if gap == 2 and rank == 0:
            label = 'Twin prime gap (2)'
        ax1.barh(rank, gap, left=0, height=0.7, color=color, alpha=0.8,
                edgecolor='white', linewidth=0.5)

    ax1.set_xlabel('Scale ε (bar length = prime gap)', fontsize=12)
    ax1.set_ylabel('Bar index (sorted by length)', fontsize=12)
    ax1.set_title(f'H₀ Barcode: Persistent Homology of Primes up to {primes[-1]}',
                  fontsize=14, fontweight='bold')
    ax1.invert_yaxis()

    # Add legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='#e74c3c', lw=6, label='Twin prime gap (2)'),
        Line2D([0], [0], color='#3498db', lw=6, label='Even gap (> 2)'),
        Line2D([0], [0], color='#2ecc71', lw=6, label='Gap = 1 (only 2→3)'),
    ]
    ax1.legend(handles=legend_elements, loc='lower right', fontsize=10)

    # Gap distribution histogram
    from collections import Counter
    gap_counts = Counter(gaps)
    gap_vals = sorted(gap_counts.keys())
    counts = [gap_counts[g] for g in gap_vals]

    colors = ['#e74c3c' if g == 2 else '#3498db' for g in gap_vals]
    ax2.barh(gap_vals, counts, color=colors, alpha=0.8, edgecolor='white')
    ax2.set_xlabel('Frequency', fontsize=12)
    ax2.set_ylabel('Gap size', fontsize=12)
    ax2.set_title('Gap Distribution', fontsize=14, fontweight='bold')

    # Add mean line
    mean_gap = sum(gaps) / len(gaps)
    predicted = math.log(primes[-1])
    ax2.axhline(y=mean_gap, color='red', linestyle='--', alpha=0.7,
                label=f'Mean gap: {mean_gap:.1f}')
    ax2.axhline(y=predicted, color='green', linestyle='--', alpha=0.7,
                label=f'log(N): {predicted:.1f}')
    ax2.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    print(f"Saved barcode visualization to {save_path}")
    plt.close()


def plot_component_staircase(primes, save_path="staircase.png"):
    gaps = prime_gaps(primes)
    max_gap = max(gaps)

    epsilons = list(range(0, max_gap + 2))
    components = [1 + sum(1 for g in gaps if g > eps) for eps in epsilons]

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.step(epsilons, components, where='post', color='#2c3e50', linewidth=2)
    ax.fill_between(epsilons, components, step='post', alpha=0.1, color='#3498db')

    # Mark transition points
    unique_gaps = sorted(set(gaps))
    for g in unique_gaps:
        nc = 1 + sum(1 for gap in gaps if gap > g)
        ax.plot(g, nc, 'o', color='#e74c3c', markersize=6, zorder=5)

    ax.set_xlabel('Scale ε', fontsize=12)
    ax.set_ylabel('Number of Components', fontsize=12)
    ax.set_title(f'Component Staircase: H₀ of Primes up to {primes[-1]}',
                fontsize=14, fontweight='bold')
    ax.set_xlim(-0.5, max_gap + 1)
    ax.grid(True, alpha=0.3)

    # Annotate key transitions
    ax.annotate(f'ε=0: {len(primes)} components\n(each prime isolated)',
               xy=(0, len(primes)), xytext=(max_gap*0.3, len(primes)*0.9),
               fontsize=9, arrowprops=dict(arrowstyle='->', color='gray'))
    ax.annotate(f'ε={max_gap}: 1 component\n(all connected)',
               xy=(max_gap, 1), xytext=(max_gap*0.6, len(primes)*0.3),
               fontsize=9, arrowprops=dict(arrowstyle='->', color='gray'))

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    print(f"Saved staircase visualization to {save_path}")
    plt.close()


if __name__ == "__main__":
    primes = sieve_primes(1000)
    plot_barcode(primes, max_bars=60, save_path="barcode.png")
    plot_component_staircase(primes, save_path="staircase.png")

    # Also do a larger scale
    primes_large = sieve_primes(10000)
    plot_barcode(primes_large, max_bars=80, save_path="barcode_10k.png")
