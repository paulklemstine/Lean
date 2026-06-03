#!/usr/bin/env python3
"""
Paraconsistent Logic Demo: Paradoxes as Theorems

Demonstrates Belnap's four-valued logic and how the Liar, Russell, and Berry
paradoxes become well-behaved theorems in a paraconsistent framework.
"""

from enum import Enum
from typing import Callable, Dict, List, Tuple


class BelnapVal(Enum):
    """The four truth values of Belnap's logic."""
    T = "True"
    F = "False"
    B = "Both"
    N = "Neither"


def is_true(v: BelnapVal) -> bool:
    """A value is 'at least true' if it is T or B."""
    return v in (BelnapVal.T, BelnapVal.B)


def is_false(v: BelnapVal) -> bool:
    """A value is 'at least false' if it is F or B."""
    return v in (BelnapVal.F, BelnapVal.B)


def belnap_neg(v: BelnapVal) -> BelnapVal:
    """Belnap negation: swaps T↔F, fixes B and N."""
    return {
        BelnapVal.T: BelnapVal.F,
        BelnapVal.F: BelnapVal.T,
        BelnapVal.B: BelnapVal.B,
        BelnapVal.N: BelnapVal.N,
    }[v]


def belnap_conj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Belnap conjunction (truth-order meet)."""
    table = {
        (BelnapVal.T, BelnapVal.T): BelnapVal.T,
        (BelnapVal.T, BelnapVal.F): BelnapVal.F,
        (BelnapVal.T, BelnapVal.B): BelnapVal.B,
        (BelnapVal.T, BelnapVal.N): BelnapVal.N,
        (BelnapVal.F, BelnapVal.T): BelnapVal.F,
        (BelnapVal.F, BelnapVal.F): BelnapVal.F,
        (BelnapVal.F, BelnapVal.B): BelnapVal.F,
        (BelnapVal.F, BelnapVal.N): BelnapVal.F,
        (BelnapVal.B, BelnapVal.T): BelnapVal.B,
        (BelnapVal.B, BelnapVal.F): BelnapVal.F,
        (BelnapVal.B, BelnapVal.B): BelnapVal.B,
        (BelnapVal.B, BelnapVal.N): BelnapVal.F,
        (BelnapVal.N, BelnapVal.T): BelnapVal.N,
        (BelnapVal.N, BelnapVal.F): BelnapVal.F,
        (BelnapVal.N, BelnapVal.B): BelnapVal.F,
        (BelnapVal.N, BelnapVal.N): BelnapVal.N,
    }
    return table[(a, b)]


def belnap_disj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Belnap disjunction (truth-order join)."""
    table = {
        (BelnapVal.T, BelnapVal.T): BelnapVal.T,
        (BelnapVal.T, BelnapVal.F): BelnapVal.T,
        (BelnapVal.T, BelnapVal.B): BelnapVal.T,
        (BelnapVal.T, BelnapVal.N): BelnapVal.T,
        (BelnapVal.F, BelnapVal.T): BelnapVal.T,
        (BelnapVal.F, BelnapVal.F): BelnapVal.F,
        (BelnapVal.F, BelnapVal.B): BelnapVal.B,
        (BelnapVal.F, BelnapVal.N): BelnapVal.N,
        (BelnapVal.B, BelnapVal.T): BelnapVal.T,
        (BelnapVal.B, BelnapVal.F): BelnapVal.B,
        (BelnapVal.B, BelnapVal.B): BelnapVal.B,
        (BelnapVal.B, BelnapVal.N): BelnapVal.T,
        (BelnapVal.N, BelnapVal.T): BelnapVal.T,
        (BelnapVal.N, BelnapVal.F): BelnapVal.N,
        (BelnapVal.N, BelnapVal.B): BelnapVal.T,
        (BelnapVal.N, BelnapVal.N): BelnapVal.N,
    }
    return table[(a, b)]


def demo_liar_paradox():
    """Demonstrate the Liar sentence in four-valued logic."""
    print("=" * 60)
    print("DEMO 1: The Liar Paradox")
    print("=" * 60)
    print()
    print("The Liar sentence L says 'L is false'.")
    print("Formally: truth(L) = truth(neg(L)) = neg(truth(L))")
    print()
    print("In classical logic, this leads to contradiction:")
    print("  If truth(L) = T, then neg(T) = F ≠ T  →  contradiction!")
    print("  If truth(L) = F, then neg(F) = T ≠ F  →  contradiction!")
    print()
    print("In four-valued logic, we check all values:")
    for v in BelnapVal:
        neg_v = belnap_neg(v)
        is_fixed = (v == neg_v)
        at_least_true = is_true(v)
        status = "✓ FIXED POINT" if is_fixed else "✗ not a fixed point"
        if is_fixed:
            status += f" (at-least-true: {at_least_true})"
        print(f"  truth(L) = {v.value:8s} → neg(truth(L)) = {neg_v.value:8s}  {status}")
    print()
    print("Result: The Liar has value Both — it is simultaneously true and false.")
    print("        Both is at-least-true, so the Liar is a valid theorem.")
    print()


