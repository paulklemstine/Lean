#!/usr/bin/env python3
"""
Demo: Paraconsistent Logic — Paradoxes as Theorems

Demonstrates Belnap's four-valued logic (FDE) and how the Liar sentence,
Russell's paradox, and Berry's paradox become provable theorems rather than
contradictions.
"""

from enum import Enum
from typing import Callable


class BelnapVal(Enum):
    """Belnap's four truth values."""
    T = "True"
    F = "False"
    B = "Both"
    N = "Neither"

    def is_true(self) -> bool:
        return self in (BelnapVal.T, BelnapVal.B)

    def is_false(self) -> bool:
        return self in (BelnapVal.F, BelnapVal.B)

    def neg(self) -> 'BelnapVal':
        return {
            BelnapVal.T: BelnapVal.F,
            BelnapVal.F: BelnapVal.T,
            BelnapVal.B: BelnapVal.B,
            BelnapVal.N: BelnapVal.N,
        }[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        if self == BelnapVal.T: return other
        if other == BelnapVal.T: return self
        if self == BelnapVal.F or other == BelnapVal.F: return BelnapVal.F
        if self == BelnapVal.B and other == BelnapVal.B: return BelnapVal.B
        if (self == BelnapVal.B and other == BelnapVal.N) or \
           (self == BelnapVal.N and other == BelnapVal.B): return BelnapVal.F
        return BelnapVal.N  # N, N

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        if self == BelnapVal.F: return other
        if other == BelnapVal.F: return self
        if self == BelnapVal.T or other == BelnapVal.T: return BelnapVal.T
        if self == BelnapVal.B and other == BelnapVal.B: return BelnapVal.B
        if (self == BelnapVal.B and other == BelnapVal.N) or \
           (self == BelnapVal.N and other == BelnapVal.B): return BelnapVal.T
        return BelnapVal.N


def demo_liar_paradox():
    """Demonstrate the Liar sentence in Belnap logic."""
    print("=" * 60)
    print("LIAR PARADOX: 'This sentence is false'")
    print("=" * 60)
    print()

    for v in BelnapVal:
        neg_v = v.neg()
        is_fixed = (v == neg_v)
        print(f"  If Liar = {v.value:8s}: neg(Liar) = {neg_v.value:8s} "
              f"{'✓ FIXED POINT' if is_fixed else '✗ not a fixed point'}")

    print()
    print("  Result: Only B (Both) and N (Neither) are fixed points of negation.")
    print("  The Liar sentence with positive truth info must be B (a dialetheia).")
    print()


def demo_russell_paradox():
    """Demonstrate Russell's paradox in Belnap logic."""
    print("=" * 60)
    print("RUSSELL'S PARADOX: R = {x | x ∉ x}")
    print("=" * 60)
    print()

    for v in BelnapVal:
        neg_v = v.neg()
        is_fixed = (v == neg_v)
        print(f"  If R ∈ R = {v.value:8s}: R ∉ R = neg({v.value}) = {neg_v.value:8s} "
              f"{'✓ CONSISTENT' if is_fixed else '✗ inconsistent'}")

    print()
    print("  Result: R ∈ R must be B or N. With positive info, R ∈ R = B.")
    print("  Russell's set both contains and doesn't contain itself.")
    print()


def demo_berry_paradox():
    """Demonstrate Berry's paradox via pigeonhole."""
    print("=" * 60)
    print("BERRY'S PARADOX: More objects than descriptions")
    print("=" * 60)
    print()

    n_descriptions = 10
    n_objects = 15

    print(f"  Descriptions available: {n_descriptions}")
    print(f"  Objects to describe:    {n_objects}")
    print(f"  Pigeonhole: {n_objects} > {n_descriptions}")
    print(f"  → At least {n_objects - n_descriptions} collisions must occur")
    print(f"  → Some description applies to multiple objects")
    print()

    # Concrete example
    import random
    random.seed(42)
    assignment = {i: random.randint(0, n_descriptions - 1) for i in range(n_objects)}
    collisions = {}
    for obj, desc in assignment.items():
        collisions.setdefault(desc, []).append(obj)

    print("  Example assignment (object → description):")
    for obj, desc in sorted(assignment.items()):
        print(f"    Object {obj:2d} → Description {desc}")

    print()
    print("  Collisions found:")
    for desc, objs in sorted(collisions.items()):
        if len(objs) > 1:
            print(f"    Description {desc}: objects {objs}")
    print()


def demo_explosion_failure():
    """Show that explosion fails in FDE."""
    print("=" * 60)
    print("EXPLOSION FAILURE IN FDE")
    print("=" * 60)
    print()

    print("  Classical logic: (p ∧ ¬p) → q  [ex falso quodlibet]")
    print("  FDE: Let p = Both, q = False")
    print()

    p = BelnapVal.B
    q = BelnapVal.F
    contradiction = p.conj(p.neg())
    print(f"  p = {p.value}")
    print(f"  ¬p = {p.neg().value}")
    print(f"  p ∧ ¬p = {contradiction.value}")
    print(f"  isTrue(p ∧ ¬p) = {contradiction.is_true()}")
    print(f"  q = {q.value}")
    print(f"  isTrue(q) = {q.is_true()}")
    print()
    print(f"  Result: p ∧ ¬p is true (Both), but q is false.")
    print(f"  Explosion FAILS: a contradiction does not make everything true.")
    print()


def demo_inconsistency_spectrum():
    """Show the inconsistency spectrum for a theory with paradoxes."""
    print("=" * 60)
    print("INCONSISTENCY SPECTRUM")
    print("=" * 60)
    print()

    # A theory on 8 sentences
    n = 8
    truth_values = [
        BelnapVal.T,  # 0: "1 + 1 = 2"
        BelnapVal.T,  # 1: "The sky is blue"
        BelnapVal.F,  # 2: "2 + 2 = 5"
        BelnapVal.F,  # 3: "The Earth is flat"
        BelnapVal.B,  # 4: "This sentence is false" (Liar)
        BelnapVal.B,  # 5: "R ∈ R" (Russell's set)
        BelnapVal.N,  # 6: "The continuum hypothesis" (undecidable)
        BelnapVal.T,  # 7: "∀x. x = x"
    ]

    names = [
        "1 + 1 = 2",
        "The sky is blue",
        "2 + 2 = 5",
        "The Earth is flat",
        "This sentence is false",
        "R ∈ R",
        "Continuum hypothesis",
        "∀x. x = x",
    ]

    print(f"  Theory with {n} sentences:")
    for i, (name, val) in enumerate(zip(names, truth_values)):
        print(f"    [{i}] {name:30s} → {val.value}")

    spectrum = {v: 0 for v in BelnapVal}
    for v in truth_values:
        spectrum[v] += 1

    print()
    print(f"  Spectrum: T={spectrum[BelnapVal.T]}, F={spectrum[BelnapVal.F]}, "
          f"B={spectrum[BelnapVal.B]}, N={spectrum[BelnapVal.N]}")
    print(f"  Total: {sum(spectrum.values())} = {n}")
    print(f"  Inconsistency degree (B count): {spectrum[BelnapVal.B]}")
    print(f"  Tolerance threshold: B ≤ n - 2 = {n - 2}: "
          f"{'✓' if spectrum[BelnapVal.B] <= n - 2 else '✗'}")
    print()


def demo_self_soundness():
    """Demonstrate self-soundness of a paraconsistent theory."""
    print("=" * 60)
    print("SELF-SOUNDNESS")
    print("=" * 60)
    print()

    provable = {
        "1 + 1 = 2": BelnapVal.T,
        "∀x. x = x": BelnapVal.T,
        "This sentence is false": BelnapVal.B,  # Liar
        "This theory is sound": BelnapVal.T,     # Soundness sentence
    }

    print("  Provable sentences and their truth values:")
    all_sound = True
    for name, val in provable.items():
        is_sound = val.is_true()
        all_sound = all_sound and is_sound
        print(f"    {name:30s} → {val.value:8s} isTrue={is_sound} "
              f"{'✓ sound' if is_sound else '✗ unsound'}")

    print()
    print(f"  Theory is sound: {all_sound}")
    print()
    print("  Key insight: The Liar sentence has value Both, which IS at-least-true.")
    print("  So the theory proves its own soundness despite containing a paradox!")
    print("  This is impossible in classical logic (Gödel's 2nd incompleteness theorem).")
    print()


def demo_truth_table():
    """Print the full truth tables for FDE connectives."""
    print("=" * 60)
    print("FDE TRUTH TABLES")
    print("=" * 60)
    print()

    vals = list(BelnapVal)

    print("  NEGATION:")
    print(f"  {'v':>8s} | {'¬v':>8s}")
    print(f"  {'-'*8}-+-{'-'*8}")
    for v in vals:
        print(f"  {v.value:>8s} | {v.neg().value:>8s}")

    print()
    print("  CONJUNCTION (∧):")
    header = "  " + " " * 10 + "".join(f"{v.value:>8s}" for v in vals)
    print(header)
    print("  " + "-" * (10 + 8 * len(vals)))
    for a in vals:
        row = f"  {a.value:>8s} |"
        for b in vals:
            row += f"{a.conj(b).value:>8s}"
        print(row)

    print()
    print("  DISJUNCTION (∨):")
    print(header)
    print("  " + "-" * (10 + 8 * len(vals)))
    for a in vals:
        row = f"  {a.value:>8s} |"
        for b in vals:
            row += f"{a.disj(b).value:>8s}"
        print(row)
    print()


if __name__ == "__main__":
    demo_truth_table()
    demo_liar_paradox()
    demo_russell_paradox()
    demo_berry_paradox()
    demo_explosion_failure()
    demo_inconsistency_spectrum()
    demo_self_soundness()


#!/usr/bin/env python3
"""
Visualization: Inconsistency Spectrum of Paraconsistent Theories

Shows how the distribution of truth values (T, F, B, N) varies across
theories with different levels of inconsistency tolerance.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_max_both(n: int, has_t: bool, has_f: bool) -> int:
    """Maximum number of Both-valued sentences in a theory of size n."""
    if has_t and has_f:
        return max(0, n - 2)
    elif has_t or has_f:
        return max(0, n - 1)
    else:
        return n


def plot_tolerance_threshold():
    """Plot the tolerance threshold: max B-count vs theory size."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Tolerance threshold
    ax = axes[0]
    ns = np.arange(2, 21)
    max_b_nontrivial = np.array([max(0, n - 2) for n in ns])
    max_b_trivial = ns.copy()

    ax.fill_between(ns, 0, max_b_nontrivial, alpha=0.3, color='green',
                     label='Allowed B-count (non-trivial)')
    ax.fill_between(ns, max_b_nontrivial, ns, alpha=0.2, color='red',
                     label='Forbidden zone')
    ax.plot(ns, max_b_nontrivial, 'g-', linewidth=2, label='Threshold: n − 2')
    ax.plot(ns, ns, 'k--', linewidth=1, alpha=0.5, label='n (trivial bound)')

    ax.set_xlabel('Number of sentences (n)', fontsize=12)
    ax.set_ylabel('Maximum Both-valued sentences', fontsize=12)
    ax.set_title('Inconsistency Tolerance Threshold', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: Example spectra
    ax = axes[1]
    theories = [
        ("Classical\n(all T/F)", [3, 5, 0, 0]),
        ("Minimal\nparadox", [3, 4, 1, 0]),
        ("Balanced\nparadox", [2, 2, 2, 2]),
        ("Heavy\nparadox", [1, 1, 5, 1]),
        ("Gap-heavy", [2, 2, 1, 3]),
    ]

    x = np.arange(len(theories))
    width = 0.2
    colors = ['#2196F3', '#F44336', '#FF9800', '#9E9E9E']
    labels = ['True (T)', 'False (F)', 'Both (B)', 'Neither (N)']

    for i, (color, label) in enumerate(zip(colors, labels)):
        values = [t[1][i] for t in theories]
        ax.bar(x + i * width, values, width, color=color, label=label, edgecolor='white')

    ax.set_xticks(x + 1.5 * width)
    ax.set_xticklabels([t[0] for t in theories], fontsize=9)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Example Inconsistency Spectra (n=8)', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('inconsistency_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: inconsistency_spectrum.png")


def plot_belnap_lattice():
    """Plot the Belnap information and truth ordering lattices."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Information ordering
    ax = axes[0]
    positions = {'N': (0, 0), 'T': (-1, 1), 'F': (1, 1), 'B': (0, 2)}
    edges = [('N', 'T'), ('N', 'F'), ('T', 'B'), ('F', 'B')]

    for (a, b) in edges:
        ax.annotate("", xy=positions[b], xytext=positions[a],
                     arrowprops=dict(arrowstyle='->', color='#333', lw=1.5))

    colors_map = {'T': '#2196F3', 'F': '#F44336', 'B': '#FF9800', 'N': '#9E9E9E'}
    for name, (x, y) in positions.items():
        ax.plot(x, y, 'o', markersize=25, color=colors_map[name], zorder=5)
        ax.text(x, y, name, ha='center', va='center', fontsize=14,
                fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.5, 2.5)
    ax.set_title('Information Ordering\n(N = least info, B = most)', fontsize=13)
    ax.set_aspect('equal')
    ax.axis('off')

    # Truth ordering
    ax = axes[1]
    positions2 = {'F': (0, 0), 'N': (-1, 1), 'B': (1, 1), 'T': (0, 2)}
    edges2 = [('F', 'N'), ('F', 'B'), ('N', 'T'), ('B', 'T')]

    for (a, b) in edges2:
        ax.annotate("", xy=positions2[b], xytext=positions2[a],
                     arrowprops=dict(arrowstyle='->', color='#333', lw=1.5))

    for name, (x, y) in positions2.items():
        ax.plot(x, y, 'o', markersize=25, color=colors_map[name], zorder=5)
        ax.text(x, y, name, ha='center', va='center', fontsize=14,
                fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.5, 2.5)
    ax.set_title('Truth Ordering\n(F = least true, T = most)', fontsize=13)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('belnap_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: belnap_lattice.png")


if __name__ == "__main__":
    plot_tolerance_threshold()
    plot_belnap_lattice()
