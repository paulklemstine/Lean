#!/usr/bin/env python3
"""
Chromatic Darkness Theory — Demonstration

Numerical examples illustrating the main theorems and constructions.
"""

from algorithms import (
    DarkFamily, equitable_block_partition, verify_dark_family,
    compute_chromatic_classes, dark_inequality_check, double_count_verify,
    compute_defect_vector, witness_overlap, rejection_set, spectrum, defect
)


def demo_equitable_partition():
    """Demonstrate the equitable block partition construction."""
    print("=" * 60)
    print("DEMO 1: Equitable Block Partition Construction")
    print("=" * 60)

    for m, N in [(2, 6), (3, 12), (4, 20), (5, 30)]:
        D = equitable_block_partition(m, N)
        is_dark, level, is_balanced = verify_dark_family(D.witnesses, N)
        lhs, rhs, satisfied = dark_inequality_check(D)

        print(f"\n  m={m} worlds, N={N} candidates:")
        print(f"    Level achieved: {level}")
        print(f"    Theoretical max: {N - N // m}")
        print(f"    Is dark: {is_dark}")
        print(f"    Is balanced: {is_balanced}")
        print(f"    Dark Inequality: {lhs} ≤ {rhs} ({satisfied})")


def demo_double_counting():
    """Demonstrate the double counting identity."""
    print("\n" + "=" * 60)
    print("DEMO 2: Double Counting Identity")
    print("=" * 60)

    D = equitable_block_partition(3, 12)
    ws, cs, eq = double_count_verify(D)
    print(f"\n  m=3, N=12 equitable partition:")
    print(f"    Sum of rejection sizes (by world): {ws}")
    print(f"    Sum of defects (by candidate):     {cs}")
    print(f"    Identity holds: {eq}")

    # Show individual values
    print(f"\n    Rejection sizes: {[len(rejection_set(D, a)) for a in range(D.m)]}")
    print(f"    Defect vector:   {compute_defect_vector(D)}")


def demo_spectrum_defect():
    """Demonstrate spectrum-defect complementarity."""
    print("\n" + "=" * 60)
    print("DEMO 3: Spectrum-Defect Complementarity")
    print("=" * 60)

    D = equitable_block_partition(4, 16)
    print(f"\n  m=4, N=16 equitable partition:")
    print(f"  For each candidate n: |spectrum(n)| + defect(n) = m = 4")

    for n in range(min(8, D.N)):
        s = len(spectrum(D, n))
        d = defect(D, n)
        print(f"    n={n:2d}: |spectrum|={s}, defect={d}, sum={s + d}")


def demo_chromatic_classes():
    """Demonstrate chromatic equivalence classes."""
    print("\n" + "=" * 60)
    print("DEMO 4: Chromatic Equivalence Classes")
    print("=" * 60)

    D = equitable_block_partition(3, 12)
    classes = compute_chromatic_classes(D)
    print(f"\n  m=3, N=12 equitable partition:")
    print(f"  Number of chromatic classes: {len(classes)}")
    print(f"  Upper bound (2^m - 1): {2**D.m - 1}")

    for pattern, members in sorted(classes.items(), key=lambda x: min(x[1])):
        print(f"    Rejection pattern {set(pattern)}: candidates {members}")


def demo_witness_overlap():
    """Demonstrate witness intersection bounds."""
    print("\n" + "=" * 60)
    print("DEMO 5: Witness Intersection Bounds")
    print("=" * 60)

    D = equitable_block_partition(4, 20)
    print(f"\n  m=4, N=20 equitable partition:")
    print(f"  Theoretical lower bound: N - 2(N/m) = {D.N - 2 * (D.N // D.m)}")

    for a in range(D.m):
        for b in range(a + 1, D.m):
            overlap = witness_overlap(D, a, b)
            print(f"    |W({a}) ∩ W({b})| = {overlap}")


def demo_unbalanced():
    """Demonstrate an unbalanced dark family."""
    print("\n" + "=" * 60)
    print("DEMO 6: Unbalanced Dark Family")
    print("=" * 60)

    # Create an unbalanced family: 3 worlds, 6 candidates
    # World 0 rejects {0, 1, 2}, world 1 rejects {0, 3}, world 2 rejects {4, 5}
    witnesses = [
        {3, 4, 5},      # world 0
        {1, 2, 4, 5},   # world 1
        {0, 1, 2, 3},   # world 2
    ]
    N = 6

    is_dark, level, is_balanced = verify_dark_family(witnesses, N)
    D = DarkFamily(m=3, N=N, witnesses=witnesses, level=level)

    print(f"\n  m=3, N=6 unbalanced family:")
    print(f"    Is dark: {is_dark}")
    print(f"    Level: {level}")
    print(f"    Is balanced: {is_balanced}")
    print(f"    Defect vector: {compute_defect_vector(D)}")

    classes = compute_chromatic_classes(D)
    print(f"    Chromatic classes: {len(classes)}")
    for pattern, members in sorted(classes.items(), key=lambda x: min(x[1])):
        print(f"      Pattern {set(pattern)}: {members}")

    ws, cs, eq = double_count_verify(D)
    print(f"    Double counting: {ws} = {cs} ({eq})")
    print(f"    Total rejection ≥ N: {cs} ≥ {N} ({cs >= N})")


