#!/usr/bin/env python3
"""
Fermat Near-Miss Explorer — Demonstration Script

Explores the landscape of Fermat near-misses: triples (a, b, c) where
|a^n + b^n - c^n| is surprisingly small relative to c^n.

Demonstrates all key theorems from the formalization:
  1. Mixed-term decomposition
  2. Power superadditivity
  3. Power gap sandwich bounds
  4. Near-miss search and quality scoring
"""

from math import gcd, floor, log
from typing import List, Tuple


def fermat_defect(a: int, b: int, c: int, n: int) -> int:
    """Compute the Fermat defect: a^n + b^n - c^n."""
    return a**n + b**n - c**n


def cross_term_sum(a: int, b: int, n: int) -> int:
    """Compute the binomial cross-term sum: (a+b)^n - a^n - b^n."""
    from math import comb
    return sum(comb(n, k) * a**k * b**(n - k) for k in range(1, n))


def near_miss_quality(a: int, b: int, c: int, n: int) -> float:
    """Compute the quality of a near-miss: |defect| / c^n.
    Lower is better (closer to Fermat's equation)."""
    d = abs(fermat_defect(a, b, c, n))
    return d / c**n if c > 0 else float('inf')


def find_best_c(a: int, b: int, n: int) -> int:
    """Find the integer c that minimizes |a^n + b^n - c^n|."""
    target = a**n + b**n
    c = int(round(target ** (1.0 / n)))
    # Search neighborhood
    best_c = c
    best_d = abs(fermat_defect(a, b, c, n))
    for dc in [-2, -1, 1, 2]:
        cc = c + dc
        if cc > 0:
            dd = abs(fermat_defect(a, b, cc, n))
            if dd < best_d:
                best_d = dd
                best_c = cc
    return best_c


def demo_mixed_term_decomposition():
    """Demonstrate that (a+b)^n = a^n + b^n + cross_terms."""
    print("=" * 60)
    print("MIXED-TERM DECOMPOSITION")
    print("(a+b)^n = a^n + b^n + Σ C(n,k) a^k b^(n-k)")
    print("=" * 60)
    for a, b, n in [(3, 5, 3), (2, 7, 4), (10, 13, 5)]:
        lhs = (a + b) ** n
        rhs = a**n + b**n + cross_term_sum(a, b, n)
        ct = cross_term_sum(a, b, n)
        print(f"  a={a}, b={b}, n={n}:")
        print(f"    (a+b)^n = {lhs}")
        print(f"    a^n + b^n = {a**n + b**n}")
        print(f"    cross terms = {ct}")
        print(f"    a^n + b^n + cross = {rhs}")
        assert lhs == rhs, "Decomposition failed!"
        print(f"    ✓ Identity verified")
    print()


def demo_power_superadditivity():
    """Demonstrate a^n + b^n < (a+b)^n for n ≥ 2, a,b > 0."""
    print("=" * 60)
    print("POWER SUPERADDITIVITY")
    print("a^n + b^n < (a+b)^n for a,b > 0, n ≥ 2")
    print("=" * 60)
    for n in range(2, 7):
        for a, b in [(1, 1), (2, 3), (5, 7), (10, 1)]:
            lhs = a**n + b**n
            rhs = (a + b) ** n
            ratio = lhs / rhs
            print(f"  n={n}, a={a}, b={b}: "
                  f"{lhs} < {rhs} (ratio = {ratio:.4f})")
            assert lhs < rhs
    print("  ✓ All cases verified\n")


def demo_power_gap_sandwich():
    """Demonstrate n·c^(n-1) ≤ (c+1)^n - c^n ≤ n·(c+1)^(n-1)."""
    print("=" * 60)
    print("POWER GAP SANDWICH THEOREM")
    print("n·c^(n-1) ≤ (c+1)^n - c^n ≤ n·(c+1)^(n-1)")
    print("=" * 60)
    for n in range(1, 6):
        for c in [1, 5, 10, 50, 100]:
            gap = (c + 1)**n - c**n
            lower = n * c**(n - 1)
            upper = n * (c + 1)**(n - 1)
            ok = lower <= gap <= upper
            print(f"  n={n}, c={c}: {lower} ≤ {gap} ≤ {upper}  {'✓' if ok else '✗'}")
            assert ok, f"Sandwich failed for n={n}, c={c}"
    print("  ✓ All cases verified\n")


