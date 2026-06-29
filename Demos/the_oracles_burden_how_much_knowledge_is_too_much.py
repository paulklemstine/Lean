#!/usr/bin/env python3
"""
Oracle Hierarchy Demo: Numerical Examples

Demonstrates the oracle jump hierarchy and its key properties
through concrete computational examples.
"""

from typing import Set, List, Tuple, Dict
import random


def oracle_jump(theory: Set[int], witness: int) -> Set[int]:
    """Apply an oracle jump by adding a fresh witness."""
    return theory | {witness}


def build_hierarchy(base: Set[int], witnesses: List[int], levels: int) -> List[Set[int]]:
    """Build the oracle hierarchy from base theory using given witnesses."""
    hierarchy = [base]
    current = base
    for i in range(levels):
        current = oracle_jump(current, witnesses[i])
        hierarchy.append(current)
    return hierarchy


def verify_strict_monotonicity(hierarchy: List[Set[int]]) -> bool:
    """Verify that each level strictly contains the previous."""
    for i in range(len(hierarchy) - 1):
        if not (hierarchy[i] < hierarchy[i + 1]):  # strict subset
            return False
    return True


def compute_separating_witnesses(hierarchy: List[Set[int]], m: int, n: int) -> Set[int]:
    """Find sentences provable at level n but not at level m."""
    return hierarchy[n] - hierarchy[m]


def knowledge_burden(level: int) -> int:
    """The number of consistency statements known at this level."""
    return level


def demonstrate_burden_paradox(levels: int = 10):
    """Demonstrate the Burden Paradox numerically."""
    print("=" * 60)
    print("THE BURDEN PARADOX")
    print("=" * 60)
    print()
    print("Level | Known Con() | Can Prove Own Con?")
    print("-" * 50)
    for n in range(levels):
        burden = knowledge_burden(n)
        known = ", ".join(f"Con(T_{k})" for k in range(n)) if n > 0 else "(none)"
        print(f"  {n:3d}  | {known:30s} | No")
    print()
    print("Key insight: Level n knows n consistency facts but cannot verify itself.")
    print()


def demonstrate_soundness_gap(levels: int = 8):
    """Demonstrate the asymmetry between consistency and soundness."""
    print("=" * 60)
    print("THE SOUNDNESS GAP")
    print("=" * 60)
    print()
    print("Level n | Con(T_n) provable at n+1? | Sound(T_n) provable at n+1?")
    print("-" * 70)
    for n in range(levels):
        print(f"    {n:3d} | {'YES':26s} | NO")
    print()
    print("Key insight: Consistency crosses one barrier per jump;")
    print("soundness requires a fundamentally different kind of upgrade.")
    print()


def demonstrate_hierarchy():
    """Build and demonstrate a concrete oracle hierarchy."""
    print("=" * 60)
    print("ORACLE HIERARCHY CONSTRUCTION")
    print("=" * 60)
    print()

    # Base theory: PA proves sentences 0-9
    base = set(range(10))

    # Each jump adds a fresh "consistency sentence"
    # Con(T_0) = 10, Con(T_1) = 11, ..., Con(T_n) = 10+n
    witnesses = list(range(10, 20))

    hierarchy = build_hierarchy(base, witnesses, 10)

    for i, level in enumerate(hierarchy):
        print(f"Level {i}: |T_{i}| = {len(level):3d} sentences, "
              f"new at this level: {sorted(level - (hierarchy[i-1] if i > 0 else set()))}")

    print()
    print(f"Strict monotonicity: {verify_strict_monotonicity(hierarchy)}")
    print()

    # Separating witnesses between levels 2 and 7
    m, n = 2, 7
    seps = compute_separating_witnesses(hierarchy, m, n)
    print(f"Separating witnesses between level {m} and {n}: {sorted(seps)}")
    print(f"Count: {len(seps)} (expected: {n - m})")
    print()


