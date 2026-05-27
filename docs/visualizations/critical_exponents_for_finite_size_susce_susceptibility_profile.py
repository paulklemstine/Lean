"""
Visualization: Susceptibility Profile of Random Hypergraph Optimization

Plots the quadratic susceptibility χ²(n,m,d) = Var(τ*) as a function of
edge density c = m/n for random d-uniform hypergraphs, showing the
susceptibility peak that defines the pseudocritical density.

This is the central visual result: the curve has a clear maximum,
analogous to magnetic susceptibility peaking at the Curie temperature.
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
n_values = [10, 15, 20]
d = 3
samples = 30
rng = np.random.default_rng(42)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for ax_idx, n in enumerate(n_values):
    from math import comb
    m_max = min(comb(n, d), int(3.5 * n))
    m_values = list(range(0, m_max + 1, max(1, m_max // 25)))

    densities = []
    chi2 = []
    tau_means = []

    for m in m_values:
        taus = [compute_frac_transversal_num(n, generate_random_hypergraph(n, m, d, rng))
                for _ in range(samples)]
        densities.append(m / n)
        chi2.append(np.var(taus))
        tau_means.append(np.mean(taus))

    densities = np.array(densities)
    chi2 = np.array(chi2)
    tau_means = np.array(tau_means)

    # Find peak
    peak_idx = np.argmax(chi2)
    c_star = densities[peak_idx]

    # Plot susceptibility
    ax = axes[ax_idx]
    ax.fill_between(densities, 0, chi2, alpha=0.3, color='steelblue')
    ax.plot(densities, chi2, 'o-', color='steelblue', markersize=3, linewidth=1.5,
            label=r'$\chi^{(2)}$ = Var($\tau^*$)')
    ax.axvline(c_star, color='red', linestyle='--', alpha=0.7, label=f'$c^*$ ≈ {c_star:.2f}')
    ax.scatter([c_star], [chi2[peak_idx]], color='red', s=80, zorder=5,
               marker='*', label=f'Peak = {chi2[peak_idx]:.4f}')

    ax.set_xlabel('Edge density $c = m/n$', fontsize=11)
    ax.set_ylabel(r'$\chi^{(2)}_{n,m,d}$ = Var($\tau^*$)', fontsize=11)
    ax.set_title(f'$n = {n}$, $d = {d}$', fontsize=13)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_xlim(0, max(densities))
    ax.set_ylim(0, None)
    ax.grid(True, alpha=0.3)

fig.suptitle('Finite-Size Susceptibility Profile: LP Optimum Variance vs Edge Density',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('susceptibility_profile.png', dpi=150, bbox_inches='tight')
print("Saved susceptibility_profile.png")
