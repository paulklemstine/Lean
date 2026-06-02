#!/usr/bin/env python3
"""
Fermat Near-Misses: Numerical Demonstrations

Explores near-misses to Fermat's Last Theorem — triples (a,b,c) where
|a^n + b^n - c^n| is small but nonzero.
"""

import math
from typing import List, Tuple


def fermat_defect(n: int, a: int, b: int, c: int) -> int:
    """Compute the Fermat defect a^n + b^n - c^n."""
    return a**n + b**n - c**n


def radical(n: int) -> int:
    """Compute the radical of n (product of distinct prime factors)."""
    if n <= 1:
        return max(n, 1)
    rad = 1
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            rad *= d
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        rad *= temp
    return rad


def find_near_misses(n: int, N: int, max_defect: int) -> List[Tuple[int, int, int, int]]:
    """Find triples (a,b,c) with 1 ≤ a ≤ b ≤ c ≤ N and |a^n + b^n - c^n| ≤ max_defect."""
    results = []
    for c in range(2, N + 1):
        cn = c**n
        for a in range(1, c + 1):
            an = a**n
            if an > cn + max_defect:
                break
            for b in range(a, c + 1):
                bn = b**n
                defect = an + bn - cn
                if abs(defect) <= max_defect:
                    results.append((a, b, c, defect))
    return results


def quality_ratio(n: int, a: int, b: int, c: int) -> float:
    """Compute the quality ratio |a^n + b^n - c^n| / c^n."""
    return abs(fermat_defect(n, a, b, c)) / c**n


def power_gap(c: int, n: int) -> int:
    """Compute (c+1)^n - c^n."""
    return (c + 1)**n - c**n


def abc_quality(a: int, b: int, c: int) -> float:
    """Compute the ABC quality: log(c) / log(rad(abc))."""
    r = radical(a * b * c)
    if r <= 1:
        return 0.0
    return math.log(c) / math.log(r)


