"""
Visualization: Edge Insertion Response Distribution

Shows the distribution of Δτ*(H, e) across candidate edges for hypergraphs
at different densities. Demonstrates the bounded response theorem (0 ≤ Δ ≤ 1)
and how the response distribution changes across the phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog
from itertools import combinations
import warnings


def compute_frac_transversal_num(n, edges):
    if not edges:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    return result.fun if result.success else float('inf')


def generate_random_hypergraph(n, m, d, rng):
    all_edges = list(combinations(range(n), d))
    if m > len(all_edges):
        m = len(all_edges)
    indices = rng.choice(len(all_edges), size=m, replace=False)
    return [all_edges[i] for i in indices]


# Parameters
n, d = 15, 3
rng = np.random.default_rng(42)
densities = [0.3, 1.0, 1.5, 2.5]
all_edges = list(combinations(range(n), d))

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for idx, c in enumerate(densities):
    ax = axes[idx // 2][idx % 2]
    m = max(1, int(c * n))
    edges = generate_random_hypergraph(n, m, d, rng)
    tau = compute_frac_transversal_num(n, edges)

    # Sample insertion deltas
    edge_set = set(edges)
    candidates = [e for e in all_edges if e not in edge_set]
    sample = [candidates[i] for i in rng.choice(len(candidates),
              size=min(40, len(candidates)), replace=False)]

    deltas = []
    for e in sample:
        tau_new = compute_frac_transversal_num(n, edges + [e])
        deltas.append(tau_new - tau)

    deltas = np.array(deltas)

    # Plot histogram
    bins = np.linspace(-0.05, 1.05, 25)
    ax.hist(deltas, bins=bins, color='steelblue', alpha=0.7, edgecolor='navy',
            density=True, label=f'{len(deltas)} insertions')

    # Mark key statistics
    chi_avg = np.mean(np.abs(deltas))
    chi_max = np.max(np.abs(deltas))
    ax.axvline(chi_avg, color='red', linestyle='--', linewidth=2,
               label=f'χ_avg = {chi_avg:.3f}')
    ax.axvline(chi_max, color='orange', linestyle=':', linewidth=2,
               label=f'χ_max = {chi_max:.3f}')

    # Theorem bounds
    ax.axvline(0, color='green', linewidth=1.5, alpha=0.5, label='Lower bound (Thm 2)')
    ax.axvline(1, color='green', linewidth=1.5, alpha=0.5, label='Upper bound (Thm 1)')

    ax.set_xlabel('Δτ*(H, e)', fontsize=11)
    ax.set_ylabel('Density', fontsize=11)
    ax.set_title(f'c = {c:.1f} (m={m}), τ* = {tau:.2f}', fontsize=12)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_xlim(-0.1, 1.1)
    ax.grid(True, alpha=0.3)

fig.suptitle('Edge Insertion Response Distribution at Different Densities\n'
             f'n={n}, d={d}-uniform hypergraphs',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('insertion_response.png', dpi=150, bbox_inches='tight')
print("Saved insertion_response.png")
