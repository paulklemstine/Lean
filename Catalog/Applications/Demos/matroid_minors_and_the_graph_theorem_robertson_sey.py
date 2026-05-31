#!/usr/bin/env python3
"""
Matroid Minor Theory: Demonstrations

This script demonstrates key concepts from the matroid minor framework:
1. Construction of well-known matroids (uniform, Fano, non-Fano)
2. Minor operations (deletion and contraction)
3. Representability testing over finite fields
4. The forbidden minor paradigm in action
"""

from algorithms import (
    Matroid, uniform_matroid, fano_matroid,
    is_representable_over_gf, check_wqo_property
)
from itertools import combinations
from typing import FrozenSet, Set


def non_fano_matroid() -> Matroid:
    """The non-Fano matroid: like F_7 but with one line 'relaxed'.

    Same as Fano but {0,2,6} is made independent (no longer a line).
    This is representable over every field EXCEPT GF(2).
    """
    ground = frozenset(range(7))
    lines = [
        frozenset({0, 1, 3}), frozenset({1, 2, 4}), frozenset({2, 3, 5}),
        frozenset({3, 4, 6}), frozenset({0, 4, 5}), frozenset({1, 5, 6}),
        # {0, 2, 6} is NOT a line in the non-Fano
    ]
    indep: Set[FrozenSet[int]] = set()
    indep.add(frozenset())
    for e in ground:
        indep.add(frozenset({e}))
    for pair in combinations(ground, 2):
        indep.add(frozenset(pair))
    for triple in combinations(ground, 3):
        t = frozenset(triple)
        if t not in lines:
            indep.add(t)
    return Matroid(ground, indep)


def demo_matroid_basics():
    """Demonstrate basic matroid operations."""
    print("=" * 60)
    print("DEMO 1: Basic Matroid Operations")
    print("=" * 60)

    # Uniform matroids
    for r, n in [(2, 4), (2, 3), (1, 3)]:
        M = uniform_matroid(n, r)
        print(f"\nU({r},{n}):")
        print(f"  Ground set: {sorted(M.ground_set)}")
        print(f"  Rank: {M.matroid_rank()}")
        print(f"  Number of bases: {len(M.bases())}")
        print(f"  Number of circuits: {len(M.circuits())}")

    # Fano matroid
    F7 = fano_matroid()
    print(f"\nFano matroid F_7:")
    print(f"  Ground set: {sorted(F7.ground_set)}")
    print(f"  Rank: {F7.matroid_rank()}")
    print(f"  Number of bases: {len(F7.bases())}")
    print(f"  Circuits (lines of PG(2,2)): {sorted(sorted(c) for c in F7.circuits())}")


def demo_minor_operations():
    """Demonstrate deletion and contraction."""
    print("\n" + "=" * 60)
    print("DEMO 2: Minor Operations (Deletion & Contraction)")
    print("=" * 60)

    U24 = uniform_matroid(4, 2)
    print(f"\nStarting matroid U(2,4):")
    print(f"  Ground set: {sorted(U24.ground_set)}")
    print(f"  Rank: {U24.matroid_rank()}")

    # Delete element 3
    M_del = U24.delete(frozenset({3}))
    print(f"\nAfter deleting {{3}}:")
    print(f"  Ground set: {sorted(M_del.ground_set)}")
    print(f"  Rank: {M_del.matroid_rank()}")
    print(f"  This is U(2,3)")

    # Contract element 0
    M_con = U24.contract(frozenset({0}))
    print(f"\nAfter contracting {{0}}:")
    print(f"  Ground set: {sorted(M_con.ground_set)}")
    print(f"  Rank: {M_con.matroid_rank()}")
    print(f"  This is U(1,3)")

    # Combined: contract 0, then delete 3
    M_minor = U24.contract(frozenset({0})).delete(frozenset({3}))
    print(f"\nAfter contracting {{0}} then deleting {{3}}:")
    print(f"  Ground set: {sorted(M_minor.ground_set)}")
    print(f"  Rank: {M_minor.matroid_rank()}")
    print(f"  This is U(1,2)")


