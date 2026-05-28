"""
Visualization: Threshold Effect and Energy Certificate
=======================================================

Visualizes how the threshold parameter theta affects the rounded set size,
and how the pair-overlap energy provides a certificate of quality.

What this visualizes: For a single hypergraph instance, shows how the
threshold set size |T_theta| changes with theta, marking the adaptive
threshold 1/d and showing the feasibility boundary. Also plots the
energy certificate rho across different instances to demonstrate its
predictive power for instance difficulty.
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


rng = np.random.default_rng(42)
n, d, m = 25, 4, 18

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# LEFT: Threshold sweep for two instances (low K vs high K)
for K, color, label in [(1, '#2ecc71', 'K=1 (low overlap)'),
                         (5, '#e74c3c', 'K=5 (high overlap)')]:
    H = gen_hypergraph(n, d, m, K, rng)
    if not H.edges:
        continue
    x = solve_lp(H)
    M = float(np.sum(x))

    thetas = np.linspace(0.01, 0.6, 100)
    sizes = []
    feasible = []
    for theta in thetas:
        T = {v for v in range(len(x)) if x[v] >= theta}
        sizes.append(len(T))
        feasible.append(all(T & e for e in H.edges))

    sizes = np.array(sizes, dtype=float)
    feas = np.array(feasible)

    axes[0].plot(thetas[feas], sizes[feas], color=color, linewidth=2.5, label=f'{label}')
    axes[0].plot(thetas[~feas], sizes[~feas], color=color, linewidth=1.5,
                linestyle='--', alpha=0.4)

    # Mark adaptive threshold
    t_ad = 1.0 / d
    T_ad = {v for v in range(len(x)) if x[v] >= t_ad}
    axes[0].scatter([t_ad], [len(T_ad)], color=color, s=120, zorder=5,
                   edgecolors='black', linewidth=1.5, marker='*')

axes[0].axvline(x=1.0/d, color='gray', linestyle=':', alpha=0.5, label=f'θ = 1/d = {1/d:.2f}')
axes[0].set_xlabel('Threshold θ', fontsize=13)
axes[0].set_ylabel('|T_θ| (rounded set size)', fontsize=13)
axes[0].set_title('Threshold Sweep: Set Size vs. Threshold', fontsize=14)
axes[0].legend(fontsize=11)
axes[0].fill_between(thetas, 0, max(sizes) * 1.1, where=thetas > 1.0/d,
                     alpha=0.05, color='red', label='May lose feasibility')

# RIGHT: rho distribution by K
K_values = [1, 2, 3, 5, 8]
rho_by_K = {K: [] for K in K_values}

for K in K_values:
    for _ in range(40):
        H = gen_hypergraph(n, d, m, K, rng)
        if not H.edges:
            continue
        x = solve_lp(H)
        M = float(np.sum(x))
        if M < 0.01:
            continue
        rho = effective_overlap(H, x)
        rho_by_K[K].append(rho)

positions = range(len(K_values))
bp = axes[1].boxplot([rho_by_K[K] for K in K_values],
                     positions=positions, patch_artist=True, widths=0.6)
colors_box = plt.cm.coolwarm(np.linspace(0.15, 0.85, len(K_values)))
for patch, c in zip(bp['boxes'], colors_box):
    patch.set_facecolor(c)
    patch.set_alpha(0.7)

# Plot theoretical bound rho <= K
axes[1].plot(positions, K_values, 'k--', linewidth=2, label='Bound: ρ ≤ K', alpha=0.7)
axes[1].set_xticks(positions)
axes[1].set_xticklabels([str(K) for K in K_values])
axes[1].set_xlabel('Pair Codegree Bound K', fontsize=13)
axes[1].set_ylabel('Effective Overlap ρ', fontsize=13)
axes[1].set_title('Diagnostic ρ vs. Codegree Bound K', fontsize=14)
axes[1].legend(fontsize=11)

plt.tight_layout()
plt.savefig('viz_threshold_effect.png', dpi=150, bbox_inches='tight')
print("Saved viz_threshold_effect.png")