def demo_near_miss_search():
    """Search for the best Fermat near-misses for small exponents."""
    print("=" * 60)
    print("FERMAT NEAR-MISS SEARCH")
    print("Finding triples with smallest |a^n + b^n - c^n| / c^n")
    print("=" * 60)
    for n in [3, 4, 5]:
        print(f"\n  Exponent n = {n}:")
        best: List[Tuple[int, int, int, float]] = []
        N = 200
        for a in range(1, N):
            for b in range(a, N):
                c = find_best_c(a, b, n)
                if c <= 0 or c <= b:
                    continue
                d = fermat_defect(a, b, c, n)
                if d == 0:
                    continue  # Impossible for n≥3 by FLT, but check anyway
                q = near_miss_quality(a, b, c, n)
                best.append((a, b, c, q))
        best.sort(key=lambda x: x[3])
        for a, b, c, q in best[:8]:
            d = fermat_defect(a, b, c, n)
            print(f"    ({a}, {b}, {c}): defect = {d}, "
                  f"quality = {q:.6e}")
    print()


def demo_exponent_gap_conjecture():
    """Test the Near-Miss Exponent Gap Conjecture:
    For coprime a,b,c with n ≥ 3: |a^n + b^n - c^n| ≥ c^(n-2)."""
    print("=" * 60)
    print("NEAR-MISS EXPONENT GAP CONJECTURE TEST")
    print("|a^n + b^n - c^n| ≥ c^(n-2) for coprime triples?")
    print("=" * 60)
    for n in [3, 4, 5]:
        min_ratio = float('inf')
        min_triple = None
        violations = 0
        tested = 0
        N = 150
        for a in range(1, N):
            for b in range(a, N):
                c = find_best_c(a, b, n)
                if c <= 0 or c <= b:
                    continue
                if gcd(a, c) > 1 or gcd(b, c) > 1:
                    continue
                d = fermat_defect(a, b, c, n)
                if d == 0:
                    continue
                tested += 1
                ratio = abs(d) / c**(n - 2)
                if ratio < min_ratio:
                    min_ratio = ratio
                    min_triple = (a, b, c, d)
                if ratio < 1:
                    violations += 1
        print(f"\n  n = {n}: tested {tested} coprime triples")
        if min_triple:
            a, b, c, d = min_triple
            print(f"    Smallest ratio: {min_ratio:.4f} "
                  f"at ({a}, {b}, {c}), defect = {d}")
        print(f"    Violations (ratio < 1): {violations}")
        if violations == 0:
            print(f"    ✓ Conjecture holds for all tested triples")
    print()


if __name__ == "__main__":
    demo_mixed_term_decomposition()
    demo_power_superadditivity()
    demo_power_gap_sandwich()
    demo_near_miss_search()
    demo_exponent_gap_conjecture()


