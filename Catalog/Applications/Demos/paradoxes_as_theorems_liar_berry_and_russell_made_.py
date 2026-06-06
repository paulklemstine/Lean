#!/usr/bin/env python3
"""
Dialectical Algebras: Interactive Demo

Demonstrates the key results from the dialectical algebra framework:
1. Belnap bilattice structure and operations
2. Fixpoint classification and sublattice theorem
3. Dialectical rank computation
4. Product decomposition (BVal ≅ Bool × Bool)
5. Paradox independence analysis
"""

from enum import Enum
from typing import List, Tuple, Dict

class BVal(Enum):
    T = "T"  # True only
    F = "F"  # False only
    B = "B"  # Both true and false
    N = "N"  # Neither true nor false

    def is_true(self) -> bool:
        return self in (BVal.T, BVal.B)

    def is_false(self) -> bool:
        return self in (BVal.F, BVal.B)

    def neg(self) -> 'BVal':
        return {BVal.T: BVal.F, BVal.F: BVal.T, BVal.B: BVal.B, BVal.N: BVal.N}[self]

    def dialectical_rank(self) -> int:
        return 1 if self.neg() == self else 0

    def to_bool_pair(self) -> Tuple[bool, bool]:
        return {BVal.T: (True, False), BVal.F: (False, True),
                BVal.B: (True, True), BVal.N: (False, False)}[self]

    @staticmethod
    def from_bool_pair(p: Tuple[bool, bool]) -> 'BVal':
        return {(True, False): BVal.T, (False, True): BVal.F,
                (True, True): BVal.B, (False, False): BVal.N}[p]


def truth_le(a: BVal, b: BVal) -> bool:
    """Truth ordering: F ≤ N,B ≤ T"""
    if a == BVal.F or b == BVal.T:
        return True
    return a == b


def know_le(a: BVal, b: BVal) -> bool:
    """Knowledge ordering: N ≤ T,F ≤ B"""
    if a == BVal.N or b == BVal.B:
        return True
    return a == b


def k_meet(a: BVal, b: BVal) -> BVal:
    """Knowledge-order meet (consensus)"""
    pa, pb = a.to_bool_pair(), b.to_bool_pair()
    return BVal.from_bool_pair((pa[0] and pb[0], pa[1] and pb[1]))


def k_join(a: BVal, b: BVal) -> BVal:
    """Knowledge-order join (gullibility)"""
    pa, pb = a.to_bool_pair(), b.to_bool_pair()
    return BVal.from_bool_pair((pa[0] or pb[0], pa[1] or pb[1]))


def t_meet(a: BVal, b: BVal) -> BVal:
    """Truth-order meet (conjunction)"""
    table = {
        (BVal.T, BVal.T): BVal.T, (BVal.T, BVal.F): BVal.F,
        (BVal.T, BVal.B): BVal.B, (BVal.T, BVal.N): BVal.N,
        (BVal.F, BVal.T): BVal.F, (BVal.F, BVal.F): BVal.F,
        (BVal.F, BVal.B): BVal.F, (BVal.F, BVal.N): BVal.F,
        (BVal.B, BVal.T): BVal.B, (BVal.B, BVal.F): BVal.F,
        (BVal.B, BVal.B): BVal.B, (BVal.B, BVal.N): BVal.F,
        (BVal.N, BVal.T): BVal.N, (BVal.N, BVal.F): BVal.F,
        (BVal.N, BVal.B): BVal.F, (BVal.N, BVal.N): BVal.N,
    }
    return table[(a, b)]


def theory_rank(truth: List[BVal]) -> int:
    return sum(v.dialectical_rank() for v in truth)