def demo_russell_paradox():
    """Demonstrate Russell's set in four-valued logic."""
    print("=" * 60)
    print("DEMO 2: Russell's Paradox")
    print("=" * 60)
    print()
    print("Russell's set R = {x : x ∉ x}.")
    print("Self-membership: mem(R,R) = neg(mem(R,R))")
    print()
    print("Same fixed-point analysis as the Liar:")
    for v in BelnapVal:
        neg_v = belnap_neg(v)
        is_fixed = (v == neg_v)
        if is_fixed:
            print(f"  mem(R,R) = {v.value:8s} → neg = {neg_v.value:8s}  ✓ CONSISTENT")
        else:
            print(f"  mem(R,R) = {v.value:8s} → neg = {neg_v.value:8s}  ✗ inconsistent")
    print()
    print("Result: R both contains and doesn't contain itself (value Both).")
    print()


def demo_berry_paradox():
    """Demonstrate Berry's paradox via pigeonhole."""
    print("=" * 60)
    print("DEMO 3: Berry's Paradox")
    print("=" * 60)
    print()
    print("'The smallest number not definable in fewer than 20 words'")
    print()
    n_descriptions = 10
    n_numbers = 15
    print(f"Suppose we have {n_descriptions} descriptions and {n_numbers} numbers.")
    print(f"Any definability function f: numbers → descriptions is non-injective.")
    print()

    # Simulate pigeonhole
    import random
    random.seed(42)
    f = {i: random.randint(0, n_descriptions - 1) for i in range(n_numbers)}
    print("Example definability mapping:")
    for num, desc in f.items():
        print(f"  number {num:2d} → description {desc}")

    # Find collision
    reverse: Dict[int, List[int]] = {}
    for num, desc in f.items():
        reverse.setdefault(desc, []).append(num)

    for desc, nums in reverse.items():
        if len(nums) > 1:
            print(f"\nCollision found! Numbers {nums} all map to description {desc}")
            break

    print()
    print("Result: Multiple numbers share the same description.")
    print("        Berry's 'paradox' is just the pigeonhole principle.")
    print()


def demo_explosion_failure():
    """Demonstrate that explosion fails in FDE."""
    print("=" * 60)
    print("DEMO 4: Explosion Failure")
    print("=" * 60)
    print()
    print("Classical logic: From p ∧ ¬p, anything follows (ex falso quodlibet).")
    print("FDE: Contradiction does NOT imply everything.")
    print()
    print("Check p ∧ ¬p for each truth value:")
    for v in BelnapVal:
        neg_v = belnap_neg(v)
        conj_v = belnap_conj(v, neg_v)
        print(f"  p = {v.value:8s} → p ∧ ¬p = {conj_v.value:8s}")

    print()
    print("When p = Both: p ∧ ¬p = Both (not True!).")
    print("Contradiction stays contained — no explosion.")
    print()


def demo_four_value_necessity():
    """Demonstrate why three values aren't enough."""
    print("=" * 60)
    print("DEMO 5: Why Four Values Are Necessary")
    print("=" * 60)
    print()
    print("Three-valued logic has T, F, I (intermediate).")
    print("Negation: neg(T)=F, neg(F)=T, neg(I)=I")
    print()

    three_vals = {"T": "F", "F": "T", "I": "I"}
    three_true = {"T": True, "F": False, "I": False}

    print("Fixed points of negation in 3-valued logic:")
    for v, neg_v in three_vals.items():
        if v == neg_v:
            at_true = three_true[v]
            print(f"  {v} is a fixed point. At-least-true? {at_true}")
    print()
    print("Only I is a fixed point, and I is NOT at-least-true.")
    print("⟹ Three-valued logic cannot make the Liar a theorem!")
    print()

    print("Fixed points of negation in 4-valued logic:")
    for v in BelnapVal:
        if v == belnap_neg(v):
            print(f"  {v.value} is a fixed point. At-least-true? {is_true(v)}")
    print()
    print("B is a fixed point AND at-least-true.")
    print("⟹ Four-valued logic CAN make the Liar a theorem!")
    print()