#!/usr/bin/env python3
"""
Visualization: Fermat Defect Monotonicity and Sign Change

Shows how the Fermat defect a^n + b^n - c^n decreases strictly in c,
demonstrating the unique sign-change point and the optimal approximant
theorem: the best integer c lies within a window of width 2.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def fermat_defect(a: int, b: int, c: int, n: int) -> int:
    return a**n + b**n - c**n


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    cases = [
        (6, 8, 3, "6³ + 8³ = 728"),
        (3, 4, 3, "3³ + 4³ = 91"),
        (2, 3, 5, "2⁵ + 3⁵ = 275"),
    ]

    for ax, (a, b, n, label) in zip(axes, cases):
        target = a**n + b**n
        c_opt = round(target ** (1.0 / n))
        c_range = range(max(1, c_opt - 8), c_opt + 9)

        cs = list(c_range)
        defects = [fermat_defect(a, b, c, n) for c in cs]

        colors = ['green' if d > 0 else ('red' if d < 0 else 'gold')
                  for d in defects]
        ax.bar(cs, defects, color=colors, alpha=0.7, edgecolor='black')
        ax.axhline(y=0, color='black', linewidth=1.5, linestyle='-')

        # Mark the optimal c
        abs_defects = [abs(d) for d in defects]
        best_idx = abs_defects.index(min(abs_defects))
        ax.bar(cs[best_idx], defects[best_idx], color='gold',
               edgecolor='black', linewidth=2, zorder=5)

        ax.set_xlabel('c', fontsize=12)
        ax.set_ylabel(f'a^{n} + b^{n} − c^{n}', fontsize=12)
        ax.set_title(f'{label}\nOptimal c = {cs[best_idx]}', fontsize=12)

        # Add legend
        from matplotlib.patches import Patch
        legend_elements = [
            Patch(facecolor='green', alpha=0.7, label='Positive defect'),
            Patch(facecolor='red', alpha=0.7, label='Negative defect'),
            Patch(facecolor='gold', edgecolor='black', label='Optimal c'),
        ]
        ax.legend(handles=legend_elements, fontsize=8)

    plt.suptitle('Fermat Defect Monotonicity: Strict Decrease in c\n'
                 'Sign change occurs between consecutive integers',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('defect_monotonicity.png', dpi=150)
    print("Saved defect_monotonicity.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Fermat Near-Miss Quality Landscape

Generates a heatmap showing the quality of the best Fermat near-miss
for each (a, b) pair, revealing structural patterns in how close
integer triples come to satisfying Fermat's equation.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd


def fermat_defect(a: int, b: int, c: int, n: int) -> int:
    return a**n + b**n - c**n


def optimal_c(a: int, b: int, n: int) -> int:
    target = a**n + b**n
    c_approx = max(1, round(target ** (1.0 / n)))
    best_c = c_approx
    best_d = abs(fermat_defect(a, b, c_approx, n))
    for dc in [-1, 0, 1]:
        cc = c_approx + dc
        if cc > 0:
            dd = abs(fermat_defect(a, b, cc, n))
            if dd < best_d:
                best_d = dd
                best_c = cc
    return best_c


def main():
    N = 80
    n = 3  # cubic case

    quality = np.zeros((N, N))
    quality[:] = np.nan

    for a in range(1, N + 1):
        for b in range(a, N + 1):
            c = optimal_c(a, b, n)
            if c <= b:
                continue
            d = fermat_defect(a, b, c, n)
            if d == 0:
                continue
            q = np.log10(abs(d) / c**n)
            quality[a - 1, b - 1] = q
            quality[b - 1, a - 1] = q  # symmetric

    fig, ax = plt.subplots(figsize=(10, 8))
    im = ax.imshow(quality, origin='lower', cmap='RdYlBu_r',
                   extent=[0.5, N + 0.5, 0.5, N + 0.5],
                   aspect='equal')
    ax.set_xlabel('b', fontsize=14)
    ax.set_ylabel('a', fontsize=14)
    ax.set_title(f'Fermat Near-Miss Quality Landscape (n={n})\n'
                 f'log₁₀(|a³ + b³ − c³| / c³) for optimal c',
                 fontsize=14)
    cbar = plt.colorbar(im, ax=ax)
    cbar.set_label('log₁₀(quality) — lower = closer to Fermat', fontsize=12)
    plt.tight_layout()
    plt.savefig('near_miss_landscape.png', dpi=150)
    print("Saved near_miss_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Power Gap Sandwich Theorem

Shows (c+1)^n - c^n sandwiched between n*c^(n-1) and n*(c+1)^(n-1)
for various exponents, illustrating how tightly the bounds constrain
the gaps between consecutive perfect powers.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, n in enumerate([2, 3, 4, 5]):
        ax = axes[idx // 2][idx % 2]
        cs = np.arange(1, 51)

        gaps = np.array([(c + 1)**n - c**n for c in cs], dtype=float)
        lowers = np.array([n * c**(n - 1) for c in cs], dtype=float)
        uppers = np.array([n * (c + 1)**(n - 1) for c in cs], dtype=float)

        ax.fill_between(cs, lowers, uppers, alpha=0.2, color='blue',
                        label='Sandwich band')
        ax.plot(cs, gaps, 'r-', linewidth=2, label=f'(c+1)^{n} − c^{n}')
        ax.plot(cs, lowers, 'b--', linewidth=1, label=f'{n}·c^{n-1}')
        ax.plot(cs, uppers, 'b:', linewidth=1, label=f'{n}·(c+1)^{n-1}')

        ax.set_xlabel('c', fontsize=12)
        ax.set_ylabel('Gap value', fontsize=12)
        ax.set_title(f'Power Gap Sandwich (n = {n})', fontsize=13)
        ax.legend(fontsize=9)
        ax.set_yscale('log')

    plt.suptitle('Power Gap Sandwich Theorem\n'
                 'n·c^(n−1) ≤ (c+1)^n − c^n ≤ n·(c+1)^(n−1)',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('power_gap_sandwich.png', dpi=150)
    print("Saved power_gap_sandwich.png")


if __name__ == "__main__":
    main()
