#!/usr/bin/env python3
"""
Hypercomputation: Computing the Uncomputable — Numerical Demonstrations

This script demonstrates the key concepts from the hypercomputation formalization:
1. The diagonal argument and why it creates undecidable problems
2. The strict oracle hierarchy with concrete examples
3. Resource divergence for oracle hierarchies
4. The accidentally vs essentially computable classification
"""

import math
from typing import Set, Callable, List, Tuple, Dict


def diagonal_set(family: Dict[int, Set[int]], universe: int) -> Set[int]:
    """Compute the diagonal set: {n | n ∉ family[n]}."""
    return {n for n in range(universe) if n not in family.get(n, set())}


def demo_diagonal_argument():
    """Demonstrate why the diagonal set differs from every member of a family."""
    print("=" * 60)
    print("DEMO 1: The Diagonal Argument")
    print("=" * 60)
    
    universe = 8
    
    # Create a family of sets (modeling "programs")
    family = {
        0: {0, 2, 4, 6},       # Even numbers
        1: {1, 3, 5, 7},       # Odd numbers
        2: {0, 1, 2, 3},       # First half
        3: {4, 5, 6, 7},       # Second half
        4: {0, 1, 4, 5},       # Binary pattern
        5: {2, 3, 6, 7},       # Complement of above
        6: {0, 3, 4, 7},       # Another pattern
        7: {1, 2, 5, 6},       # Complement
    }
    
    print(f"\nFamily of {universe} sets over {{0, ..., {universe-1}}}:")
    for k, s in sorted(family.items()):
        print(f"  F_{k} = {sorted(s)}")
    
    diag = diagonal_set(family, universe)
    print(f"\nDiagonal set D = {{n | n ∉ F_n}} = {sorted(diag)}")
    
    print("\nVerification that D ≠ F_k for all k:")
    for k in range(universe):
        if k in diag and k in family[k]:
            print(f"  IMPOSSIBLE: k={k} in both D and F_{k}")
        elif k not in diag and k not in family[k]:
            print(f"  IMPOSSIBLE: k={k} in neither D nor F_{k}")
        elif k in diag:
            print(f"  k={k}: {k} ∈ D but {k} ∉ F_{k} → D ≠ F_{k} ✓")
        else:
            print(f"  k={k}: {k} ∉ D but {k} ∈ F_{k} → D ≠ F_{k} ✓")


def demo_oracle_hierarchy():
    """Demonstrate the strict oracle hierarchy with a concrete model."""
    print("\n" + "=" * 60)
    print("DEMO 2: The Strict Oracle Hierarchy")
    print("=" * 60)
    
    # Model: level n = {0, 1, ..., n-1} ∪ base
    # Jump adds one new element at each level
    base = {100, 200, 300}  # Some base decidable problems
    
    def level(n: int) -> Set[int]:
        return base | set(range(n))
    
    num_levels = 7
    print(f"\nBase = {sorted(base)}")
    for n in range(num_levels):
        lvl = level(n)
        print(f"  Level {n} = {sorted(lvl)} (size {len(lvl)})")
    
    print("\nStrict hierarchy verification:")
    for n in range(num_levels - 1):
        ln = level(n)
        ln1 = level(n + 1)
        subset = ln.issubset(ln1)
        strict = ln != ln1
        new_elements = ln1 - ln
        print(f"  Level {n} ⊊ Level {n+1}: subset={subset}, strict={strict}, "
              f"new elements={new_elements}")
    
    print("\nNo collapse verification:")
    for m in range(num_levels):
        for n in range(m + 1, num_levels):
            assert level(m) != level(n), f"Collapse at m={m}, n={n}!"
    print("  ✓ No two distinct levels are equal")


def demo_resource_divergence():
    """Demonstrate resource divergence for oracle hierarchies."""
    print("\n" + "=" * 60)
    print("DEMO 3: Resource Divergence Theorem")
    print("=" * 60)
    
    # Three cost models: linear, quadratic, exponential
    models = {
        "Linear (c(n) = n+1)": lambda n: n + 1,
        "Quadratic (c(n) = (n+1)²)": lambda n: (n + 1) ** 2,
        "Exponential (c(n) = 2^n)": lambda n: 2 ** n,
    }
    
    for name, cost in models.items():
        print(f"\n{name}:")
        cumulative = 0.0
        for n in range(15):
            c = cost(n)
            cumulative += c
            print(f"  Level {n:2d}: cost = {c:10.0f}, cumulative = {cumulative:12.0f}")
        print(f"  → Cumulative cost diverges to ∞")
    
    print("\nResource Divergence Theorem: For linear costs c(n) ≥ αn,")
    print("cumulative cost C(n) ≥ α·n(n-1)/2 → ∞")
    alpha = 1.0
    for target_C in [100, 1000, 10000, 100000]:
        # Solve α·n(n-1)/2 > C → n > (1 + sqrt(1 + 8C/α))/2
        n_needed = math.ceil((1 + math.sqrt(1 + 8 * target_C / alpha)) / 2)
        actual_cum = sum(alpha * i for i in range(n_needed))
        print(f"  To exceed C = {target_C:>6}: need level n ≥ {n_needed}, "
              f"actual cumulative = {actual_cum:.0f}")


