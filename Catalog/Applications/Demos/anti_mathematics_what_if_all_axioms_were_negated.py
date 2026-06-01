"""
Anti-Axiom Mathematics: Interactive Demo

Demonstrates the key results from the anti-axiom theory:
1. Extensional defect computation in tagged universes
2. Cyclic membership and anti-foundation
3. Cantor barrier for finite universes
4. Anti-axiom profile enumeration and tension detection
"""

import numpy as np
from algorithms import (
    compute_all_defects,
    extensional_collapse,
    is_anti_extensional,
    build_cyclic_membership,
    detect_membership_cycle,
    is_well_founded,
    cantor_barrier,
    tower_exp,
    build_tagged_universe,
    AntiAxiomProfile,
    finite_choice_function,
)


def demo_anti_extensionality():
    """Demonstrate anti-extensionality in tagged universes."""
    print("=" * 60)
    print("DEMO 1: Anti-Extensionality in Tagged Universes")
    print("=" * 60)

    for m, n in [(3, 2), (2, 3), (4, 4)]:
        print(f"\n--- Tagged Universe Fin({m}) × Fin({n}) ---")
        M = build_tagged_universe(m, n)
        size = m * n

        # Check anti-extensionality
        is_ae = is_anti_extensional(M)
        print(f"  Universe size: {size}")
        print(f"  Anti-extensional: {is_ae}")

        # Compute defects
        defects = compute_all_defects(M)
        print(f"  Extensional defects: {defects}")
        print(f"  Expected defect (n-1 = {n-1}): {'✓ VERIFIED' if all(d == n-1 for d in defects) else '✗ FAILED'}")

        # Compute collapse
        groups = extensional_collapse(M)
        print(f"  Equivalence classes: {len(groups)}")
        print(f"  Expected classes (m = {m}): {'✓ VERIFIED' if len(groups) == m else '✗ FAILED'}")
        for key, members in groups.items():
            print(f"    Class with {len(members)} members: elements {members}")


def demo_anti_foundation():
    """Demonstrate anti-foundation with cyclic membership."""
    print("\n" + "=" * 60)
    print("DEMO 2: Anti-Foundation — Cyclic Membership")
    print("=" * 60)

    for n in [3, 5, 7]:
        print(f"\n--- Cyclic Membership on Fin({n}) ---")
        M = build_cyclic_membership(n)

        # Detect cycle
        cycle = detect_membership_cycle(M)
        wf = is_well_founded(M)
        print(f"  Well-founded: {wf}")
        print(f"  Cycle found: {cycle}")
        print(f"  Cycle length: {len(cycle) if cycle else 0}")
        print(f"  Expected: not well-founded, cycle of length {n}")
        print(f"  {'✓ VERIFIED' if not wf and cycle and len(cycle) == n else '✗ FAILED'}")

        # Show the membership structure
        edges = [(a, (a + 1) % n) for a in range(n)]
        print(f"  Membership edges: {edges}")


def demo_cantor_barrier():
    """Demonstrate the Cantor barrier for finite universes."""
    print("\n" + "=" * 60)
    print("DEMO 3: The Cantor Barrier")
    print("=" * 60)

    print("\n  n  | |P(Fin n)| = 2^n |  Fin n  | Barrier (2^n > n)")
    print("  " + "-" * 55)
    for n in range(8):
        ps, base, holds = cantor_barrier(n)
        print(f"  {n}  |     {ps:>6}        |    {base}    |   {'✓' if holds else '✗'}")

    print("\n--- Tower of Exponentials ---")
    print("  The iterated power set grows as a tower of 2s:")
    for k in range(5):
        val = tower_exp(2, k)
        if val < 10**15:
            print(f"  tower(2, {k}) = {val}")
        else:
            print(f"  tower(2, {k}) = 2^{tower_exp(2, k-1)} (too large to display)")


def demo_anti_choice():
    """Demonstrate finite choice automaticity."""
    print("\n" + "=" * 60)
    print("DEMO 4: Finite Choice is Automatic")
    print("=" * 60)

    families = [
        {"A": {1, 2, 3}, "B": {4, 5}, "C": {6}},
        {"X": {10, 20}, "Y": {30, 40, 50}, "Z": {60, 70, 80, 90}},
        {f"S_{i}": {i * 10 + j for j in range(1, i + 2)} for i in range(5)},
    ]

    for i, family in enumerate(families):
        print(f"\n--- Family {i+1} ---")
        print(f"  Sets: {family}")
        choice = finite_choice_function(family)
        print(f"  Choice function: {choice}")
        if choice:
            valid = all(choice[k] in v for k, v in family.items())
            print(f"  Valid choice: {'✓ VERIFIED' if valid else '✗ FAILED'}")


def demo_anti_axiom_profiles():
    """Enumerate and analyze anti-axiom profiles."""
    print("\n" + "=" * 60)
    print("DEMO 5: Anti-Axiom Profile Space")
    print("=" * 60)

    profiles = AntiAxiomProfile.enumerate_all()
    print(f"\n  Total profiles: {len(profiles)} (expected 32)")

    tensioned = [p for p in profiles if p.has_tension()]
    eliminable = [p for p in profiles if p.is_eliminable()]

    print(f"  Profiles with anti-choice/anti-infinity tension: {len(tensioned)}")
    print(f"  Profiles with eliminable anti-extensionality: {len(eliminable)}")

    print("\n  Profiles with tension (¬Choice ∧ ¬Infinity):")
    for p in tensioned:
        print(f"    {p}")

    print("\n  ZFC (no negations):")
    zfc = [p for p in profiles if not any([
        p.neg_extensionality, p.neg_infinity, p.neg_choice,
        p.neg_foundation, p.neg_power_set
    ])]
    for p in zfc:
        print(f"    {p}")

    # Count profiles by number of negated axioms
    print("\n  Distribution by number of negated axioms:")
    from collections import Counter
    counts = Counter()
    for p in profiles:
        k = sum([
            p.neg_extensionality, p.neg_infinity, p.neg_choice,
            p.neg_foundation, p.neg_power_set
        ])
        counts[k] += 1
    for k in sorted(counts):
        print(f"    {k} negated: {counts[k]} profiles (C(5,{k}) = {counts[k]})")