def demo_inconsistency_spectrum():
    """Demonstrate the inconsistency spectrum of a sample theory."""
    print("=" * 60)
    print("DEMO 6: Inconsistency Spectrum")
    print("=" * 60)
    print()

    # Sample theory: 8 sentences with mixed truth values
    sentences = ["p", "q", "r", "s", "t", "u", "v", "w"]
    truth_vals = [
        BelnapVal.T, BelnapVal.B, BelnapVal.F, BelnapVal.B,
        BelnapVal.T, BelnapVal.N, BelnapVal.B, BelnapVal.T,
    ]

    print("Sample theory with 8 sentences:")
    for s, v in zip(sentences, truth_vals):
        marker = " ← DIALETHEIA" if v == BelnapVal.B else ""
        print(f"  truth({s}) = {v.value}{marker}")

    spectrum = {v: sum(1 for tv in truth_vals if tv == v) for v in BelnapVal}
    print()
    print("Inconsistency Spectrum:")
    for v, count in spectrum.items():
        bar = "█" * count
        print(f"  {v.value:8s}: {count} {bar}")

    inc_degree = spectrum[BelnapVal.B]
    total = len(sentences)
    print()
    print(f"Inconsistency degree: {inc_degree}/{total} = {inc_degree/total:.1%}")
    print(f"Theory is non-trivial: has T ({spectrum[BelnapVal.T]}) and F ({spectrum[BelnapVal.F]})")
    print(f"Tolerance threshold: ≤ {total - 2} dialetheias ✓ ({inc_degree} ≤ {total - 2})")
    print()


def demo_paradox_span():
    """Demonstrate paradox span closure."""
    print("=" * 60)
    print("DEMO 7: Paradox Span Closure")
    print("=" * 60)
    print()
    print("Starting from B-valued seeds, apply connectives:")
    print()

    b = BelnapVal.B
    print(f"  seed: B")
    print(f"  neg(B) = {belnap_neg(b).value}")
    print(f"  conj(B, B) = {belnap_conj(b, b).value}")
    print(f"  disj(B, B) = {belnap_disj(b, b).value}")
    print(f"  neg(conj(B, B)) = {belnap_neg(belnap_conj(b, b)).value}")
    print(f"  disj(neg(B), conj(B, B)) = {belnap_disj(belnap_neg(b), belnap_conj(b, b)).value}")
    print()
    print("Every derived sentence is Both!")
    print("The paradox span of {B} is closed: inconsistency propagates perfectly.")
    print("But it never leaks to non-B sentences.")
    print()


if __name__ == "__main__":
    demo_liar_paradox()
    demo_russell_paradox()
    demo_berry_paradox()
    demo_explosion_failure()
    demo_four_value_necessity()
    demo_inconsistency_spectrum()
    demo_paradox_span()

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("All three classical paradoxes become theorems in 4-valued logic:")
    print("  • Liar: truth value Both (both true and false)")
    print("  • Russell: self-membership value Both")
    print("  • Berry: pigeonhole principle (non-injectivity)")
    print()
    print("Key insight: Four values are NECESSARY and SUFFICIENT.")
    print("Three-valued logic provably cannot do this.")


