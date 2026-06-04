#!/usr/bin/env python3
"""
Non-Well-Founded Proof Systems: Demonstrations

Computes circularity gaps, approximation sequences, and self-referential
classifications for concrete proof systems on finite types.
"""

from itertools import product
from typing import Callable, FrozenSet, Set as SetType

# Type aliases
Prop = int  # Propositions as integers
PropSet = frozenset  # Immutable sets of propositions


def identity_derive(s: PropSet) -> PropSet:
    """Identity proof system: derive(S) = S."""
    return s


def constant_derive(axioms: PropSet) -> Callable[[PropSet], PropSet]:
    """Constant proof system: derive(S) = axioms for all S."""
    return lambda s: axioms


def union_axiom_derive(axioms: PropSet) -> Callable[[PropSet], PropSet]:
    """Union-axiom proof system: derive(S) = S ∪ axioms."""
    return lambda s: s | axioms


def compute_lfp(derive: Callable[[PropSet], PropSet], universe: PropSet) -> PropSet:
    """Compute least fixed point by ascending iteration from ∅."""
    current = frozenset()
    while True:
        next_val = derive(current)
        if next_val == current:
            return current
        current = next_val


def compute_gfp(derive: Callable[[PropSet], PropSet], universe: PropSet) -> PropSet:
    """Compute greatest fixed point by descending iteration from universe."""
    current = universe
    while True:
        next_val = derive(current)
        if next_val == current:
            return current
        current = next_val


def compute_circularity_gap(derive, universe):
    """Compute the circularity gap: gfp \\ lfp."""
    lfp = compute_lfp(derive, universe)
    gfp = compute_gfp(derive, universe)
    return gfp - lfp, lfp, gfp


def is_safe(derive, a, universe):
    """Check if proposition a is safe: a ∈ derive(S) → a ∈ S for all S."""
    for size in range(len(universe) + 1):
        for subset in _subsets_of_size(universe, size):
            s = frozenset(subset)
            if a in derive(s) and a not in s:
                return False
    return True


def is_self_referential(derive, a, universe):
    """Check if proposition a is self-referential: safe and a ∈ derive({a})."""
    return is_safe(derive, a, universe) and a in derive(frozenset([a]))


def _subsets_of_size(universe, size):
    """Generate all subsets of given size."""
    from itertools import combinations
    return combinations(sorted(universe), size)


def lfp_approximation(derive, n_steps):
    """Compute ascending approximation sequence."""
    seq = [frozenset()]
    for _ in range(n_steps):
        seq.append(derive(seq[-1]))
    return seq


def gfp_approximation(derive, universe, n_steps):
    """Compute descending approximation sequence."""
    seq = [universe]
    for _ in range(n_steps):
        seq.append(derive(seq[-1]))
    return seq


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_identity_system():
    """Demonstrate the identity proof system."""
    print("=" * 60)
    print("DEMO 1: Identity Proof System (derive(S) = S)")
    print("=" * 60)

    universe = frozenset(range(5))  # {0, 1, 2, 3, 4}
    gap, lfp, gfp = compute_circularity_gap(identity_derive, universe)

    print(f"Universe: {sorted(universe)}")
    print(f"Well-founded closure (lfp): {sorted(lfp)}")
    print(f"Non-well-founded closure (gfp): {sorted(gfp)}")
    print(f"Circularity gap: {sorted(gap)}")
    print(f"Gap size: {len(gap)} / {len(universe)}")

    print("\nSafety classification:")
    for a in sorted(universe):
        safe = is_safe(identity_derive, a, universe)
        selfref = is_self_referential(identity_derive, a, universe)
        print(f"  {a}: safe={safe}, self-referential={selfref}")

    print("\nApproximation sequences (5 steps):")
    lfp_seq = lfp_approximation(identity_derive, 5)
    gfp_seq = gfp_approximation(identity_derive, universe, 5)
    for i in range(6):
        print(f"  Step {i}: lfpApprox={sorted(lfp_seq[i])}, "
              f"gfpApprox={sorted(gfp_seq[i])}")


def demo_constant_system():
    """Demonstrate the constant proof system."""
    print("\n" + "=" * 60)
    print("DEMO 2: Constant Proof System (derive(S) = {0, 1})")
    print("=" * 60)

    universe = frozenset(range(5))
    axioms = frozenset([0, 1])
    derive = constant_derive(axioms)
    gap, lfp, gfp = compute_circularity_gap(derive, universe)

    print(f"Universe: {sorted(universe)}")
    print(f"Axioms: {sorted(axioms)}")
    print(f"Well-founded closure (lfp): {sorted(lfp)}")
    print(f"Non-well-founded closure (gfp): {sorted(gfp)}")
    print(f"Circularity gap: {sorted(gap)}")
    print(f"✓ Gap is empty (as predicted by constant_circGap_empty)")


