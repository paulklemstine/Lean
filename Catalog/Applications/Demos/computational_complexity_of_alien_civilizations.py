#!/usr/bin/env python3
"""
Universal Computational Complexity: Demonstrations

Demonstrates the key mathematical concepts:
1. Diagonal construction on enumerable families
2. Strict resource hierarchies
3. Simulation overhead composition
4. Hypercomputation hierarchy levels
"""

from typing import Callable, Set, List, Tuple


def diagonal_set(family: List[Set[int]], universe_size: int) -> Set[int]:
    """
    Construct the diagonal set from a family of sets.
    D(family) = {n | n ∉ family[n]}
    """
    return {n for n in range(min(len(family), universe_size)) if n not in family[n]}


def demonstrate_diagonal():
    """Show that the diagonal set differs from every set in the family."""
    print("=" * 60)
    print("DIAGONAL CONSTRUCTION DEMO")
    print("=" * 60)
    
    # Create a family of 10 sets
    family = [
        {0, 2, 4, 6, 8},      # L_0: even numbers
        {1, 3, 5, 7, 9},      # L_1: odd numbers
        {0, 1, 2, 3, 4},      # L_2: small numbers
        {5, 6, 7, 8, 9},      # L_3: large numbers
        {0, 1, 4, 9},         # L_4: perfect squares
        {2, 3, 5, 7},         # L_5: primes ≤ 9
        {0, 6},               # L_6: multiples of 6
        {1, 7},               # L_7: ≡ 1 mod 6
        {0, 2, 4, 6, 8},      # L_8: even (duplicate)
        {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},  # L_9: everything
    ]
    
    print("\nFamily of languages (programs 0-9):")
    for i, L in enumerate(family):
        contains_self = "✓" if i in L else "✗"
        print(f"  L_{i} = {str(sorted(L)):30s}  [{i} ∈ L_{i}? {contains_self}]")
    
    diag = diagonal_set(family, 10)
    print(f"\nDiagonal set D = {{n | n ∉ L_n}} = {sorted(diag)}")
    
    print("\nVerification (D differs from every L_i):")
    for i, L in enumerate(family):
        if diag == L:
            print(f"  D = L_{i}  ← IMPOSSIBLE (this should never happen)")
        else:
            # Find a witness of disagreement
            diff = diag.symmetric_difference(L)
            witness = min(diff)
            in_D = witness in diag
            in_L = witness in L
            print(f"  D ≠ L_{i}: witness {witness} (in D: {in_D}, in L_{i}: {in_L})")


def demonstrate_hierarchy():
    """Show a strict resource hierarchy with witnesses."""
    print("\n" + "=" * 60)
    print("STRICT RESOURCE HIERARCHY DEMO")
    print("=" * 60)
    
    # Model: "programs" are polynomials, "resources" bound the degree
    # class_at(n) = {polynomials of degree ≤ n}
    # This is a proper hierarchy: x^(n+1) is in class(n+1) \ class(n)
    
    print("\nResource Hierarchy: Polynomial Complexity")
    print("class_at(n) = {polynomials of degree ≤ n}")
    print()
    
    for n in range(8):
        witness = f"x^{n+1}"
        print(f"  Level {n}: degree ≤ {n}  |  Witness in class({n+1})\\class({n}): {witness}")
    
    print("\nStrict monotonicity verification:")
    for m in range(6):
        for n in range(m + 1, min(m + 4, 8)):
            print(f"  class({m}) ⊊ class({n}): witness x^{m+1}")


def demonstrate_simulation():
    """Show simulation composition with overhead."""
    print("\n" + "=" * 60)
    print("SIMULATION COMPOSITION DEMO")
    print("=" * 60)
    
    # Three models with different clock speeds
    # Model A: base model (1 step per operation)
    # Model B: 2x overhead (simulate A with 2 steps per A-step)
    # Model C: 3x overhead from B (simulate B with 3 steps per B-step)
    
    overheads_ab = lambda n: 2 * n + 1    # A → B overhead
    overheads_bc = lambda n: 3 * n + 2    # B → C overhead
    overheads_ac = lambda n: overheads_bc(overheads_ab(n))  # Composed: A → C
    
    print("\nSimulation overhead functions:")
    print("  h_AB(n) = 2n + 1     (Model A → Model B)")
    print("  h_BC(n) = 3n + 2     (Model B → Model C)")
    print("  h_AC(n) = h_BC(h_AB(n)) = 3(2n+1) + 2 = 6n + 5  (Composed)")
    print()
    
    print("  Resource level | A cost | B cost (h_AB) | C cost (h_AC)")
    print("  " + "-" * 55)
    for n in range(10):
        b_cost = overheads_ab(n)
        c_cost = overheads_ac(n)
        print(f"  {n:14d} | {n:6d} | {b_cost:13d} | {c_cost:13d}")
    
    print("\n  Key insight: if class_A(m) ⊊ class_A(n),")
    print("  then the separation transfers to B and C via the embedding.")


