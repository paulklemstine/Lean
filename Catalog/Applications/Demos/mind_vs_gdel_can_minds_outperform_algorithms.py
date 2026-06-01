#!/usr/bin/env python3
"""
Mind vs Gödel: Demonstrations of Incompleteness Phenomena

This script demonstrates the mathematical structures formalized in
the Lean proofs: incompleteness hierarchies, Berry paradox dynamics,
and Chaitin complexity bounds.
"""

from typing import Callable, Set, Optional, List, Tuple
import math


# ============================================================
# 1. Incompleteness Hierarchy Simulation
# ============================================================

def simulate_incompleteness_chain(levels: int = 10) -> None:
    """
    Simulate an incompleteness chain where each level proves
    the Gödel sentence of the previous level.

    At each level n:
    - The system proves sentences {G_0, G_1, ..., G_{n-1}}
    - The Gödel sentence G_n is true but unprovable
    - The next level proves G_n but has its own G_{n+1}
    """
    print("=" * 60)
    print("INCOMPLETENESS HIERARCHY SIMULATION")
    print("=" * 60)
    print()

    for n in range(levels):
        provable = set(range(n))  # G_0 through G_{n-1}
        godel_sentence = n  # G_n is the current Gödel sentence

        print(f"Level {n}:")
        print(f"  Provable Gödel sentences: {{{', '.join(f'G_{i}' for i in provable)}}}" if provable else f"  Provable Gödel sentences: {{}}")
        print(f"  Current Gödel sentence: G_{godel_sentence} (TRUE but UNPROVABLE)")
        print(f"  Total provability power: {n} previous Gödel sentences")
        print()

    print(f"Pattern: At level n, exactly n Gödel sentences are provable,")
    print(f"but the (n+1)-th is always out of reach.")
    print(f"The hierarchy is STRICTLY ASCENDING — each level is genuinely")
    print(f"more powerful, yet none achieves completeness.")
    print()


# ============================================================
# 2. Berry Paradox Demonstration
# ============================================================

def berry_paradox_demo() -> None:
    """
    Demonstrate the Berry paradox: "the least number not definable
    in fewer than N words" uses fewer than N words for large N.
    """
    print("=" * 60)
    print("BERRY PARADOX DEMONSTRATION")
    print("=" * 60)
    print()

    # Simulate definability levels
    # At level n, we can define numbers 0 through f(n)-1
    # where f(n) grows but is always finite

    def definable_count(n: int) -> int:
        """Number of natural numbers definable at resource level n."""
        # Exponential growth: 2^n numbers definable with n bits
        return 2 ** n

    for n in range(1, 16):
        count = definable_count(n)
        berry_number = count  # The least number NOT definable at level n

        # The Berry description "the least number not definable at level n"
        # has a fixed descriptive cost (roughly log(n) + constant)
        berry_cost = int(math.log2(n + 1)) + 5  # Approximate cost

        print(f"Level {n:2d}: {count:6d} numbers definable | Berry number = {berry_number:6d} | Berry description cost ≈ {berry_cost}")

        if berry_cost <= n:
            print(f"         ⚠ PARADOX ZONE: Berry description ({berry_cost}) ≤ level ({n})")
            print(f"         → Berry number is BOTH definable AND not definable at level {n}")

    print()
    print("The paradox: for large n, the Berry description has cost ~log(n) + C,")
    print("which is less than n. So the 'least undefinable' number IS definable.")
    print("Resolution: the Berry operator cannot be part of the definability system.")
    print()


# ============================================================
# 3. Chaitin Bound Computation
# ============================================================

def chaitin_bound_demo() -> None:
    """
    Demonstrate Chaitin's bound: a formal system of complexity C
    cannot prove that any string has Kolmogorov complexity > C.
    """
    print("=" * 60)
    print("CHAITIN COMPLEXITY BOUND DEMONSTRATION")
    print("=" * 60)
    print()

    # Simulate a formal system with limited axioms
    # Each "axiom" is a string, and the system's complexity is bounded
    # by the total length of its axioms

    axiom_sets = [
        ("Minimal system", ["0=0", "S(x)≠0"]),
        ("Robinson arithmetic", ["0=0", "S(x)≠0", "x+0=x", "x+Sy=S(x+y)", "x·0=0", "x·Sy=x·y+x"]),
        ("Peano arithmetic", ["0=0", "S(x)≠0", "x+0=x", "x+Sy=S(x+y)", "x·0=0", "x·Sy=x·y+x", "Induction schema"]),
        ("PA + Con(PA)", ["0=0", "S(x)≠0", "x+0=x", "x+Sy=S(x+y)", "x·0=0", "x·Sy=x·y+x", "Induction schema", "Con(PA)"]),
    ]

    for name, axioms in axiom_sets:
        total_complexity = sum(len(a) for a in axioms)
        chaitin_bound = total_complexity + 10  # Overhead for the proof checker

        print(f"System: {name}")
        print(f"  Axioms: {axioms}")
        print(f"  Total axiom complexity: {total_complexity}")
        print(f"  Chaitin bound C ≈ {chaitin_bound}")
        print(f"  → Cannot prove K(x) > {chaitin_bound} for any string x")
        print(f"  → Can potentially certify complexity up to {chaitin_bound}")
        print()

    print("Key insight: adding axioms (like Con(PA)) increases the Chaitin bound,")
    print("allowing the system to certify higher complexity — but the bound is")
    print("always finite. No finite system can certify arbitrarily high complexity.")
    print()