def demo_union_axiom_system():
    """Demonstrate the union-axiom proof system."""
    print("\n" + "=" * 60)
    print("DEMO 3: Union-Axiom System (derive(S) = S ∪ {0})")
    print("=" * 60)

    universe = frozenset(range(4))
    axioms = frozenset([0])
    derive = union_axiom_derive(axioms)
    gap, lfp, gfp = compute_circularity_gap(derive, universe)

    print(f"Universe: {sorted(universe)}")
    print(f"Axioms: {sorted(axioms)}")
    print(f"Well-founded closure (lfp): {sorted(lfp)}")
    print(f"Non-well-founded closure (gfp): {sorted(gfp)}")
    print(f"Circularity gap: {sorted(gap)}")

    print("\nClassification:")
    for a in sorted(universe):
        safe = is_safe(derive, a, universe)
        selfref = is_self_referential(derive, a, universe)
        in_gap = a in gap
        print(f"  {a}: safe={safe}, self-ref={selfref}, in_gap={in_gap}")

    print("\n✓ Non-axiom elements are safe & self-referential → in gap")
    print("✓ Axiom element 0 is NOT safe → in lfp, not in gap")


def demo_liar_paradox():
    """Demonstrate why the liar paradox is excluded."""
    print("\n" + "=" * 60)
    print("DEMO 4: The Liar Paradox Exclusion")
    print("=" * 60)

    print("Testing: Does there exist P such that P ↔ ¬P?")
    print("  For P = True:  P ↔ ¬P  ⟺  True ↔ False  ⟺  False  ✗")
    print("  For P = False: P ↔ ¬P  ⟺  False ↔ True   ⟺  False  ✗")
    print("  ∴ No fixed point exists for negation.")
    print()
    print("Mathematical reason: negation is anti-monotone.")
    print("  P → Q  implies  ¬Q → ¬P  (direction reverses)")
    print("  This violates the monotonicity requirement for fixed points.")
    print("  The Knaster-Tarski theorem does not apply.")
    print()
    print("In our framework: the liar sentence is not a valid NWFP")
    print("because the derivation operator it would require is not monotone.")


def demo_approximation_convergence():
    """Demonstrate approximation sequence convergence."""
    print("\n" + "=" * 60)
    print("DEMO 5: Approximation Sequence Convergence")
    print("=" * 60)

    # A more interesting system: derive(S) = S ∪ {x+1 | x ∈ S, x+1 < 8} ∪ {0}
    universe = frozenset(range(8))

    def derive(s):
        result = s | frozenset([0])  # axiom: 0
        for x in s:
            if x + 1 < 8:
                result = result | frozenset([x + 1])
        return result

    print("System: derive(S) = S ∪ {x+1 | x ∈ S, x < 8} ∪ {0}")
    print("This models: '0 is an axiom, and if x is proved, so is x+1'")
    print()

    lfp_seq = lfp_approximation(derive, 10)
    gfp_seq = gfp_approximation(derive, universe, 10)

    print("Ascending (lfp) approximation:")
    for i, s in enumerate(lfp_seq[:9]):
        marker = " ← FIXED POINT" if i > 0 and s == lfp_seq[i-1] else ""
        print(f"  Step {i}: {sorted(s)}{marker}")

    print("\nDescending (gfp) approximation:")
    for i, s in enumerate(gfp_seq[:5]):
        marker = " ← FIXED POINT" if i > 0 and s == gfp_seq[i-1] else ""
        print(f"  Step {i}: {sorted(s)}{marker}")

    gap, lfp, gfp = compute_circularity_gap(derive, universe)
    print(f"\nlfp = {sorted(lfp)}")
    print(f"gfp = {sorted(gfp)}")
    print(f"gap = {sorted(gap)}")
    print(f"✓ lfp = gfp (no circularity gap for this 'complete' induction system)")


