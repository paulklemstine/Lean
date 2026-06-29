"""
Demonstration of Reduction-Enriched Complexity Hierarchies.

This script demonstrates the key concepts from the formalized framework:
1. Construction of a concrete reduction hierarchy (the oracle tower)
2. Verification of diagonal separation
3. Computation of dense chains
4. Simulation of the information gap theorem
"""

from typing import Callable


def oracle_tower(level: int) -> Callable[[int], bool]:
    """Construct the oracle tower at a given level.

    Level 0: constant False function
    Level n+1: adds the diagonal of level n as program 0
    """
    if level == 0:
        return lambda k: False
    else:
        prev = oracle_tower(level - 1)
        prev_diag_val = not prev(0)  # diag evaluated at 0 for simplicity

        def tower_fn(k: int) -> bool:
            if k == 0:
                # The diagonal of the previous level
                return not oracle_tower(level - 1)(k)
            else:
                return oracle_tower(level - 1)(k - 1)
        return tower_fn


def diagonal(f: Callable[[int], Callable[[int], bool]]) -> Callable[[int], bool]:
    """The diagonal language: flip f(n)(n) for each n."""
    return lambda n: not f(n)(n)


def demonstrate_diagonal_separation():
    """Show that the diagonal differs from every enumerated function."""
    print("=" * 60)
    print("DIAGONAL SEPARATION DEMONSTRATION")
    print("=" * 60)

    # Create a simple enumeration of functions
    def enum(k: int) -> Callable[[int], bool]:
        """Function k maps n to whether n mod (k+1) == 0."""
        return lambda n: (n % (k + 1) == 0)

    diag = diagonal(lambda k: enum(k))

    print("\nEnumeration f(k)(n) = (n mod (k+1) == 0):")
    for k in range(5):
        vals = [enum(k)(n) for n in range(8)]
        print(f"  f({k}): {vals}")

    print(f"\nDiagonal values diag(n) = NOT f(n)(n):")
    diag_vals = [diag(n) for n in range(8)]
    print(f"  diag: {diag_vals}")

    print("\nVerification that diag differs from each f(k):")
    for k in range(5):
        fk_at_k = enum(k)(k)
        diag_at_k = diag(k)
        print(f"  f({k})({k}) = {fk_at_k}, diag({k}) = {diag_at_k}, differ = {fk_at_k != diag_at_k}")


def demonstrate_oracle_tower():
    """Show the oracle tower alternation pattern."""
    print("\n" + "=" * 60)
    print("ORACLE TOWER ALTERNATION PATTERN")
    print("=" * 60)

    print("\nDiagonal value at input 0 for each oracle level:")
    for level in range(8):
        tower = oracle_tower(level)
        diag_val = not tower(0)
        print(f"  Level {level}: diag(oracleTower {level})(0) = {diag_val}")

    print("\nPattern: True, False, True, False, ... (alternating)")
    print("Each level genuinely changes the computational landscape.")


def demonstrate_reduction_chain():
    """Demonstrate a concrete reduction chain with strictly increasing levels."""
    print("\n" + "=" * 60)
    print("REDUCTION CHAIN DEMONSTRATION")
    print("=" * 60)

    # Model: problems are (level, index) pairs
    # Reduction: (l1, i1) reduces to (l2, i2) iff l1 <= l2
    chain_length = 10
    chain = [(i, 0) for i in range(chain_length)]

    print(f"\nChain of {chain_length} problems with strictly increasing levels:")
    for i, (level, idx) in enumerate(chain):
        reduces_to_next = "→" if i < chain_length - 1 else ""
        print(f"  Problem ({level}, {idx}) [level {level}] {reduces_to_next}")

    print(f"\nLevel sequence: {[p[0] for p in chain]}")
    print(f"Strictly monotone: {all(chain[i][0] < chain[i+1][0] for i in range(len(chain)-1))}")


def demonstrate_information_gap():
    """Demonstrate the information gap theorem with a concrete measure."""
    print("\n" + "=" * 60)
    print("INFORMATION GAP THEOREM")
    print("=" * 60)

    # Concrete information measure: info(p) = log2(level + 1) + level
    import math

    def info(level: int) -> float:
        return math.log2(level + 1) + level

    print("\nInformation measure: info(level) = log2(level + 1) + level")
    print("\nLevel | Info       | Gap from previous")
    print("-" * 45)
    prev_info = 0.0
    for level in range(10):
        i = info(level)
        gap = i - prev_info
        print(f"  {level:3d}  | {i:8.4f}   | {gap:8.4f}")
        prev_info = i

    print("\nThe information gap is always positive (strict monotonicity).")
    print("This mirrors our formal information_gap theorem.")


def demonstrate_ladner():
    """Demonstrate the abstract Ladner theorem."""
    print("\n" + "=" * 60)
    print("ABSTRACT LADNER THEOREM")
    print("=" * 60)

    # Dense hierarchy: every level from 0 to 10 is populated
    problems = {level: [f"problem_{level}_{i}" for i in range(3)]
                for level in range(11)}

    m, n = 2, 8
    print(f"\nLevels m={m} and n={n} (gap = {n-m} ≥ 2)")
    print(f"Dense hierarchy: every level {m+1}..{n-1} is populated")

    print(f"\nIntermediate problems (m < level < n):")
    for level in range(m + 1, n):
        print(f"  Level {level}: {problems[level][0]} (intermediate)")

    print(f"\nTotal intermediate levels: {n - m - 1}")
    print("The abstract Ladner theorem guarantees these exist.")