def demonstrate_hypercomputation():
    """Show the hypercomputation hierarchy with diagonal barriers."""
    print("\n" + "=" * 60)
    print("HYPERCOMPUTATION HIERARCHY DEMO")
    print("=" * 60)
    
    # Simulate oracle levels
    # Level 0: computable functions (those with finite lookup tables of size ≤ 10)
    # Level 1: Level 0 + ability to check diag(Level 0)
    # Level 2: Level 1 + ability to check diag(Level 1)
    # etc.
    
    universe = 8
    
    # Level 0: simple families
    level_0 = [set() for _ in range(universe)]
    for i in range(universe):
        level_0[i] = {j for j in range(universe) if (i + j) % 3 == 0}
    
    print(f"\nLevel 0 languages (universe = {{0,...,{universe-1}}}):")
    for i, L in enumerate(level_0):
        print(f"  L⁰_{i} = {sorted(L)}")
    
    diag_0 = diagonal_set(level_0, universe)
    print(f"\n  Diagonal D⁰ = {sorted(diag_0)}")
    print(f"  D⁰ is NOT computable at Level 0 (by diagonal theorem)")
    
    # Level 1: includes all of level 0, plus diag_0 as a new language
    level_1 = level_0.copy()
    level_1.append(diag_0)  # Add diagonal as a new computable language
    # Add more languages
    for i in range(universe):
        level_1.append({j for j in range(universe) if (i * j) % 4 == 0})
    
    diag_1 = diagonal_set(level_1, universe)
    print(f"\n  Level 1 has {len(level_1)} languages (includes D⁰)")
    print(f"  Diagonal D¹ = {sorted(diag_1)}")
    print(f"  D¹ is NOT computable at Level 1 (by diagonal theorem)")
    
    # Level 2
    level_2 = level_1.copy()
    level_2.append(diag_1)
    for i in range(universe):
        level_2.append({j for j in range(universe) if abs(i - j) <= 2})
    
    diag_2 = diagonal_set(level_2, universe)
    print(f"\n  Level 2 has {len(level_2)} languages (includes D⁰, D¹)")
    print(f"  Diagonal D² = {sorted(diag_2)}")
    print(f"  D² is NOT computable at Level 2 (by diagonal theorem)")
    
    print("\n  Summary: The hierarchy is strictly cumulative:")
    print("  Level 0 ⊊ Level 1 ⊊ Level 2 ⊊ ...")
    print("  Each level's diagonal escapes to the next level.")
    print("  This pattern continues FOREVER — no finite number of")
    print("  oracle levels can capture all languages.")


def demonstrate_counting_argument():
    """Show that programs are countable but problems are uncountable."""
    print("\n" + "=" * 60)
    print("COUNTABLE PROGRAMS vs UNCOUNTABLE PROBLEMS")
    print("=" * 60)
    
    # For a universe of size n, there are n programs but 2^n languages
    print("\n  Universe size n | # Programs | # Languages (2^n) | Ratio")
    print("  " + "-" * 60)
    for n in range(1, 21):
        languages = 2 ** n
        ratio = languages / n
        print(f"  {n:15d} | {n:10d} | {languages:18d} | {ratio:.1f}x")
    
    print("\n  As n → ∞, the ratio 2^n / n → ∞")
    print("  Most languages have NO deciding program.")
    print("  This is the fundamental asymmetry driving complexity theory.")


if __name__ == "__main__":
    demonstrate_diagonal()
    demonstrate_hierarchy()
    demonstrate_simulation()
    demonstrate_hypercomputation()
    demonstrate_counting_argument()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Resource Hierarchy Structure