def demo_self_consistent_theories():
    """Demonstrate post-fixed point structure."""
    print("\n" + "=" * 60)
    print("DEMO 6: Self-Consistent Theories (Post-Fixed Points)")
    print("=" * 60)

    universe = frozenset(range(4))

    # System where pairs support each other
    def derive(s):
        result = set()
        if 0 in s and 1 in s:
            result.update([0, 1])
        if 2 in s and 3 in s:
            result.update([2, 3])
        if 0 in s:
            result.add(0)
        if 2 in s:
            result.add(2)
        return frozenset(result)

    print("System: derive supports pairs (0,1) and (2,3)")
    print("  - 0 ∈ derive(S) if 0 ∈ S")
    print("  - 1 ∈ derive(S) if {0,1} ⊆ S")
    print("  - 2 ∈ derive(S) if 2 ∈ S")
    print("  - 3 ∈ derive(S) if {2,3} ⊆ S")

    # Find all post-fixed points
    from itertools import chain, combinations
    def powerset(s):
        s = list(s)
        return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))

    print("\nPost-fixed points (self-consistent theories):")
    post_fixed = []
    for subset in powerset(universe):
        s = frozenset(subset)
        if s <= derive(s):
            post_fixed.append(s)
            print(f"  {sorted(s)}")

    print(f"\nTotal: {len(post_fixed)} post-fixed points")

    # Verify union closure
    print("\nVerifying union closure (Theorem 7):")
    for i, s1 in enumerate(post_fixed):
        for s2 in post_fixed[i+1:]:
            union = s1 | s2
            is_pf = union <= derive(union)
            if not is_pf:
                print(f"  COUNTEREXAMPLE: {sorted(s1)} ∪ {sorted(s2)} = {sorted(union)}")
            else:
                if s1 and s2 and s1 != s2:
                    print(f"  ✓ {sorted(s1)} ∪ {sorted(s2)} = {sorted(union)} is post-fixed")

    gap, lfp, gfp = compute_circularity_gap(derive, universe)
    print(f"\nlfp = {sorted(lfp)}")
    print(f"gfp = {sorted(gfp)}")
    print(f"gap = {sorted(gap)}")


if __name__ == "__main__":
    demo_identity_system()
    demo_constant_system()
    demo_union_axiom_system()
    demo_liar_paradox()
    demo_approximation_convergence()
    demo_self_consistent_theories()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Circularity Gap Structure

Plots the circularity gap for various proof systems, showing
the relationship between lfp (well-founded) and gfp (non-well-founded).
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def identity_derive(s):
    return s


def union_axiom_derive(axioms):
    return lambda s: s | axioms


def compute_lfp(derive, universe):
    current = frozenset()
    for _ in range(100):
        nxt = derive(current)
        if nxt == current:
            return current
        current = nxt
    return current


def compute_gfp(derive, universe):
    current = universe
    for _ in range(100):
        nxt = derive(current)
        if nxt == current:
            return current
        current = nxt
    return current


