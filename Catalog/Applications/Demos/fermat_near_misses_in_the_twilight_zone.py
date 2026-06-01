#!/usr/bin/env python3
"""
Fermat Near-Misses: Numerical Demonstrations

Explores triples (a, b, c) where |a^n + b^n - c^n| is small,
demonstrating the theoretical results proved in Lean.
"""

import math


def fermat_defect(n: int, a: int, b: int, c: int) -> int:
    """Compute the Fermat defect a^n + b^n - c^n."""
    return a**n + b**n - c**n


def consecutive_power_gap(n: int, c: int) -> int:
    """Compute (c+1)^n - c^n."""
    return (c + 1)**n - c**n


def near_miss_quality(n: int, a: int, b: int, c: int) -> float:
    """Relative quality: |defect| / c^n. Lower is better."""
    if c == 0:
        return float('inf')
    return abs(fermat_defect(n, a, b, c)) / c**n


def find_best_near_misses(n: int, N: int, top_k: int = 10):
    """Find the best near-misses with max(a,b,c) ≤ N for exponent n."""
    results = []
    for c in range(1, N + 1):
        for a in range(1, N + 1):
            for b in range(a, N + 1):  # b ≥ a by symmetry
                d = fermat_defect(n, a, b, c)
                if d != 0:
                    results.append((abs(d), a, b, c, d))
    results.sort()
    return results[:top_k]


def verify_power_gap_bounds(n: int, max_c: int = 20):
    """Verify the power gap sandwich: n*c^(n-1) ≤ gap ≤ n*(c+1)^(n-1)."""
    print(f"\n{'='*60}")
    print(f"Power Gap Bounds Verification (n={n})")
    print(f"{'='*60}")
    print(f"{'c':>4} {'gap':>12} {'lower':>12} {'upper':>12} {'OK?':>5}")
    print(f"{'-'*4:>4} {'-'*12:>12} {'-'*12:>12} {'-'*12:>12} {'-'*5:>5}")
    for c in range(max_c + 1):
        gap = consecutive_power_gap(n, c)
        lower = n * c**(n - 1) if n >= 1 else 0
        upper = n * (c + 1)**(n - 1)
        ok = lower <= gap <= upper
        print(f"{c:>4} {gap:>12} {lower:>12} {upper:>12} {'✓' if ok else '✗':>5}")


def verify_gap_monotonicity(n: int, max_c: int = 15):
    """Verify that power gaps are strictly increasing for n ≥ 2."""
    print(f"\n{'='*60}")
    print(f"Power Gap Strict Monotonicity (n={n})")
    print(f"{'='*60}")
    gaps = [consecutive_power_gap(n, c) for c in range(max_c + 1)]
    for c in range(max_c):
        increasing = gaps[c] < gaps[c + 1]
        print(f"  gap({c}) = {gaps[c]:>10}  <  gap({c+1}) = {gaps[c+1]:>10}  {'✓' if increasing else '✗'}")


def demonstrate_quality_decay(max_n: int = 15):
    """Show super-exponential decay of near-miss quality 1/c^n."""
    print(f"\n{'='*60}")
    print(f"Super-Exponential Quality Decay (c=2)")
    print(f"{'='*60}")
    print(f"{'n':>4} {'1/2^n':>20} {'ratio':>12}")
    print(f"{'-'*4:>4} {'-'*20:>20} {'-'*12:>12}")
    prev = 1.0
    for n in range(1, max_n + 1):
        q = 1.0 / 2**n
        ratio = q / prev if prev > 0 else 0
        print(f"{n:>4} {q:>20.12f} {ratio:>12.6f}")
        prev = q


def compute_spectrum(n: int, N: int) -> set:
    """Compute the near-miss spectrum for exponent n with bound N."""
    spectrum = set()
    for a in range(1, N + 1):
        for b in range(1, N + 1):
            for c in range(1, N + 1):
                spectrum.add(fermat_defect(n, a, b, c))
    return spectrum


def demonstrate_spectrum_growth(n: int = 3):
    """Show how the spectrum grows with N."""
    print(f"\n{'='*60}")
    print(f"Spectrum Growth (n={n})")
    print(f"{'='*60}")
    for N in [2, 3, 5, 8, 10]:
        spec = compute_spectrum(n, N)
        min_pos = min(d for d in spec if d > 0) if any(d > 0 for d in spec) else None
        max_neg = max(d for d in spec if d < 0) if any(d < 0 for d in spec) else None
        print(f"  N={N:>3}: |spectrum| = {len(spec):>6}, "
              f"range [{min(spec):>8}, {max(spec):>8}], "
              f"min_pos={min_pos}, max_neg={max_neg}")
        if 0 in spec:
            print(f"         ⚠ 0 is in spectrum (Fermat equation has solution!)")
        else:
            print(f"         ✓ 0 not in spectrum")


def famous_near_misses():
    """Display famous Fermat near-misses from mathematical history."""
    print(f"\n{'='*60}")
    print(f"Famous Fermat Near-Misses")
    print(f"{'='*60}")
    cases = [
        (3, 1, 12, 10, "Ramanujan taxi number related"),
        (3, 10, 9, 12, "10³ + 9³ = 1729 = 12³ + 1"),
        (3, 6, 8, 9, "Euler's near miss"),
        (3, 71, 138, 144, "Large cubic near-miss"),
        (5, 27, 84, 85, "Quintic near-miss"),
        (3, 135, 138, 172, "Another cubic near-miss"),
    ]
    for n, a, b, c, desc in cases:
        d = fermat_defect(n, a, b, c)
        q = near_miss_quality(n, a, b, c)
        print(f"  {a}^{n} + {b}^{n} - {c}^{n} = {d}")
        print(f"    quality = {q:.2e}  ({desc})")
        print()