def demo_dark_inequality_tightness():
    """Demonstrate tightness of the Dark Inequality."""
    print("\n" + "=" * 60)
    print("DEMO 7: Dark Inequality Tightness")
    print("=" * 60)

    print("\n  Checking level × m ≤ N × (m-1) for equitable partitions:")
    for m in range(2, 7):
        for k in [1, 2, 5]:
            N = m * k
            D = equitable_block_partition(m, N)
            lhs = D.level * m
            rhs = N * (m - 1)
            ratio = lhs / rhs if rhs > 0 else 0
            print(f"    m={m}, N={N:3d}: {lhs:4d} ≤ {rhs:4d} (ratio={ratio:.4f}, tight={lhs == rhs})")


if __name__ == "__main__":
    demo_equitable_partition()
    demo_double_counting()
    demo_spectrum_defect()
    demo_chromatic_classes()
    demo_witness_overlap()
    demo_unbalanced()
    demo_dark_inequality_tightness()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Dark Inequality Feasibility Region

Plots the feasibility region of the Dark Inequality: level × m ≤ N × (m-1).
Shows how the maximum achievable darkness level depends on m and N.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def max_level(m, N):
    """Maximum darkness level: N(m-1)/m = N - N/m."""
    if m <= 1:
        return 0
    return N * (m - 1) / m


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Max level vs N for various m
    ax1 = axes[0]
    N_vals = np.arange(1, 51)
    for m in [2, 3, 4, 5, 8]:
        levels = [max_level(m, N) for N in N_vals]
        ax1.plot(N_vals, levels, 'o-', markersize=2, label=f'm={m}')
        # Mark integer achievable points (m | N)
        achievable_N = [N for N in N_vals if N % m == 0]
        achievable_L = [N - N // m for N in achievable_N]
        ax1.plot(achievable_N, achievable_L, 's', markersize=6, alpha=0.7)

    ax1.set_xlabel('N (candidates)', fontsize=12)
    ax1.set_ylabel('Max darkness level', fontsize=12)
    ax1.set_title('Maximum Darkness Level vs N', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Feasibility region for fixed N=24
    ax2 = axes[1]
    N = 24
    m_vals = np.arange(2, 25)
    max_levels = [N - N // m if N % m == 0 else N * (m - 1) // m for m in m_vals]
    ax2.fill_between(m_vals, 0, max_levels, alpha=0.3, color='#2ecc71', label='Feasible region')
    ax2.plot(m_vals, max_levels, 'o-', color='#27ae60', markersize=4, label='Max level boundary')

    # Mark special points
    for m in [2, 3, 4, 6, 8, 12, 24]:
        if m <= 24:
            L = N - N // m if N % m == 0 else N * (m - 1) // m
            ax2.annotate(f'({m},{L})', (m, L), textcoords="offset points",
                        xytext=(5, 5), fontsize=8)

    ax2.set_xlabel('m (worlds)', fontsize=12)
    ax2.set_ylabel('Darkness level', fontsize=12)
    ax2.set_title(f'Feasibility Region (N={N})', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_dark_inequality.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_dark_inequality.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Darkness Structure Heatmap

Shows the witness/rejection structure of dark families as a heatmap,
with worlds on one axis and candidates on the other.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def equitable_block_partition(m, N):
    block_size = N // m
    witnesses = []
    for a in range(m):
        rejected = set(range(a * block_size, (a + 1) * block_size))
        witnesses.append(set(range(N)) - rejected)
    return witnesses


def make_matrix(witnesses, m, N):
    mat = np.zeros((m, N))
    for a in range(m):
        for n in witnesses[a]:
            mat[a, n] = 1
    return mat


def plot_dark_family(ax, witnesses, m, N, title):
    mat = make_matrix(witnesses, m, N)
    cmap = plt.cm.colors.ListedColormap(['#2c3e50', '#27ae60'])
    ax.imshow(mat, cmap=cmap, aspect='auto', interpolation='nearest')
    ax.set_xlabel('Candidate', fontsize=10)
    ax.set_ylabel('World', fontsize=10)
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.set_yticks(range(m))
    if N <= 20:
        ax.set_xticks(range(N))


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 8))
    fig.suptitle('Dark Witness Family Structures', fontsize=14, fontweight='bold')

    # 1. Balanced equitable (m=3, N=12)
    w1 = equitable_block_partition(3, 12)
    plot_dark_family(axes[0, 0], w1, 3, 12, 'Balanced Equitable (m=3, N=12)')

    # 2. Balanced equitable (m=4, N=16)
    w2 = equitable_block_partition(4, 16)
    plot_dark_family(axes[0, 1], w2, 4, 16, 'Balanced Equitable (m=4, N=16)')

    # 3. Unbalanced family
    w3 = [
        {3, 4, 5},
        {1, 2, 4, 5},
        {0, 1, 2, 3},
    ]
    plot_dark_family(axes[1, 0], w3, 3, 6, 'Unbalanced (m=3, N=6)')

    # 4. Large balanced (m=5, N=25)
    w4 = equitable_block_partition(5, 25)
    plot_dark_family(axes[1, 1], w4, 5, 25, 'Balanced Equitable (m=5, N=25)')

    # Legend
    accept_patch = mpatches.Patch(color='#27ae60', label='Accepted (witness)')
    reject_patch = mpatches.Patch(color='#2c3e50', label='Rejected (dark)')
    fig.legend(handles=[accept_patch, reject_patch], loc='lower center',
              ncol=2, fontsize=11, frameon=True)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('viz_darkness_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_darkness_heatmap.png")


if __name__ == "__main__":
    main()