def demo_representability():
    """Demonstrate representability testing over finite fields."""
    print("\n" + "=" * 60)
    print("DEMO 3: Representability over Finite Fields")
    print("=" * 60)

    matroids = {
        "U(2,3)": uniform_matroid(3, 2),
        "U(2,4)": uniform_matroid(4, 2),
        "Fano F_7": fano_matroid(),
        "Non-Fano F_7^-": non_fano_matroid(),
    }

    fields = [2, 3, 5]

    print(f"\n{'Matroid':<20}", end="")
    for q in fields:
        print(f"{'GF(' + str(q) + ')':<12}", end="")
    print()
    print("-" * 56)

    for name, M in matroids.items():
        print(f"{name:<20}", end="")
        for q in fields:
            result = is_representable_over_gf(M, q)
            if result[0] is None:
                status = "too large"
            elif result[0]:
                status = "YES"
            else:
                status = "NO"
            print(f"{status:<12}", end="")
        print()

    print("\nKey observations:")
    print("  - Fano F_7 is representable over GF(2) but NOT over GF(3)")
    print("  - Non-Fano F_7^- is representable over GF(3) but NOT over GF(2)")
    print("  - These are the 'forbidden minors' that distinguish binary/ternary matroids")


def demo_forbidden_minors():
    """Demonstrate the forbidden minor paradigm."""
    print("\n" + "=" * 60)
    print("DEMO 4: The Forbidden Minor Paradigm")
    print("=" * 60)

    print("""
The Robertson-Seymour theorem for graphs states:
  Every minor-closed graph property is characterized by
  a FINITE set of forbidden minors.

For matroids over finite fields, we conjecture the same:

  CONJECTURE (Rota, 1971): For every finite field GF(q),
  the class of GF(q)-representable matroids has finitely
  many excluded minors.

Known results:
  q=2 (binary):   Excluded minor = U(2,4)         [Tutte 1958]
  q=3 (ternary):  Excluded minors include F_7, F_7*, U(2,5), U(3,5),
                  and others                       [partial: Bixby, Seymour]
  q=4:            10 excluded minors known          [Geelen-Gerards-Kapoor 2000]
  q≥5:            OPEN (conjecture: finitely many)

Our formalized framework proves:
  IF the RS property (WQO by minors) holds for GF(q)-representable matroids,
  THEN every minor-closed subproperty has finitely many excluded minors.
""")


def demo_wqo_test():
    """Test WQO property on small sequences of matroids."""
    print("=" * 60)
    print("DEMO 5: Testing the Well-Quasi-Ordering Property")
    print("=" * 60)

    # Create a sequence of uniform matroids
    sequence = [uniform_matroid(n, min(n, 2)) for n in range(2, 6)]
    names = [f"U(min(2,{n}),{n})" for n in range(2, 6)]

    print("\nSequence of uniform matroids:")
    for i, (name, M) in enumerate(zip(names, sequence)):
        print(f"  [{i}] {name}: rank={M.matroid_rank()}, |E|={len(M.ground_set)}")

    found, pair = check_wqo_property(sequence)
    if found:
        i, j = pair
        print(f"\nWQO witness found: {names[i]} is a minor of {names[j]}")
        print(f"  (indices i={i} < j={j})")
    else:
        print("\nNo WQO pair found in this sequence")


def demo_antichain_obstruction():
    """Show that general matroids can have infinite antichains."""
    print("\n" + "=" * 60)
    print("DEMO 6: Antichain Obstruction for General Matroids")
    print("=" * 60)

    print("""
For GENERAL matroids (not restricted to a finite field), the WQO
property FAILS. There exist infinite antichains:

Example: The 'spike' matroids S_n form an infinite antichain.
  - S_n has rank n+1 on 2n elements
  - No S_i is a minor of S_j for i ≠ j
  - These are not representable over any fixed finite field

This is why the Robertson-Seymour conjecture for matroids
restricts to F_q-representable matroids.

Verified theorem (Lean 4):
  rs_implies_no_infinite_antichain:
    HasRobertsonSeymourProperty C → HasNoInfiniteAntichain C
  
  Proof: By contradiction. An infinite antichain in C would give
  an injective f : ℕ → C with no minor relations. But the RS
  property guarantees i < j with f(i) ≤_m f(j), contradicting
  the antichain property.
""")


