#!/usr/bin/env python3
"""
Non-Desarguesian Planes: Demonstration of Hall Quasifield Properties

This script demonstrates the key algebraic properties of the Hall quasifield
on GF(9), including:
- Non-associativity witness
- Nucleus computation
- Associator distribution
- Comparison with standard field multiplication
"""

from typing import Tuple

# Type alias for GF(9) elements
GF9 = Tuple[int, int]


def gf9_add(x: GF9, y: GF9) -> GF9:
    """Componentwise addition mod 3."""
    return ((x[0] + y[0]) % 3, (x[1] + y[1]) % 3)


def gf9_neg(x: GF9) -> GF9:
    """Negation mod 3."""
    return ((-x[0]) % 3, (-x[1]) % 3)


def gf9_sub(x: GF9, y: GF9) -> GF9:
    """Subtraction mod 3."""
    return gf9_add(x, gf9_neg(y))


def gf9_mul(x: GF9, y: GF9) -> GF9:
    """Standard field multiplication in GF(9) = GF(3)[α]/(α²+1)."""
    return (
        (x[0] * y[0] + 2 * x[1] * y[1]) % 3,
        (x[0] * y[1] + x[1] * y[0]) % 3,
    )


def frobenius(x: GF9) -> GF9:
    """Frobenius automorphism σ(a, b) = (a, 2b)."""
    return (x[0], (2 * x[1]) % 3)


def hall_mul(x: GF9, y: GF9) -> GF9:
    """Hall multiplication on GF(9).
    x ○ y = x·y if y in GF(3), σ(x)·y otherwise."""
    if y[1] == 0:
        return ((x[0] * y[0]) % 3, (x[1] * y[0]) % 3)
    else:
        return (
            (x[0] * y[0] + x[1] * y[1]) % 3,
            (x[0] * y[1] + 2 * x[1] * y[0]) % 3,
        )


# All elements of GF(9)
GF9_ELEMENTS = [(a, b) for a in range(3) for b in range(3)]


def demo_nonassociativity():
    """Demonstrate that Hall multiplication is non-associative."""
    print("=" * 60)
    print("NON-ASSOCIATIVITY OF HALL MULTIPLICATION")
    print("=" * 60)

    a, b, c = (1, 1), (1, 1), (0, 1)
    ab = hall_mul(a, b)
    ab_c = hall_mul(ab, c)
    bc = hall_mul(b, c)
    a_bc = hall_mul(a, bc)

    print(f"\nWitness: a = {a}, b = {b}, c = {c}")
    print(f"  a ○ b = {ab}")
    print(f"  (a ○ b) ○ c = {ab_c}")
    print(f"  b ○ c = {bc}")
    print(f"  a ○ (b ○ c) = {a_bc}")
    print(f"\n  (a ○ b) ○ c = {ab_c} ≠ {a_bc} = a ○ (b ○ c)")
    print("  → Hall multiplication is NOT associative! ✓")


def demo_field_associativity():
    """Verify that standard GF(9) multiplication IS associative."""
    print("\n" + "=" * 60)
    print("ASSOCIATIVITY OF STANDARD GF(9) MULTIPLICATION")
    print("=" * 60)

    failures = 0
    for a in GF9_ELEMENTS:
        for b in GF9_ELEMENTS:
            for c in GF9_ELEMENTS:
                if gf9_mul(gf9_mul(a, b), c) != gf9_mul(a, gf9_mul(b, c)):
                    failures += 1

    print(f"\n  Checked all {len(GF9_ELEMENTS)**3} triples")
    print(f"  Associativity failures: {failures}")
    print(f"  → Standard GF(9) multiplication IS associative ✓")


def demo_right_distributivity():
    """Verify right distributivity of Hall multiplication."""
    print("\n" + "=" * 60)
    print("RIGHT DISTRIBUTIVITY OF HALL MULTIPLICATION")
    print("=" * 60)

    failures = 0
    for a in GF9_ELEMENTS:
        for b in GF9_ELEMENTS:
            for c in GF9_ELEMENTS:
                lhs = hall_mul(gf9_add(a, b), c)
                rhs = gf9_add(hall_mul(a, c), hall_mul(b, c))
                if lhs != rhs:
                    failures += 1

    print(f"\n  Checked all {len(GF9_ELEMENTS)**3} triples")
    print(f"  Right distributivity failures: {failures}")
    print(f"  → Hall multiplication IS right-distributive ✓")