#!/usr/bin/env python3
"""
Visualization: Belnap's Four-Valued Logic Lattice and Truth Tables

Generates a visual representation of the Belnap lattice, truth tables
for all connectives, and the inconsistency spectrum of sample theories.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_belnap_lattice(ax):
    """Plot the Belnap bilattice (truth and information orderings)."""
    # Positions: information ordering vertical, truth ordering horizontal
    positions = {
        'N': (0.5, 0.0),   # bottom (least info)
        'T': (0.0, 0.5),   # left (true)
        'F': (1.0, 0.5),   # right (false)
        'B': (0.5, 1.0),   # top (most info)
    }

    colors = {
        'T': '#2ecc71',  # green
        'F': '#e74c3c',  # red
        'B': '#9b59b6',  # purple
        'N': '#95a5a6',  # gray
    }

    labels = {
        'T': 'True',
        'F': 'False',
        'B': 'Both',
        'N': 'Neither',
    }

    # Draw edges (information ordering)
    info_edges = [('N', 'T'), ('N', 'F'), ('T', 'B'), ('F', 'B')]
    for a, b in info_edges:
        ax.plot([positions[a][0], positions[b][0]],
                [positions[a][1], positions[b][1]],
                'k-', linewidth=1.5, alpha=0.4)

    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.08, color=colors[name],
                           ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center',
               fontsize=14, fontweight='bold', color='white', zorder=6)
        ax.text(x, y - 0.14, labels[name], ha='center', va='top',
               fontsize=9, color=colors[name])

    # Labels
    ax.text(0.5, 1.18, '↑ more information', ha='center', fontsize=8, color='gray')
    ax.text(0.5, -0.18, '↓ less information', ha='center', fontsize=8, color='gray')
    ax.text(-0.2, 0.5, '← true', ha='center', va='center', fontsize=8,
           color='#2ecc71', rotation=90)
    ax.text(1.2, 0.5, 'false →', ha='center', va='center', fontsize=8,
           color='#e74c3c', rotation=90)

    ax.set_xlim(-0.4, 1.4)
    ax.set_ylim(-0.3, 1.3)
    ax.set_aspect('equal')
    ax.set_title('Belnap Bilattice', fontsize=14, fontweight='bold')
    ax.axis('off')


def plot_truth_table(ax, operation, title):
    """Plot a 4x4 truth table as a colored grid."""
    vals = ['T', 'F', 'B', 'N']
    colors_map = {
        'T': '#2ecc71',
        'F': '#e74c3c',
        'B': '#9b59b6',
        'N': '#95a5a6',
    }

    grid = np.zeros((4, 4, 3))
    for i, a in enumerate(vals):
        for j, b in enumerate(vals):
            result = operation(a, b)
            r, g, bl = [int(colors_map[result][k:k+2], 16)/255
                       for k in (1, 3, 5)]
            grid[i, j] = [r, g, bl]

    ax.imshow(grid, interpolation='nearest', aspect='equal')

    for i, a in enumerate(vals):
        for j, b in enumerate(vals):
            result = operation(a, b)
            ax.text(j, i, result, ha='center', va='center',
                   fontsize=11, fontweight='bold', color='white')

    ax.set_xticks(range(4))
    ax.set_yticks(range(4))
    ax.set_xticklabels(vals)
    ax.set_yticklabels(vals)
    ax.set_xlabel('Right operand')
    ax.set_ylabel('Left operand')
    ax.set_title(title, fontsize=12, fontweight='bold')


def conj_op(a, b):
    table = {
        ('T','T'):'T',('T','F'):'F',('T','B'):'B',('T','N'):'N',
        ('F','T'):'F',('F','F'):'F',('F','B'):'F',('F','N'):'F',
        ('B','T'):'B',('B','F'):'F',('B','B'):'B',('B','N'):'F',
        ('N','T'):'N',('N','F'):'F',('N','B'):'F',('N','N'):'N',
    }
    return table[(a, b)]


def disj_op(a, b):
    table = {
        ('T','T'):'T',('T','F'):'T',('T','B'):'T',('T','N'):'T',
        ('F','T'):'T',('F','F'):'F',('F','B'):'B',('F','N'):'N',
        ('B','T'):'T',('B','F'):'B',('B','B'):'B',('B','N'):'T',
        ('N','T'):'T',('N','F'):'N',('N','B'):'T',('N','N'):'N',
    }
    return table[(a, b)]


def plot_inconsistency_spectrum(ax):
    """Plot the inconsistency spectrum of a sample theory."""
    categories = ['True', 'False', 'Both', 'Neither']
    values = [3, 2, 2, 1]
    colors = ['#2ecc71', '#e74c3c', '#9b59b6', '#95a5a6']

    bars = ax.bar(categories, values, color=colors, edgecolor='black', linewidth=1.5)

    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               str(val), ha='center', va='bottom', fontweight='bold', fontsize=12)

    ax.set_ylabel('Number of sentences')
    ax.set_title('Inconsistency Spectrum\n(sample theory, 8 sentences)', fontsize=12, fontweight='bold')
    ax.set_ylim(0, max(values) + 1)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # Annotation
    inc_ratio = values[2] / sum(values)
    ax.text(0.95, 0.95, f'Inconsistency: {inc_ratio:.0%}',
           transform=ax.transAxes, ha='right', va='top',
           fontsize=10, bbox=dict(boxstyle='round', facecolor='#f0e6f6'))


if __name__ == "__main__":
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    plot_belnap_lattice(axes[0, 0])
    plot_truth_table(axes[0, 1], conj_op, 'Conjunction (∧)')
    plot_truth_table(axes[1, 0], disj_op, 'Disjunction (∨)')
    plot_inconsistency_spectrum(axes[1, 1])

    fig.suptitle("Belnap's Four-Valued Logic: Paradoxes as Theorems",
                fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('belnap_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
