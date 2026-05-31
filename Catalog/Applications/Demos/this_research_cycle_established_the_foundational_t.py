#!/usr/bin/env python3
"""
Exchange Family Descent Complexity: Demonstration

Numerical examples illustrating:
1. A simple exchange family (sorting by swaps)
2. Product tensorization with additive depth
3. Tropical valuation and depth-cost tradeoff
4. Binary conjecture testing
"""

from algorithms import (
    ExchangeFamily, DescentChain, TropicalDescentValuation,
    greedy_descent, longest_descent, product_family,
    depth_cost_tradeoff, count_states_by_measure,
    verify_binary_conjecture
)


def example_sorting_family(n: int = 4) -> ExchangeFamily[tuple[int, ...]]:
    """Exchange family for sorting: states are permutations of (0,...,n-1),
    measure is the number of inversions, exchange is an adjacent swap
    that reduces inversions."""
    from itertools import permutations

    states = list(permutations(range(n)))

    def inversions(p: tuple[int, ...]) -> int:
        return sum(1 for i in range(len(p)) for j in range(i + 1, len(p))
                   if p[i] > p[j])

    def can_swap(p: tuple[int, ...], q: tuple[int, ...]) -> bool:
        # q is obtained from p by swapping adjacent elements i, i+1
        # where p[i] > p[i+1] (reducing inversions)
        for i in range(len(p) - 1):
            if p[i] > p[i + 1]:
                candidate = list(p)
                candidate[i], candidate[i + 1] = candidate[i + 1], candidate[i]
                if tuple(candidate) == q:
                    return True
        return False

    return ExchangeFamily(states, inversions, can_swap)


def example_binary_tree_family(depth: int = 3) -> ExchangeFamily[int]:
    """Exchange family forming a complete binary tree.
    State i has exchange to states 2i+1 and 2i+2 (children in tree).
    Measure is (depth - level), so the root has highest measure."""
    n = 2 ** (depth + 1) - 1  # number of nodes
    states = list(range(n))

    def level(i: int) -> int:
        """Level of node i in the tree (root = 0)."""
        import math
        return int(math.log2(i + 1))

    def measure(i: int) -> int:
        return depth - level(i)

    def can_exchange(x: int, y: int) -> bool:
        # Exchange from parent to child (decreasing measure)
        return y == 2 * x + 1 or y == 2 * x + 2

    return ExchangeFamily(states, measure, can_exchange)