def demo_nucleus():
    """Compute and display the left nucleus of the Hall quasifield."""
    print("\n" + "=" * 60)
    print("LEFT NUCLEUS OF HALL QUASIFIELD")
    print("=" * 60)

    nucleus = []
    for a in GF9_ELEMENTS:
        in_nucleus = True
        for b in GF9_ELEMENTS:
            for c in GF9_ELEMENTS:
                if hall_mul(a, hall_mul(b, c)) != hall_mul(hall_mul(a, b), c):
                    in_nucleus = False
                    break
            if not in_nucleus:
                break
        if in_nucleus:
            nucleus.append(a)

    print(f"\n  Left nucleus elements: {nucleus}")
    print(f"  Nucleus size: {len(nucleus)}")
    print(f"  GF(9) size: {len(GF9_ELEMENTS)}")
    print(f"  Defect: {len(GF9_ELEMENTS) - len(nucleus)}")

    base_field = [x for x in GF9_ELEMENTS if x[1] == 0]
    print(f"\n  Base field GF(3): {base_field}")
    print(f"  Nucleus = Base field: {set(map(tuple, nucleus)) == set(map(tuple, base_field))}")
    print("  → Left nucleus is exactly the base field GF(3) ✓")


def demo_associator_distribution():
    """Analyze the distribution of associator values."""
    print("\n" + "=" * 60)
    print("ASSOCIATOR DISTRIBUTION")
    print("=" * 60)

    associator_counts: dict = {}
    total_nonzero = 0

    for a in GF9_ELEMENTS:
        for b in GF9_ELEMENTS:
            for c in GF9_ELEMENTS:
                lhs = hall_mul(hall_mul(a, b), c)
                rhs = hall_mul(a, hall_mul(b, c))
                assoc = gf9_sub(lhs, rhs)
                if assoc != (0, 0):
                    total_nonzero += 1
                associator_counts[assoc] = associator_counts.get(assoc, 0) + 1

    print(f"\n  Total triples: {len(GF9_ELEMENTS)**3}")
    print(f"  Non-associating triples: {total_nonzero}")
    print(f"  Associating triples: {len(GF9_ELEMENTS)**3 - total_nonzero}")
    print(f"\n  Associator value distribution:")
    for val in sorted(associator_counts.keys()):
        count = associator_counts[val]
        pct = 100 * count / len(GF9_ELEMENTS) ** 3
        marker = " (zero)" if val == (0, 0) else ""
        print(f"    [{val}]: {count:4d} ({pct:5.1f}%){marker}")


def demo_symmetry_loss():
    """Demonstrate the symmetry loss theorem numerically."""
    print("\n" + "=" * 60)
    print("SYMMETRY LOSS: HALL vs PGL")
    print("=" * 60)

    print(f"\n  {'q':>3} | {'Hall order':>12} | {'PGL(3,q²) order':>18} | {'Ratio':>10}")
    print(f"  {'-'*3}-+-{'-'*12}-+-{'-'*18}-+-{'-'*10}")

    for q in [3, 4, 5, 7, 8, 9, 11, 13]:
        hall = q**2 * (q**2 - 1) * q * (q - 1)
        q2 = q**2
        pgl = q2**3 * (q2**3 - 1) * (q2**2 - 1)
        ratio = pgl / hall if hall > 0 else float("inf")
        print(f"  {q:3d} | {hall:12,d} | {pgl:18,d} | {ratio:10,.1f}")

    print("\n  → The ratio grows rapidly, confirming symmetry loss theorem ✓")


if __name__ == "__main__":
    demo_nonassociativity()
    demo_field_associativity()
    demo_right_distributivity()
    demo_nucleus()
    demo_associator_distribution()
    demo_symmetry_loss()
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of the Hall Quasifield Associator Distribution

Creates a heatmap showing which triples (a,b,c) fail to associate
under Hall multiplication on GF(9).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Tuple


GF9 = Tuple[int, int]