if __name__ == "__main__":
    demo_matroid_basics()
    demo_minor_operations()
    demo_representability()
    demo_forbidden_minors()
    demo_wqo_test()
    demo_antichain_obstruction()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Matroid Minor Lattice

Generates a visualization of the minor partial order for small matroids,
highlighting forbidden minors and the antichain structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_matroid_minor_lattice():
    """Draw the minor lattice for small uniform matroids and the Fano matroid."""

    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left panel: Minor lattice of uniform matroids
    ax1 = axes[0]
    ax1.set_title("Minor Lattice of Small Matroids\n(Uniform Matroids)", fontsize=14, fontweight='bold')

    # Positions for uniform matroids U(r,n)
    # Format: (r, n) -> (x, y)
    matroids = {
        'U(0,0)': (3, 0),
        'U(0,1)': (1.5, 1), 'U(1,1)': (4.5, 1),
        'U(0,2)': (0, 2), 'U(1,2)': (3, 2), 'U(2,2)': (6, 2),
        'U(0,3)': (-0.5, 3), 'U(1,3)': (2, 3), 'U(2,3)': (4, 3), 'U(3,3)': (6.5, 3),
        'U(1,4)': (1, 4), 'U(2,4)': (3, 4), 'U(3,4)': (5, 4),
    }

    # Minor relations (edges)
    edges = [
        ('U(0,0)', 'U(0,1)'), ('U(0,0)', 'U(1,1)'),
        ('U(0,1)', 'U(0,2)'), ('U(0,1)', 'U(1,2)'),
        ('U(1,1)', 'U(1,2)'), ('U(1,1)', 'U(2,2)'),
        ('U(0,2)', 'U(0,3)'), ('U(0,2)', 'U(1,3)'),
        ('U(1,2)', 'U(1,3)'), ('U(1,2)', 'U(2,3)'),
        ('U(2,2)', 'U(2,3)'), ('U(2,2)', 'U(3,3)'),
        ('U(1,3)', 'U(1,4)'), ('U(1,3)', 'U(2,4)'),
        ('U(2,3)', 'U(2,4)'), ('U(2,3)', 'U(3,4)'),
        ('U(3,3)', 'U(3,4)'),
    ]

    # Colors: GF(2)-representable = blue, not = red
    binary = {'U(0,0)', 'U(0,1)', 'U(1,1)', 'U(0,2)', 'U(1,2)', 'U(2,2)',
              'U(0,3)', 'U(1,3)', 'U(2,3)', 'U(3,3)', 'U(1,4)', 'U(3,4)'}
    forbidden = {'U(2,4)'}  # The unique excluded minor for binary matroids

    for name, (x, y) in matroids.items():
        if name in forbidden:
            color = '#ff4444'
            edgecolor = '#cc0000'
            size = 800
        elif name in binary:
            color = '#4488ff'
            edgecolor = '#2266cc'
            size = 500
        else:
            color = '#ffaa44'
            edgecolor = '#cc8822'
            size = 500
        ax1.scatter(x, y, s=size, c=color, edgecolors=edgecolor, linewidths=2, zorder=5)
        ax1.annotate(name, (x, y), textcoords="offset points", xytext=(0, -20),
                    ha='center', fontsize=8, fontweight='bold')

    for start, end in edges:
        x1, y1 = matroids[start]
        x2, y2 = matroids[end]
        ax1.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="-", color='gray', lw=1.5))

    legend_elements = [
        mpatches.Patch(facecolor='#4488ff', edgecolor='#2266cc', label='Binary (GF(2)-rep.)'),
        mpatches.Patch(facecolor='#ff4444', edgecolor='#cc0000', label='Excluded minor: U(2,4)'),
        mpatches.Patch(facecolor='#ffaa44', edgecolor='#cc8822', label='Not binary'),
    ]
    ax1.legend(handles=legend_elements, loc='upper left', fontsize=10)
    ax1.set_xlim(-1.5, 7.5)
    ax1.set_ylim(-0.5, 5)
    ax1.set_ylabel("Complexity (size of ground set)", fontsize=11)
    ax1.axis('off')

    # Right panel: The Forbidden Minor Paradigm
    ax2 = axes[1]
    ax2.set_title("Forbidden Minor Paradigm\nfor Finite Field Representability", fontsize=14, fontweight='bold')

    # Draw a schematic of the forbidden minor hierarchy
    fields = [
        ('GF(2)', 1, ['U(2,4)'], '#4488ff'),
        ('GF(3)', 2, ['U(2,5)', 'U(3,5)', 'F₇', 'F₇*'], '#44bb44'),
        ('GF(4)', 3, ['7 minors'], '#ffaa44'),
        ('GF(5)', 4, ['? (open)'], '#ff6666'),
    ]

    for field, y_pos, minors, color in fields:
        # Field label
        ax2.text(0.5, y_pos, field, fontsize=16, fontweight='bold',
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.7))

        # Arrow and forbidden minors
        minor_text = ', '.join(minors)
        ax2.annotate('', xy=(2.0, y_pos), xytext=(1.2, y_pos),
                    arrowprops=dict(arrowstyle='->', lw=2, color='black'))
        ax2.text(2.2, y_pos, f"Excluded minors: {minor_text}",
                fontsize=11, va='center')

    # Add theorem statement
    ax2.text(2.5, 0.2,
            "Theorem (Formalized):\nWQO ⟹ finitely many\nexcluded minors",
            fontsize=12, style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#eeeeee', alpha=0.8),
            ha='center', va='center')

    ax2.set_xlim(-0.5, 5.5)
    ax2.set_ylim(-0.5, 5)
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig('matroid_minor_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: matroid_minor_lattice.png")


def draw_antichain_theorem():
    """Visualize the antichain theorem for forbidden minors."""

    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_title("The Antichain Theorem\nForbidden Minors Cannot Be Compared",
                fontsize=16, fontweight='bold')

    # Draw several "forbidden minors" as nodes
    forbidden = [
        ('F₇', 2, 4), ('F₇*', 5, 4), ('U(2,5)', 3.5, 2.5),
        ('U(3,5)', 1, 2), ('M₁', 6, 2.5),
    ]

    for name, x, y in forbidden:
        ax.scatter(x, y, s=1000, c='#ff4444', edgecolors='#cc0000',
                  linewidths=3, zorder=5)
        ax.text(x, y, name, ha='center', va='center', fontsize=12,
               fontweight='bold', color='white')

    # Draw crossed-out arrows between them (no minor relations)
    for i in range(len(forbidden)):
        for j in range(i + 1, len(forbidden)):
            x1, y1 = forbidden[i][1], forbidden[i][2]
            x2, y2 = forbidden[j][1], forbidden[j][2]
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            ax.plot([x1, x2], [y1, y2], '--', color='#cccccc', lw=1, zorder=1)
            ax.text(mx, my, '✗', fontsize=20, ha='center', va='center',
                   color='red', fontweight='bold', zorder=3)

    # Add explanation
    ax.text(3.5, 0.5,
            "Theorem: No forbidden minor is a minor of another.\n"
            "Proof: If F₁ ≤ₘ F₂ and F₁ ≠ F₂, then F₂ being a\n"
            "forbidden minor means all proper minors satisfy P.\n"
            "So P(F₁) holds — contradiction with F₁ ∈ Forb(P).",
            fontsize=11, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#fff8e0', alpha=0.9))

    ax.set_xlim(-0.5, 7.5)
    ax.set_ylim(-0.5, 5.5)
    ax.axis('off')

    plt.savefig('antichain_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: antichain_theorem.png")


if __name__ == "__main__":
    draw_matroid_minor_lattice()
    draw_antichain_theorem()
    print("\nAll visualizations generated.")
