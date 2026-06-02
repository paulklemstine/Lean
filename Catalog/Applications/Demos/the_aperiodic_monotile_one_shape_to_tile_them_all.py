#!/usr/bin/env python3
"""
Demo: The Aperiodic Monotile Hat Spectrum

Demonstrates the key mathematical properties of the hat tile family:
1. Expansion factor algebra
2. Hat spectrum parameterization
3. Substitution matrix spectral analysis
4. Phase transition at the critical parameter
"""

import math
from algorithms import (
    hat_expansion_factor, hat_expansion_conjugate,
    verify_minimal_polynomial, verify_conjugate_product,
    edge_length_a, edge_length_b, edge_ratio,
    hat_tile_area, is_aperiodic, critical_parameter,
    tile_count_at_level, metatile_frequencies,
    hat_spectrum_sample, hat_vertices,
    substitution_matrix, matrix_power
)


def demo_expansion_factor():
    """Demonstrate the algebraic properties of the expansion factor."""
    print("=" * 60)
    print("DEMO 1: The Expansion Factor λ = 2 + √3")
    print("=" * 60)

    lam = hat_expansion_factor()
    lam_bar = hat_expansion_conjugate()

    print(f"\nλ = 2 + √3 = {lam:.15f}")
    print(f"λ̄ = 2 - √3 = {lam_bar:.15f}")
    print()

    # Minimal polynomial
    residual = verify_minimal_polynomial(lam)
    print(f"Minimal polynomial: λ² - 4λ + 1 = {residual:.2e}")
    print(f"  (Machine epsilon: {2.2e-16:.2e})")
    print()

    # Conjugate product
    product = lam * lam_bar
    print(f"λ · λ̄ = {product:.15f}  (should be 1)")
    print(f"λ + λ̄ = {lam + lam_bar:.15f}  (should be 4)")
    print()

    # Irrationality argument
    print("Irrationality: √3 is irrational because 3 is prime.")
    print("Therefore λ = 2 + √3 is irrational (rational + irrational).")
    print("This irrationality is the KEY to aperiodicity!")
    print()

    # Powers of lambda
    print("Powers of the expansion factor:")
    for n in range(6):
        print(f"  λ^{n} = {lam**n:.6f}")


def demo_hat_spectrum():
    """Demonstrate the hat spectrum parameterization."""
    print("\n" + "=" * 60)
    print("DEMO 2: The Hat Spectrum")
    print("=" * 60)

    print(f"\nCritical parameter: t* = {critical_parameter()}")
    print()

    # Sample key points
    key_points = [
        (0.0, "Hat"),
        (0.25, "Quarter"),
        (0.5, "Critical (periodic)"),
        (0.75, "Three-quarter"),
        (1.0, "Turtle"),
    ]

    print(f"{'t':>6} {'Name':>20} {'a(t)':>10} {'b(t)':>10} {'a/b':>10} {'Aperiodic':>10}")
    print("-" * 70)
    for t, name in key_points:
        a = edge_length_a(t)
        b = edge_length_b(t)
        ratio = edge_ratio(t)
        aperiodic = is_aperiodic(t)
        print(f"{t:6.2f} {name:>20} {a:10.6f} {b:10.6f} {ratio:10.6f} {str(aperiodic):>10}")

    print()
    print("Notice: At t = 0.5, a = b (edges equal), tile becomes periodic.")
    print("For ALL other t, the tile is an aperiodic monotile.")


def demo_phase_transition():
    """Demonstrate the phase transition near t = 1/2."""
    print("\n" + "=" * 60)
    print("DEMO 3: Phase Transition at t = 1/2")
    print("=" * 60)

    print("\nEdge difference |a(t) - b(t)| near the critical point:")
    print()

    for delta in [0.1, 0.01, 0.001, 0.0001, 0.00001]:
        t_minus = 0.5 - delta
        t_plus = 0.5 + delta
        diff_minus = abs(edge_length_a(t_minus) - edge_length_b(t_minus))
        diff_plus = abs(edge_length_a(t_plus) - edge_length_b(t_plus))
        print(f"  t = 0.5 ± {delta:.5f}: |a-b| = {diff_minus:.10f} (left), {diff_plus:.10f} (right)")

    print()
    print("The edge difference vanishes linearly: |a-b| = |1-2t| · |1-√3|")
    print(f"|1-√3| = {abs(1 - math.sqrt(3)):.10f}")