def demonstrate_isomorphism():
    """Demonstrate the order isomorphism with Turing degrees."""
    print("=" * 60)
    print("JUMP ISOMORPHISM")
    print("=" * 60)
    print()

    levels = 8
    base = set(range(10))
    witnesses = list(range(10, 10 + levels))
    hierarchy = build_hierarchy(base, witnesses, levels)

    # Power measure: cardinality of provable set
    powers = [len(level) for level in hierarchy]

    # Turing degree chain (abstract: d(n) = n)
    degrees = list(range(levels + 1))

    print("Level | |T_n| (power) | d(n) (degree) | Both strictly increasing?")
    print("-" * 70)
    for i in range(levels + 1):
        increasing = "✓" if i == 0 or (powers[i] > powers[i-1] and degrees[i] > degrees[i-1]) else "✗"
        print(f"  {i:3d}  | {powers[i]:13d} | {degrees[i]:13d} | {increasing}")

    print()
    print("Both sequences are strictly monotone ℕ → ℕ, hence order-isomorphic to (ℕ, <).")
    print()


def demonstrate_limit_theory():
    """Demonstrate the limit theory and escape theorem."""
    print("=" * 60)
    print("LIMIT THEORY AND ESCAPE")
    print("=" * 60)
    print()

    levels = 10
    base = set(range(5))
    witnesses = list(range(5, 5 + levels))
    hierarchy = build_hierarchy(base, witnesses, levels)

    limit = set()
    for level in hierarchy:
        limit |= level

    print(f"Limit theory T_ω = ⋃ T_n: {sorted(limit)}")
    print(f"|T_ω| = {len(limit)}")
    print()

    for n in range(levels + 1):
        escape = limit - hierarchy[n]
        print(f"Level {n:2d}: |T_ω \\ T_{n}| = {len(escape):3d} "
              f"(sentences in limit but not at level {n})")

    print()
    print("The escape count decreases with level but is always positive for n < max.")
    print()


if __name__ == "__main__":
    demonstrate_hierarchy()
    demonstrate_burden_paradox()
    demonstrate_soundness_gap()
    demonstrate_isomorphism()
    demonstrate_limit_theory()


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy Structure