def main():
    print("=" * 70)
    print("FERMAT NEAR-MISSES: NUMERICAL EXPLORATION")
    print("=" * 70)

    # Demo 1: Unit family (1, c, c) with defect 1
    print("\n--- Demo 1: Unit Family (1, c, c) ---")
    print(f"{'n':>3} {'c':>5} {'defect':>10} {'quality':>15}")
    for n in range(2, 8):
        for c in [10, 100, 1000]:
            d = fermat_defect(n, 1, c, c)
            q = quality_ratio(n, 1, c, c)
            print(f"{n:>3} {c:>5} {d:>10} {q:>15.2e}")

    # Demo 2: Near-misses for n=3
    print("\n--- Demo 2: Near-Misses for n=3, N=50, |defect| ≤ 100 ---")
    misses = find_near_misses(3, 50, 100)
    misses.sort(key=lambda x: abs(x[3]))
    print(f"Found {len(misses)} near-misses")
    print(f"{'a':>5} {'b':>5} {'c':>5} {'defect':>10} {'quality':>12}")
    for a, b, c, d in misses[:20]:
        q = quality_ratio(3, a, b, c)
        print(f"{a:>5} {b:>5} {c:>5} {d:>10} {q:>12.6f}")

    # Demo 3: Power gap sandwich verification
    print("\n--- Demo 3: Power Gap Sandwich ---")
    print(f"{'c':>5} {'n':>3} {'lower':>12} {'gap':>12} {'upper':>12}")
    for c in [5, 10, 20]:
        for n in [2, 3, 5]:
            lower = n * c**(n - 1)
            gap = power_gap(c, n)
            upper = n * (c + 1)**(n - 1)
            print(f"{c:>5} {n:>3} {lower:>12} {gap:>12} {upper:>12}")

    # Demo 4: Geometric decay of quality
    print("\n--- Demo 4: Quality Decay (c=10) ---")
    c = 10
    print(f"{'n':>3} {'quality':>20} {'ratio':>12}")
    prev_q = None
    for n in range(1, 12):
        q = 1.0 / c**n
        ratio = q / prev_q if prev_q else float('nan')
        print(f"{n:>3} {q:>20.2e} {ratio:>12.4f}")
        prev_q = q

    # Demo 5: Famous near-misses
    print("\n--- Demo 5: Famous Near-Misses ---")
    famous = [
        (3, 6, 8, 9, "Ramanujan taxi"),
        (3, 10, 9, 12, "Euler"),
        (3, 1, 12, 10, "Simple"),
    ]
    for n, a, b, c, name in famous:
        d = fermat_defect(n, a, b, c)
        q = quality_ratio(n, a, b, c)
        print(f"{name:>20}: {a}^{n} + {b}^{n} - {c}^{n} = {d} (quality={q:.6f})")

    # Demo 6: Mixed-term sum positivity
    print("\n--- Demo 6: Mixed-Term Sum (a+b)^n - a^n - b^n ---")
    for n in [2, 3, 4, 5]:
        for a, b in [(1, 1), (2, 3), (5, 7)]:
            mt = (a + b)**n - a**n - b**n
            print(f"  n={n}, a={a}, b={b}: mixed_term = {mt} > 0 ✓" if mt > 0 else f"  n={n}, a={a}, b={b}: mixed_term = {mt}")

    # Demo 7: Conjecture test — minimum defect for n=3
    print("\n--- Demo 7: Conjecture Test (min coprime defect for n=3) ---")
    for N in [10, 30, 50, 80]:
        min_defect = float('inf')
        best = None
        for c in range(2, N + 1):
            for a in range(1, c + 1):
                for b in range(a, c + 1):
                    if math.gcd(math.gcd(a, b), c) != 1:
                        continue
                    d = abs(fermat_defect(3, a, b, c))
                    if 0 < d < min_defect:
                        min_defect = d
                        best = (a, b, c)
        bound = N  # c^(n-2) = c^1 for n=3
        print(f"  N={N:>3}: min|defect| = {min_defect:>6} at {best}, c^(n-2)={best[2] if best else '?'}, {'HOLDS' if min_defect >= best[2] else 'FAILS'}")

    # Demo 8: Radical computation
    print("\n--- Demo 8: Radical Examples ---")
    for n in [12, 30, 60, 100, 360]:
        print(f"  radical({n}) = {radical(n)}, ratio = {radical(n)/n:.4f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Fermat Near-Miss Distribution

Generates plots showing the distribution of Fermat near-misses,
power gap bounds, and quality decay.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def fermat_defect(n, a, b, c):
    return a**n + b**n - c**n


def radical(n):
    if n <= 1:
        return max(n, 1)
    rad = 1
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            rad *= d
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        rad *= temp
    return rad


def plot_power_gap_sandwich():
    """Plot the power gap sandwich bounds for various n."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([2, 3, 5]):
        cs = np.arange(1, 50)
        gaps = [(c + 1)**n - c**n for c in cs]
        lowers = [n * c**(n - 1) for c in cs]
        uppers = [n * (c + 1)**(n - 1) for c in cs]

        ax = axes[idx]
        ax.fill_between(cs, lowers, uppers, alpha=0.3, color='blue', label='Sandwich band')
        ax.plot(cs, gaps, 'r-', linewidth=2, label='Actual gap')
        ax.plot(cs, lowers, 'b--', linewidth=1, label=f'{n}·c^{n-1}')
        ax.plot(cs, uppers, 'b:', linewidth=1, label=f'{n}·(c+1)^{n-1}')
        ax.set_xlabel('c')
        ax.set_ylabel('(c+1)^n - c^n')
        ax.set_title(f'Power Gap Sandwich (n={n})')
        ax.legend(fontsize=8)
        ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('power_gap_sandwich.png', dpi=150)
    plt.close()
    print("Saved power_gap_sandwich.png")


def plot_quality_decay():
    """Plot quality ratio decay for different c values."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = np.arange(1, 20)
    for c in [2, 3, 5, 10]:
        qualities = [1.0 / c**n for n in ns]
        ax.semilogy(ns, qualities, 'o-', label=f'c = {c}', markersize=4)

    # Show the 1/2^n envelope
    envelope = [0.5**n for n in ns]
    ax.semilogy(ns, envelope, 'k--', linewidth=2, alpha=0.5, label='(1/2)^n bound')

    ax.set_xlabel('Exponent n')
    ax.set_ylabel('Quality ratio 1/c^n')
    ax.set_title('Super-Exponential Decay of Near-Miss Quality')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quality_decay.png', dpi=150)
    plt.close()
    print("Saved quality_decay.png")


def plot_near_miss_heatmap():
    """Plot heatmap of Fermat defects for n=3."""
    N = 30
    n = 3

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Heatmap of |defect| for fixed c
    for idx, c in enumerate([20, 30]):
        data = np.zeros((c, c))
        for a in range(1, c + 1):
            for b in range(1, c + 1):
                d = abs(fermat_defect(n, a, b, c))
                data[a - 1, b - 1] = np.log10(max(d, 1))

        ax = axes[idx]
        im = ax.imshow(data, origin='lower', cmap='viridis', aspect='equal')
        ax.set_xlabel('b')
        ax.set_ylabel('a')
        ax.set_title(f'log₁₀|a³ + b³ - {c}³|')
        plt.colorbar(im, ax=ax, shrink=0.8)

    plt.suptitle('Fermat Defect Heatmaps (n=3)', fontsize=14)
    plt.tight_layout()
    plt.savefig('near_miss_heatmap.png', dpi=150)
    plt.close()
    print("Saved near_miss_heatmap.png")


def plot_mixed_term_growth():
    """Plot mixed-term sum growth showing binomial cross-term accumulation."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = range(2, 15)
    for a, b in [(1, 1), (1, 2), (2, 3), (3, 5)]:
        mts = [(a + b)**n - a**n - b**n for n in ns]
        ax.semilogy(list(ns), mts, 'o-', label=f'a={a}, b={b}', markersize=5)

    ax.set_xlabel('Exponent n')
    ax.set_ylabel('Mixed-term sum (a+b)^n - a^n - b^n')
    ax.set_title('Growth of Mixed Terms (Always Positive for n ≥ 2)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('mixed_term_growth.png', dpi=150)
    plt.close()
    print("Saved mixed_term_growth.png")


if __name__ == "__main__":
    plot_power_gap_sandwich()
    plot_quality_decay()
    plot_near_miss_heatmap()
    plot_mixed_term_growth()
    print("\nAll visualizations generated.")