# ============================================================
# 4. Lucas-Penrose Escape Simulation
# ============================================================

def lucas_penrose_escape() -> None:
    """
    Simulate the Lucas-Penrose 'escape' argument: a mind recognizes
    the Gödel sentence of its formalization, but this creates a new
    formalization with a new Gödel sentence.
    """
    print("=" * 60)
    print("LUCAS-PENROSE ESCAPE SIMULATION")
    print("=" * 60)
    print()

    print("Scenario: A mind M is formalized as system F_0.")
    print()

    for step in range(8):
        if step == 0:
            print(f"Step {step}: Mind M is formalized as F_0")
            print(f"  F_0 has Gödel sentence G_0: 'I am not provable in F_0'")
            print(f"  G_0 is true but F_0 cannot prove it")
            print()
        else:
            print(f"Step {step}: Mind recognizes G_{step-1} → formalization becomes F_{step}")
            print(f"  F_{step} = F_{step-1} + G_{step-1}")
            print(f"  F_{step} has NEW Gödel sentence G_{step}: 'I am not provable in F_{step}'")
            print(f"  G_{step} is true but F_{step} cannot prove it")
            print()

    print("The escape NEVER terminates.")
    print("Each recognition creates a new blind spot.")
    print("The mind and its formalization are in an infinite chase.")
    print()
    print("This is the content of our 'escape_never_terminates' theorem:")
    print("∀ n, ∃ s, true(s) ∧ ¬provable_n(s)")
    print()


# ============================================================
# 5. Mind Function Blind Spots
# ============================================================