Shows the strict hierarchy of complexity classes as nested sets,
with diagonal witnesses at each level.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_hierarchy():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Left panel: Nested hierarchy visualization
    ax = axes[0]
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 8)
    ax.set_aspect('equal')
    ax.set_title('Strict Resource Hierarchy\n(Nested Complexity Classes)', fontsize=13)
    
    colors = plt.cm.Blues(np.linspace(0.15, 0.85, 7))
    
    for i in range(6, -1, -1):
        width = 1.5 + i * 1.3
        height = 1.0 + i * 0.85
        x = 5 - width / 2
        y = 3.5 - height / 2
        rect = mpatches.FancyBboxPatch(
            (x, y), width, height,
            boxstyle="round,pad=0.1",
            facecolor=colors[i], edgecolor='navy',
            linewidth=1.5, alpha=0.6
        )
        ax.add_patch(rect)
        ax.text(x + width - 0.3, y + 0.25, f'C({i})',
                fontsize=9, fontweight='bold', color='navy',
                ha='right')
    
    # Add diagonal witnesses
    for i in range(6):
        wx = 5 + (i - 2.5) * 0.8
        wy = 3.5 + (i - 2.5) * 0.5
        ax.plot(wx, wy, 'r*', markersize=12, zorder=10)
        ax.annotate(f'w_{i}', (wx, wy), textcoords="offset points",
                   xytext=(8, 5), fontsize=8, color='red',
                   fontweight='bold')
    
    ax.text(5, -0.5, 'w_i ∈ C(i+1) \\ C(i): diagonal witnesses',
            ha='center', fontsize=9, color='red', style='italic')
    ax.axis('off')
    
    # Right panel: Hierarchy size growth
    ax2 = axes[1]
    levels = np.arange(0, 15)
    
    # Programs at each level (polynomial growth)
    programs = levels ** 2 + 1
    # Problems (exponential)
    problems = 2.0 ** levels
    
    ax2.semilogy(levels, programs, 'b-o', label='Programs at level n (n² + 1)',
                linewidth=2, markersize=6)
    ax2.semilogy(levels, problems, 'r-s', label='Languages over {0..n} (2ⁿ)',
                linewidth=2, markersize=6)
    
    ax2.fill_between(levels, programs, problems, alpha=0.15, color='red',
                     label='Gap: undecidable at level n')
    
    ax2.set_xlabel('Resource Level n', fontsize=12)
    ax2.set_ylabel('Count (log scale)', fontsize=12)
    ax2.set_title('Countable Programs vs Uncountable Problems\n'
                  'The gap forces strict hierarchies', fontsize=13)
    ax2.legend(fontsize=9, loc='upper left')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 14)
    
    plt.tight_layout()
    plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hierarchy_visualization.png")


def plot_simulation_transfer():
    fig, ax = plt.subplots(figsize=(10, 6))
    
    levels = np.arange(0, 10)
    
    # Model A: identity overhead
    overhead_a = levels
    # Model B: linear overhead (2n + 1)
    overhead_b = 2 * levels + 1
    # Model C: composed (3(2n+1) + 2 = 6n + 5)
    overhead_c = 6 * levels + 5
    
    ax.plot(levels, overhead_a, 'b-o', label='Model A (base)', linewidth=2)
    ax.plot(levels, overhead_b, 'g-s', label='Model B (h = 2n+1)', linewidth=2)
    ax.plot(levels, overhead_c, 'r-^', label='Model C (h = 6n+5)', linewidth=2)
    
    # Show separation transfer
    m, n = 2, 5
    for model_name, overhead, color in [
        ('A', overhead_a, 'blue'),
        ('B', overhead_b, 'green'),
        ('C', overhead_c, 'red')
    ]:
        ax.axhline(y=overhead[m], color=color, linestyle=':', alpha=0.3)
        ax.axhline(y=overhead[n], color=color, linestyle=':', alpha=0.3)
        ax.annotate('', xy=(9.5, overhead[n]), xytext=(9.5, overhead[m]),
                   arrowprops=dict(arrowstyle='<->', color=color, lw=1.5))
    
    ax.set_xlabel('Source Resource Level', fontsize=12)
    ax.set_ylabel('Target Resource Level (with overhead)', fontsize=12)
    ax.set_title('Simulation Transfer: Separations Preserved\n'
                 'Across Models with Bounded Overhead', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('simulation_transfer.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: simulation_transfer.png")


def plot_hypercomputation_tower():
    fig, ax = plt.subplots(figsize=(10, 7))
    
    max_k = 8
    universe = 10
    
    # Simulate language counts at each level
    lang_counts = [universe]  # Level 0
    for k in range(1, max_k + 1):
        # Each level adds: diagonal + some new languages
        lang_counts.append(lang_counts[-1] + 1 + universe)
    
    # Total possible languages
    total_possible = 2 ** universe
    
    bars = ax.bar(range(max_k + 1), lang_counts, color=plt.cm.viridis(
        np.linspace(0.2, 0.9, max_k + 1)), edgecolor='black', linewidth=0.5)
    
    ax.axhline(y=total_possible, color='red', linestyle='--', linewidth=2,
              label=f'Total languages over {{0..{universe-1}}}: 2^{universe} = {total_possible}')
    
    # Mark diagonal escapes
    for k in range(max_k):
        ax.annotate(f'D^{k}↗', xy=(k, lang_counts[k]),
                   xytext=(k + 0.5, lang_counts[k] + total_possible * 0.03),
                   fontsize=8, color='red', fontweight='bold',
                   arrowprops=dict(arrowstyle='->', color='red', lw=1))
    
    ax.set_xlabel('Oracle Level k', fontsize=12)
    ax.set_ylabel('Number of Computable Languages', fontsize=12)
    ax.set_title('Hypercomputation Tower\n'
                 'Each level\'s diagonal escapes to the next', fontsize=13)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('hypercomputation_tower.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hypercomputation_tower.png")


if __name__ == "__main__":
    plot_hierarchy()
    plot_simulation_transfer()
    plot_hypercomputation_tower()
    print("\nAll visualizations generated.")
