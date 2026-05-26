"""
Visualization 1: Integrality Gap Profile vs. Density

Visualizes the core finding: the integrality gap τ/τ* as a function of
edge density c = m/n for random 3-uniform hypergraphs. Shows that the
gap is strictly below the worst-case bound d=3 for all densities, with
a characteristic shape that increases with density but remains sub-d.

This is the central plot of the random transversal thermodynamics theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog


def random_uniform_hypergraph(n, m, d, rng):
    edges = []
    vertices = list(range(n))
    for _ in range(m):
        edge = frozenset(rng.choice(vertices, size=d, replace=False))
        edges.append(edge)
    return edges


def solve_fractional_lp(n, edges):
    if not edges:
        return 0.0, np.zeros(n)
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1
    bounds = [(0, None)] * n
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if result.success:
        return result.fun, result.x
    return float('inf'), np.ones(n)


def threshold_round(x, d, edges):
    threshold = 1.0 / d
    S = {v for v in range(len(x)) if x[v] >= threshold}
    for e in edges:
        if not S & e:
            S.add(max(e, key=lambda v: x[v]))
    return S


def greedy_transversal(n, edges):
    uncovered = list(range(len(edges)))
    S = set()
    while uncovered:
        hits = {}
        for idx in uncovered:
            for v in edges[idx]:
                hits[v] = hits.get(v, 0) + 1
        if not hits:
            break
        best = max(hits, key=hits.get)
        S.add(best)
        uncovered = [i for i in uncovered if best not in edges[i]]
    return S


rng = np.random.default_rng(42)
d = 3
n = 80
c_values = np.linspace(0.2, 5.0, 30)
num_samples = 40

mean_gaps = []
std_gaps = []
mean_vars = []
mean_defects = []

for c in c_values:
    m = max(1, int(c * n))
    gaps = []
    defects = []
    for _ in range(num_samples):
        edges = random_uniform_hypergraph(n, m, d, rng)
        frac_opt, x = solve_fractional_lp(n, edges)
        if frac_opt < 1e-10:
            continue
        S_t = threshold_round(x, d, edges)
        S_g = greedy_transversal(n, edges)
        best = min(len(S_t), len(S_g))
        gap = best / frac_opt
        gaps.append(gap)
        defects.append(best - frac_opt)
    if gaps:
        mean_gaps.append(np.mean(gaps))
        std_gaps.append(np.std(gaps))
        mean_vars.append(np.var(gaps))
        mean_defects.append(np.mean(defects))
    else:
        mean_gaps.append(np.nan)
        std_gaps.append(np.nan)
        mean_vars.append(np.nan)
        mean_defects.append(np.nan)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: Mean gap vs density
ax1 = axes[0, 0]
ax1.plot(c_values, mean_gaps, 'b-o', markersize=4, label='Mean τ/τ*')
ax1.fill_between(c_values,
                  np.array(mean_gaps) - np.array(std_gaps),
                  np.array(mean_gaps) + np.array(std_gaps),
                  alpha=0.2, color='blue')
ax1.axhline(y=d, color='red', linestyle='--', linewidth=2, label=f'Worst-case bound (d={d})')
ax1.axhline(y=1, color='green', linestyle=':', linewidth=1, label='Perfect rounding')
ax1.set_xlabel('Edge density c = m/n', fontsize=12)
ax1.set_ylabel('Integrality gap τ/τ*', fontsize=12)
ax1.set_title('Integrality Gap vs. Edge Density', fontsize=14)
ax1.legend(fontsize=10)
ax1.set_ylim(0.8, d + 0.3)
ax1.grid(True, alpha=0.3)

# Plot 2: Variance (susceptibility proxy)
ax2 = axes[0, 1]
ax2.plot(c_values, mean_vars, 'r-s', markersize=4)
ax2.set_xlabel('Edge density c = m/n', fontsize=12)
ax2.set_ylabel('Var(τ/τ*)', fontsize=12)
ax2.set_title('Gap Variance (Susceptibility Proxy)', fontsize=14)
ax2.grid(True, alpha=0.3)

# Plot 3: Rounding defect
ax3 = axes[1, 0]
ax3.plot(c_values, mean_defects, 'g-^', markersize=4)
ax3.set_xlabel('Edge density c = m/n', fontsize=12)
ax3.set_ylabel('Rounding defect τ - τ*', fontsize=12)
ax3.set_title('Rounding Defect (Order Parameter)', fontsize=14)
ax3.grid(True, alpha=0.3)

# Plot 4: Gap improvement over worst case
improvement = [d - g if not np.isnan(g) else np.nan for g in mean_gaps]
ax4 = axes[1, 1]
ax4.plot(c_values, improvement, 'm-D', markersize=4)
ax4.axhline(y=0, color='red', linestyle='--', linewidth=1)
ax4.set_xlabel('Edge density c = m/n', fontsize=12)
ax4.set_ylabel('d - gap', fontsize=12)
ax4.set_title('Improvement Over Worst Case', fontsize=14)
ax4.grid(True, alpha=0.3)

plt.suptitle(f'Random Transversal Thermodynamics: d={d}, n={n}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gap_profile.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_gap_profile.png")
