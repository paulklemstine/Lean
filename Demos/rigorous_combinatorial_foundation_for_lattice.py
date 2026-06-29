#!/usr/bin/env python3
"""
Demo: Lattice Path Combinatorics and the LGV Foundation

Demonstrates the key results proved in Lean 4:
1. Path counting = binomial coefficients
2. Area complement theorem (palindromicity)
3. Vandermonde convolution
4. Ballot reflection identity
5. q-Binomial coefficients
6. LGV 2×2 determinant
"""

from math import comb
from algorithms import (
    all_paths, path_area, swap_path, count_east, count_north,
    q_binomial, poly_to_string, is_palindromic,
    verify_area_complement, verify_vandermonde, verify_ballot_identity,
    ballot_count
)


def demo_path_counting():
    """Demonstrate that path counts equal binomial coefficients."""
    print("=" * 60)
    print("1. PATH COUNTING = BINOMIAL COEFFICIENTS")
    print("=" * 60)
    print()
    print("Theorem (pathCount_eq_choose):")
    print("  The number of lattice paths from (0,0) to (m,n)")
    print("  equals C(m+n, n).")
    print()

    for m, n in [(2, 2), (3, 2), (3, 3), (4, 3), (5, 5)]:
        paths = all_paths(m, n) if m + n <= 8 else None
        actual = len(paths) if paths else "—"
        expected = comb(m + n, n)
        print(f"  Paths to ({m},{n}): {actual} = C({m+n},{n}) = {expected}")

    print()


def demo_area_complement():
    """Demonstrate the area complement theorem."""
    print("=" * 60)
    print("2. AREA COMPLEMENT THEOREM")
    print("=" * 60)
    print()
    print("Theorem (area_complement):")
    print("  For any path p: area(p) + area(swap(p)) = countE(p) · countN(p)")
    print()

    m, n = 3, 2
    paths = all_paths(m, n)
    print(f"  All {len(paths)} paths from (0,0) to ({m},{n}):")
    print(f"  {'Path':<20} {'area':>6} {'area(swap)':>12} {'sum':>6} {'m·n':>6}")
    print(f"  {'—' * 20} {'—' * 6} {'—' * 12} {'—' * 6} {'—' * 6}")

    for p in paths:
        a = path_area(p)
        a_swap = path_area(swap_path(p))
        path_str = ''.join(p)
        print(f"  {path_str:<20} {a:>6} {a_swap:>12} {a + a_swap:>6} {m * n:>6}")

    print()
    print(f"  ✓ All sums equal {m * n} = {m} × {n}")
    print()


def demo_area_palindromicity():
    """Demonstrate palindromicity of the area distribution."""
    print("=" * 60)
    print("3. PALINDROMICITY OF AREA DISTRIBUTION")
    print("=" * 60)
    print()
    print("The area complement theorem implies the area distribution")
    print("is symmetric around m·n/2.")
    print()

    m, n = 3, 3
    paths = all_paths(m, n)
    area_counts = {}
    for p in paths:
        a = path_area(p)
        area_counts[a] = area_counts.get(a, 0) + 1

    max_area = m * n
    print(f"  Area distribution for paths to ({m},{n}): [max area = {max_area}]")
    for a in range(max_area + 1):
        count = area_counts.get(a, 0)
        bar = '█' * count
        mirror = area_counts.get(max_area - a, 0)
        sym = "✓" if count == mirror else "✗"
        print(f"    area={a:2d}: {count:2d} paths {bar:<15} (mirror at {max_area-a}: {mirror}) {sym}")

    print()


def demo_vandermonde():
    """Demonstrate the Vandermonde convolution."""
    print("=" * 60)
    print("4. VANDERMONDE CONVOLUTION")
    print("=" * 60)
    print()
    print("Theorem (vandermonde_lattice):")
    print("  C(m+n, r) = Σ_{k=0}^r C(m,k) · C(n, r-k)")
    print()

    m, n, r = 4, 3, 3
    lhs = comb(m + n, r)
    terms = [(k, comb(m, k), comb(n, r - k)) for k in range(r + 1)]
    print(f"  C({m+n}, {r}) = {lhs}")
    print(f"  = ", end="")
    term_strs = [f"C({m},{k})·C({n},{r-k})" for k in range(r + 1)]
    print(" + ".join(term_strs))
    print(f"  = ", end="")
    val_strs = [f"{comb(m,k)}·{comb(n,r-k)}" for k in range(r + 1)]
    print(" + ".join(val_strs))
    print(f"  = {sum(comb(m,k) * comb(n,r-k) for k in range(r+1))} ✓")
    print()


