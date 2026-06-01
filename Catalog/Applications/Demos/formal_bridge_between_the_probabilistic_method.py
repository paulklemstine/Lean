#!/usr/bin/env python3
"""
Tropical-Probabilistic Bridge: Demonstration

Demonstrates the core ideas connecting the probabilistic method
to tropical (min-plus) algebra through concrete numerical examples.
"""

import random
import math
from typing import List, Tuple, Optional

# ============================================================
# Example 1: Tropical Witness Theorem in action
# ============================================================

def tropical_witness_demo():
    """
    Demonstrate the Tropical Witness Theorem:
    If sum(costs) < |universe|, a zero-cost element exists.
    """
    print("=" * 60)
    print("DEMO 1: Tropical Witness Theorem")
    print("=" * 60)

    # Universe: all 2-colorings of edges of K_5
    # Cost: number of monochromatic triangles
    n = 5
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    triangles = [(i, j, k) for i in range(n)
                 for j in range(i+1, n) for k in range(j+1, n)]

    num_colorings = 2 ** len(edges)
    total_cost = 0
    witness = None

    # Sample random colorings and count monochromatic triangles
    for trial in range(min(num_colorings, 1000)):
        if num_colorings <= 1024:
            # Enumerate all colorings
            coloring = [(trial >> i) & 1 for i in range(len(edges))]
        else:
            coloring = [random.randint(0, 1) for _ in edges]

        # Count monochromatic triangles
        cost = 0
        for (i, j, k) in triangles:
            eij = edges.index((i, j))
            eik = edges.index((i, k))
            ejk = edges.index((j, k))
            if coloring[eij] == coloring[eik] == coloring[ejk]:
                cost += 1

        total_cost += cost
        if cost == 0 and witness is None:
            witness = coloring

    if num_colorings <= 1024:
        avg_cost = total_cost / num_colorings
        print(f"  K_{n}: {len(edges)} edges, {len(triangles)} triangles")
        print(f"  Total colorings: {num_colorings}")
        print(f"  Sum of costs: {total_cost}")
        print(f"  Average cost: {avg_cost:.4f}")
        print(f"  First moment bound: avg < 1? {avg_cost < 1}")
        if witness:
            print(f"  Zero-cost witness found: {witness}")
        else:
            print(f"  No zero-cost witness (expected if avg >= 1)")
    print()


# ============================================================
# Example 2: LLL Product Positivity
# ============================================================

def lll_product_demo():
    """
    Demonstrate LLL Product Positivity:
    If all x_i in (0,1), then prod(1-x_i) > 0.
    """
    print("=" * 60)
    print("DEMO 2: LLL Product Positivity")
    print("=" * 60)

    test_cases = [
        [0.1, 0.2, 0.3],
        [0.5, 0.5, 0.5, 0.5],
        [0.99, 0.99, 0.99],
        [0.01] * 100,
        [0.5] * 20,
    ]

    for xs in test_cases:
        product = 1.0
        for x in xs:
            product *= (1 - x)
        trop_sum = sum(-math.log(1-x) for x in xs)
        print(f"  x = {xs[:5]}{'...' if len(xs) > 5 else ''} (n={len(xs)})")
        print(f"    prod(1-x_i) = {product:.10f} > 0? {product > 0}")
        print(f"    Tropical sum = {trop_sum:.4f}")
        half_bound = 0.5 ** len(xs) if all(x <= 0.5 for x in xs) else None
        if half_bound is not None:
            print(f"    (1/2)^n bound = {half_bound:.10f}, satisfied? {product >= half_bound - 1e-15}")
        print()


# ============================================================
# Example 3: MinPlus-Arithmetic Duality
# ============================================================

def minplus_duality_demo():
    """
    Demonstrate the duality: sum < |universe| <=> min = 0.
    """
    print("=" * 60)
    print("DEMO 3: MinPlus-Arithmetic Duality")
    print("=" * 60)

    test_cases = [
        ("Students/questions", [0, 1, 2, 0, 1, 0, 3, 0, 1, 2]),
        ("All nonzero", [1, 2, 3, 4, 5]),
        ("Just barely works", [0, 1, 1, 1, 1, 1, 1, 1, 1, 0]),
        ("High cost", [10, 20, 30, 0, 15]),
    ]

    for name, costs in test_cases:
        n = len(costs)
        total = sum(costs)
        minimum = min(costs)
        avg = total / n
        print(f"  {name}: costs = {costs}")
        print(f"    |universe| = {n}, sum = {total}, avg = {avg:.2f}")
        print(f"    sum < |universe|? {total < n}")
        print(f"    min(costs) = {minimum} (= 0? {minimum == 0})")
        print(f"    Duality holds: (sum < n) => (min = 0)? "
              f"{'N/A (premise false)' if total >= n else minimum == 0}")
        print()