def hall_mul(x: GF9, y: GF9) -> GF9:
    """Hall multiplication on GF(9)."""
    if y[1] == 0:
        return ((x[0] * y[0]) % 3, (x[1] * y[0]) % 3)
    else:
        return (
            (x[0] * y[0] + x[1] * y[1]) % 3,
            (x[0] * y[1] + 2 * x[1] * y[0]) % 3,
        )


def gf9_index(x: GF9) -> int:
    """Map GF(9) element to index 0-8."""
    return x[0] * 3 + x[1]


def index_to_gf9(i: int) -> GF9:
    """Map index 0-8 to GF(9) element."""
    return (i // 3, i % 3)


def main():
    elements = [(a, b) for a in range(3) for b in range(3)]

    # For each fixed c, create a 9x9 heatmap of associator norm
    fig, axes = plt.subplots(3, 3, figsize=(14, 12))
    fig.suptitle('Associator Distribution in Hall Quasifield on GF(9)\n'
                 'Color = |[a,b,c]| (0 = associative, nonzero = failure)',
                 fontsize=14, fontweight='bold')

    for ci, c in enumerate(elements):
        ax = axes[ci // 3][ci % 3]
        matrix = np.zeros((9, 9))

        for ai, a in enumerate(elements):
            for bi, b in enumerate(elements):
                lhs = hall_mul(hall_mul(a, b), c)
                rhs = hall_mul(a, hall_mul(b, c))
                # Norm: sum of squared differences mod 3
                diff = ((lhs[0] - rhs[0]) % 3, (lhs[1] - rhs[1]) % 3)
                norm = min(diff[0], 3 - diff[0]) ** 2 + min(diff[1], 3 - diff[1]) ** 2
                matrix[ai][bi] = norm

        im = ax.imshow(matrix, cmap='RdYlBu_r', aspect='equal', vmin=0, vmax=2)
        ax.set_title(f'c = {c}', fontsize=10)
        ax.set_xlabel('b index')
        ax.set_ylabel('a index')

        # Mark base field elements
        for i in [0, 3, 6]:  # indices with second coord = 0
            ax.axhline(y=i - 0.5, color='green', linewidth=0.5, alpha=0.5)
            ax.axvline(x=i - 0.5, color='green', linewidth=0.5, alpha=0.5)

    plt.tight_layout()
    fig.colorbar(im, ax=axes, shrink=0.6, label='Associator magnitude')
    plt.savefig('hall_associator_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved: hall_associator_heatmap.png")

    # Summary plot: total non-associating pairs for each c
    fig2, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Count failures per element in left position
    left_failures = []
    labels = []
    for a in elements:
        count = 0
        for b in elements:
            for c in elements:
                if hall_mul(hall_mul(a, b), c) != hall_mul(a, hall_mul(b, c)):
                    count += 1
        left_failures.append(count)
        labels.append(str(a))

    colors = ['#2ecc71' if elements[i][1] == 0 else '#e74c3c' for i in range(9)]
    ax1.bar(range(9), left_failures, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xticks(range(9))
    ax1.set_xticklabels(labels, rotation=45)
    ax1.set_xlabel('Element a')
    ax1.set_ylabel('Number of (b,c) pairs where [a,b,c] ≠ 0')
    ax1.set_title('Associativity Failures by Left Element\n'
                   '(Green = base field / nucleus, Red = non-nuclear)')

    # Symmetry loss chart
    qs = [3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19]
    hall_orders = [float(q**2) * (q**2 - 1) * q * (q - 1) for q in qs]
    pgl_orders = [float(q**6) * (q**6 - 1) * (q**4 - 1) for q in qs]

    ax2.semilogy(qs, pgl_orders, 'bo-', label='|PGL(3, q²)|', markersize=6)
    ax2.semilogy(qs, hall_orders, 'rs-', label='|Aut(Hall(q²))|', markersize=6)
    ax2.fill_between(qs, hall_orders, pgl_orders, alpha=0.15, color='purple')
    ax2.set_xlabel('q (base field order)')
    ax2.set_ylabel('Group order (log scale)')
    ax2.set_title('Symmetry Loss: Hall Plane vs Desarguesian Plane')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hall_symmetry_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: hall_symmetry_analysis.png")


if __name__ == "__main__":
    main()
