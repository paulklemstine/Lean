#!/usr/bin/env python3
"""
Langlands Shape-Color Correspondence: Numerical Demonstrations

Demonstrates the GL₁ Langlands correspondence by computing:
1. Quadratic characters (Legendre symbols) for small primes
2. Gauss sums and verification of g(χ)² = χ(-1)·p
3. Character orthogonality (color conservation)
4. Square detection and color mixing rules
"""

import cmath
import math
from typing import List, Tuple, Dict


def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) for odd prime p."""
    if a % p == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return val if val == 1 else -1


def gauss_sum(p: int) -> complex:
    """Compute the quadratic Gauss sum g(χ) = Σ_{t=0}^{p-1} χ(t)·e^{2πit/p}."""
    omega = cmath.exp(2j * cmath.pi / p)
    return sum(legendre_symbol(t, p) * omega**t for t in range(p))


def verify_gauss_sum_squared(p: int) -> Tuple[complex, complex, bool]:
    """Verify g(χ)² = χ(-1)·p for prime p."""
    g = gauss_sum(p)
    g_sq = g * g
    chi_neg1 = legendre_symbol(-1, p)
    expected = chi_neg1 * p
    close = abs(g_sq - expected) < 1e-6
    return g_sq, expected, close


def verify_color_conservation(p: int) -> Tuple[int, bool]:
    """Verify Σ χ(a) = 0 for the quadratic character mod p."""
    total = sum(legendre_symbol(a, p) for a in range(p))
    return total, total == 0


def count_squares(p: int) -> Tuple[int, int, bool]:
    """Count squares mod p and verify half_units_are_squares."""
    squares = sum(1 for a in range(1, p) if legendre_symbol(a, p) == 1)
    non_squares = sum(1 for a in range(1, p) if legendre_symbol(a, p) == -1)
    return squares, non_squares, squares == non_squares == (p - 1) // 2


def verify_color_mixing(p: int) -> List[Tuple[int, int, int, int, str]]:
    """Verify color mixing rules: sq×sq=sq, nsq×nsq=sq, sq×nsq=nsq."""
    results = []
    for a in range(1, p):
        for b in range(1, p):
            ca = legendre_symbol(a, p)
            cb = legendre_symbol(b, p)
            cab = legendre_symbol((a * b) % p, p)
            expected = ca * cb
            rule = ""
            if ca == 1 and cb == 1: rule = "sq×sq=sq"
            elif ca == -1 and cb == -1: rule = "nsq×nsq=sq"
            elif ca == 1 and cb == -1: rule = "sq×nsq=nsq"
            elif ca == -1 and cb == 1: rule = "nsq×sq=nsq"
            if cab != expected:
                results.append((a, b, cab, expected, f"FAIL: {rule}"))
            elif len(results) < 10:
                results.append((a, b, cab, expected, f"OK: {rule}"))
    return results


def main():
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    print("=" * 70)
    print("LANGLANDS SHAPE-COLOR CORRESPONDENCE: NUMERICAL VERIFICATION")
    print("=" * 70)

    # 1. Quadratic characters
    print("\n--- 1. Quadratic Characters (Legendre Symbols) ---")
    for p in primes[:8]:
        chars = [legendre_symbol(a, p) for a in range(p)]
        squares = [a for a in range(1, p) if legendre_symbol(a, p) == 1]
        print(f"F_{p}: χ = {chars[1:]}")
        print(f"       Squares: {squares}")

    # 2. Gauss sum squared
    print("\n--- 2. Gauss Sum Squared: g(χ)² = χ(-1)·p ---")
    for p in primes:
        g_sq, expected, ok = verify_gauss_sum_squared(p)
        chi_neg1 = legendre_symbol(-1, p)
        sign = "+" if chi_neg1 == 1 else "-"
        status = "✓" if ok else "✗"
        print(f"  p={p:3d}: g(χ)² = {g_sq.real:8.3f} + {g_sq.imag:.3f}i, "
              f"χ(-1)·p = {sign}{p}, {status}")

    # 3. Color conservation
    print("\n--- 3. Color Conservation: Σ χ(a) = 0 ---")
    for p in primes:
        total, ok = verify_color_conservation(p)
        print(f"  p={p:3d}: Σ χ(a) = {total}, {'✓' if ok else '✗'}")

    # 4. Half units are squares
    print("\n--- 4. Color Balance: |squares| = |non-squares| = (p-1)/2 ---")
    for p in primes:
        sq, nsq, ok = count_squares(p)
        print(f"  p={p:3d}: squares={sq}, non-squares={nsq}, "
              f"(p-1)/2={(p-1)//2}, {'✓' if ok else '✗'}")

    # 5. Color mixing verification
    print("\n--- 5. Color Mixing Rules (sample from F₇) ---")
    results = verify_color_mixing(7)
    for a, b, cab, exp, status in results[:10]:
        print(f"  χ({a})·χ({b}) = χ({(a*b)%7}): {cab} = {exp} {status}")

    # 6. Shape detection: χ(-1) classifies p mod 4
    print("\n--- 6. Shape Detection: χ(-1) = +1 iff p ≡ 1 (mod 4) ---")
    for p in primes:
        chi_neg1 = legendre_symbol(-1, p)
        p_mod4 = p % 4
        expected = 1 if p_mod4 == 1 else -1
        ok = chi_neg1 == expected
        print(f"  p={p:3d}: χ(-1) = {chi_neg1:+d}, p mod 4 = {p_mod4}, {'✓' if ok else '✗'}")

    print("\n" + "=" * 70)
    print("All verifications demonstrate the shape-color correspondence at GL₁.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Shape-Color Correspondence Table

Creates a heatmap showing the quadratic character values χ(a) for
different primes p, visualizing the "coloring" of each finite field.
Squares are white (+1), non-squares are black (-1).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def legendre_symbol(a: int, p: int) -> int:
    if a % p == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return val if val == 1 else -1


def main():
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    max_a = max(primes)

    # Create the character table
    data = np.zeros((len(primes), max_a))
    for i, p in enumerate(primes):
        for a in range(max_a):
            if a < p:
                data[i, a] = legendre_symbol(a, p)
            else:
                data[i, a] = np.nan

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6),
                                     gridspec_kw={'width_ratios': [3, 1]})

    # Heatmap
    cmap = mcolors.ListedColormap(['#D32F2F', '#BDBDBD', '#1565C0'])
    bounds = [-1.5, -0.5, 0.5, 1.5]
    norm = mcolors.BoundaryNorm(bounds, cmap.N)

    masked_data = np.ma.masked_invalid(data)
    im = ax1.imshow(masked_data, cmap=cmap, norm=norm, aspect='auto',
                    interpolation='nearest')

    ax1.set_yticks(range(len(primes)))
    ax1.set_yticklabels([f'F_{p}' for p in primes])
    ax1.set_xlabel('Element a', fontsize=12)
    ax1.set_ylabel('Prime Field', fontsize=12)
    ax1.set_title('Shape-Color Table: χ(a) for Finite Fields', fontsize=13)

    cbar = plt.colorbar(im, ax=ax1, ticks=[-1, 0, 1], shrink=0.8)
    cbar.set_ticklabels(['Non-square (-1)', 'Zero (0)', 'Square (+1)'])

    # Bar chart: count of squares vs non-squares
    sq_counts = []
    nsq_counts = []
    for p in primes:
        sq = sum(1 for a in range(1, p) if legendre_symbol(a, p) == 1)
        nsq = sum(1 for a in range(1, p) if legendre_symbol(a, p) == -1)
        sq_counts.append(sq)
        nsq_counts.append(nsq)

    y_pos = np.arange(len(primes))
    ax2.barh(y_pos - 0.15, sq_counts, 0.3, label='Squares (+1)', color='#1565C0', alpha=0.8)
    ax2.barh(y_pos + 0.15, nsq_counts, 0.3, label='Non-squares (-1)', color='#D32F2F', alpha=0.8)
    ax2.set_yticks(y_pos)
    ax2.set_yticklabels([f'F_{p}' for p in primes])
    ax2.set_xlabel('Count', fontsize=12)
    ax2.set_title('Color Balance: |sq| = |nsq| = (p-1)/2', fontsize=11)
    ax2.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('shape_color_table.png', dpi=150, bbox_inches='tight')
    print("Saved shape_color_table.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Gauss Sums in the Complex Plane

Shows how the Gauss sum g(χ) = Σ χ(t)·e^{2πit/p} is built from
individual terms, each of which is a root of unity weighted by ±1.
The sum spirals to a point with |g(χ)| = √p.
"""