# ============================================================
# Example 4: Ramsey Bounds via Tropical Counting
# ============================================================

def ramsey_bounds_demo():
    """
    Demonstrate Erdős's Ramsey lower bound via tropical counting.
    """
    print("=" * 60)
    print("DEMO 4: Ramsey Lower Bounds (Tropical Counting)")
    print("=" * 60)

    for k in range(3, 10):
        # The bound: R(k,k) > n if 2 * C(n,k) < 2^C(k,2)
        edges_in_clique = k * (k - 1) // 2
        threshold = 2 ** edges_in_clique

        # Find largest n satisfying the bound
        best_n = 1
        for n in range(1, 1000):
            lhs = 2 * math.comb(n, k)
            if lhs < threshold:
                best_n = n
            else:
                break

        tropical_cost = math.log2(2 * math.comb(best_n, k)) if math.comb(best_n, k) > 0 else 0
        tropical_threshold = edges_in_clique  # = log2(2^{C(k,2)})

        print(f"  k={k}: R({k},{k}) > {best_n}")
        print(f"    C(k,2) = {edges_in_clique}, threshold = 2^{edges_in_clique} = {threshold}")
        print(f"    Tropical cost at n={best_n}: {tropical_cost:.2f} < {tropical_threshold} ✓")
        print(f"    Erdős bound: R({k},{k}) ≥ {best_n + 1}")
        print(f"    Approx 2^(k/2) = {2**(k/2):.1f}")
        print()


# ============================================================
# Example 5: Tropical Deletion Method
# ============================================================

def deletion_method_demo():
    """
    Demonstrate the deletion method in tropical language.
    """
    print("=" * 60)
    print("DEMO 5: Tropical Deletion Method")
    print("=" * 60)

    # Example: random graph, cost = number of triangles containing each vertex
    n = 20
    p = 0.5
    random.seed(42)

    # Generate random graph
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if random.random() < p:
                adj[i][j] = adj[j][i] = True

    # Count triangles per vertex
    costs = [0] * n
    for i in range(n):
        for j in range(i+1, n):
            for k in range(j+1, n):
                if adj[i][j] and adj[j][k] and adj[i][k]:
                    costs[i] += 1
                    costs[j] += 1
                    costs[k] += 1

    total_cost = sum(costs)
    avg_cost = total_cost / n
    min_cost = min(costs)

    print(f"  Random graph G({n}, {p}):")
    print(f"    Costs (triangles per vertex): {costs}")
    print(f"    Sum = {total_cost}, Avg = {avg_cost:.1f}")
    print(f"    Min cost = {min_cost} (vertex {costs.index(min_cost)})")
    print(f"    Deletion bound: δ = ⌊avg⌋ = {int(avg_cost)}")
    print(f"    ∃ vertex with ≤ {int(avg_cost)} triangles? Yes (min = {min_cost})")
    print()


if __name__ == "__main__":
    tropical_witness_demo()
    lll_product_demo()
    minplus_duality_demo()
    ramsey_bounds_demo()
    deletion_method_demo()


