"""
Visualization: Finite-Size Scaling Analysis

Plots the peak susceptibility as a function of system size n on a log-log
scale to estimate the critical exponent γ. The conjecture predicts
max_m χ²(n,m,d) ~ n^γ for some γ > 0.

Also shows the convergence of the pseudocritical density c*(n,d) = m*/n.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog
from itertools import combinations
from math import comb
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
d = 3
n_values = [8, 10, 12, 15, 18]
samples = 25
rng = np.random.default_rng(42)

peaks = []
pc_densities = []

print("Computing scaling data...")
for n in n_values:
    m_max = min(comb(n, d), int(3.5 * n))
    m_vals = list(range(0, m_max + 1, max(1, m_max // 25)))
    best_var = 0
    best_c = 0

    for m in m_vals:
        taus = [compute_frac_transversal_num(n, generate_random_hypergraph(n, m, d, rng))
                for _ in range(samples)]
        v = np.var(taus)
        if v > best_var:
            best_var = v
            best_c = m / n

    peaks.append(best_var)
    pc_densities.append(best_c)
    print(f"  n={n}: c*={best_c:.3f}, peak={best_var:.6f}")

peaks = np.array(peaks)
pc_densities = np.array(pc_densities)
n_arr = np.array(n_values, dtype=float)

# Fit gamma
log_n = np.log(n_arr)
log_peaks = np.log(peaks + 1e-12)
gamma, intercept = np.polyfit(log_n, log_peaks, 1)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: log-log scaling of peak susceptibility
ax1.scatter(log_n, log_peaks, color='darkblue', s=60, zorder=5, label='Data')
fit_line = gamma * log_n + intercept
ax1.plot(log_n, fit_line, 'r--', linewidth=2, label=f'Fit: γ ≈ {gamma:.3f}')
ax1.set_xlabel('log(n)', fontsize=12)
ax1.set_ylabel('log(peak χ²)', fontsize=12)
ax1.set_title(f'Scaling Exponent: d={d}', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Annotate
for i, n in enumerate(n_values):
    ax1.annotate(f'n={n}', (log_n[i], log_peaks[i]),
                 textcoords="offset points", xytext=(8, 5), fontsize=9)

# Right: pseudocritical density convergence
ax2.plot(n_arr, pc_densities, 'o-', color='darkgreen', markersize=8, linewidth=2)
ax2.axhline(np.mean(pc_densities), color='gray', linestyle=':', alpha=0.6,
            label=f'Mean c* ≈ {np.mean(pc_densities):.3f}')
ax2.fill_between(n_arr,
                 np.mean(pc_densities) - np.std(pc_densities),
                 np.mean(pc_densities) + np.std(pc_densities),
                 alpha=0.2, color='green')
ax2.set_xlabel('System size n', fontsize=12)
ax2.set_ylabel('Pseudocritical density c*', fontsize=12)
ax2.set_title('Convergence of Critical Density', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

fig.suptitle(f'Finite-Size Scaling of {d}-Uniform Hypergraph Susceptibility',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('scaling_analysis.png', dpi=150, bbox_inches='tight')
print(f"\nEstimated γ(d={d}) ≈ {gamma:.3f}")
print("Saved scaling_analysis.png")