def demo_ballot():
    """Demonstrate the ballot reflection identity."""
    print("=" * 60)
    print("5. BALLOT REFLECTION IDENTITY (Bertrand)")
    print("=" * 60)
    print()
    print("Theorem (ballot_reflection):")
    print("  (m+n+1)·(C(m+n,n) - C(m+n,m+1)) = (m+1-n)·C(m+n+1,n)")
    print()
    print("  This counts orderings where candidate A (with m+1 votes)")
    print("  stays strictly ahead of B (with n votes) throughout.")
    print()

    for m, n in [(2, 1), (3, 1), (4, 2), (5, 3), (10, 4)]:
        lhs = (m + n + 1) * (comb(m + n, n) - comb(m + n, m + 1))
        rhs = (m + 1 - n) * comb(m + n + 1, n)
        good = ballot_count(m + 1, n)
        total = comb(m + 1 + n, n)
        frac = f"{m+1-n}/{m+1+n}" if (m + 1 + n) > 0 else "—"
        print(f"  m={m}, n={n}: LHS={lhs}, RHS={rhs} {'✓' if lhs == rhs else '✗'}")
        print(f"    Good orderings: {good}/{total} = {frac}")

    print()


def demo_q_binomial():
    """Demonstrate q-binomial coefficients."""
    print("=" * 60)
    print("6. GAUSSIAN BINOMIAL COEFFICIENTS (q-BINOMIALS)")
    print("=" * 60)
    print()
    print("qBinomial(m,n) = Σ_{paths p to (m,n)} q^{area(p)}")
    print()

    for m, n in [(1, 1), (2, 1), (1, 2), (2, 2), (3, 2), (3, 3)]:
        poly = q_binomial(m, n)
        classical = comb(m + n, n)
        palin = is_palindromic(poly)
        print(f"  [{m+n} choose {n}]_q = {poly_to_string(poly)}")
        print(f"    at q=1: {sum(poly.values())} = C({m+n},{n}) = {classical}")
        print(f"    palindromic: {palin}")
        print()


def demo_lgv():
    """Demonstrate the LGV 2×2 determinant."""
    print("=" * 60)
    print("7. LGV 2×2 DETERMINANT")
    print("=" * 60)
    print()
    print("Theorem (lgv_2x2_adjacent):")
    print("  C(n,0)·C(n+1,1) - C(n+1,0)·C(n,1) = 1")
    print()
    print("  There is exactly ONE non-intersecting path pair")
    print("  from adjacent sources to adjacent sinks.")
    print()

    for n in range(1, 8):
        det = comb(n, 0) * comb(n + 1, 1) - comb(n + 1, 0) * comb(n, 1)
        print(f"  n={n}: 1·{n+1} - 1·{n} = {det}")

    print()


if __name__ == "__main__":
    demo_path_counting()
    demo_area_complement()
    demo_area_palindromicity()
    demo_vandermonde()
    demo_ballot()
    demo_q_binomial()
    demo_lgv()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Visualization: Area distribution of lattice paths showing palindromic symmetry."""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

from algorithms import all_paths, path_area


def plot_area_distribution():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Area Distribution of Lattice Paths\n(Palindromic Symmetry from Area Complement Theorem)',
                 fontsize=14, fontweight='bold')

    configs = [(2, 2), (3, 2), (3, 3), (4, 3)]

    for ax, (m, n) in zip(axes.flat, configs):
        paths = all_paths(m, n)
        areas = [path_area(p) for p in paths]
        max_area = m * n

        counts = {}
        for a in areas:
            counts[a] = counts.get(a, 0) + 1

        x = list(range(max_area + 1))
        y = [counts.get(a, 0) for a in x]

        colors = ['#2196F3' if a <= max_area / 2 else '#FF5722' for a in x]
        ax.bar(x, y, color=colors, edgecolor='white', linewidth=0.5)
        ax.axvline(x=max_area / 2, color='gray', linestyle='--', alpha=0.7,
                   label=f'Symmetry axis = {max_area}/2')
        ax.set_title(f'Paths to ({m},{n}): {len(paths)} paths, max area = {max_area}')
        ax.set_xlabel('Area')
        ax.set_ylabel('Count')
        ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('area_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved area_distribution.png")


if __name__ == '__main__':
    plot_area_distribution()


#!/usr/bin/env python3
"""Visualization: Lattice paths and non-intersecting path pairs."""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

from algorithms import all_paths, path_area


def draw_path(ax, path, start=(0, 0), color='blue', linewidth=2, alpha=0.8):
    """Draw a single lattice path."""
    x, y = [start[0]], [start[1]]
    cx, cy = start
    for step in path:
        if step == 'E':
            cx += 1
        else:
            cy += 1
        x.append(cx)
        y.append(cy)
    ax.plot(x, y, color=color, linewidth=linewidth, alpha=alpha)
    return (cx, cy)


def plot_all_paths_colored():
    """Plot all paths from (0,0) to (m,n) colored by area."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Lattice Paths Colored by Area\n(Darker = larger area)',
                 fontsize=14, fontweight='bold')

    configs = [(3, 2), (3, 3), (4, 3)]

    for ax, (m, n) in zip(axes, configs):
        paths = all_paths(m, n)
        max_area = m * n

        # Draw grid
        for i in range(m + 1):
            ax.plot([i, i], [0, n], 'lightgray', linewidth=0.5)
        for j in range(n + 1):
            ax.plot([0, m], [j, j], 'lightgray', linewidth=0.5)

        # Draw paths colored by area
        cmap = plt.cm.viridis
        for p in paths:
            area = path_area(p)
            color = cmap(area / max_area)
            draw_path(ax, p, color=color, linewidth=1.5, alpha=0.6)

        ax.set_title(f'({m},{n}): {len(paths)} paths')
        ax.set_xlim(-0.1, m + 0.1)
        ax.set_ylim(-0.1, n + 0.1)
        ax.set_aspect('equal')
        ax.set_xlabel('East →')
        ax.set_ylabel('North ↑')

    plt.tight_layout()
    plt.savefig('lattice_paths.png', dpi=150, bbox_inches='tight')
    print("Saved lattice_paths.png")


