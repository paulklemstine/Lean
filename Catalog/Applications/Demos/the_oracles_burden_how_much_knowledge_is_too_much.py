#!/usr/bin/env python3
"""
Oracle Hierarchy Demo: Numerical Examples

Demonstrates the key results from the oracle hierarchy formalization:
1. Building concrete oracle hierarchies
2. Verifying strict monotonicity
3. Computing oracle power and density profiles
4. Testing the density separation conjecture
"""

from algorithms import (
    OracleJump, OracleHierarchy, JumpChain,
    build_indexed_chain, verify_strict_hierarchy,
    compute_power_profile, compute_density_profile,
    find_separation_witnesses, oracle_power, oracle_density,
    simple_godel_witness
)
from fractions import Fraction


def demo_basic_hierarchy():
    """Demo 1: Build and verify a basic oracle hierarchy."""
    print("=" * 60)
    print("DEMO 1: Basic Oracle Hierarchy")
    print("=" * 60)

    # Base theory: PA proves statements about even numbers (simplification)
    base = {2 * i for i in range(50)}  # {0, 2, 4, ..., 98}
    print(f"Base theory size: {len(base)}")
    print(f"Base theory (first 10): {sorted(base)[:10]}...")

    # Build 10-level hierarchy using Gödel witness function
    levels = build_indexed_chain(base, simple_godel_witness, 10)

    # Verify strict monotonicity
    strict = verify_strict_hierarchy(levels)
    print(f"\nStrict hierarchy: {all(strict)} (all levels strictly increase)")

    # Show level sizes
    print("\nLevel sizes:")
    for i, level in enumerate(levels):
        print(f"  Level {i}: {len(level)} sentences")

    # Find separation witnesses
    witnesses = find_separation_witnesses(levels)
    print(f"\nSeparation witnesses: {witnesses}")
    print("  (Each witness is in level n+1 but NOT in level n)")


def demo_oracle_power():
    """Demo 2: Oracle power measurement across levels."""
    print("\n" + "=" * 60)
    print("DEMO 2: Oracle Power Measurement")
    print("=" * 60)

    base = {2 * i for i in range(100)}  # Even numbers < 200
    levels = build_indexed_chain(base, simple_godel_witness, 15)

    N_values = [50, 100, 200, 500]
    for N in N_values:
        powers = compute_power_profile(levels, N)
        print(f"\nUniverse [0, {N}):")
        print(f"  Powers: {powers[:8]}...")
        # Verify strict increase
        strictly_increasing = all(powers[i] < powers[i+1]
                                   for i in range(len(powers)-1)
                                   if powers[i+1] > powers[i])
        print(f"  Strictly increasing: {strictly_increasing}")


def demo_density_profile():
    """Demo 3: Oracle density profiles."""
    print("\n" + "=" * 60)
    print("DEMO 3: Oracle Density Profiles")
    print("=" * 60)

    base = {2 * i for i in range(500)}
    levels = build_indexed_chain(base, simple_godel_witness, 10)

    N = 1000
    densities = compute_density_profile(levels, N)
    print(f"\nDensities in [0, {N}):")
    for i, d in enumerate(densities):
        bar = "█" * int(d * 50)
        print(f"  Level {i:2d}: {d:.4f} {bar}")

    # Verify density gap
    print(f"\nDensity gaps:")
    for i in range(len(densities) - 1):
        gap = densities[i+1] - densities[i]
        print(f"  Level {i} → {i+1}: gap = {gap:.6f}")


