#!/usr/bin/env python3
"""
Zombies and Qualia: Numerical Demonstrations

Demonstrates the key mathematical results about the gap between
functional descriptions and subjective experience.
"""

import itertools
from typing import Callable


def demo_zombie_system():
    """Demonstrate a concrete zombie system and verify theorems."""
    print("=" * 60)
    print("DEMO 1: Concrete Zombie System")
    print("=" * 60)

    # States: 6 elements representing brain states
    states = list(range(6))

    # Functional equivalence: states 0,1 are equivalent; 2,3; 4,5
    equiv_classes = {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2}

    def func_equiv(x, y):
        return equiv_classes[x] == equiv_classes[y]

    # Qualia: even states are conscious, odd are zombies
    def qualia(x):
        return x % 2 == 0

    print(f"\nStates: {states}")
    print(f"Equivalence classes: {set(equiv_classes.values())}")
    print(f"Qualia (conscious): {[s for s in states if qualia(s)]}")
    print(f"Zombies: {[s for s in states if not qualia(s)]}")

    # Verify zombie hypothesis
    print("\n--- Zombie Twin Verification ---")
    for x in states:
        if qualia(x):
            twins = [y for y in states if func_equiv(x, y) and not qualia(y)]
            print(f"  State {x} (conscious) → zombie twins: {twins}")
            assert len(twins) > 0, f"No zombie twin for state {x}!"

    # Verify functional opacity
    print("\n--- Functional Opacity Verification ---")
    # Check: qualia does NOT respect func_equiv
    found_violation = False
    for x in states:
        for y in states:
            if func_equiv(x, y) and qualia(x) != qualia(y):
                print(f"  Violation: states {x},{y} are functionally equivalent")
                print(f"    but qualia({x})={qualia(x)}, qualia({y})={qualia(y)}")
                found_violation = True
                break
        if found_violation:
            break
    assert found_violation, "Expected opacity violation!"
    print("  ✓ Qualia do NOT respect functional equivalence")

    # Verify no functional detection
    print("\n--- No Functional Detection ---")
    # Enumerate all predicates that respect func_equiv
    n_classes = len(set(equiv_classes.values()))
    respecting_preds = []
    for bits in itertools.product([False, True], repeat=n_classes):
        pred = lambda x, b=bits: b[equiv_classes[x]]
        respecting_preds.append(pred)

    print(f"  Total predicates: {2**len(states)} = {2**len(states)}")
    print(f"  Respecting predicates: {len(respecting_preds)} = 2^{n_classes}")
    print(f"  Non-respecting (qualia-like): {2**len(states) - len(respecting_preds)}")

    for i, pred in enumerate(respecting_preds):
        matches = all(pred(x) == qualia(x) for x in states)
        if matches:
            print(f"  ✗ Found matching predicate #{i}!")
            break
    else:
        print("  ✓ No respecting predicate matches qualia")