def demo_substitution_growth():
    """Demonstrate tile count growth under substitution."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tile Count Growth Under Substitution")
    print("=" * 60)

    lam = hat_expansion_factor()
    print(f"\nArea expansion factor: λ² = {lam**2:.6f}")
    print()

    print(f"{'Level':>6} {'Approx Tiles':>15} {'Ratio to Prev':>15}")
    print("-" * 40)
    prev = 1.0
    for n in range(10):
        count = tile_count_at_level(n)
        ratio = count / prev if n > 0 else float('inf')
        print(f"{n:6d} {count:15.1f} {ratio:15.6f}")
        prev = count

    print(f"\nExpected ratio: λ² = {lam**2:.6f}")


def demo_metatile_frequencies():
    """Demonstrate metatile frequency convergence."""
    print("\n" + "=" * 60)
    print("DEMO 5: Metatile Frequency Convergence")
    print("=" * 60)

    print(f"\n{'Level':>6} {'H':>12} {'T':>12} {'P':>12} {'F':>12}")
    print("-" * 56)
    for n in range(1, 12):
        freqs = metatile_frequencies(n)
        print(f"{n:6d} {freqs[0]:12.8f} {freqs[1]:12.8f} {freqs[2]:12.8f} {freqs[3]:12.8f}")

    print()
    print("The frequencies converge to the Perron eigenvector components.")
    print("By symmetry of the circulant-like matrix, all frequencies → 0.25.")


def demo_hat_vertices():
    """Show the hat tile vertex coordinates."""
    print("\n" + "=" * 60)
    print("DEMO 6: Hat Tile Vertices")
    print("=" * 60)

    # Hat at t=0: a=1, b=sqrt(3)
    verts = hat_vertices(1.0, math.sqrt(3))
    print("\nHat tile (t=0, a=1, b=√3), 13 vertices:")
    for i, (x, y) in enumerate(verts):
        print(f"  V{i:2d}: ({x:8.4f}, {y:8.4f})")


if __name__ == "__main__":
    demo_expansion_factor()
    demo_hat_spectrum()
    demo_phase_transition()
    demo_substitution_growth()
    demo_metatile_frequencies()
    demo_hat_vertices()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Expansion Factor Growth and Substitution Levels"""

import math

def hat_expansion_factor():
    return 2.0 + math.sqrt(3)

