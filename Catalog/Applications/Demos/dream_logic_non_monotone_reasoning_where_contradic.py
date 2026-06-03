#!/usr/bin/env python3
"""
Dream Logic: Numerical Demonstrations

Demonstrates Belnap's four-valued paraconsistent logic,
dream belief states, and pre-topological semantics.
"""

from enum import Enum
from typing import Dict, Set, List, Tuple, Optional
from itertools import product


class BelnapVal(Enum):
    """Belnap's four truth values."""
    VERUM = "T"      # true only
    FALSUM = "F"     # false only
    BOTH = "B"       # both true and false (glut)
    NEITHER = "N"    # neither true nor false (gap)

    def is_designated(self) -> bool:
        """At least true."""
        return self in (BelnapVal.VERUM, BelnapVal.BOTH)

    def neg(self) -> 'BelnapVal':
        """Belnap negation."""
        return {
            BelnapVal.VERUM: BelnapVal.FALSUM,
            BelnapVal.FALSUM: BelnapVal.VERUM,
            BelnapVal.BOTH: BelnapVal.BOTH,
            BelnapVal.NEITHER: BelnapVal.NEITHER,
        }[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        """Belnap conjunction (truth-order meet)."""
        table = {
            (BelnapVal.VERUM, BelnapVal.VERUM): BelnapVal.VERUM,
            (BelnapVal.VERUM, BelnapVal.FALSUM): BelnapVal.FALSUM,
            (BelnapVal.VERUM, BelnapVal.BOTH): BelnapVal.BOTH,
            (BelnapVal.VERUM, BelnapVal.NEITHER): BelnapVal.NEITHER,
            (BelnapVal.FALSUM, BelnapVal.VERUM): BelnapVal.FALSUM,
            (BelnapVal.FALSUM, BelnapVal.FALSUM): BelnapVal.FALSUM,
            (BelnapVal.FALSUM, BelnapVal.BOTH): BelnapVal.FALSUM,
            (BelnapVal.FALSUM, BelnapVal.NEITHER): BelnapVal.FALSUM,
            (BelnapVal.BOTH, BelnapVal.VERUM): BelnapVal.BOTH,
            (BelnapVal.BOTH, BelnapVal.FALSUM): BelnapVal.FALSUM,
            (BelnapVal.BOTH, BelnapVal.BOTH): BelnapVal.BOTH,
            (BelnapVal.BOTH, BelnapVal.NEITHER): BelnapVal.FALSUM,
            (BelnapVal.NEITHER, BelnapVal.VERUM): BelnapVal.NEITHER,
            (BelnapVal.NEITHER, BelnapVal.FALSUM): BelnapVal.FALSUM,
            (BelnapVal.NEITHER, BelnapVal.BOTH): BelnapVal.FALSUM,
            (BelnapVal.NEITHER, BelnapVal.NEITHER): BelnapVal.NEITHER,
        }
        return table[(self, other)]

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        """Belnap disjunction (truth-order join)."""
        table = {
            (BelnapVal.VERUM, BelnapVal.VERUM): BelnapVal.VERUM,
            (BelnapVal.VERUM, BelnapVal.FALSUM): BelnapVal.VERUM,
            (BelnapVal.VERUM, BelnapVal.BOTH): BelnapVal.VERUM,
            (BelnapVal.VERUM, BelnapVal.NEITHER): BelnapVal.VERUM,
            (BelnapVal.FALSUM, BelnapVal.VERUM): BelnapVal.VERUM,
            (BelnapVal.FALSUM, BelnapVal.FALSUM): BelnapVal.FALSUM,
            (BelnapVal.FALSUM, BelnapVal.BOTH): BelnapVal.BOTH,
            (BelnapVal.FALSUM, BelnapVal.NEITHER): BelnapVal.NEITHER,
            (BelnapVal.BOTH, BelnapVal.VERUM): BelnapVal.VERUM,
            (BelnapVal.BOTH, BelnapVal.FALSUM): BelnapVal.BOTH,
            (BelnapVal.BOTH, BelnapVal.BOTH): BelnapVal.BOTH,
            (BelnapVal.BOTH, BelnapVal.NEITHER): BelnapVal.VERUM,
            (BelnapVal.NEITHER, BelnapVal.VERUM): BelnapVal.VERUM,
            (BelnapVal.NEITHER, BelnapVal.FALSUM): BelnapVal.NEITHER,
            (BelnapVal.NEITHER, BelnapVal.BOTH): BelnapVal.VERUM,
            (BelnapVal.NEITHER, BelnapVal.NEITHER): BelnapVal.NEITHER,
        }
        return table[(self, other)]

    def impl(self, other: 'BelnapVal') -> 'BelnapVal':
        """Material implication: A → B = ¬A ∨ B."""
        return self.neg().disj(other)


def demo_explosion_failure():
    """Demonstrate that explosion fails in Belnap's logic."""
    print("=" * 60)
    print("DEMO 1: Explosion Failure in FDE")
    print("=" * 60)

    p_val = BelnapVal.BOTH
    q_val = BelnapVal.FALSUM

    print(f"\nValuation: P = {p_val.value} (both true and false)")
    print(f"           Q = {q_val.value} (false)")
    print(f"\nP is designated (at least true): {p_val.is_designated()}")
    print(f"¬P = {p_val.neg().value}")
    print(f"¬P is designated: {p_val.neg().is_designated()}")
    print(f"\nSo P and ¬P are BOTH designated (contradiction exists).")
    print(f"But Q is designated: {q_val.is_designated()}")
    print(f"\n→ Explosion FAILS: {p_val.value} ∧ ¬{p_val.value} does NOT entail {q_val.value}")


def demo_modus_ponens():
    """Show when modus ponens works and when it fails."""
    print("\n" + "=" * 60)
    print("DEMO 2: Modus Ponens — When It Works and When It Fails")
    print("=" * 60)

    print("\nChecking all 16 cases of modus ponens (A, A→B ⊨ B):")
    print(f"{'A':>8} {'B':>8} {'A→B':>8} {'A des':>8} {'A→B des':>8} {'B des':>8} {'MP ok?':>8}")
    print("-" * 60)

    failures = []
    for a, b in product(BelnapVal, BelnapVal):
        imp = a.impl(b)
        a_des = a.is_designated()
        imp_des = imp.is_designated()
        b_des = b.is_designated()
        mp_ok = not (a_des and imp_des) or b_des
        marker = "✓" if mp_ok else "✗ FAIL"
        print(f"{a.value:>8} {b.value:>8} {imp.value:>8} {str(a_des):>8} {str(imp_des):>8} {str(b_des):>8} {marker:>8}")
        if not mp_ok:
            failures.append((a, b))

    print(f"\nModus ponens failures: {len(failures)}")
    for a, b in failures:
        print(f"  A={a.value}, B={b.value}: A and A→B are designated but B is not")


def demo_de_morgan():
    """Verify De Morgan's law for all value pairs."""
    print("\n" + "=" * 60)
    print("DEMO 3: De Morgan's Law ¬(A∧B) = ¬A∨¬B")
    print("=" * 60)

    all_pass = True
    for a, b in product(BelnapVal, BelnapVal):
        lhs = a.conj(b).neg()
        rhs = a.neg().disj(b.neg())
        ok = lhs == rhs
        if not ok:
            print(f"  FAIL: A={a.value}, B={b.value}: ¬(A∧B)={lhs.value} ≠ ¬A∨¬B={rhs.value}")
            all_pass = False

    if all_pass:
        print("✓ De Morgan's law holds for ALL 16 value combinations!")


def demo_dream_state():
    """Demonstrate dream belief states and retraction."""
    print("\n" + "=" * 60)
    print("DEMO 4: Dream Belief States and Retraction")
    print("=" * 60)

    # A dream state where "the cat is alive" is contradictory
    beliefs: Dict[str, BelnapVal] = {
        "cat_alive": BelnapVal.BOTH,       # alive AND dead
        "sky_blue": BelnapVal.VERUM,       # normally true
        "unicorn": BelnapVal.NEITHER,      # unknown
        "gravity_up": BelnapVal.FALSUM,    # false
    }

    print("\nDream state:")
    for prop, val in beliefs.items():
        status = "★ contradictory" if val == BelnapVal.BOTH else ""
        print(f"  {prop}: {val.value} (designated: {val.is_designated()}) {status}")

    # Retract the contradiction
    prop_to_retract = "cat_alive"
    print(f"\nRetracting '{prop_to_retract}'...")
    if beliefs[prop_to_retract] == BelnapVal.BOTH:
        beliefs[prop_to_retract] = BelnapVal.NEITHER

    print("\nAfter retraction:")
    for prop, val in beliefs.items():
        status = "★ contradictory" if val == BelnapVal.BOTH else ""
        print(f"  {prop}: {val.value} (designated: {val.is_designated()}) {status}")

    contradictions = [p for p, v in beliefs.items() if v == BelnapVal.BOTH]
    print(f"\nContradictions remaining: {len(contradictions)}")
    print("→ Retraction successfully removed the contradiction!")


def demo_pretopology():
    """Demonstrate the pre-topology that fails to be a topology."""
    print("\n" + "=" * 60)
    print("DEMO 5: Pre-Topological Space (Dream Geometry)")
    print("=" * 60)

    # Open sets on {0, 1, 2}
    open_sets = [
        frozenset(),           # empty
        frozenset({0}),        # singleton 0
        frozenset({1}),        # singleton 1
        frozenset({0, 1, 2}),  # full set
    ]

    print("\nOpen sets of the dream pre-topology on {0, 1, 2}:")
    for s in open_sets:
        print(f"  {set(s) if s else '∅'}")

    # Check intersection closure
    print("\nIntersection closure check:")
    for i, u in enumerate(open_sets):
        for j, v in enumerate(open_sets):
            if i <= j:
                inter = u & v
                is_open = inter in open_sets
                print(f"  {set(u) if u else '∅'} ∩ {set(v) if v else '∅'} = {set(inter) if inter else '∅'} — open: {is_open}")

    # Check union failure
    print("\nUnion closure check (showing failure):")
    u1 = frozenset({0})
    u2 = frozenset({1})
    union = u1 | u2
    is_open = union in open_sets
    print(f"  {set(u1)} ∪ {set(u2)} = {set(union)} — open: {is_open}")
    print(f"\n→ The union {set(union)} is NOT open!")
    print("→ This pre-topology is NOT a topology.")
    print("→ This mirrors how individually coherent dream-fragments")
    print("  can produce incoherent combinations.")


def demo_bilattice():
    """Demonstrate the independence of truth and information orderings."""
    print("\n" + "=" * 60)
    print("DEMO 6: Bilattice Structure — Independent Orderings")
    print("=" * 60)

    # Information ordering: N ≤ T, N ≤ F, T ≤ B, F ≤ B
    info_order = {
        (BelnapVal.NEITHER, BelnapVal.VERUM): True,
        (BelnapVal.NEITHER, BelnapVal.FALSUM): True,
        (BelnapVal.NEITHER, BelnapVal.BOTH): True,
        (BelnapVal.VERUM, BelnapVal.BOTH): True,
        (BelnapVal.FALSUM, BelnapVal.BOTH): True,
    }

    # Truth ordering: F ≤ N, F ≤ B, N ≤ T, B ≤ T
    truth_order = {
        (BelnapVal.FALSUM, BelnapVal.NEITHER): True,
        (BelnapVal.FALSUM, BelnapVal.BOTH): True,
        (BelnapVal.FALSUM, BelnapVal.VERUM): True,
        (BelnapVal.NEITHER, BelnapVal.VERUM): True,
        (BelnapVal.BOTH, BelnapVal.VERUM): True,
    }

    print("\nCases where info-order holds but truth-order doesn't:")
    for (a, b), _ in info_order.items():
        if (a, b) not in truth_order:
            print(f"  {a.value} ≤ᵢ {b.value}  but  {a.value} ≰ₜ {b.value}")

    print("\nCases where truth-order holds but info-order doesn't:")
    for (a, b), _ in truth_order.items():
        if (a, b) not in info_order:
            print(f"  {a.value} ≤ₜ {b.value}  but  {a.value} ≰ᵢ {b.value}")

    print("\n→ The orderings are genuinely independent!")


if __name__ == "__main__":
    demo_explosion_failure()
    demo_modus_ponens()
    demo_de_morgan()
    demo_dream_state()
    demo_pretopology()
    demo_bilattice()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Belnap's Bilattice Structure

Shows the two independent orderings (truth and information)
on the four-valued logic as a Hasse diagram.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_bilattice():
    """Draw the bilattice with both orderings overlaid."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Node positions (shared)
    positions = {
        'T': (0, 1),     # verum (top of truth, middle of info)
        'F': (0, -1),    # falsum (bottom of truth, middle of info)
        'B': (1, 0),     # both (top of info, middle of truth)
        'N': (-1, 0),    # neither (bottom of info, middle of truth)
    }

    labels = {'T': 'True (⊤)', 'F': 'False (⊥)', 'B': 'Both (B)', 'N': 'Neither (N)'}
    colors = {'T': '#2ecc71', 'F': '#e74c3c', 'B': '#9b59b6', 'N': '#95a5a6'}

    # Truth ordering edges
    truth_edges = [('F', 'N'), ('F', 'B'), ('N', 'T'), ('B', 'T')]
    # Information ordering edges
    info_edges = [('N', 'T'), ('N', 'F'), ('T', 'B'), ('F', 'B')]

    def draw_nodes(ax):
        for node, (x, y) in positions.items():
            circle = plt.Circle((x, y), 0.2, color=colors[node], ec='black', lw=2, zorder=5)
            ax.add_patch(circle)
            ax.text(x, y, node, ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)

    def draw_edges(ax, edges, color, style='-'):
        for (a, b) in edges:
            x1, y1 = positions[a]
            x2, y2 = positions[b]
            dx, dy = x2 - x1, y2 - y1
            length = np.sqrt(dx**2 + dy**2)
            # Shorten by node radius
            r = 0.22
            ax.annotate('', xy=(x2 - r*dx/length, y2 - r*dy/length),
                        xytext=(x1 + r*dx/length, y1 + r*dy/length),
                        arrowprops=dict(arrowstyle='->', color=color, lw=2, linestyle=style))

    # Panel 1: Truth ordering
    ax = axes[0]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title('Truth Ordering (≤ₜ)', fontsize=14, fontweight='bold')
    draw_edges(ax, truth_edges, '#e67e22')
    draw_nodes(ax)
    ax.text(0, -1.6, 'F ≤ₜ {N,B} ≤ₜ T', ha='center', fontsize=10, style='italic')
    ax.axis('off')

    # Panel 2: Information ordering
    ax = axes[1]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title('Information Ordering (≤ᵢ)', fontsize=14, fontweight='bold')
    draw_edges(ax, info_edges, '#3498db')
    draw_nodes(ax)
    ax.text(0, -1.6, 'N ≤ᵢ {T,F} ≤ᵢ B', ha='center', fontsize=10, style='italic')
    ax.axis('off')

    # Panel 3: Both orderings overlaid
    ax = axes[2]
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title('Bilattice (Both Orderings)', fontsize=14, fontweight='bold')
    draw_edges(ax, truth_edges, '#e67e22', '-')
    draw_edges(ax, [e for e in info_edges if e not in truth_edges], '#3498db', '--')
    draw_nodes(ax)
    truth_patch = mpatches.Patch(color='#e67e22', label='Truth (≤ₜ)')
    info_patch = mpatches.Patch(color='#3498db', label='Information (≤ᵢ)')
    ax.legend(handles=[truth_patch, info_patch], loc='lower center', fontsize=9)
    ax.axis('off')

    plt.suptitle("Belnap's Four-Valued Bilattice", fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('bilattice.png', dpi=150, bbox_inches='tight')
    print("Saved bilattice.png")


def draw_pretopology():
    """Draw the dream pre-topology showing union failure."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Draw the three elements
    positions = {0: (0, 0), 1: (2, 0), 2: (1, 1.5)}

    # Draw open sets as colored regions
    from matplotlib.patches import FancyBboxPatch, Circle, Ellipse

    # Background: full set (open)
    bg = plt.Rectangle((-0.8, -0.8), 3.6, 3.2, fc='#ecf0f1', ec='#2c3e50', lw=2, zorder=0)
    ax.add_patch(bg)
    ax.text(2.5, 2.2, '{0,1,2} ✓ open', fontsize=10, color='#2c3e50')

    # {0} open
    c0 = Circle((0, 0), 0.5, fc='#a8e6cf', ec='#27ae60', lw=2, alpha=0.7, zorder=1)
    ax.add_patch(c0)
    ax.text(-0.7, -0.7, '{0} ✓ open', fontsize=9, color='#27ae60')

    # {1} open
    c1 = Circle((2, 0), 0.5, fc='#a8d8ea', ec='#2980b9', lw=2, alpha=0.7, zorder=1)
    ax.add_patch(c1)
    ax.text(2.3, -0.7, '{1} ✓ open', fontsize=9, color='#2980b9')

    # {0,1} NOT open - shown with dashed red border
    e01 = Ellipse((1, 0), 3.2, 1.4, fc='#ffcccc', ec='#e74c3c', lw=2, ls='--', alpha=0.3, zorder=0.5)
    ax.add_patch(e01)
    ax.text(0.3, -1.2, '{0,1} ✗ NOT open!', fontsize=11, color='#e74c3c', fontweight='bold')

    # Draw points
    for idx, (x, y) in positions.items():
        ax.plot(x, y, 'ko', markersize=12, zorder=3)
        ax.text(x, y + 0.25, str(idx), ha='center', fontsize=14, fontweight='bold', zorder=4)

    ax.set_xlim(-1.2, 3.2)
    ax.set_ylim(-1.6, 2.6)
    ax.set_aspect('equal')
    ax.set_title('Dream Pre-Topology on {0, 1, 2}\n{0}∪{1} = {0,1} breaks the union axiom',
                 fontsize=13, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('pretopology.png', dpi=150, bbox_inches='tight')
    print("Saved pretopology.png")


if __name__ == "__main__":
    draw_bilattice()
    draw_pretopology()
