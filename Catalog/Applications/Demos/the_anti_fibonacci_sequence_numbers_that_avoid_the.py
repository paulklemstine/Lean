#!/usr/bin/env python3
"""
Anti-Fibonacci Sequence: Demonstration and Numerical Exploration

This script demonstrates the key properties of the anti-Fibonacci sequence
a(n) = n*(n-1)/2 + 1, which grows quadratically while systematically avoiding
the Fibonacci recurrence for n >= 4.
"""

def anti_fib(n: int) -> int:
    """Compute the n-th anti-Fibonacci number using the closed form."""
    return n * (n - 1) // 2 + 1


def fib(n: int) -> int:
    """Compute the n-th Fibonacci number iteratively."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def fib_defect(n: int) -> float:
    """Compute the Fibonacci defect at position n: a(n+2) - a(n+1) - a(n)."""
    return anti_fib(n + 2) - anti_fib(n + 1) - anti_fib(n)


def fib_defect_formula(n: int) -> float:
    """Compute the Fibonacci defect using the exact formula n*(3-n)/2."""
    return n * (3 - n) / 2


def main():
    print("=" * 70)
    print("THE ANTI-FIBONACCI SEQUENCE")
    print("=" * 70)

    # Display the first 20 terms
    print("\n--- First 20 terms ---")
    for i in range(20):
        print(f"  a({i:2d}) = {anti_fib(i):6d}")

    # Verify closed form
    print("\n--- Closed Form Verification ---")
    print("Verifying a(n) = n*(n-1)/2 + 1 for n = 0..100:")
    # Compute via recurrence
    rec = [1, 1]
    for i in range(2, 101):
        rec.append(rec[-1] + (i - 1))
    all_match = all(rec[n] == anti_fib(n) for n in range(101))
    print(f"  All 101 values match closed form: {all_match}")

    # Fibonacci defect
    print("\n--- Fibonacci Defect d(n) = a(n+2) - a(n+1) - a(n) ---")
    print(f"  {'n':>4s}  {'d(n) computed':>14s}  {'d(n) formula':>14s}  {'Match':>6s}")
    for n in range(15):
        dc = fib_defect(n)
        df = fib_defect_formula(n)
        print(f"  {n:4d}  {dc:14.1f}  {df:14.1f}  {'✓' if dc == df else '✗':>6s}")

    # Anti-Fibonacci property: positions where a(n+2) = a(n+1) + a(n)
    print("\n--- Fibonacci Recurrence Coincidences ---")
    print("Positions where a(n+2) = a(n+1) + a(n):")
    coincidences = [n for n in range(10000) if fib_defect(n) == 0]
    print(f"  Found at positions: {coincidences}")
    print(f"  (Theorem: exactly n=0 and n=3)")

    # Ratio convergence
    print("\n--- Consecutive Ratio a(n+1)/a(n) ---")
    print(f"  {'n':>4s}  {'a(n+1)/a(n)':>12s}  {'Fibonacci F(n+1)/F(n)':>22s}")
    for n in [1, 2, 5, 10, 20, 50, 100, 500, 1000]:
        af_ratio = anti_fib(n + 1) / anti_fib(n)
        fib_ratio = fib(n + 1) / fib(n) if fib(n) > 0 else float('inf')
        print(f"  {n:4d}  {af_ratio:12.6f}  {fib_ratio:22.6f}")
    print(f"\n  Anti-Fibonacci ratio → 1.0 (trivial)")
    print(f"  Fibonacci ratio → φ ≈ 1.618034...")

    # Growth comparison
    print("\n--- Growth Comparison: Anti-Fibonacci vs Fibonacci ---")
    print(f"  {'n':>4s}  {'antiFib(n)':>12s}  {'Fib(n)':>12s}  {'antiFib < Fib':>14s}")
    for n in [5, 10, 12, 15, 20, 30, 50]:
        af = anti_fib(n)
        f = fib(n)
        print(f"  {n:4d}  {af:12d}  {f:12d}  {'✓' if af < f else '✗':>14s}")

    # Quadratic growth verification
    print("\n--- Quadratic Growth: a(n)/n² → 1/2 ---")
    print(f"  {'n':>8s}  {'a(n)/n²':>12s}")
    for n in [10, 100, 1000, 10000, 100000, 1000000]:
        ratio = anti_fib(n) / n**2
        print(f"  {n:8d}  {ratio:12.8f}")
    print(f"  Limit = 0.5")

    # Large-scale defect behavior
    print("\n--- Defect Growth: |d(n)| ~ n²/2 ---")
    print(f"  {'n':>8s}  {'|d(n)|':>12s}  {'n²/2':>12s}  {'ratio':>8s}")
    for n in [10, 100, 1000, 10000]:
        d = abs(fib_defect(n))
        expected = n**2 / 2
        print(f"  {n:8d}  {d:12.0f}  {expected:12.0f}  {d/expected:8.4f}")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: Anti-Fibonacci vs Fibonacci Growth Comparison

Plots the anti-Fibonacci sequence alongside the Fibonacci sequence on a
log-linear scale to highlight the dramatic difference between polynomial
and exponential growth.
"""