def demo_accidentally_vs_essentially():
    """Demonstrate the accidentally vs essentially computable classification."""
    print("\n" + "=" * 60)
    print("DEMO 4: Accidentally vs Essentially Computable")
    print("=" * 60)
    
    # Model: base = even numbers, level k adds numbers ≡ 0 mod 2^k
    base = {n for n in range(100) if n % 2 == 0}
    
    def level(k: int) -> Set[int]:
        if k == 0:
            return base
        return level(k - 1) | {n for n in range(100) if n % (2 ** k) == 1}
    
    print("\nBase (level 0) = even numbers in [0, 100)")
    print(f"  |base| = {len(base)}")
    
    for k in range(1, 5):
        lvl = level(k)
        new = lvl - level(k - 1)
        print(f"  Level {k}: |level| = {len(lvl)}, new elements: {sorted(list(new))[:10]}...")
    
    # Classify some problems
    problems = {
        "P1 = {0, 2, 4}": {0, 2, 4},
        "P2 = {1, 3}": {1, 3},
        "P3 = {0, 1, 2, 3}": {0, 1, 2, 3},
        "P4 = {99}": {99},
    }
    
    print("\nClassification:")
    for name, P in problems.items():
        is_essentially = P.issubset(base)
        min_level = None
        for k in range(10):
            if P.issubset(level(k)):
                min_level = k
                break
        
        if is_essentially:
            classification = "Essentially Computable (strength 0)"
        elif min_level is not None and min_level > 0:
            classification = f"Accidentally Computable (strength {min_level})"
        else:
            classification = f"Strength = {min_level}"
        
        print(f"  {name}: {classification}")
    
    # Demonstrate existence of accidentally computable problems
    print("\nExistence of accidentally computable problems:")
    for k in range(1, 5):
        witness = level(k) - level(k - 1)
        if witness:
            w = min(witness)
            print(f"  Witness at level {k}: {{{w}}} ∈ level({k}) \\ level({k-1})")


def demo_oracle_strength_ordering():
    """Demonstrate the oracle strength ordering."""
    print("\n" + "=" * 60)
    print("DEMO 5: Oracle Strength and Reducibility")
    print("=" * 60)
    
    # Simple model: level k = {0, ..., k-1}
    def level(k: int) -> Set[int]:
        return set(range(k))
    
    problems = [
        ("∅ (empty)", set()),
        ("{0}", {0}),
        ("{0, 1}", {0, 1}),
        ("{0, 1, 2}", {0, 1, 2}),
        ("{3}", {3}),
        ("{0, 3}", {0, 3}),
    ]
    
    print("\nOracle strength (minimum level to contain the problem):")
    for name, P in problems:
        strength = 0
        if P:
            strength = max(P) + 1
        print(f"  {name:20s}: strength = {strength}")
    
    print("\nReducibility check (P ≤ Q iff strength(P) ≤ strength(Q)):")
    for i, (name_p, P) in enumerate(problems):
        for j, (name_q, Q) in enumerate(problems):
            sp = max(P) + 1 if P else 0
            sq = max(Q) + 1 if Q else 0
            if sp <= sq and i != j:
                print(f"  {name_p} ≤ {name_q} (strength {sp} ≤ {sq})")


if __name__ == "__main__":
    demo_diagonal_argument()
    demo_oracle_hierarchy()
    demo_resource_divergence()
    demo_accidentally_vs_essentially()
    demo_oracle_strength_ordering()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy and Resource Divergence