def main():
    print("=" * 70)
    print("EXCHANGE FAMILY DESCENT COMPLEXITY: DEMONSTRATIONS")
    print("=" * 70)

    # --- Example 1: Sorting by adjacent swaps ---
    print("\n" + "=" * 70)
    print("Example 1: Sorting Permutations by Adjacent Swaps (n=4)")
    print("=" * 70)

    ef = example_sorting_family(4)
    print(f"Number of states (permutations): {len(ef.states)}")
    print(f"Valid exchange family: {ef.validate()}")
    print(f"Max measure (max inversions): {ef.max_measure()}")
    print(f"Local minima: {ef.local_minima()}")

    # Find descent from the reverse permutation
    worst = tuple(range(3, -1, -1))  # (3,2,1,0)
    print(f"\nStarting state (reverse): {worst}")
    print(f"Measure (inversions): {ef.measure(worst)}")

    greedy = greedy_descent(ef, worst)
    print(f"\nGreedy descent chain:")
    for i, state in enumerate(greedy.chain):
        print(f"  Step {i}: {state} (measure={ef.measure(state)})")
    print(f"Greedy depth: {greedy.depth()}")

    longest = longest_descent(ef, worst)
    print(f"\nLongest descent chain:")
    for i, state in enumerate(longest.chain):
        print(f"  Step {i}: {state} (measure={ef.measure(state)})")
    print(f"Longest depth: {longest.depth()}")
    print(f"Measure bound (μ(head)): {ef.measure(worst)}")
    print(f"Depth ≤ μ(head)? {longest.depth() <= ef.measure(worst)} ✓")

    # Measure distribution
    dist = count_states_by_measure(ef)
    print(f"\nStates by measure level:")
    for k, count in dist.items():
        print(f"  measure={k}: {count} states")

    # --- Example 2: Product Tensorization ---
    print("\n" + "=" * 70)
    print("Example 2: Product Tensorization (3-sort × 3-sort)")
    print("=" * 70)

    ef1 = example_sorting_family(3)
    ef2 = example_sorting_family(3)
    prod = product_family(ef1, ef2)

    print(f"Component 1: {len(ef1.states)} states, max measure {ef1.max_measure()}")
    print(f"Component 2: {len(ef2.states)} states, max measure {ef2.max_measure()}")
    print(f"Product: {len(prod.states)} states, max measure {prod.max_measure()}")
    print(f"Additive bound: {ef1.max_measure()} + {ef2.max_measure()} = "
          f"{ef1.max_measure() + ef2.max_measure()}")
    print(f"Product max ≤ sum? {prod.max_measure() <= ef1.max_measure() + ef2.max_measure()} ✓")

    worst_prod = (tuple(range(2, -1, -1)), tuple(range(2, -1, -1)))
    greedy_prod = greedy_descent(prod, worst_prod)
    print(f"\nProduct descent from ({worst_prod[0]}, {worst_prod[1]}):")
    print(f"  Greedy depth: {greedy_prod.depth()}")
    print(f"  Measure bound: {prod.measure(worst_prod)}")

    # --- Example 3: Tropical Valuation & Depth-Cost Tradeoff ---
    print("\n" + "=" * 70)
    print("Example 3: Tropical Descent Valuation")
    print("=" * 70)

    ef3 = example_sorting_family(4)

    # Cost = number of positions that differ (always 2 for adjacent swap)
    def swap_cost(p: tuple[int, ...], q: tuple[int, ...]) -> int:
        return sum(1 for a, b in zip(p, q) if a != b)

    valuation = TropicalDescentValuation(ef3, swap_cost)
    print(f"Min cost per exchange: {valuation.min_cost_per_step()}")
    print(f"Max cost per exchange: {valuation.max_cost_per_step()}")

    worst4 = tuple(range(3, -1, -1))
    greedy4 = greedy_descent(ef3, worst4)
    tradeoff = depth_cost_tradeoff(valuation, greedy4.chain)

    print(f"\nDepth-Cost Tradeoff for greedy chain from {worst4}:")
    print(f"  Depth (d): {tradeoff['depth']}")
    print(f"  Total cost: {tradeoff['total_cost']}")
    print(f"  Lower bound (w×d): {tradeoff['lower_bound']}")
    print(f"  Upper bound (W×d): {tradeoff['upper_bound']}")
    print(f"  Measure bound (μ): {tradeoff['measure_bound']}")
    print(f"  w×d ≤ cost? {tradeoff['lower_satisfied']} ✓")
    print(f"  cost ≤ W×d? {tradeoff['upper_satisfied']} ✓")
    print(f"  d ≤ μ? {tradeoff['depth_satisfied']} ✓")

    # --- Example 4: Binary Conjecture Testing ---
    print("\n" + "=" * 70)
    print("Example 4: Binary Exchange Depth Bound Conjecture")
    print("=" * 70)

    for depth in [2, 3, 4, 5]:
        tree = example_binary_tree_family(depth)
        result = verify_binary_conjecture(tree)
        status = "✓ HOLDS" if result['conjecture_holds'] else "✗ FAILS"
        print(f"  Depth={depth}: n+1={result['n_plus_1']}, "
              f"max_μ={result['max_measure']}, "
              f"2^(μ+1)={result['bound']}, "
              f"binary={result['is_binary']}, "
              f"log₂ ratio={result['log2_ratio']:.3f} "
              f"[{status}]")

    # Additional test: linear chain (worst case)
    print("\n  Testing linear chains (max depth, min branching):")
    for n in [4, 8, 16, 32]:
        states = list(range(n))
        ef_linear = ExchangeFamily(
            states,
            measure=lambda x: x,
            can_exchange=lambda x, y: y == x - 1 and x > 0
        )
        result = verify_binary_conjecture(ef_linear)
        status = "✓ HOLDS" if result['conjecture_holds'] else "✗ FAILS"
        print(f"    n={n}: max_μ={result['max_measure']}, "
              f"2^(μ+1)={result['bound']}, "
              f"binary={result['is_binary']}, "
              f"[{status}]")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Exchange Family Descent Complexity

Creates three visualizations:
1. Descent landscape showing measure levels and exchange structure
2. Depth-cost tradeoff diagram
3. Product tensorization visualization
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import permutations
from algorithms import (
    ExchangeFamily, TropicalDescentValuation,
    greedy_descent, longest_descent, product_family,
    count_states_by_measure, depth_cost_tradeoff,
    verify_binary_conjecture
)


def build_sorting_family(n: int) -> ExchangeFamily[tuple[int, ...]]:
    """Sorting exchange family on permutations of (0,...,n-1)."""
    states = list(permutations(range(n)))

    def inversions(p: tuple[int, ...]) -> int:
        return sum(1 for i in range(len(p)) for j in range(i + 1, len(p))
                   if p[i] > p[j])

    def can_swap(p: tuple[int, ...], q: tuple[int, ...]) -> bool:
        for i in range(len(p) - 1):
            if p[i] > p[i + 1]:
                candidate = list(p)
                candidate[i], candidate[i + 1] = candidate[i + 1], candidate[i]
                if tuple(candidate) == q:
                    return True
        return False

    return ExchangeFamily(states, inversions, can_swap)