import cmath
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def legendre_symbol(a: int, p: int) -> int:
    if a % p == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return val if val == 1 else -1


def gauss_sum_partial(p: int, k: int) -> complex:
    omega = cmath.exp(2j * cmath.pi / p)
    return sum(legendre_symbol(t, p) * omega**t for t in range(k + 1))


def plot_gauss_sum_spiral(p: int, ax: plt.Axes):
    """Plot the cumulative Gauss sum as a spiral in the complex plane."""
    points = [0j] + [gauss_sum_partial(p, k) for k in range(p)]

    xs = [z.real for z in points]
    ys = [z.imag for z in points]

    # Color by Legendre symbol
    for i in range(len(points) - 1):
        chi = legendre_symbol(i, p)
        color = '#2196F3' if chi == 1 else '#F44336' if chi == -1 else '#9E9E9E'
        ax.plot([xs[i], xs[i+1]], [ys[i], ys[i+1]], color=color, linewidth=1.5, alpha=0.8)

    # Mark the final point
    final = points[-1]
    ax.plot(final.real, final.imag, 'ko', markersize=8, zorder=5)
    ax.annotate(f'g(χ) = {final.real:.2f} + {final.imag:.2f}i',
                xy=(final.real, final.imag), fontsize=8,
                xytext=(10, 10), textcoords='offset points')

    # Circle of radius sqrt(p)
    theta = np.linspace(0, 2*np.pi, 100)
    r = math.sqrt(p)
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'k--', alpha=0.3, linewidth=1)
    ax.annotate(f'|g(χ)| = √{p} ≈ {r:.2f}', xy=(r, 0), fontsize=7,
                xytext=(5, -15), textcoords='offset points', alpha=0.5)

    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title(f'Gauss Sum Spiral for F_{p}', fontsize=11)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)


def main():
    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    primes = [3, 5, 7, 11, 13, 17]

    for ax, p in zip(axes.flat, primes):
        plot_gauss_sum_spiral(p, ax)

    # Add legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='#2196F3', linewidth=2, label='χ(t) = +1 (square)'),
        Line2D([0], [0], color='#F44336', linewidth=2, label='χ(t) = -1 (non-square)'),
        Line2D([0], [0], color='#9E9E9E', linewidth=2, label='χ(t) = 0'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=10)

    fig.suptitle('Gauss Sum Spirals: Colors Encoding Shapes', fontsize=14, fontweight='bold')
    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('gauss_sum_spirals.png', dpi=150, bbox_inches='tight')
    print("Saved gauss_sum_spirals.png")


if __name__ == "__main__":
    main()