def demo_explanatory_gap():
    """Demonstrate the explanatory gap measure."""
    print("\n" + "=" * 60)
    print("DEMO 2: Explanatory Gap Measurement")
    print("=" * 60)

    for n in [4, 6, 8, 10, 12]:
        # k equivalence classes of equal size
        for k in [1, 2, n // 2, n]:
            total_preds = 2 ** n
            respecting_preds = 2 ** k
            gap = 1.0 - respecting_preds / total_preds
            print(f"  n={n:2d}, k={k:2d}: "
                  f"total={total_preds:6d}, respecting={respecting_preds:4d}, "
                  f"gap={gap:.6f}")
        print()


def demo_reflective_qualia_gap():
    """Demonstrate why reflective systems can't represent all properties."""
    print("=" * 60)
    print("DEMO 3: Reflective Qualia Gap (Cantor's Argument)")
    print("=" * 60)

    # For finite sets, demonstrate the counting argument
    for n in range(2, 8):
        endomorphisms = n ** n
        predicates = 2 ** n
        print(f"\n  |X| = {n}:")
        print(f"    Endomorphisms |X → X| = {n}^{n} = {endomorphisms}")
        print(f"    Predicates    |X → 2| = 2^{n} = {predicates}")
        if endomorphisms >= n:
            print(f"    Surjection X → (X→X) possible? "
                  f"Need |X| ≥ |X→X|: {n} ≥ {endomorphisms} → {'Yes' if n >= endomorphisms else 'No'}")
        print(f"    Surjection X → (X→Prop) possible? "
              f"Need |X| ≥ |X→2|: {n} ≥ {predicates} → {'Yes' if n >= predicates else 'No'}")
        print(f"    QUALIA GAP = |X→Prop| - |X| = {predicates - n}")


def demo_godel_zombie_correspondence():
    """Demonstrate the Gödel-Zombie correspondence."""
    print("\n" + "=" * 60)
    print("DEMO 4: Gödel-Zombie Correspondence")
    print("=" * 60)

    print("""
    GÖDEL                          ZOMBIE
    ─────                          ──────
    Sentences                      States
    Provable                       Functionally detectable
    True                           Actually present
    Sound: Provable ⊂ True         Sound: Detectable ⊂ Present
    Gap: True ∖ Provable ≠ ∅       Gap: Present ∖ Detectable ≠ ∅
    Gödel sentence G               Quale Q
    G is true but unprovable       Q is present but undetectable

    Both gaps arise from DIAGONALIZATION:
    - Gödel: "This sentence is not provable"
    - Zombie: "This property is not functionally definable"
    - Cantor: "This set is not in the range"

    All three are instances of Lawvere's fixed-point theorem.
    """)


def demo_tower_stabilization():
    """Demonstrate consciousness tower stabilization."""
    print("=" * 60)
    print("DEMO 5: Consciousness Tower Stabilization")
    print("=" * 60)

    # Simulate: observe = project then embed (idempotent)
    # Using numeric projection as a model
    import math

    def project(x: float) -> int:
        """Project to discrete 'self-model' level."""
        return round(x)

    def embed(n: int) -> float:
        """Embed discrete model back into continuous space."""
        return float(n)

    def observe(x: float) -> float:
        return embed(project(x))

    test_values = [0.3, 1.7, 2.5, 3.14, -0.8, 4.99]
    print("\n  Testing observe ∘ observe = observe:")
    for x in test_values:
        obs1 = observe(x)
        obs2 = observe(obs1)
        print(f"    x={x:6.2f} → observe(x)={obs1:4.1f} → observe²(x)={obs2:4.1f} "
              f"{'✓' if obs1 == obs2 else '✗'}")


if __name__ == "__main__":
    demo_zombie_system()
    demo_explanatory_gap()
    demo_reflective_qualia_gap()
    demo_godel_zombie_correspondence()
    demo_tower_stabilization()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Qualia Gap

Shows how the explanatory gap grows as system complexity increases,
comparing the number of functional properties vs total properties.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_qualia_gap():
    """Plot the qualia gap as a function of system size."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Gap fraction vs system size for various k
    ax1 = axes[0]
    n_values = np.arange(2, 20)
    for k_frac in [0.1, 0.25, 0.5, 0.75]:
        gaps = []
        for n in n_values:
            k = max(1, int(k_frac * n))
            gap = 1.0 - 2**k / 2**n
            gaps.append(gap)
        ax1.plot(n_values, gaps, 'o-', label=f'k/n = {k_frac}', markersize=4)
    ax1.set_xlabel('Number of states (n)')
    ax1.set_ylabel('Qualia gap fraction')
    ax1.set_title('Explanatory Gap vs System Size')
    ax1.legend()
    ax1.set_ylim(-0.05, 1.05)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Log scale comparison of endomorphisms vs predicates
    ax2 = axes[1]
    n_values = np.arange(2, 10)
    endos = [n**n for n in n_values]
    preds = [2**n for n in n_values]
    ax2.semilogy(n_values, endos, 's-', label='Endomorphisms (n^n)', color='blue')
    ax2.semilogy(n_values, preds, 'o-', label='Predicates (2^n)', color='red')
    ax2.semilogy(n_values, n_values, '^-', label='States (n)', color='green')
    ax2.fill_between(n_values, n_values, preds, alpha=0.15, color='red',
                      label='Qualia gap region')
    ax2.set_xlabel('System size (n)')
    ax2.set_ylabel('Count (log scale)')
    ax2.set_title('Reflective Qualia Gap\n(Can model dynamics, not properties)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Zombie system diagram
    ax3 = axes[2]
    ax3.set_xlim(-1.5, 1.5)
    ax3.set_ylim(-1.5, 1.5)
    ax3.set_aspect('equal')

    # Draw equivalence classes as circles
    for i, (cx, cy, label) in enumerate([(-0.7, 0.5, 'Class A'),
                                           (0.7, 0.5, 'Class B'),
                                           (0.0, -0.7, 'Class C')]):
        circle = plt.Circle((cx, cy), 0.55, fill=False, color='gray',
                           linestyle='--', linewidth=1.5)
        ax3.add_patch(circle)
        ax3.text(cx, cy + 0.7, label, ha='center', fontsize=9, color='gray')

        # Conscious state (filled)
        ax3.plot(cx - 0.15, cy + 0.1, 'o', color='gold', markersize=14,
                markeredgecolor='black', markeredgewidth=1.5)
        ax3.text(cx - 0.15, cy + 0.1, '☀', ha='center', va='center', fontsize=8)

        # Zombie state (hollow)
        ax3.plot(cx + 0.2, cy - 0.15, 'o', color='lightgray', markersize=14,
                markeredgecolor='black', markeredgewidth=1.5)
        ax3.text(cx + 0.2, cy - 0.15, '🧟', ha='center', va='center', fontsize=7)

        # Arrow between them
        ax3.annotate('', xy=(cx + 0.05, cy - 0.1), xytext=(cx - 0.0, cy + 0.0),
                    arrowprops=dict(arrowstyle='<->', color='red', lw=1.5))

    ax3.set_title('Zombie System\n(☀ = conscious, 🧟 = zombie)')
    ax3.text(0, -1.35, 'Same function, different experience',
            ha='center', fontsize=9, style='italic', color='red')
    ax3.axis('off')

    plt.tight_layout()
    plt.savefig('qualia_gap_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: qualia_gap_visualization.png")


if __name__ == "__main__":
    plot_qualia_gap()