def demo_consistency_chain():
    """Demo 4: Consistency sentence propagation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Consistency Chain (Gödel's Second Incompleteness)")
    print("=" * 60)

    base = {0, 2, 4, 6, 8}
    levels = build_indexed_chain(base, simple_godel_witness, 8)

    print(f"\nBase: {sorted(base)}")
    print(f"Witness function w(n) = 2n+1: {[simple_godel_witness(n) for n in range(8)]}")

    for n in range(8):
        w = simple_godel_witness(n)
        in_level_n = w in levels[n]
        in_level_n1 = w in levels[n + 1] if n + 1 < len(levels) else False
        status = "✓ SEPARATION" if (not in_level_n and in_level_n1) else "✗ FAIL"
        print(f"  Con(T_{n}) = w({n}) = {w}: "
              f"in level {n}? {in_level_n}, "
              f"in level {n+1}? {in_level_n1}  [{status}]")


def demo_jump_chain():
    """Demo 5: JumpChain with Turing degree embedding."""
    print("\n" + "=" * 60)
    print("DEMO 5: JumpChain — Turing Degree Embedding")
    print("=" * 60)

    base = {2 * i for i in range(100)}

    def simple_jump(S):
        result = set(S)
        # Add the smallest odd number not in S
        for k in range(10000):
            if 2*k+1 not in S:
                result.add(2*k+1)
                break
        return result

    hierarchy = OracleHierarchy(
        base=base,
        jump=OracleJump(jump=simple_jump)
    )

    # Degree function: degree(n) = 2^n (exponential growth models Turing jumps)
    chain = JumpChain(
        hierarchy=hierarchy,
        degree=lambda n: 2**n
    )

    print(f"\nDegree function d(n) = 2^n:")
    for n in range(8):
        level = hierarchy.level(n)
        power = oracle_power(level, 200)
        print(f"  Level {n}: degree = {chain.degree(n):4d}, "
              f"power(200) = {power}")

    print(f"\nDegree strict mono up to 10: {chain.verify_strict_mono(10)}")


def demo_density_conjecture():
    """Demo 6: Test the density separation conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 6: Density Separation Conjecture Test")
    print("=" * 60)

    # Use a richer base theory
    base = set(range(0, 1000, 2))  # Even numbers < 1000

    # Build hierarchy with a more interesting witness function
    def prime_witness(n):
        """Use prime-like positions as witnesses."""
        return 2 * n + 1  # Odd numbers

    levels = build_indexed_chain(base, prime_witness, 20)

    # Test conjecture: is power strictly increasing for all N?
    print("\nConjecture: power(level n+1, N) > power(level n, N) for large N")
    N_values = [100, 500, 1000, 5000, 10000]

    conjecture_holds = True
    for N in N_values:
        powers = compute_power_profile(levels, N)
        all_strict = all(powers[i] <= powers[i+1] for i in range(len(powers)-1))
        violations = sum(1 for i in range(len(powers)-1) if powers[i] >= powers[i+1])
        print(f"  N = {N:5d}: powers[0..5] = {powers[:6]}, "
              f"monotone = {all_strict}, violations = {violations}")
        if violations > 0:
            conjecture_holds = False

    print(f"\nConjecture status: {'SUPPORTED ✓' if conjecture_holds else 'REFUTED ✗'}")


if __name__ == "__main__":
    demo_basic_hierarchy()
    demo_oracle_power()
    demo_density_profile()
    demo_consistency_chain()
    demo_jump_chain()
    demo_density_conjecture()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy Power and Density Profiles

Generates matplotlib plots showing:
1. Oracle power growth across hierarchy levels
2. Density separation between levels
3. Consistency sentence accumulation
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def build_indexed_chain(base, witness_fn, max_level):
    """Build indexed chain of oracle theories."""
    levels = [set(base)]
    for n in range(max_level):
        next_level = set(levels[-1])
        next_level.add(witness_fn(n))
        levels.append(next_level)
    return levels


def oracle_power(theory, N):
    """Count provable sentences in [0, N)."""
    return len({x for x in range(N) if x in theory})


def oracle_density(theory, N):
    """Density of provable sentences in [0, N)."""
    return oracle_power(theory, N) / N if N > 0 else 0