#!/usr/bin/env python3
"""
Visualization: Tropical-Probabilistic Bridge

Generates plots showing the duality between arithmetic and tropical moments,
LLL product bounds, and Ramsey lower bounds.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_minplus_duality():
    """Plot the MinPlus-Arithmetic Duality: sum vs minimum."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: scatter of (sum/n, min) for random cost vectors
    np.random.seed(42)
    n = 20
    num_samples = 500

    sums = []
    mins = []
    colors = []
    for _ in range(num_samples):
        # Mix of vectors with and without zeros
        if np.random.random() < 0.5:
            costs = np.random.randint(0, 5, size=n)
        else:
            costs = np.random.randint(1, 5, size=n)
        sums.append(np.sum(costs) / n)
        mins.append(np.min(costs))
        colors.append('forestgreen' if np.min(costs) == 0 else 'crimson')

    ax = axes[0]
    ax.scatter(sums, mins, c=colors, alpha=0.5, s=30, edgecolors='none')
    ax.axvline(x=1, color='navy', linestyle='--', linewidth=2, label='avg = 1 threshold')
    ax.set_xlabel('Average cost (∑f / n)', fontsize=12)
    ax.set_ylabel('Minimum cost (min f)', fontsize=12)
    ax.set_title('MinPlus-Arithmetic Duality', fontsize=14)
    ax.legend(fontsize=10)
    ax.annotate('Zero-cost element\nguaranteed here',
                xy=(0.5, 0), xytext=(0.3, 1.5),
                fontsize=9, color='forestgreen',
                arrowprops=dict(arrowstyle='->', color='forestgreen'))

    # Right: LLL product bound
    ax = axes[1]
    ns = range(1, 51)

    for x_val in [0.1, 0.2, 0.3, 0.4, 0.5]:
        products = [(1 - x_val) ** n for n in ns]
        ax.semilogy(ns, products, label=f'x = {x_val}', linewidth=2)

    half_bounds = [0.5 ** n for n in ns]
    ax.semilogy(ns, half_bounds, 'k--', linewidth=2, label='(1/2)^n bound')
    ax.set_xlabel('Number of events (n)', fontsize=12)
    ax.set_ylabel('Product ∏(1 - xᵢ)', fontsize=12)
    ax.set_title('LLL Product Positivity', fontsize=14)
    ax.legend(fontsize=9, loc='upper right')
    ax.set_ylim(1e-16, 1.5)

    plt.tight_layout()
    plt.savefig('tropical_bridge_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_bridge_duality.png")


def plot_ramsey_bounds():
    """Plot Ramsey lower bounds from tropical counting."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Ramsey bounds vs 2^(k/2)
    ax = axes[0]
    ks = range(3, 15)
    erdos_bounds = []
    sqrt_bounds = []

    for k in ks:
        edges = k * (k - 1) // 2
        threshold = 2 ** edges
        best_n = 1
        for n in range(1, 100000):
            if 2 * math.comb(n, k) < threshold:
                best_n = n
            else:
                break
        erdos_bounds.append(best_n)
        sqrt_bounds.append(2 ** (k / 2))

    ax.semilogy(list(ks), erdos_bounds, 'bo-', label='Erdős bound', linewidth=2, markersize=8)
    ax.semilogy(list(ks), sqrt_bounds, 'r--', label='2^(k/2)', linewidth=2)
    ax.set_xlabel('Clique size k', fontsize=12)
    ax.set_ylabel('Lower bound on R(k,k)', fontsize=12)
    ax.set_title('Ramsey Lower Bounds via Tropical Counting', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: Tropical cost landscape for k=3
    ax = axes[1]
    k = 3
    edges_in_clique = 3
    ns = range(2, 30)
    tropical_costs = []

    for n in ns:
        cn_k = math.comb(n, k)
        if cn_k > 0:
            cost = math.log2(2 * cn_k)
        else:
            cost = 0
        tropical_costs.append(cost)

    ax.plot(list(ns), tropical_costs, 'b-', linewidth=2, label='log₂(2·C(n,3))')
    ax.axhline(y=edges_in_clique, color='r', linestyle='--',
               linewidth=2, label=f'Threshold = C(3,2) = {edges_in_clique}')
    ax.fill_between(list(ns), 0, tropical_costs,
                    where=[c < edges_in_clique for c in tropical_costs],
                    alpha=0.2, color='green', label='Good coloring exists')
    ax.set_xlabel('Number of vertices n', fontsize=12)
    ax.set_ylabel('Tropical cost', fontsize=12)
    ax.set_title('Tropical Cost Landscape (k=3)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('ramsey_tropical_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ramsey_tropical_bounds.png")


def plot_tropical_deletion():
    """Plot the tropical deletion method: cost distribution."""
    fig, ax = plt.subplots(figsize=(10, 5))

    np.random.seed(42)
    n = 50

    # Simulate costs from a random graph triangle counting
    costs = np.random.poisson(lam=3, size=n)
    costs[np.random.choice(n, size=5, replace=False)] = 0  # Add some zeros

    sorted_costs = np.sort(costs)
    avg_cost = np.mean(costs)

    bars = ax.bar(range(n), sorted_costs, color='steelblue', alpha=0.7, edgecolor='navy')

    # Color bars below threshold
    for i, (bar, c) in enumerate(zip(bars, sorted_costs)):
        if c <= int(avg_cost):
            bar.set_color('forestgreen')
            bar.set_alpha(0.8)

    ax.axhline(y=avg_cost, color='red', linestyle='--', linewidth=2,
               label=f'Average cost δ = {avg_cost:.1f}')
    ax.axhline(y=0, color='black', linewidth=0.5)

    ax.set_xlabel('Elements (sorted by cost)', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Tropical Deletion Method: Finding Low-Cost Elements', fontsize=14)
    ax.legend(fontsize=11)
    ax.annotate('Elements with cost ≤ δ\n(guaranteed to exist)',
                xy=(2, sorted_costs[2] + 0.3), xytext=(10, max(costs) * 0.7),
                fontsize=10, color='forestgreen',
                arrowprops=dict(arrowstyle='->', color='forestgreen', lw=2))

    plt.tight_layout()
    plt.savefig('tropical_deletion.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_deletion.png")


if __name__ == "__main__":
    plot_minplus_duality()
    plot_ramsey_bounds()
    plot_tropical_deletion()
    print("\nAll visualizations saved.")