if __name__ == "__main__":
    demo_anti_extensionality()
    demo_anti_foundation()
    demo_cantor_barrier()
    demo_anti_choice()
    demo_anti_axiom_profiles()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Anti-Axiom Universe Explorer

Creates visualizations of:
1. Extensional defect heatmap for tagged universes
2. Cyclic membership graph
3. Cantor barrier growth chart
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def build_tagged_universe(m: int, n: int) -> np.ndarray:
    size = m * n
    M = np.zeros((size, size), dtype=bool)
    for x in range(size):
        for y in range(size):
            x1 = x // n
            y1 = y // n
            M[x][y] = (x1 == y1)
    return M


def compute_extensional_defect(M: np.ndarray, element: int) -> int:
    n = M.shape[0]
    col_a = M[:, element]
    defect = 0
    for b in range(n):
        if b != element and np.array_equal(M[:, b], col_a):
            defect += 1
    return defect


def plot_extensional_defect_heatmap():
    """Plot extensional defect heatmap for various tagged universes."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    configs = [(4, 3), (3, 5), (6, 2)]

    for ax, (m, n) in zip(axes, configs):
        M = build_tagged_universe(m, n)
        size = m * n
        defects = [compute_extensional_defect(M, i) for i in range(size)]

        # Reshape defects into m x n grid
        defect_grid = np.array(defects).reshape(m, n)

        im = ax.imshow(defect_grid, cmap='YlOrRd', aspect='auto')
        ax.set_title(f'Fin({m}) × Fin({n})\nDefect = {n-1}', fontsize=12)
        ax.set_xlabel('Tag index')
        ax.set_ylabel('Content index')
        plt.colorbar(im, ax=ax, label='Extensional Defect')

        # Annotate cells
        for i in range(m):
            for j in range(n):
                ax.text(j, i, str(defect_grid[i, j]),
                       ha='center', va='center', fontsize=10, fontweight='bold')

    plt.suptitle('Extensional Defect in Tagged Universes', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_extensional_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_extensional_defect.png")


def plot_cyclic_membership():
    """Plot cyclic membership graphs for various sizes."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for ax, n in zip(axes, [4, 6, 8]):
        angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
        x = np.cos(angles)
        y = np.sin(angles)

        # Draw edges (membership arrows)
        for i in range(n):
            j = (i + 1) % n
            dx = x[j] - x[i]
            dy = y[j] - y[i]
            ax.annotate('', xy=(x[j], y[j]), xytext=(x[i], y[i]),
                       arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                      lw=2, connectionstyle='arc3,rad=0.1'))

        # Draw nodes
        ax.scatter(x, y, s=400, c='#3498db', zorder=5, edgecolors='white', linewidth=2)
        for i in range(n):
            ax.text(x[i], y[i], str(i), ha='center', va='center',
                   fontsize=12, fontweight='bold', color='white')

        ax.set_title(f'Cyclic Membership on Fin({n})\n¬Well-Founded', fontsize=12)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.axis('off')

    plt.suptitle('Anti-Foundation: Membership Cycles', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_cyclic_membership.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_cyclic_membership.png")


def plot_cantor_barrier():
    """Plot the Cantor barrier: 2^n vs n."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: 2^n vs n
    ns = np.arange(0, 10)
    powerset = 2 ** ns

    ax1.bar(ns - 0.2, powerset, width=0.4, label='|P(Fin n)| = 2^n',
            color='#e74c3c', alpha=0.8)
    ax1.bar(ns + 0.2, ns, width=0.4, label='|Fin n| = n',
            color='#3498db', alpha=0.8)
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Cardinality', fontsize=12)
    ax1.set_title('Cantor Barrier: Power Set vs Base', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.set_ylim(0.5, 1500)

    # Right: Tower of exponentials
    def tower_exp(b, k):
        if k == 0:
            return 1
        return b ** tower_exp(b, k - 1)

    ks = list(range(5))
    towers = [tower_exp(2, k) for k in ks]

    ax2.plot(ks, towers, 'o-', color='#e74c3c', linewidth=2, markersize=10)
    for k, t in zip(ks, towers):
        ax2.annotate(f'{t}', (k, t), textcoords='offset points',
                    xytext=(10, 5), fontsize=11)

    ax2.set_xlabel('Height k', fontsize=12)
    ax2.set_ylabel('tower(2, k)', fontsize=12)
    ax2.set_title('Tower of Exponentials: 2↑↑k', fontsize=13)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Anti-Infinity: The Cantor Barrier', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_cantor_barrier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_cantor_barrier.png")


if __name__ == "__main__":
    plot_extensional_defect_heatmap()
    plot_cyclic_membership()
    plot_cantor_barrier()
    print("\nAll visualizations generated!")