def conjecture_test(n: int = 3, N_values: list = None):
    """Test the conjecture that min coprime defect grows polynomially."""
    if N_values is None:
        N_values = [5, 10, 15, 20]
    print(f"\n{'='*60}")
    print(f"Conjecture Test: Coprime Gap Growth (n={n})")
    print(f"{'='*60}")
    for N in N_values:
        min_defect = float('inf')
        best_triple = None
        for a in range(1, N + 1):
            for b in range(a, N + 1):
                for c in range(1, N + 1):
                    d = abs(fermat_defect(n, a, b, c))
                    if d > 0 and math.gcd(math.gcd(a, b), c) == 1:
                        if a != b or True:  # include all
                            if d < min_defect:
                                min_defect = d
                                best_triple = (a, b, c)
        print(f"  N={N:>3}: min coprime |defect| = {min_defect:>6}, "
              f"triple = {best_triple}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     FERMAT NEAR-MISSES: NUMERICAL DEMONSTRATIONS       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # 1. Verify power gap sandwich bounds
    verify_power_gap_bounds(3, max_c=12)
    verify_power_gap_bounds(5, max_c=8)

    # 2. Gap monotonicity
    verify_gap_monotonicity(3)

    # 3. Super-exponential decay
    demonstrate_quality_decay()

    # 4. Spectrum growth
    demonstrate_spectrum_growth(n=3)

    # 5. Famous near-misses
    famous_near_misses()

    # 6. Conjecture test
    conjecture_test(n=3)

    print("\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Power Gap Sandwich Bounds

Shows the consecutive power gap (c+1)^n - c^n sandwiched between
n*c^(n-1) (lower) and n*(c+1)^(n-1) (upper) for various exponents.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def consecutive_power_gap(n, c):
    return (c + 1)**n - c**n


def lower_bound(n, c):
    return n * c**(n - 1)


def upper_bound(n, c):
    return n * (c + 1)**(n - 1)


def plot_power_gap_sandwich():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Power Gap Sandwich: n·c^(n-1) ≤ (c+1)^n - c^n ≤ n·(c+1)^(n-1)',
                 fontsize=14, fontweight='bold')

    exponents = [2, 3, 4, 5]
    max_c = 15

    for ax, n in zip(axes.flat, exponents):
        cs = np.arange(1, max_c + 1)
        gaps = [consecutive_power_gap(n, c) for c in cs]
        lowers = [lower_bound(n, c) for c in cs]
        uppers = [upper_bound(n, c) for c in cs]

        ax.fill_between(cs, lowers, uppers, alpha=0.2, color='blue',
                        label='Sandwich region')
        ax.plot(cs, gaps, 'ro-', markersize=4, linewidth=2,
                label=f'(c+1)^{n} - c^{n}')
        ax.plot(cs, lowers, 'b--', linewidth=1, alpha=0.7,
                label=f'{n}·c^{n-1}')
        ax.plot(cs, uppers, 'g--', linewidth=1, alpha=0.7,
                label=f'{n}·(c+1)^{n-1}')

        ax.set_xlabel('c')
        ax.set_ylabel('Gap value')
        ax.set_title(f'n = {n}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_power_gap_sandwich.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_power_gap_sandwich.png")


def plot_quality_decay():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Super-Exponential Decay of Near-Miss Quality',
                 fontsize=14, fontweight='bold')

    # Left: quality vs n for different c values
    ns = np.arange(1, 16)
    for c in [2, 3, 5, 10]:
        qualities = [1.0 / c**n for n in ns]
        ax1.semilogy(ns, qualities, 'o-', markersize=4, label=f'c = {c}')

    ax1.set_xlabel('Exponent n')
    ax1.set_ylabel('Quality 1/c^n (log scale)')
    ax1.set_title('Quality decay for trivial near-misses (1, c, c)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: ratio of consecutive qualities
    for c in [2, 3, 5]:
        ratios = [1.0/c for _ in ns]
        ax2.plot(ns, ratios, '--', linewidth=2, label=f'1/{c} (exact ratio for c={c})')

    ax2.set_xlabel('Exponent n')
    ax2.set_ylabel('Quality ratio q(n+1)/q(n)')
    ax2.set_title('Decay ratio ≤ 1/2 (proved for c ≥ 2)')
    ax2.axhline(y=0.5, color='red', linestyle=':', linewidth=2, label='1/2 bound')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 0.6)

    plt.tight_layout()
    plt.savefig('viz_quality_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_quality_decay.png")


def plot_gap_monotonicity():
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title('Power Gap Strict Monotonicity (proved for n ≥ 2)',
                 fontsize=14, fontweight='bold')

    max_c = 12
    cs = list(range(max_c + 1))
    for n in [2, 3, 4, 5]:
        gaps = [consecutive_power_gap(n, c) for c in cs]
        ax.plot(cs, gaps, 'o-', markersize=5, linewidth=2, label=f'n = {n}')

    ax.set_xlabel('c', fontsize=12)
    ax.set_ylabel('(c+1)^n - c^n', fontsize=12)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_gap_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_gap_monotonicity.png")


if __name__ == "__main__":
    plot_power_gap_sandwich()
    plot_quality_decay()
    plot_gap_monotonicity()
    print("All visualizations generated.")