Generates plots showing:
1. The strict oracle hierarchy as nested sets
2. Resource cost growth (linear, quadratic, exponential)
3. Oracle strength classification of problems
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def plot_resource_divergence():
    """Plot cumulative resource costs for different growth models."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    levels = np.arange(0, 20)
    
    # Cost functions
    linear_cost = levels + 1
    quadratic_cost = (levels + 1) ** 2
    exponential_cost = 2.0 ** levels
    
    # Cumulative costs
    linear_cum = np.cumsum(linear_cost)
    quadratic_cum = np.cumsum(quadratic_cost)
    exponential_cum = np.cumsum(exponential_cost)
    
    # Plot per-level costs
    ax1 = axes[0]
    ax1.semilogy(levels, linear_cost, 'b-o', label='Linear: c(n) = n+1', markersize=4)
    ax1.semilogy(levels, quadratic_cost, 'r-s', label='Quadratic: c(n) = (n+1)²', markersize=4)
    ax1.semilogy(levels, exponential_cost, 'g-^', label='Exponential: c(n) = 2ⁿ', markersize=4)
    ax1.set_xlabel('Oracle Level n', fontsize=12)
    ax1.set_ylabel('Resource Cost c(n)', fontsize=12)
    ax1.set_title('Per-Level Resource Cost', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Plot cumulative costs
    ax2 = axes[1]
    ax2.semilogy(levels, linear_cum, 'b-o', label='Linear', markersize=4)
    ax2.semilogy(levels, quadratic_cum, 'r-s', label='Quadratic', markersize=4)
    ax2.semilogy(levels, exponential_cum, 'g-^', label='Exponential', markersize=4)
    ax2.set_xlabel('Oracle Level n', fontsize=12)
    ax2.set_ylabel('Cumulative Cost C(n)', fontsize=12)
    ax2.set_title('Cumulative Resource Cost (Divergence)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Add annotation about divergence
    ax2.annotate('All costs diverge\n(Resource Divergence Theorem)',
                xy=(15, exponential_cum[15]), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7))
    
    plt.tight_layout()
    plt.savefig('resource_divergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved resource_divergence.png")


def plot_oracle_hierarchy():
    """Plot the oracle hierarchy as concentric regions."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    
    num_levels = 7
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, num_levels))
    
    # Draw concentric circles representing hierarchy levels
    for i in range(num_levels - 1, -1, -1):
        radius = (i + 1) * 0.8
        circle = plt.Circle((0, 0), radius, fill=True, 
                           facecolor=colors[i], alpha=0.3,
                           edgecolor=colors[i], linewidth=2)
        ax.add_patch(circle)
        
        # Label the level
        angle = math.pi / 4
        x = (radius - 0.3) * math.cos(angle)
        y = (radius - 0.3) * math.sin(angle)
        ax.text(x, y, f'Level {i}', fontsize=11, fontweight='bold',
               ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))
    
    # Add witness points between levels
    for i in range(num_levels - 1):
        r = (i + 1) * 0.8 + 0.4
        angle = -math.pi / 3 + i * 0.15
        x = r * math.cos(angle)
        y = r * math.sin(angle)
        ax.plot(x, y, 'r*', markersize=15)
        ax.annotate(f'w_{i}', (x, y), fontsize=9, 
                   xytext=(10, 5), textcoords='offset points',
                   color='red', fontweight='bold')
    
    ax.set_xlim(-7, 7)
    ax.set_ylim(-7, 7)
    ax.set_aspect('equal')
    ax.set_title('Strict Oracle Hierarchy\n(Each level ⊊ next level, witnesses w_n separate them)',
                fontsize=14)
    ax.text(0, -6.5, 'The hierarchy never collapses: Level m ≠ Level n for m ≠ n',
           ha='center', fontsize=11, style='italic')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved oracle_hierarchy.png")


def plot_computability_classification():
    """Plot the computability classification of problems."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    
    # Create regions
    # Essentially computable (green, inner)
    # Accidentally computable levels 1-5 (blues/purples, concentric)
    # Undecidable (red, outer)
    
    categories = [
        ('Undecidable\n(no finite level)', 6.0, '#ff6666', 0.3),
        ('Accidentally\nComputable\n(Level 5)', 5.0, '#9966ff', 0.3),
        ('Accidentally\nComputable\n(Level 4)', 4.2, '#6699ff', 0.3),
        ('Accidentally\nComputable\n(Level 3)', 3.4, '#66bbff', 0.3),
        ('Accidentally\nComputable\n(Level 2)', 2.6, '#66ddff', 0.3),
        ('Accidentally\nComputable\n(Level 1)', 1.8, '#66ffdd', 0.3),
        ('Essentially\nComputable\n(Level 0)', 1.0, '#66ff66', 0.5),
    ]
    
    for label, radius, color, alpha in categories:
        circle = plt.Circle((0, 0), radius, fill=True,
                           facecolor=color, alpha=alpha,
                           edgecolor='black', linewidth=1.5)
        ax.add_patch(circle)
    
    # Add labels
    positions = [
        ('Essentially\nComputable', 0, 0, 11, 'black'),
        ('Level 1', 0, 1.4, 9, '#006600'),
        ('Level 2', 0, 2.2, 9, '#003366'),
        ('Level 3', 0, 3.0, 9, '#003366'),
        ('Level 4', 0, 3.8, 9, '#330066'),
        ('Level 5', 0, 4.6, 9, '#330066'),
        ('Undecidable', 0, 5.5, 10, '#660000'),
    ]
    
    for label, x, y, size, color in positions:
        ax.text(x, y, label, ha='center', va='center', fontsize=size,
               fontweight='bold', color=color)
    
    # Add arrows showing the separation
    ax.annotate('', xy=(4, -0.8), xytext=(1.2, -0.8),
               arrowprops=dict(arrowstyle='<->', color='red', lw=2))
    ax.text(2.6, -1.2, 'Separation\nTheorem', ha='center', fontsize=10,
           color='red', fontweight='bold')
    
    ax.set_xlim(-7, 7)
    ax.set_ylim(-7, 7)
    ax.set_aspect('equal')
    ax.set_title('Computability Classification\nAccidentally vs Essentially Computable',
                fontsize=14)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('computability_classification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved computability_classification.png")


if __name__ == "__main__":
    plot_resource_divergence()
    plot_oracle_hierarchy()
    plot_computability_classification()
    print("\nAll visualizations generated successfully.")