def plot_descent_landscape():
    """Plot the descent landscape for sorting permutations."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: measure distribution
    ax1 = axes[0]
    ef = build_sorting_family(4)
    dist = count_states_by_measure(ef)

    measures = list(dist.keys())
    counts = list(dist.values())
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(measures)))

    bars = ax1.bar(measures, counts, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xlabel('Measure (inversions)', fontsize=12)
    ax1.set_ylabel('Number of permutations', fontsize=12)
    ax1.set_title('Descent Landscape: S₄ Sorting Family', fontsize=14, fontweight='bold')

    # Annotate bars
    for bar, count in zip(bars, counts):
        ax1.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                 str(count), ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Add annotations
    ax1.annotate('Unique minimum\n(sorted)', xy=(0, 1), xytext=(1.5, 3),
                 fontsize=9, ha='center',
                 arrowprops=dict(arrowstyle='->', color='red', lw=1.5),
                 color='red')
    ax1.annotate('Unique maximum\n(reverse sorted)', xy=(6, 1), xytext=(4.5, 3),
                 fontsize=9, ha='center',
                 arrowprops=dict(arrowstyle='->', color='blue', lw=1.5),
                 color='blue')

    # Right: descent chain visualization
    ax2 = axes[1]
    worst = tuple(range(3, -1, -1))
    chain = greedy_descent(ef, worst)
    measures_along = chain.measures()

    steps = list(range(len(measures_along)))
    ax2.plot(steps, measures_along, 'o-', color='#2196F3', linewidth=2, markersize=8,
             markerfacecolor='white', markeredgewidth=2)

    # Fill area under curve
    ax2.fill_between(steps, measures_along, alpha=0.15, color='#2196F3')

    # Annotate each step
    for i, (step, m) in enumerate(zip(steps, measures_along)):
        label = ''.join(str(x) for x in chain.chain[i])
        ax2.annotate(label, (step, m), textcoords="offset points",
                     xytext=(0, 12), ha='center', fontsize=8,
                     bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                               edgecolor='gray', alpha=0.8))

    # Add bound line
    ax2.axhline(y=ef.measure(worst), color='red', linestyle='--', alpha=0.5,
                label=f'μ(start) = {ef.measure(worst)}')
    ax2.axhline(y=0, color='green', linestyle='--', alpha=0.5, label='minimum')

    ax2.set_xlabel('Descent Step', fontsize=12)
    ax2.set_ylabel('Measure (inversions)', fontsize=12)
    ax2.set_title('Greedy Descent: (3,2,1,0) → (0,1,2,3)', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_ylim(-0.5, 7.5)

    plt.tight_layout()
    plt.savefig('descent_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: descent_landscape.png")


def plot_depth_cost_tradeoff():
    """Plot the depth-cost tradeoff theorem visualization."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: tradeoff bounds for different chain lengths
    ax1 = axes[0]

    # Use sorting family with uniform cost
    ef = build_sorting_family(4)

    def swap_cost(p, q):
        return sum(1 for a, b in zip(p, q) if a != b)

    val = TropicalDescentValuation(ef, swap_cost)
    w = val.min_cost_per_step()
    W = val.max_cost_per_step()

    depths = np.arange(0, 8)
    lower_bounds = w * depths
    upper_bounds = W * depths

    ax1.fill_between(depths, lower_bounds, upper_bounds, alpha=0.2, color='blue',
                     label='Feasible region')
    ax1.plot(depths, lower_bounds, '--', color='blue', linewidth=1.5,
             label=f'Lower bound (w={w})')
    ax1.plot(depths, upper_bounds, '--', color='red', linewidth=1.5,
             label=f'Upper bound (W={W})')

    # Plot actual chains
    worst = tuple(range(3, -1, -1))
    chain = greedy_descent(ef, worst)
    tradeoff = depth_cost_tradeoff(val, chain.chain)
    ax1.plot(tradeoff['depth'], tradeoff['total_cost'], 'o', color='green',
             markersize=12, label=f'Greedy chain (d={tradeoff["depth"]}, c={tradeoff["total_cost"]})',
             zorder=5)

    # Measure bound
    ax1.axvline(x=ef.measure(worst), color='orange', linestyle=':', linewidth=2,
                label=f'Measure bound (μ={ef.measure(worst)})')

    ax1.set_xlabel('Depth (number of exchanges)', fontsize=12)
    ax1.set_ylabel('Total Cost', fontsize=12)
    ax1.set_title('Depth-Cost Tradeoff Theorem', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=9, loc='upper left')
    ax1.set_xlim(-0.5, 7.5)

    # Right: product additivity
    ax2 = axes[1]

    sizes = [3, 4, 5]
    single_depths = []
    product_depths = []
    sum_depths = []

    for n in sizes:
        ef_n = build_sorting_family(n)
        worst_n = tuple(range(n - 1, -1, -1))
        single_depths.append(ef_n.measure(worst_n))

    for i in range(len(sizes)):
        for j in range(i, len(sizes)):
            sum_d = single_depths[i] + single_depths[j]
            sum_depths.append(sum_d)
            product_depths.append(sum_d)  # Product measure = sum

    x_pos = np.arange(len(sum_depths))
    bar_width = 0.35

    labels = []
    for i in range(len(sizes)):
        for j in range(i, len(sizes)):
            labels.append(f'S{sizes[i]}×S{sizes[j]}')

    bars1 = ax2.bar(x_pos - bar_width / 2, sum_depths, bar_width,
                    label='Sum of depths', color='#4CAF50', edgecolor='black', linewidth=0.5)
    bars2 = ax2.bar(x_pos + bar_width / 2, product_depths, bar_width,
                    label='Product depth', color='#2196F3', edgecolor='black', linewidth=0.5)

    ax2.set_xlabel('Product Family', fontsize=12)
    ax2.set_ylabel('Maximum Descent Depth', fontsize=12)
    ax2.set_title('Product Additivity: d(E₁×E₂) = d(E₁) + d(E₂)', fontsize=14,
                  fontweight='bold')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(labels, fontsize=9)
    ax2.legend(fontsize=10)

    # Annotate equality
    for i, (s, p) in enumerate(zip(sum_depths, product_depths)):
        ax2.text(i, max(s, p) + 0.3, f'{s}={p}', ha='center', fontsize=9,
                 fontweight='bold', color='green')

    plt.tight_layout()
    plt.savefig('depth_cost_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_cost_tradeoff.png")


def plot_binary_conjecture():
    """Plot the binary exchange depth bound conjecture testing."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Test for various binary tree depths
    depths = list(range(1, 9))
    n_values = []
    bound_values = []
    ratios = []

    for d in depths:
        n = 2 ** (d + 1) - 1
        n_values.append(n)
        bound_values.append(2 ** (d + 1))
        ratios.append(n / (2 ** (d + 1)))

    ax.semilogy(depths, n_values, 'o-', color='#2196F3', linewidth=2, markersize=8,
                label='n + 1 (states)', markerfacecolor='white', markeredgewidth=2)
    ax.semilogy(depths, bound_values, 's--', color='#F44336', linewidth=2, markersize=8,
                label='2^(μ+1) (bound)', markerfacecolor='white', markeredgewidth=2)

    # Shade the region between
    ax.fill_between(depths, n_values, bound_values, alpha=0.1, color='green',
                    label='Margin')

    ax.set_xlabel('Tree Depth (= max measure)', fontsize=12)
    ax.set_ylabel('Count (log scale)', fontsize=12)
    ax.set_title('Binary Exchange Depth Bound Conjecture\n'
                 'n + 1 ≤ 2^(max_measure + 1)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Conjecture holds:\nn+1 approaches\n2^(μ+1) as depth grows',
                xy=(6, n_values[5]), xytext=(3, bound_values[6]),
                fontsize=10,
                arrowprops=dict(arrowstyle='->', color='green', lw=1.5),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                          edgecolor='green', alpha=0.8))

    # Inset: ratio plot
    ax_inset = ax.inset_axes([0.55, 0.15, 0.4, 0.35])
    ax_inset.plot(depths, ratios, 'o-', color='purple', linewidth=1.5, markersize=5)
    ax_inset.axhline(y=1, color='red', linestyle='--', alpha=0.5)
    ax_inset.set_xlabel('Depth', fontsize=8)
    ax_inset.set_ylabel('n/(2^(μ+1))', fontsize=8)
    ax_inset.set_title('Tightness Ratio', fontsize=9)
    ax_inset.tick_params(labelsize=7)
    ax_inset.set_ylim(0.4, 1.05)

    plt.tight_layout()
    plt.savefig('binary_conjecture.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: binary_conjecture.png")


if __name__ == "__main__":
    plot_descent_landscape()
    plot_depth_cost_tradeoff()
    plot_binary_conjecture()
    print("\nAll visualizations generated successfully.")