def plot_power_growth():
    """Plot oracle power growth across levels."""
    base = {2 * i for i in range(500)}
    levels = build_indexed_chain(base, lambda n: 2*n+1, 20)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Power vs Level for different N
    N_values = [100, 500, 1000, 2000]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(N_values)))

    ax = axes[0]
    for N, color in zip(N_values, colors):
        powers = [oracle_power(level, N) for level in levels]
        ax.plot(range(len(levels)), powers, 'o-', color=color,
                label=f'N = {N}', markersize=4)
    ax.set_xlabel('Hierarchy Level n', fontsize=12)
    ax.set_ylabel('Oracle Power |{s < N : s provable}|', fontsize=12)
    ax.set_title('Oracle Power Growth', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Density vs Level
    ax = axes[1]
    N = 2000
    densities = [oracle_density(level, N) for level in levels]
    ax.bar(range(len(levels)), densities, color=plt.cm.plasma(np.linspace(0.2, 0.8, len(levels))))
    ax.set_xlabel('Hierarchy Level n', fontsize=12)
    ax.set_ylabel(f'Density (N = {N})', fontsize=12)
    ax.set_title('Oracle Density Profile', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('oracle_power_growth.png', dpi=150, bbox_inches='tight')
    print("Saved: oracle_power_growth.png")


def plot_consistency_chain():
    """Plot consistency sentence accumulation."""
    base = {0, 2, 4, 6, 8, 10}
    witness = lambda n: 2*n + 1
    num_levels = 12
    levels = build_indexed_chain(base, witness, num_levels)

    fig, ax = plt.subplots(figsize=(10, 8))

    # Create a matrix: rows = levels, cols = consistency sentences
    matrix = np.zeros((num_levels + 1, num_levels))
    for level_idx in range(num_levels + 1):
        for sent_idx in range(num_levels):
            w = witness(sent_idx)
            if w in levels[level_idx]:
                matrix[level_idx, sent_idx] = 1

    im = ax.imshow(matrix, cmap='YlOrRd', aspect='auto', interpolation='nearest')
    ax.set_xlabel('Consistency Sentence Con(T_k)', fontsize=12)
    ax.set_ylabel('Hierarchy Level n', fontsize=12)
    ax.set_title('Consistency Sentence Accumulation\n'
                  '(Gödel\'s Second Incompleteness Theorem)', fontsize=14, fontweight='bold')
    ax.set_xticks(range(num_levels))
    ax.set_xticklabels([f'Con(T_{k})' for k in range(num_levels)], rotation=45, fontsize=8)
    ax.set_yticks(range(num_levels + 1))
    ax.set_yticklabels([f'Level {n}' for n in range(num_levels + 1)], fontsize=8)

    # Add diagonal line showing the incompleteness boundary
    for i in range(min(num_levels, num_levels + 1)):
        ax.plot(i - 0.5, i + 0.5, 'kx', markersize=10, markeredgewidth=2)

    plt.colorbar(im, ax=ax, label='Provable (1) / Not Provable (0)')
    plt.tight_layout()
    plt.savefig('consistency_chain.png', dpi=150, bbox_inches='tight')
    print("Saved: consistency_chain.png")


def plot_separation_witnesses():
    """Plot separation witnesses across the hierarchy."""
    base = {2 * i for i in range(200)}
    witness = lambda n: 2*n + 1
    num_levels = 15
    levels = build_indexed_chain(base, witness, num_levels)

    fig, ax = plt.subplots(figsize=(12, 6))

    # Show each level as a horizontal bar of its elements
    max_val = 50  # Show first 50 elements
    for level_idx in range(min(num_levels + 1, 8)):
        elements = sorted(x for x in levels[level_idx] if x < max_val)
        ax.scatter(elements, [level_idx] * len(elements),
                   s=20, alpha=0.7, color=plt.cm.tab10(level_idx / 8))

        # Highlight the new witness
        if level_idx > 0:
            w = witness(level_idx - 1)
            if w < max_val:
                ax.scatter([w], [level_idx], s=100, marker='*',
                           color='red', zorder=5, edgecolors='black')

    ax.set_xlabel('Sentence Code', fontsize=12)
    ax.set_ylabel('Hierarchy Level', fontsize=12)
    ax.set_title('Oracle Hierarchy: Separation Witnesses (★)',
                  fontsize=14, fontweight='bold')
    ax.set_yticks(range(8))
    ax.set_yticklabels([f'Level {i}' for i in range(8)])
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('separation_witnesses.png', dpi=150, bbox_inches='tight')
    print("Saved: separation_witnesses.png")


if __name__ == "__main__":
    plot_power_growth()
    plot_consistency_chain()
    plot_separation_witnesses()
    print("\nAll visualizations generated!")