import matplotlib.pyplot as plt
import numpy as np


def anti_fib(n: int) -> int:
    return n * (n - 1) // 2 + 1


def fib_sequence(max_n: int) -> list:
    seq = [0, 1]
    for _ in range(max_n - 1):
        seq.append(seq[-1] + seq[-2])
    return seq


def main():
    N = 30
    ns = list(range(N + 1))
    af = [anti_fib(n) for n in ns]
    fibs = fib_sequence(N + 1)[:N + 1]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Linear scale
    ax1 = axes[0]
    ax1.plot(ns, af, 'b-o', markersize=4, label='Anti-Fibonacci', linewidth=2)
    ax1.plot(ns, fibs, 'r-s', markersize=4, label='Fibonacci', linewidth=2)
    ax1.set_xlabel('n', fontsize=13)
    ax1.set_ylabel('Value', fontsize=13)
    ax1.set_title('Linear Scale', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Log scale
    ax2 = axes[1]
    af_pos = [(n, v) for n, v in zip(ns, af) if v > 0]
    fib_pos = [(n, v) for n, v in zip(ns, fibs) if v > 0]
    ax2.semilogy([x[0] for x in af_pos], [x[1] for x in af_pos],
                 'b-o', markersize=4, label='Anti-Fibonacci ~ n²/2', linewidth=2)
    ax2.semilogy([x[0] for x in fib_pos], [x[1] for x in fib_pos],
                 'r-s', markersize=4, label='Fibonacci ~ φⁿ/√5', linewidth=2)
    ax2.set_xlabel('n', fontsize=13)
    ax2.set_ylabel('Value (log scale)', fontsize=13)
    ax2.set_title('Logarithmic Scale', fontsize=14)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('The Anti-Fibonacci Sequence: Quadratic vs Exponential Growth',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('antifib_growth_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: antifib_growth_comparison.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: Fibonacci Defect Profile

Plots the Fibonacci defect d(n) = a(n+2) - a(n+1) - a(n) for the
anti-Fibonacci sequence, showing the parabolic shape with roots at
n=0 and n=3, and the increasingly negative defect for large n.
"""

import matplotlib.pyplot as plt
import numpy as np


def anti_fib(n: int) -> int:
    return n * (n - 1) // 2 + 1


def fib_defect(n: int) -> float:
    return anti_fib(n + 2) - anti_fib(n + 1) - anti_fib(n)


def defect_formula(n: float) -> float:
    return n * (3 - n) / 2


def main():
    N = 50
    ns = list(range(N + 1))
    defects = [fib_defect(n) for n in ns]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Full defect profile
    ax1 = axes[0]
    ax1.bar(ns, defects, color=['green' if d >= 0 else 'red' for d in defects],
            alpha=0.7, edgecolor='black', linewidth=0.3)

    # Overlay formula curve
    x_cont = np.linspace(0, N, 500)
    y_cont = [defect_formula(x) for x in x_cont]
    ax1.plot(x_cont, y_cont, 'k--', linewidth=2, label='d(n) = n(3−n)/2')

    # Mark coincidence points
    coinc = [n for n in ns if defects[n] == 0]
    ax1.scatter(coinc, [0]*len(coinc), color='gold', s=150, zorder=5,
                edgecolors='black', linewidths=2,
                label=f'Fibonacci coincidences: n={coinc}')

    ax1.axhline(y=0, color='black', linewidth=0.8)
    ax1.set_xlabel('Position n', fontsize=13)
    ax1.set_ylabel('Fibonacci Defect d(n)', fontsize=13)
    ax1.set_title('Fibonacci Defect: Full Profile', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Zoomed view near the transition
    ax2 = axes[1]
    ns_zoom = list(range(10))
    defects_zoom = [fib_defect(n) for n in ns_zoom]
    colors = []
    for n, d in zip(ns_zoom, defects_zoom):
        if d > 0:
            colors.append('#2ecc71')
        elif d == 0:
            colors.append('#f1c40f')
        else:
            colors.append('#e74c3c')

    bars = ax2.bar(ns_zoom, defects_zoom, color=colors, alpha=0.8,
                   edgecolor='black', linewidth=1)

    for n, d in zip(ns_zoom, defects_zoom):
        ax2.annotate(f'd={d}', (n, d),
                     textcoords="offset points", xytext=(0, 10 if d >= 0 else -15),
                     ha='center', fontsize=10, fontweight='bold')

    ax2.axhline(y=0, color='black', linewidth=1)
    ax2.set_xlabel('Position n', fontsize=13)
    ax2.set_ylabel('Fibonacci Defect d(n)', fontsize=13)
    ax2.set_title('Zoomed View: The Transition Region', fontsize=14)
    ax2.set_xticks(ns_zoom)
    ax2.grid(True, alpha=0.3)

    # Custom legend for zoomed view
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#2ecc71', edgecolor='black', label='Positive (faster than Fib)'),
        Patch(facecolor='#f1c40f', edgecolor='black', label='Zero (Fibonacci coincidence)'),
        Patch(facecolor='#e74c3c', edgecolor='black', label='Negative (slower than Fib)'),
    ]
    ax2.legend(handles=legend_elements, fontsize=10)

    fig.suptitle('The Fibonacci Defect of the Anti-Fibonacci Sequence',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fibonacci_defect_profile.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fibonacci_defect_profile.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Consecutive Ratio Convergence

Compares the convergence of consecutive ratios a(n+1)/a(n) for the
anti-Fibonacci sequence (→ 1) versus the Fibonacci sequence (→ φ ≈ 1.618).
"""

import matplotlib.pyplot as plt
import numpy as np


def anti_fib(n: int) -> int:
    return n * (n - 1) // 2 + 1


def fib_sequence(max_n: int) -> list:
    seq = [0, 1]
    for _ in range(max_n):
        seq.append(seq[-1] + seq[-2])
    return seq


def main():
    N = 50
    fibs = fib_sequence(N + 1)

    ns = list(range(1, N + 1))
    af_ratios = [anti_fib(n + 1) / anti_fib(n) for n in ns]
    fib_ratios = [fibs[n + 1] / fibs[n] if fibs[n] > 0 else 0 for n in ns]

    phi = (1 + np.sqrt(5)) / 2

    fig, ax = plt.subplots(figsize=(12, 7))

    ax.plot(ns, af_ratios, 'b-o', markersize=4, label='Anti-Fibonacci ratio → 1',
            linewidth=2, alpha=0.8)
    ax.plot(ns, fib_ratios, 'r-s', markersize=4, label=f'Fibonacci ratio → φ ≈ {phi:.4f}',
            linewidth=2, alpha=0.8)

    # Reference lines
    ax.axhline(y=1.0, color='blue', linestyle='--', alpha=0.5, linewidth=1.5,
               label='y = 1 (anti-Fibonacci limit)')
    ax.axhline(y=phi, color='red', linestyle='--', alpha=0.5, linewidth=1.5,
               label=f'y = φ ≈ {phi:.4f} (Fibonacci limit)')

    # Highlight the gap
    ax.fill_between(ns, [1.0]*len(ns), [phi]*len(ns),
                    alpha=0.08, color='purple',
                    label='Gap between limits')

    ax.set_xlabel('Position n', fontsize=13)
    ax.set_ylabel('Consecutive Ratio a(n+1) / a(n)', fontsize=13)
    ax.set_title('Ratio Convergence: Anti-Fibonacci (→ 1) vs Fibonacci (→ φ)',
                 fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='center right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.8, 2.2)

    # Add annotation
    ax.annotate('The golden ratio φ\nis never approached',
                xy=(25, phi), xytext=(30, 1.9),
                arrowprops=dict(arrowstyle='->', color='darkred', lw=2),
                fontsize=12, color='darkred', fontweight='bold')

    ax.annotate('Anti-Fibonacci converges\nto the trivial limit 1',
                xy=(35, af_ratios[34]), xytext=(20, 0.9),
                arrowprops=dict(arrowstyle='->', color='darkblue', lw=2),
                fontsize=12, color='darkblue', fontweight='bold')

    plt.tight_layout()
    plt.savefig('ratio_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ratio_convergence.png")


if __name__ == "__main__":
    main()