def plot_gap_comparison():
    """Compare circularity gaps across different proof systems."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    n = 8
    universe = frozenset(range(n))
    systems = [
        ("Identity\nderive(S) = S", lambda s: s),
        ("Union-Axiom\nderive(S) = S ∪ {0,1}", union_axiom_derive(frozenset([0, 1]))),
        ("Constant\nderive(S) = {0,1,2}", lambda s: frozenset([0, 1, 2])),
    ]

    for ax, (name, derive) in zip(axes, systems):
        lfp = compute_lfp(derive, universe)
        gfp = compute_gfp(derive, universe)
        gap = gfp - lfp

        colors = []
        for i in range(n):
            if i in lfp:
                colors.append('#2ecc71')  # green = well-founded
            elif i in gap:
                colors.append('#e74c3c')  # red = circularity gap
            else:
                colors.append('#95a5a6')  # grey = not derivable

        bars = ax.bar(range(n), [1]*n, color=colors, edgecolor='white', linewidth=2)
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xlabel('Proposition')
        ax.set_ylabel('')
        ax.set_ylim(0, 1.3)
        ax.set_xticks(range(n))
        ax.set_yticks([])

        # Annotate sizes
        ax.text(n/2, 1.15, f'lfp={len(lfp)}  gap={len(gap)}  outside={n-len(gfp)}',
                ha='center', fontsize=10, style='italic')

    # Legend
    legend_patches = [
        mpatches.Patch(color='#2ecc71', label='Well-founded (lfp)'),
        mpatches.Patch(color='#e74c3c', label='Circularity gap'),
        mpatches.Patch(color='#95a5a6', label='Not derivable'),
    ]
    fig.legend(handles=legend_patches, loc='lower center', ncol=3,
               fontsize=11, bbox_to_anchor=(0.5, -0.02))

    plt.suptitle('Circularity Gap Structure Across Proof Systems',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('circularity_gap_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: circularity_gap_comparison.png")


def plot_approximation_sequences():
    """Plot the ascending and descending approximation sequences."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    n = 6
    universe = frozenset(range(n))

    # Use a system with interesting convergence
    def derive(s):
        result = set(s)
        result.add(0)  # axiom
        for x in s:
            if x + 1 < n:
                result.add(x + 1)
        return frozenset(result)

    # Ascending sequence
    steps = 8
    lfp_seq = [frozenset()]
    for _ in range(steps):
        lfp_seq.append(derive(lfp_seq[-1]))

    # Plot as heatmap
    matrix_asc = np.zeros((steps + 1, n))
    for i, s in enumerate(lfp_seq):
        for j in range(n):
            if j in s:
                matrix_asc[i, j] = 1

    ax1.imshow(matrix_asc, cmap='Greens', aspect='auto', interpolation='nearest')
    ax1.set_xlabel('Proposition')
    ax1.set_ylabel('Iteration step')
    ax1.set_title('Ascending (lfp) Approximation', fontweight='bold')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(steps + 1))

    # Descending sequence
    gfp_seq = [universe]
    for _ in range(steps):
        gfp_seq.append(derive(gfp_seq[-1]))

    matrix_desc = np.zeros((steps + 1, n))
    for i, s in enumerate(gfp_seq):
        for j in range(n):
            if j in s:
                matrix_desc[i, j] = 1

    ax2.imshow(matrix_desc, cmap='Reds', aspect='auto', interpolation='nearest')
    ax2.set_xlabel('Proposition')
    ax2.set_ylabel('Iteration step')
    ax2.set_title('Descending (gfp) Approximation', fontweight='bold')
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(steps + 1))

    plt.suptitle('Approximation Sequences Converge to Fixed Points',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('approximation_sequences.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: approximation_sequences.png")


def plot_post_fixed_lattice():
    """Visualize the lattice of post-fixed points (self-consistent theories)."""
    fig, ax = plt.subplots(figsize=(10, 8))

    n = 4
    universe = frozenset(range(n))

    # Pair-support system
    def derive(s):
        result = set()
        if 0 in s:
            result.add(0)
        if {0, 1} <= s:
            result.update([0, 1])
        if 2 in s:
            result.add(2)
        if {2, 3} <= s:
            result.update([2, 3])
        return frozenset(result)

    # Find all post-fixed points
    from itertools import chain, combinations
    def powerset(s):
        s = list(s)
        return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))

    post_fixed = []
    all_sets = []
    for subset in powerset(universe):
        s = frozenset(subset)
        all_sets.append(s)
        if s <= derive(s):
            post_fixed.append(s)

    # Position by cardinality
    by_size = {}
    for s in post_fixed:
        sz = len(s)
        if sz not in by_size:
            by_size[sz] = []
        by_size[sz].append(s)

    positions = {}
    for sz, sets in by_size.items():
        for i, s in enumerate(sets):
            x = (i - (len(sets) - 1) / 2) * 2
            y = sz * 2
            positions[s] = (x, y)

    # Draw edges (subset relations between adjacent levels)
    for s1 in post_fixed:
        for s2 in post_fixed:
            if s1 < s2 and len(s2) == len(s1) + 1:
                x1, y1 = positions[s1]
                x2, y2 = positions[s2]
                ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    for s in post_fixed:
        x, y = positions[s]
        label = '{' + ','.join(str(e) for e in sorted(s)) + '}' if s else '∅'
        ax.scatter(x, y, s=800, c='#3498db', zorder=5, edgecolors='white', linewidth=2)
        ax.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold',
                color='white')

    ax.set_title('Lattice of Post-Fixed Points\n(Self-Consistent Theories)',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('', fontsize=1)
    ax.set_ylabel('Cardinality', fontsize=11)
    ax.set_yticks([sz * 2 for sz in sorted(by_size.keys())])
    ax.set_yticklabels([str(sz) for sz in sorted(by_size.keys())])
    ax.grid(False)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    plt.tight_layout()
    plt.savefig('post_fixed_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: post_fixed_lattice.png")


if __name__ == "__main__":
    plot_gap_comparison()
    plot_approximation_sequences()
    plot_post_fixed_lattice()
    print("\nAll visualizations generated.")