def mind_function_demo() -> None:
    """
    Demonstrate that any finite collection of 'mind functions'
    has simultaneous blind spots.
    """
    print("=" * 60)
    print("JOINT MIND FUNCTION BLIND SPOTS")
    print("=" * 60)
    print()

    for k in range(1, 6):
        minds = [f"M_{i}" for i in range(k)]
        combined_power = sum(range(1, k + 1))  # Symbolic "power"

        print(f"Committee of {k} minds: {', '.join(minds)}")
        print(f"  Combined into system E_{k}")
        print(f"  E_{k} has Gödel sentence G*_{k}")
        print(f"  G*_{k} escapes ALL of {', '.join(minds)} simultaneously")
        print(f"  → No single mind in the committee can recognize G*_{k}")
        print()

    print("Adding more minds NEVER eliminates all blind spots.")
    print("The combined system always has its own Gödel sentence")
    print("that no individual mind can see.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    simulate_incompleteness_chain(10)
    berry_paradox_demo()
    chaitin_bound_demo()
    lucas_penrose_escape()
    mind_function_demo()

    print("=" * 60)
    print("SUMMARY OF VERIFIED THEOREMS")
    print("=" * 60)
    print()
    print("All of the following are machine-verified (sorry-free):")
    print()
    theorems = [
        ("godel_first_incompleteness", "Sound + diagonal → incomplete"),
        ("tarski_undefinability", "Truth ≠ provability"),
        ("lucas_penrose_barrier", "Oracle extensions remain incomplete"),
        ("extension_new_godel", "New extensions have new Gödel sentences"),
        ("incompleteness_hierarchy_strict", "Hierarchy is strictly ascending"),
        ("chain_all_incomplete", "Every level is incomplete"),
        ("chain_godel_all_true", "All Gödel sentences are true"),
        ("self_recognition_impossibility", "Mind functions have blind spots"),
        ("joint_minds_insufficient", "Finite mind committees have blind spots"),
        ("berry_paradox", "Self-referential definability is contradictory"),
        ("berry_paradox_constructive", "Berry operator has unbounded cost"),
        ("chaitin_complexity_bound", "Finite systems have bounded complexity"),
        ("penrose_core", "Mind-as-system has unprovable truths"),
        ("escape_never_terminates", "Escape creates new blind spots"),
        ("oracle_cannot_complete", "No oracle completes a sound system"),
        ("sound_implies_consistent", "Sound systems are consistent"),
    ]
    for name, desc in theorems:
        print(f"  ✓ {name}: {desc}")
    print()


#!/usr/bin/env python3
"""Visualization: Berry Paradox - Definability vs Description Cost"""

import matplotlib.pyplot as plt
import numpy as np
import math


def create_berry_visualization():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Berry numbers vs description cost
    levels = np.arange(1, 25)
    berry_numbers = 2 ** levels  # Numbers definable at each level
    berry_description_cost = np.array([int(math.log2(n + 1)) + 5 for n in levels])

    ax1.semilogy(levels, berry_numbers, 'b-o', linewidth=2, markersize=4,
                label='Berry number (least undefinable)')
    ax1.plot(levels, levels, 'r--', linewidth=2, label='Level n (available resources)')
    ax1.plot(levels, berry_description_cost, 'g-s', linewidth=2, markersize=4,
            label='Berry description cost (~log n + C)')

    # Shade the paradox zone
    paradox_start = None
    for i, n in enumerate(levels):
        if berry_description_cost[i] <= n and paradox_start is None:
            paradox_start = i
            break

    if paradox_start is not None:
        ax1.axvspan(levels[paradox_start], levels[-1], alpha=0.15, color='red',
                   label='Paradox zone (cost ≤ level)')

    ax1.set_xlabel('Resource level n', fontsize=12)
    ax1.set_ylabel('Value / Cost', fontsize=12)
    ax1.set_title("Berry's Paradox:\nDescription Cost vs Available Resources", fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right panel: Chaitin bound illustration
    system_sizes = np.arange(10, 200, 10)
    chaitin_bounds = system_sizes + 10  # Bound = system complexity + overhead

    ax2.fill_between(system_sizes, 0, chaitin_bounds, alpha=0.3, color='blue',
                    label='Provable complexity range')
    ax2.fill_between(system_sizes, chaitin_bounds, 250, alpha=0.15, color='red',
                    label='Unprovable complexity (above Chaitin bound)')
    ax2.plot(system_sizes, chaitin_bounds, 'k-', linewidth=2,
            label='Chaitin bound C')
    ax2.plot(system_sizes, system_sizes, 'g--', linewidth=1.5,
            label='System complexity', alpha=0.7)

    ax2.set_xlabel('Formal system complexity', fontsize=12)
    ax2.set_ylabel('String complexity K(x)', fontsize=12)
    ax2.set_title("Chaitin's Bound:\nSystems Can't Certify High Complexity", fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10, loc='upper left')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 250)

    plt.tight_layout()
    plt.savefig('berry_chaitin.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: berry_chaitin.png")


if __name__ == "__main__":
    create_berry_visualization()


#!/usr/bin/env python3
"""Visualization: Incompleteness Hierarchy as Staircase"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def create_hierarchy_visualization():
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    levels = 8
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, levels))

    for n in range(levels):
        # Draw the "stair" - provable region
        rect = mpatches.FancyBboxPatch(
            (n * 1.2, 0), 0.9, n + 1,
            boxstyle="round,pad=0.05",
            facecolor=colors[n], alpha=0.7, edgecolor='black', linewidth=1.5
        )
        ax.add_patch(rect)

        # Label the system
        ax.text(n * 1.2 + 0.45, -0.5, f'$F_{n}$', ha='center', va='top',
                fontsize=12, fontweight='bold')

        # Label provable Gödel sentences
        for k in range(n):
            ax.text(n * 1.2 + 0.45, k + 0.5, f'$G_{k}$', ha='center', va='center',
                    fontsize=9, color='white', fontweight='bold')

        # Mark the unprovable Gödel sentence (true but unprovable)
        ax.plot(n * 1.2 + 0.45, n + 1.3, 'r*', markersize=15)
        ax.text(n * 1.2 + 0.45, n + 1.7, f'$G_{n}$\n(true,\nunprovable)',
                ha='center', va='bottom', fontsize=8, color='red', fontweight='bold')

        # Arrow from one level to the next
        if n < levels - 1:
            ax.annotate('', xy=((n+1) * 1.2, n + 1.5), xytext=(n * 1.2 + 0.9, n + 1.3),
                       arrowprops=dict(arrowstyle='->', color='darkred', lw=1.5))

    ax.set_xlim(-0.5, levels * 1.2 + 0.5)
    ax.set_ylim(-1.5, levels + 3)
    ax.set_xlabel('Formal System Level', fontsize=14)
    ax.set_ylabel('Provability Power (number of Gödel sentences proved)', fontsize=14)
    ax.set_title('Incompleteness Hierarchy: The Infinite Staircase\n'
                'Each level proves the previous Gödel sentence but has its own',
                fontsize=14, fontweight='bold')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=colors[3], alpha=0.7, label='Provable region'),
        plt.Line2D([0], [0], marker='*', color='w', markerfacecolor='red',
                   markersize=15, label='True but unprovable (Gödel sentence)')
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=11)

    ax.set_aspect('equal')
    plt.tight_layout()
    plt.savefig('hierarchy_staircase.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hierarchy_staircase.png")


if __name__ == "__main__":
    create_hierarchy_visualization()