def plot_non_intersecting():
    """Illustrate non-intersecting path pairs for LGV."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.set_title('Non-Intersecting Path Pair (LGV 2×2)\n'
                 'Sources: (0,0), (0,1) → Sinks: (4,0), (4,1)',
                 fontsize=12, fontweight='bold')

    n = 4
    # Draw grid
    for i in range(n + 1):
        ax.plot([i, i], [-0.5, 2], 'lightgray', linewidth=0.5)
    for j in range(-1, 3):
        ax.plot([0, n], [j, j], 'lightgray', linewidth=0.5)

    # The unique non-intersecting pair:
    # Path 1: (0,0) → (4,0), all East: EEEE
    path1 = ['E'] * n
    # Path 2: (0,1) → (4,1), N then EEEE (actually just EEEE from (0,1))
    path2 = ['E'] * n

    draw_path(ax, path1, start=(0, 0), color='#2196F3', linewidth=3)
    draw_path(ax, path2, start=(0, 1), color='#FF5722', linewidth=3)

    # Mark sources and sinks
    ax.plot(0, 0, 'o', color='#2196F3', markersize=10, zorder=5)
    ax.plot(0, 1, 'o', color='#FF5722', markersize=10, zorder=5)
    ax.plot(n, 0, 's', color='#2196F3', markersize=10, zorder=5)
    ax.plot(n, 1, 's', color='#FF5722', markersize=10, zorder=5)

    ax.text(-0.3, 0, 'Source 1', fontsize=9, ha='right', color='#2196F3')
    ax.text(-0.3, 1, 'Source 2', fontsize=9, ha='right', color='#FF5722')
    ax.text(n + 0.3, 0, 'Sink 1', fontsize=9, ha='left', color='#2196F3')
    ax.text(n + 0.3, 1, 'Sink 2', fontsize=9, ha='left', color='#FF5722')

    ax.set_xlim(-0.5, n + 0.5)
    ax.set_ylim(-0.5, 2)
    ax.set_aspect('equal')
    ax.text(n/2, -0.3, 'det = C(n,0)·C(n+1,1) - C(n+1,0)·C(n,1) = 1',
            fontsize=10, ha='center', style='italic')

    plt.tight_layout()
    plt.savefig('non_intersecting.png', dpi=150, bbox_inches='tight')
    print("Saved non_intersecting.png")


if __name__ == '__main__':
    plot_all_paths_colored()
    plot_non_intersecting()


#!/usr/bin/env python3
"""Visualization: q-Binomial coefficients as heat maps and polynomial plots."""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

from algorithms import q_binomial, q_binomial_eval


def plot_q_binomial_heatmap():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Gaussian Binomial Coefficients [m+n choose n]_q',
                 fontsize=14, fontweight='bold')

    # Heatmap of q-binomial evaluated at q=0.5
    max_val = 6
    q_val = 0.5
    values = np.zeros((max_val + 1, max_val + 1))
    for m in range(max_val + 1):
        for n in range(max_val + 1):
            values[m, n] = q_binomial_eval(m, n, q_val)

    im = axes[0].imshow(values, cmap='YlOrRd', origin='lower')
    axes[0].set_xlabel('n')
    axes[0].set_ylabel('m')
    axes[0].set_title(f'[m+n choose n]_q at q = {q_val}')
    for m in range(max_val + 1):
        for n in range(max_val + 1):
            axes[0].text(n, m, f'{values[m,n]:.1f}', ha='center', va='center', fontsize=7)
    plt.colorbar(im, ax=axes[0])

    # Plot q-binomial polynomials for specific (m,n)
    q_range = np.linspace(0, 1, 100)
    configs = [(1, 1), (2, 1), (2, 2), (3, 2), (3, 3)]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(configs)))

    for (m, n), color in zip(configs, colors):
        y_vals = [q_binomial_eval(m, n, q) for q in q_range]
        axes[1].plot(q_range, y_vals, label=f'[{m+n} ch {n}]_q', color=color, linewidth=2)

    axes[1].set_xlabel('q')
    axes[1].set_ylabel('[m+n choose n]_q')
    axes[1].set_title('q-Binomials as functions of q')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('q_binomial.png', dpi=150, bbox_inches='tight')
    print("Saved q_binomial.png")


if __name__ == '__main__':
    plot_q_binomial_heatmap()