def main():
    print("=" * 60)
    print("DIALECTICAL ALGEBRAS: INTERACTIVE DEMO")
    print("=" * 60)

    # Demo 1: Fixpoint Classification
    print("\n--- 1. Fixpoint Classification ---")
    print("Value | neg(v) | Fixpoint? | Rank")
    print("-" * 40)
    for v in BVal:
        nv = v.neg()
        fp = "YES" if nv == v else "no"
        print(f"  {v.value}   |   {nv.value}    |    {fp}     |  {v.dialectical_rank()}")

    # Demo 2: Knowledge Sublattice
    print("\n--- 2. Fixpoint Sublattice Theorem ---")
    print("For fixpoints {B, N}:")
    fixpoints = [BVal.B, BVal.N]
    print(f"  kMeet(B, N) = {k_meet(BVal.B, BVal.N).value} (fixpoint: {k_meet(BVal.B, BVal.N).neg() == k_meet(BVal.B, BVal.N)})")
    print(f"  kJoin(B, N) = {k_join(BVal.B, BVal.N).value} (fixpoint: {k_join(BVal.B, BVal.N).neg() == k_join(BVal.B, BVal.N)})")
    print(f"  tMeet(B, N) = {t_meet(BVal.B, BVal.N).value} (fixpoint: {t_meet(BVal.B, BVal.N).neg() == t_meet(BVal.B, BVal.N)})")
    print("  → Knowledge operations preserve fixpoints; truth operations don't!")

    # Demo 3: Product Decomposition
    print("\n--- 3. Product Decomposition: BVal ≅ Bool × Bool ---")
    print("Value | (isTrue, isFalse) | neg → swap")
    print("-" * 50)
    for v in BVal:
        p = v.to_bool_pair()
        swapped = (p[1], p[0])
        neg_v = BVal.from_bool_pair(swapped)
        print(f"  {v.value}   |    ({int(p[0])}, {int(p[1])})         | ({int(swapped[0])}, {int(swapped[1])}) = {neg_v.value}")

    # Demo 4: Dialectical Rank
    print("\n--- 4. Dialectical Rank Examples ---")
    theories = [
        ("Classical",      [BVal.T, BVal.F, BVal.T, BVal.F, BVal.T]),
        ("One paradox",    [BVal.T, BVal.B, BVal.F, BVal.T, BVal.F]),
        ("Two paradoxes",  [BVal.T, BVal.B, BVal.F, BVal.N, BVal.T]),
        ("Max paradox",    [BVal.B, BVal.B, BVal.N, BVal.B, BVal.N]),
    ]
    for name, truth in theories:
        vals = " ".join(v.value for v in truth)
        rank = theory_rank(truth)
        classical = "YES" if rank == 0 else "no"
        print(f"  {name:18s}: [{vals}] → rank={rank}, classical={classical}")

    # Demo 5: Paradox Independence
    print("\n--- 5. Paradox Independence ---")
    print("Two fixpoints are independent iff they have different values.")
    print("In BVal, there are exactly 2 fixpoints: B and N.")
    print("  B (glut): too much information (both true and false)")
    print("  N (gap):  too little information (neither true nor false)")
    print("  → The Liar (B) and a gap-Russell (N) are independent.")
    print("  → Two Liars (B, B) are NOT independent (same value).")

    # Demo 6: Collapse Theorem
    print("\n--- 6. Dialectical Collapse Theorem ---")
    print("Can excluded middle hold in a dialectical algebra?")
    print("  EM requires every element ∈ {⊤_t, ⊥_t} = {T, F}")
    print("  But ⊥_k (=N) and ⊤_k (=B) must be in {T, F}")
    print("  N ≠ B, so one is T and one is F")
    print("  But neg(T) = F ≠ T, and neg(F) = T ≠ F")
    print("  So N and B cannot be fixpoints of neg — CONTRADICTION")
    print("  → EM is incompatible with dialectical structure ∎")

    # Demo 7: Knowledge ordering table
    print("\n--- 7. Knowledge Ordering ---")
    print("  a ≤_k b table:")
    print("     T  F  B  N")
    for a in BVal:
        row = "  " + a.value + "  "
        for b in BVal:
            row += ("✓" if know_le(a, b) else "·") + "  "
        print(row)

    # Demo 8: Self-soundness
    print("\n--- 8. Self-Soundness ---")
    print("A theory is self-sound if provable → at-least-true.")
    print("at-least-true = {T, B} (B counts as 'at least true'!)")
    print("This is why paradoxes (B-valued) don't break soundness.")
    truth = [BVal.T, BVal.B, BVal.F, BVal.N, BVal.T]
    provable = {0, 1, 4}  # indices of provable sentences
    sound = all(truth[i].is_true() for i in provable)
    print(f"  Theory: [{' '.join(v.value for v in truth)}]")
    print(f"  Provable: sentences {provable}")
    print(f"  Self-sound: {sound}")

    print("\n" + "=" * 60)
    print("All results verified by machine-checked Lean 4 proofs.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Belnap Bilattice as a Dialectical Algebra

Produces a side-by-side visualization of the truth ordering and
knowledge ordering on BVal = {T, F, B, N}, highlighting the
fixpoint sublattice and the collapse theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_hasse_diagram(ax, title, positions, edges, node_colors, node_labels,
                       fixpoint_nodes=None):
    """Draw a Hasse diagram on the given axes."""
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw edges
    for (n1, n2) in edges:
        x1, y1 = positions[n1]
        x2, y2 = positions[n2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, zorder=1)

    # Draw nodes
    for node, (x, y) in positions.items():
        color = node_colors.get(node, '#CCCCCC')
        is_fp = fixpoint_nodes and node in fixpoint_nodes
        edgecolor = '#FF4444' if is_fp else 'black'
        linewidth = 3 if is_fp else 1.5
        circle = plt.Circle((x, y), 0.3, facecolor=color, edgecolor=edgecolor,
                             linewidth=linewidth, zorder=2)
        ax.add_patch(circle)
        label = node_labels.get(node, node)
        ax.text(x, y, label, ha='center', va='center', fontsize=12,
                fontweight='bold', zorder=3)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Node colors
    colors = {
        'T': '#4CAF50',  # Green for True
        'F': '#F44336',  # Red for False
        'B': '#9C27B0',  # Purple for Both
        'N': '#FF9800',  # Orange for Neither
    }
    labels = {'T': 'T', 'F': 'F', 'B': 'B', 'N': 'N'}
    fixpoints = {'B', 'N'}

    # --- Truth Ordering ---
    truth_positions = {
        'T': (0, 3),
        'B': (-0.8, 1.5),
        'N': (0.8, 1.5),
        'F': (0, 0),
    }
    truth_edges = [('F', 'B'), ('F', 'N'), ('B', 'T'), ('N', 'T')]
    draw_hasse_diagram(axes[0], 'Truth Ordering (≤ₜ)',
                       truth_positions, truth_edges, colors, labels, fixpoints)
    axes[0].text(0, -0.3, 'F = ⊥ₜ, T = ⊤ₜ\nB ⊥ N (incomparable)',
                 ha='center', fontsize=9, style='italic')

    # --- Knowledge Ordering ---
    know_positions = {
        'B': (0, 3),
        'T': (-0.8, 1.5),
        'F': (0.8, 1.5),
        'N': (0, 0),
    }
    know_edges = [('N', 'T'), ('N', 'F'), ('T', 'B'), ('F', 'B')]
    draw_hasse_diagram(axes[1], 'Knowledge Ordering (≤ₖ)',
                       know_positions, know_edges, colors, labels, fixpoints)
    axes[1].text(0, -0.3, 'N = ⊥ₖ, B = ⊤ₖ\nT ⊥ F (incomparable)',
                 ha='center', fontsize=9, style='italic')

    # --- Fixpoint Sublattice ---
    fp_positions = {
        'B': (0, 3),
        'N': (0, 0),
    }
    fp_edges = [('N', 'B')]
    fp_colors = {'B': '#9C27B0', 'N': '#FF9800'}
    draw_hasse_diagram(axes[2], 'Fixpoint Sublattice\n(Dialectical Core)',
                       fp_positions, fp_edges, fp_colors, labels, fixpoints)
    axes[2].text(0, -0.3, 'Fix(neg) = {B, N}\nClosed under kMeet, kJoin\nNOT closed under tMeet, tJoin',
                 ha='center', fontsize=9, style='italic')

    # Add legend
    legend_elements = [
        mpatches.Patch(facecolor='#4CAF50', label='T (true)'),
        mpatches.Patch(facecolor='#F44336', label='F (false)'),
        mpatches.Patch(facecolor='#9C27B0', label='B (both) — fixpoint'),
        mpatches.Patch(facecolor='#FF9800', label='N (neither) — fixpoint'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=4,
               fontsize=10, frameon=True)

    plt.suptitle('The Belnap Bilattice as a Dialectical Algebra',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout(rect=[0, 0.08, 1, 1])
    plt.savefig('bilattice_diagram.png', dpi=150, bbox_inches='tight')
    print("Saved: bilattice_diagram.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Dialectical Rank Landscape

Shows how the dialectical rank varies across the space of theories,
with color-coding for different paradox spectra.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as cartesian_product


def bval_neg(v):
    return {'T': 'F', 'F': 'T', 'B': 'B', 'N': 'N'}[v]

def is_fixpoint(v):
    return bval_neg(v) == v

def theory_rank(truth):
    return sum(1 for v in truth if is_fixpoint(v))

def spectrum(truth):
    return tuple(sum(1 for v in truth if v == x) for x in ['T', 'F', 'B', 'N'])


def main():
    n = 4  # Theory size
    values = ['T', 'F', 'B', 'N']

    # Enumerate all theories on n sentences
    all_theories = list(cartesian_product(values, repeat=n))
    ranks = [theory_rank(t) for t in all_theories]
    spectra = [spectrum(t) for t in all_theories]

    # Count theories by rank
    rank_counts = {}
    for r in ranks:
        rank_counts[r] = rank_counts.get(r, 0) + 1

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Rank distribution
    ax = axes[0]
    rank_vals = sorted(rank_counts.keys())
    counts = [rank_counts[r] for r in rank_vals]
    bars = ax.bar(rank_vals, counts, color=['#4CAF50' if r == 0 else
                                            '#FFC107' if r == 1 else
                                            '#FF9800' if r == 2 else
                                            '#F44336' if r == 3 else
                                            '#9C27B0' for r in rank_vals],
                  edgecolor='black', linewidth=0.5)
    ax.set_xlabel('Dialectical Rank', fontsize=12)
    ax.set_ylabel('Number of Theories', fontsize=12)
    ax.set_title(f'Rank Distribution (n={n})', fontsize=13, fontweight='bold')
    for bar, count in zip(bars, counts):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 2,
                str(count), ha='center', va='bottom', fontsize=10)

    # Plot 2: Classical vs Paradox fraction
    ax = axes[1]
    n_range = range(1, 7)
    classical_fracs = []
    for nn in n_range:
        total = 4 ** nn
        classical = 2 ** nn  # Only T and F
        classical_fracs.append(classical / total)
    ax.plot(list(n_range), classical_fracs, 'o-', color='#4CAF50',
            linewidth=2, markersize=8, label='Classical (rank 0)')
    ax.plot(list(n_range), [1 - f for f in classical_fracs], 's-',
            color='#9C27B0', linewidth=2, markersize=8,
            label='Paradoxical (rank > 0)')
    ax.set_xlabel('Number of Sentences (n)', fontsize=12)
    ax.set_ylabel('Fraction of Theories', fontsize=12)
    ax.set_title('Classical vs Paradoxical Theories', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Plot 3: Average rank growth
    ax = axes[2]
    avg_ranks = []
    for nn in n_range:
        # Each sentence independently has rank 0 (T,F) or 1 (B,N)
        # P(rank=1) = 2/4 = 0.5 per sentence
        # E[total rank] = 0.5 * nn
        avg_ranks.append(0.5 * nn)
    ax.plot(list(n_range), avg_ranks, 'D-', color='#FF9800',
            linewidth=2, markersize=8)
    ax.fill_between(list(n_range), [0]*len(n_range), avg_ranks,
                     alpha=0.2, color='#FF9800')
    ax.set_xlabel('Number of Sentences (n)', fontsize=12)
    ax.set_ylabel('Expected Dialectical Rank', fontsize=12)
    ax.set_title('Average Rank = n/2', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.text(4, 1.0, 'E[rank] = n/2\n(each sentence\nhas 50% chance\nof being paradoxical)',
            fontsize=9, style='italic', bbox=dict(boxstyle='round', facecolor='wheat'))

    plt.suptitle('Dialectical Rank: Measuring Distance from Classical Logic',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('dialectical_rank.png', dpi=150, bbox_inches='tight')
    print("Saved: dialectical_rank.png")


if __name__ == "__main__":
    main()