def demonstrate_relativization():
    """Demonstrate the relativization obstruction."""
    print("\n" + "=" * 60)
    print("RELATIVIZATION OBSTRUCTION")
    print("=" * 60)

    # Two oracles that reverse the ordering of problems A and B
    print("\nProblem A (level 3) and Problem B (level 5)")
    print("\nOracle O1: augments A to level 4, B to level 7")
    print("  → A is easier than B under O1")
    print("\nOracle O2: augments A to level 8, B to level 6")
    print("  → B is easier than A under O2")
    print("\nConclusion: No oracle-uniform proof can determine")
    print("the relative complexity of A and B.")
    print("\nThis is the abstract Baker-Gill-Solovay phenomenon.")


if __name__ == "__main__":
    demonstrate_diagonal_separation()
    demonstrate_oracle_tower()
    demonstrate_reduction_chain()
    demonstrate_information_gap()
    demonstrate_ladner()
    demonstrate_relativization()

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


"""
Visualization: Reduction Hierarchy with Complete Elements and Chains.

Standalone matplotlib script showing the structure of a reduction hierarchy.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def generate_hierarchy_data(num_levels: int, problems_per_level: int):
    """Generate problem positions for visualization."""
    problems = []
    for level in range(num_levels):
        for i in range(problems_per_level):
            x = i - (problems_per_level - 1) / 2.0
            problems.append({
                'level': level,
                'index': i,
                'x': x + np.random.normal(0, 0.1),
                'y': level,
                'is_complete': (i == problems_per_level - 1),  # last one is complete
            })
    return problems


def draw_reductions(ax, problems, num_levels):
    """Draw reduction arrows between problems."""
    for p in problems:
        if p['level'] < num_levels - 1:
            # Find problems at next level
            next_level = [q for q in problems if q['level'] == p['level'] + 1]
            for q in next_level:
                ax.annotate('', xy=(q['x'], q['y'] - 0.15),
                           xytext=(p['x'], p['y'] + 0.15),
                           arrowprops=dict(arrowstyle='->', color='lightgray',
                                          alpha=0.3, lw=0.5))


def main():
    num_levels = 8
    problems_per_level = 5
    np.random.seed(42)

    problems = generate_hierarchy_data(num_levels, problems_per_level)

    fig, axes = plt.subplots(1, 3, figsize=(18, 8))

    # Panel 1: Full hierarchy with complete elements
    ax1 = axes[0]
    ax1.set_title('Reduction Hierarchy\nwith Complete Elements', fontsize=14, fontweight='bold')

    draw_reductions(ax1, problems, num_levels)

    for p in problems:
        color = '#e74c3c' if p['is_complete'] else '#3498db'
        size = 120 if p['is_complete'] else 60
        marker = '*' if p['is_complete'] else 'o'
        ax1.scatter(p['x'], p['y'], c=color, s=size, marker=marker,
                   zorder=5, edgecolors='black', linewidth=0.5)

    ax1.set_ylabel('Level (Complexity)', fontsize=12)
    ax1.set_xlabel('Problem Space', fontsize=12)
    ax1.set_yticks(range(num_levels))

    complete_patch = mpatches.Patch(color='#e74c3c', label='Complete element')
    normal_patch = mpatches.Patch(color='#3498db', label='Regular problem')
    ax1.legend(handles=[complete_patch, normal_patch], loc='upper left')

    # Panel 2: Dense chain
    ax2 = axes[1]
    ax2.set_title('Dense Chain\n(Hardness Condensation)', fontsize=14, fontweight='bold')

    chain = [(0, i) for i in range(num_levels)]
    chain_x = [0] * num_levels
    chain_y = list(range(num_levels))

    for i in range(num_levels):
        ax2.scatter(chain_x[i], chain_y[i], c='#2ecc71', s=150,
                   marker='s', zorder=5, edgecolors='black', linewidth=1)
        ax2.text(0.3, chain_y[i], f'Level {i}', fontsize=10, va='center')

        if i < num_levels - 1:
            ax2.annotate('', xy=(0, chain_y[i+1] - 0.15),
                        xytext=(0, chain_y[i] + 0.15),
                        arrowprops=dict(arrowstyle='->', color='#27ae60',
                                       lw=2))

    ax2.set_ylabel('Level (Complexity)', fontsize=12)
    ax2.set_xlim(-1, 2)
    ax2.set_yticks(range(num_levels))

    # Panel 3: Relativization obstruction
    ax3 = axes[2]
    ax3.set_title('Relativization Obstruction\n(Baker-Gill-Solovay)', fontsize=14, fontweight='bold')

    # Two problems under two different oracles
    oracle_names = ['Oracle O₁', 'Oracle O₂']
    problem_a = [3, 7]  # levels under O1, O2
    problem_b = [6, 4]  # levels under O1, O2

    x = np.arange(len(oracle_names))
    width = 0.35

    bars_a = ax3.bar(x - width/2, problem_a, width, label='Problem A',
                     color='#3498db', edgecolor='black')
    bars_b = ax3.bar(x + width/2, problem_b, width, label='Problem B',
                     color='#e74c3c', edgecolor='black')

    ax3.set_ylabel('Level (Complexity)', fontsize=12)
    ax3.set_xticks(x)
    ax3.set_xticklabels(oracle_names, fontsize=12)
    ax3.legend()

    # Add annotations
    ax3.annotate('A < B', xy=(0, 6.5), fontsize=11, ha='center',
                color='#27ae60', fontweight='bold')
    ax3.annotate('B < A', xy=(1, 7.5), fontsize=11, ha='center',
                color='#e74c3c', fontweight='bold')
    ax3.annotate('⟹ No oracle-uniform\nseparation possible!',
                xy=(0.5, -0.5), fontsize=10, ha='center',
                style='italic', color='gray',
                transform=ax3.get_xaxis_transform())

    plt.tight_layout()
    plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved hierarchy_visualization.png")


if __name__ == "__main__":
    main()
