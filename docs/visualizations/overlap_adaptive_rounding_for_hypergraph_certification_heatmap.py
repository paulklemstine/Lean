"""
Visualization: Certification Heatmap
=====================================

Visualizes the relationship between structural parameters (d, K) and the
energy diagnostic rho, showing how the diagnostic serves as an a posteriori
certificate of instance quality.

What this visualizes: A heatmap showing average approximation ratio as a
function of (d, K), alongside the average diagnostic rho. Demonstrates
that the diagnostic captures the same information as the structural
parameters, but is computable from the LP solution alone.
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass


@dataclass
class HG:
    n: int
    edges: list

    def max_edge_size(self):
        return max((len(e) for e in self.edges), default=0)


def pair_overlap_energy(H, x):
    energy = 0.0
    for e in H.edges:
        el = sorted(e)
        for i, u in enumerate(el):
            for v in el[i+1:]:
                energy += 2 * x[u] * x[v]
    return energy


def effective_overlap(H, x):
    M = float(np.sum(x))
    if M == 0:
        return 0.0
    return pair_overlap_energy(H, x) / (M ** 2)


def solve_lp(H):
    try:
        from scipy.optimize import linprog
        c = np.ones(H.n)
        A_ub = [[-1 if v in e else 0 for v in range(H.n)] for e in H.edges]
        b_ub = [-1.0] * len(H.edges)
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, 1)] * H.n, method='highs')
        if result.success:
            return result.x
    except ImportError:
        pass
    d = H.max_edge_size()
    x = np.zeros(H.n)
    for e in H.edges:
        for v in e:
            x[v] = max(x[v], 1.0 / d)
    return x


def gen_hypergraph(n, d, m, K, rng):
    edges = []
    pair_count = {}
    for _ in range(m * 30):
        if len(edges) >= m:
            break
        e = frozenset(rng.choice(n, size=d, replace=False))
        el = sorted(e)
        ok = True
        for i, u in enumerate(el):
            for v in el[i+1:]:
                if pair_count.get((u, v), 0) >= K:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            edges.append(e)
            for i, u in enumerate(el):
                for v in el[i+1:]:
                    pair_count[(u, v)] = pair_count.get((u, v), 0) + 1
    return HG(n=n, edges=edges)


def adaptive_round(H, x, d):
    theta = 1.0 / d
    T = {v for v in range(len(x)) if x[v] >= theta}
    for e in H.edges:
        if not T & e:
            T.add(max(e, key=lambda v: x[v]))
    return T


rng = np.random.default_rng(42)
n, m = 25, 18
d_values = [3, 4, 5, 6]
K_values = [1, 2, 3, 5, 8]
n_trials = 25

ratio_matrix = np.zeros((len(d_values), len(K_values)))
rho_matrix = np.zeros((len(d_values), len(K_values)))

for i, d in enumerate(d_values):
    for j, K in enumerate(K_values):
        ratios = []
        rhos = []
        for _ in range(n_trials):
            H = gen_hypergraph(n, d, m, K, rng)
            if not H.edges:
                continue
            x = solve_lp(H)
            M = float(np.sum(x))
            if M < 0.01:
                continue
            T = adaptive_round(H, x, d)
            ratios.append(len(T) / M)
            rhos.append(effective_overlap(H, x))
        if ratios:
            ratio_matrix[i, j] = np.mean(ratios)
            rho_matrix[i, j] = np.mean(rhos)

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: Approximation ratio heatmap
im1 = axes[0].imshow(ratio_matrix, cmap='RdYlGn_r', aspect='auto',
                      vmin=1.0, vmax=max(d_values))
axes[0].set_xticks(range(len(K_values)))
axes[0].set_xticklabels([str(K) for K in K_values])
axes[0].set_yticks(range(len(d_values)))
axes[0].set_yticklabels([str(d) for d in d_values])
axes[0].set_xlabel('Pair Codegree K', fontsize=13)
axes[0].set_ylabel('Uniformity d', fontsize=13)
axes[0].set_title('Average Approximation Ratio |T|/τ*', fontsize=14)
cbar1 = plt.colorbar(im1, ax=axes[0])
cbar1.set_label('Ratio', fontsize=11)

# Annotate cells
for i in range(len(d_values)):
    for j in range(len(K_values)):
        axes[0].text(j, i, f'{ratio_matrix[i,j]:.2f}',
                    ha='center', va='center', fontsize=10, fontweight='bold',
                    color='white' if ratio_matrix[i,j] > 2.5 else 'black')

# Right: Diagnostic rho heatmap
im2 = axes[1].imshow(rho_matrix, cmap='YlOrRd', aspect='auto')
axes[1].set_xticks(range(len(K_values)))
axes[1].set_xticklabels([str(K) for K in K_values])
axes[1].set_yticks(range(len(d_values)))
axes[1].set_yticklabels([str(d) for d in d_values])
axes[1].set_xlabel('Pair Codegree K', fontsize=13)
axes[1].set_ylabel('Uniformity d', fontsize=13)
axes[1].set_title('Average Diagnostic ρ (Energy Certificate)', fontsize=14)
cbar2 = plt.colorbar(im2, ax=axes[1])
cbar2.set_label('ρ = E/M²', fontsize=11)

# Annotate cells
for i in range(len(d_values)):
    for j in range(len(K_values)):
        axes[1].text(j, i, f'{rho_matrix[i,j]:.2f}',
                    ha='center', va='center', fontsize=10, fontweight='bold',
                    color='white' if rho_matrix[i,j] > 1.5 else 'black')

plt.suptitle('Instance Difficulty Certification: Structural Parameters vs. LP Diagnostic',
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_certification_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_certification_heatmap.png")