Creates a visualization showing the strict hierarchy of oracle theories,
the knowledge burden, and the soundness gap.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_oracle_hierarchy():
    """Visualize the oracle hierarchy as nested sets with annotations."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # --- Panel 1: Hierarchy as nested circles ---
    ax1 = axes[0]
    ax1.set_title("Oracle Theory Hierarchy\nPA < PA$^H$ < PA$^{H^H}$ < ...", fontsize=13)

    levels = 6
    colors = plt.cm.Blues(np.linspace(0.2, 0.9, levels))

    for i in range(levels - 1, -1, -1):
        radius = 0.3 + i * 0.12
        circle = plt.Circle((0.5, 0.5), radius, color=colors[i],
                           alpha=0.3, ec='black', lw=1.5)
        ax1.add_patch(circle)
        label = f"T$_{i}$"
        angle = np.pi / 4
        x = 0.5 + (radius - 0.03) * np.cos(angle)
        y = 0.5 + (radius - 0.03) * np.sin(angle)
        ax1.annotate(label, (x, y), fontsize=10, fontweight='bold',
                    ha='center', va='center')

    # Mark Con(T_n) as dots between levels
    for i in range(levels - 1):
        r_inner = 0.3 + i * 0.12
        r_outer = 0.3 + (i + 1) * 0.12
        r_mid = (r_inner + r_outer) / 2
        x = 0.5 + r_mid * np.cos(-np.pi / 6)
        y = 0.5 + r_mid * np.sin(-np.pi / 6)
        ax1.plot(x, y, 'r*', markersize=8)
        ax1.annotate(f"Con(T$_{i}$)", (x + 0.02, y - 0.03), fontsize=7,
                    color='red')

    ax1.set_xlim(-0.15, 1.15)
    ax1.set_ylim(-0.15, 1.15)
    ax1.set_aspect('equal')
    ax1.axis('off')

    # --- Panel 2: Knowledge Burden ---
    ax2 = axes[1]
    ax2.set_title("Knowledge Burden\n(Consistency facts known at each level)", fontsize=13)

    levels_range = np.arange(0, 10)
    burden = levels_range  # Level n knows n consistency facts

    bars = ax2.bar(levels_range, burden, color=plt.cm.Oranges(np.linspace(0.3, 0.9, 10)),
                   edgecolor='black', linewidth=0.5)

    # Add "Can't prove own" markers
    for i in range(10):
        ax2.plot(i, burden[i] + 0.3, 'rx', markersize=8, markeredgewidth=2)

    ax2.set_xlabel("Theory Level n", fontsize=11)
    ax2.set_ylabel("Known Con() statements", fontsize=11)
    ax2.legend([mpatches.Patch(color='orange', alpha=0.7),
                plt.Line2D([0], [0], marker='x', color='r', linestyle='None', markersize=8)],
               ['Known', "Can't prove Con(T_n)"],
               loc='upper left', fontsize=9)

    # --- Panel 3: Soundness Gap ---
    ax3 = axes[2]
    ax3.set_title("Consistency vs. Soundness\n(The Deep Gap)", fontsize=13)

    levels_range = np.arange(0, 8)

    # Consistency: provable one level up (jump of 1)
    con_resolved = np.ones_like(levels_range)

    # Soundness: not provable even one level up (infinite gap)
    snd_gap = np.full_like(levels_range, 3)

    width = 0.35
    ax3.bar(levels_range - width/2, con_resolved, width, color='#2ecc71',
            label='Con(T_n): resolved at n+1', edgecolor='black', linewidth=0.5)
    ax3.bar(levels_range + width/2, snd_gap, width, color='#e74c3c',
            label='Sound(T_n): NOT resolved at n+1', edgecolor='black', linewidth=0.5)

    ax3.set_xlabel("Theory Level n", fontsize=11)
    ax3.set_ylabel("Jumps needed to resolve", fontsize=11)
    ax3.set_yticks([0, 1, 2, 3])
    ax3.set_yticklabels(['0', '1', '2', '∞'])
    ax3.legend(fontsize=9, loc='upper right')

    plt.tight_layout()
    plt.savefig('oracle_hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oracle_hierarchy_visualization.png")


def plot_jump_isomorphism():
    """Visualize the order isomorphism between oracle and Turing hierarchies."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title("Jump Isomorphism: Oracle Theories ↔ Turing Degrees", fontsize=14)

    levels = 8

    # Oracle theory powers (monotonically increasing)
    theory_power = [10 + i for i in range(levels)]

    # Turing degrees (also monotonically increasing)
    turing_degrees = list(range(levels))

    # Plot both chains
    y_oracle = np.ones(levels) * 2
    y_turing = np.ones(levels) * 0

    # Oracle chain (top)
    for i in range(levels):
        ax.plot(i, 2, 'bo', markersize=12)
        ax.annotate(f"T$_{i}$\n|T|={theory_power[i]}", (i, 2.15),
                   ha='center', fontsize=9, color='blue')
        if i < levels - 1:
            ax.annotate('', xy=(i + 0.8, 2), xytext=(i + 0.2, 2),
                       arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))

    # Turing chain (bottom)
    for i in range(levels):
        ax.plot(i, 0, 'rs', markersize=12)
        ax.annotate(f"∅$^{{({i})}}$\nd={turing_degrees[i]}", (i, -0.25),
                   ha='center', fontsize=9, color='red')
        if i < levels - 1:
            ax.annotate('', xy=(i + 0.8, 0), xytext=(i + 0.2, 0),
                       arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

    # Isomorphism arrows
    for i in range(levels):
        ax.annotate('', xy=(i, 0.2), xytext=(i, 1.8),
                   arrowprops=dict(arrowstyle='<->', color='green', lw=2,
                                  linestyle='dashed'))

    ax.set_ylim(-0.6, 2.6)
    ax.set_xlim(-0.5, levels - 0.5)
    ax.set_yticks([0, 2])
    ax.set_yticklabels(['Turing Degrees', 'Oracle Theories'], fontsize=11)
    ax.set_xlabel('Level n', fontsize=12)

    # Legend
    ax.plot([], [], 'g--', lw=2, label='Order Isomorphism')
    ax.legend(fontsize=11, loc='center right')

    plt.tight_layout()
    plt.savefig('jump_isomorphism.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: jump_isomorphism.png")


if __name__ == "__main__":
    plot_oracle_hierarchy()
    plot_jump_isomorphism()