def metatile_frequencies(n):
    M = [[1,0,0,1],[1,1,0,0],[0,1,1,0],[0,0,1,1]]
    def mat_mul(A, B):
        n_ = len(A)
        C = [[0]*n_ for _ in range(n_)]
        for i in range(n_):
            for j in range(n_):
                for k in range(n_):
                    C[i][j] += A[i][k]*B[k][j]
        return C
    result = [[1 if i==j else 0 for j in range(4)] for i in range(4)]
    base = [row[:] for row in M]
    p = n
    while p > 0:
        if p % 2 == 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        p //= 2
    col = [result[i][0] for i in range(4)]
    total = sum(col)
    return [c/total for c in col]

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib and numpy required.")
        return

    lam = hat_expansion_factor()

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Exponential growth of tile counts
    ax = axes[0]
    levels = list(range(12))
    counts = [lam**(2*n) for n in levels]
    ax.semilogy(levels, counts, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('Substitution Level n', fontsize=12)
    ax.set_ylabel('Number of Tiles (log scale)', fontsize=12)
    ax.set_title(f'Tile Count Growth: λ^(2n), λ = 2+√3', fontsize=13)
    ax.grid(True, alpha=0.3)
    for n in [0, 3, 6, 9]:
        ax.annotate(f'{counts[n]:.0f}', (n, counts[n]),
                   textcoords="offset points", xytext=(10, 5), fontsize=9)

    # Plot 2: Period growth (unbounded periods theorem)
    ax = axes[1]
    n_vals = np.arange(0, 15)
    v_norm = 1.0  # unit period vector
    period_lengths = [lam**n * v_norm for n in n_vals]
    ax.plot(n_vals, period_lengths, 'r^-', linewidth=2, markersize=8,
            label=f'λⁿ|v|, λ={lam:.3f}')
    ax.axhline(y=100, color='gray', linestyle='--', alpha=0.5, label='Any bound M')
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('|λⁿv| (period length)', fontsize=12)
    ax.set_title('Unbounded Periods Theorem', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, max(period_lengths) * 1.1)

    # Plot 3: Metatile frequency convergence
    ax = axes[2]
    max_level = 15
    H_freqs, T_freqs, P_freqs, F_freqs = [], [], [], []
    for n in range(1, max_level + 1):
        f = metatile_frequencies(n)
        H_freqs.append(f[0])
        T_freqs.append(f[1])
        P_freqs.append(f[2])
        F_freqs.append(f[3])
    levels_freq = list(range(1, max_level + 1))
    ax.plot(levels_freq, H_freqs, 'b-o', markersize=5, label='H')
    ax.plot(levels_freq, T_freqs, 'r-s', markersize=5, label='T')
    ax.plot(levels_freq, P_freqs, 'g-^', markersize=5, label='P')
    ax.plot(levels_freq, F_freqs, 'm-d', markersize=5, label='F')
    ax.axhline(y=0.25, color='gray', linestyle='--', alpha=0.5, label='0.25')
    ax.set_xlabel('Substitution Level', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title('Metatile Frequency Convergence', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('expansion_growth_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: expansion_growth_visualization.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Hat Spectrum Edge Ratio and Phase Transition"""

import math

def edge_length_a(t):
    return (1.0 - t) + t * math.sqrt(3)

def edge_length_b(t):
    return t + (1.0 - t) * math.sqrt(3)

def main():
    try:
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
        import numpy as np
    except ImportError:
        print("matplotlib and numpy required. Install with: pip install matplotlib numpy")
        return

    t_vals = np.linspace(0, 1, 500)
    a_vals = np.array([edge_length_a(t) for t in t_vals])
    b_vals = np.array([edge_length_b(t) for t in t_vals])
    ratio_vals = a_vals / b_vals

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Edge lengths
    ax = axes[0]
    ax.plot(t_vals, a_vals, 'b-', linewidth=2, label='a(t)')
    ax.plot(t_vals, b_vals, 'r-', linewidth=2, label='b(t)')
    ax.axvline(x=0.5, color='gray', linestyle='--', alpha=0.7, label='t = 1/2 (critical)')
    ax.scatter([0, 1], [1, math.sqrt(3)], color='blue', zorder=5, s=60)
    ax.scatter([0, 1], [math.sqrt(3), 1], color='red', zorder=5, s=60)
    ax.set_xlabel('Parameter t', fontsize=12)
    ax.set_ylabel('Edge length', fontsize=12)
    ax.set_title('Edge Lengths in the Hat Spectrum', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Edge ratio
    ax = axes[1]
    ax.plot(t_vals, ratio_vals, 'purple', linewidth=2)
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='a/b = 1 (periodic)')
    ax.axvline(x=0.5, color='gray', linestyle='--', alpha=0.5)
    ax.fill_between(t_vals, ratio_vals, 1.0, alpha=0.15, color='purple')
    ax.scatter([0], [1/math.sqrt(3)], color='blue', zorder=5, s=80, label='Hat (t=0)')
    ax.scatter([1], [math.sqrt(3)], color='green', zorder=5, s=80, label='Turtle (t=1)')
    ax.scatter([0.5], [1.0], color='red', zorder=5, s=80, label='Critical (t=1/2)')
    ax.set_xlabel('Parameter t', fontsize=12)
    ax.set_ylabel('Edge ratio a/b', fontsize=12)
    ax.set_title('Edge Ratio and the Aperiodicity Boundary', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Phase diagram
    ax = axes[2]
    t_left = t_vals[t_vals < 0.5]
    t_right = t_vals[t_vals > 0.5]
    a_left = np.array([edge_length_a(t) for t in t_left])
    b_left = np.array([edge_length_b(t) for t in t_left])
    a_right = np.array([edge_length_a(t) for t in t_right])
    b_right = np.array([edge_length_b(t) for t in t_right])

    ax.fill_between(t_left, 0, abs(a_left - b_left), alpha=0.3, color='blue', label='Aperiodic (hat side)')
    ax.fill_between(t_right, 0, abs(a_right - b_right), alpha=0.3, color='green', label='Aperiodic (turtle side)')
    ax.plot(t_vals, np.abs(a_vals - b_vals), 'k-', linewidth=2)
    ax.axvline(x=0.5, color='red', linewidth=2, linestyle='-', label='Phase transition')
    ax.set_xlabel('Parameter t', fontsize=12)
    ax.set_ylabel('|a(t) - b(t)|', fontsize=12)
    ax.set_title('Phase Transition: Aperiodic ↔ Periodic', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hat_spectrum_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hat_spectrum_visualization.png")

if __name__ == "__main__":
    main()
