#!/usr/bin/env python3
"""
Visualization: Phi Landscape across Graph Density

Shows how integrated information varies with the number of edges
in a causal system, demonstrating the key theorems:
- Phi = 0 for disconnected graphs (low edge count)
- Phi increases monotonically with edge addition
- Phi saturates at the complete graph value
"""

import itertools
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
from typing import Set, Tuple, Dict, List


def cut_value(n: int, edges: Set[Tuple[int, int]], cut: Tuple[bool, ...]) -> int:
    return sum(1 for (i, j) in edges if cut[i] != cut[j])


def compute_phi(n: int, edges: Set[Tuple[int, int]]) -> int:
    if n < 2:
        return 0
    cuts = [c for c in itertools.product([True, False], repeat=n)
            if any(c) and not all(c)]
    return min(cut_value(n, edges, c) for c in cuts)


def main():
    n = 4
    possible_edges = [(i, j) for i in range(n) for j in range(n) if i != j]
    max_edges = len(possible_edges)

    # Collect Phi values by edge count
    phi_by_density: Dict[int, List[int]] = defaultdict(list)

    total_sampled = 0
    max_per_density = 200

    for num_edges in range(max_edges + 1):
        count = 0
        for edge_combo in itertools.combinations(possible_edges, num_edges):
            if count >= max_per_density:
                break
            p = compute_phi(n, set(edge_combo))
            phi_by_density[num_edges].append(p)
            count += 1
            total_sampled += 1

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Phi vs Edge Count (scatter with jitter)
    ax = axes[0]
    for num_edges, phis in sorted(phi_by_density.items()):
        jitter = np.random.normal(0, 0.15, len(phis))
        ax.scatter([num_edges + j for j in jitter], phis,
                   alpha=0.3, s=10, c='steelblue')

    means = {k: np.mean(v) for k, v in phi_by_density.items()}
    ax.plot(sorted(means.keys()), [means[k] for k in sorted(means.keys())],
            'r-', linewidth=2, label='Mean Φ')
    ax.set_xlabel('Number of Edges', fontsize=12)
    ax.set_ylabel('Φ (Integrated Information)', fontsize=12)
    ax.set_title(f'Integration vs. Wiring Complexity (n={n})', fontsize=13)
    ax.legend()

    # Plot 2: Phi distribution histogram
    ax = axes[1]
    all_phis = [p for phis in phi_by_density.values() for p in phis]
    phi_range = range(max(all_phis) + 1)
    counts = [all_phis.count(p) for p in phi_range]
    ax.bar(phi_range, counts, color='coral', edgecolor='darkred', alpha=0.8)
    ax.set_xlabel('Φ Value', fontsize=12)
    ax.set_ylabel('Number of Graphs', fontsize=12)
    ax.set_title(f'Distribution of Φ (n={n})', fontsize=13)

    # Plot 3: Fraction of disconnected graphs by edge count
    ax = axes[2]
    densities = sorted(phi_by_density.keys())
    frac_disconnected = []
    frac_high_phi = []
    for d in densities:
        phis = phi_by_density[d]
        frac_disconnected.append(sum(1 for p in phis if p == 0) / len(phis))
        frac_high_phi.append(sum(1 for p in phis if p >= 2) / len(phis))

    ax.plot(densities, frac_disconnected, 'b-o', markersize=4,
            label='Φ = 0 (disconnected)')
    ax.plot(densities, frac_high_phi, 'r-s', markersize=4,
            label='Φ ≥ 2 (highly integrated)')
    ax.fill_between(densities, frac_disconnected, alpha=0.2, color='blue')
    ax.fill_between(densities, frac_high_phi, alpha=0.2, color='red')
    ax.set_xlabel('Number of Edges', fontsize=12)
    ax.set_ylabel('Fraction of Graphs', fontsize=12)
    ax.set_title('Phase Transition in Integration', fontsize=13)
    ax.legend()

    plt.tight_layout()
    plt.savefig('phi_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved phi_landscape.png (sampled {total_sampled} graphs)")


if __name__ == "__main__":
    main()
