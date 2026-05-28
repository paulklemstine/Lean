"""
Visualization: Energy-Diagnostic Landscape
===========================================

Visualizes the relationship between pair-overlap energy (rho), codegree bound (K),
and approximation ratio across random hypergraph instances. Shows how the
overlap diagnostic serves as a self-calibrating measure of instance difficulty.

What this visualizes: A scatter plot of instances in (rho, approximation_ratio) space,
colored by their true pair codegree K. The theorem predicts rho <= K, so points
should lie below the diagonal rho = K, and lower rho should correlate with
better (lower) approximation ratios.
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


def adaptive_round(H, x, d):
    theta = 1.0 / d
    T = {v for v in range(len(x)) if x[v] >= theta}
    for e in H.edges:
        if not T & e:
            T.add(max(e, key=lambda v: x[v]))
    return T


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


# Generate data
rng = np.random.default_rng(42)
n, d, m = 25, 3, 20
data = []  # (K, rho, ratio)

for K in [1, 2, 3, 5, 8]:
    for trial in range(30):
        H = gen_hypergraph(n, d, m, K, rng)
        if not H.edges:
            continue
        x = solve_lp(H)
        M = float(np.sum(x))
        if M < 0.01:
            continue
        rho = effective_overlap(H, x)
        T = adaptive_round(H, x, d)
        ratio = len(T) / M
        data.append((K, rho, ratio))

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: rho vs ratio colored by K
Ks = [d[0] for d in data]
rhos = [d[1] for d in data]
ratios = [d[2] for d in data]

sc = axes[0].scatter(rhos, ratios, c=Ks, cmap='viridis', s=50, alpha=0.7, edgecolors='k', linewidth=0.5)
axes[0].set_xlabel('Overlap Diagnostic ρ', fontsize=13)
axes[0].set_ylabel('Approximation Ratio |T|/τ*', fontsize=13)
axes[0].set_title('Energy Diagnostic vs. Approximation Quality', fontsize=14)
cbar = plt.colorbar(sc, ax=axes[0])
cbar.set_label('Pair Codegree K', fontsize=12)
axes[0].axhline(y=d, color='red', linestyle='--', alpha=0.5, label=f'd = {d} (worst case)')
axes[0].legend(fontsize=11)

# Right: boxplot of ratio grouped by K
K_vals = sorted(set(Ks))
box_data = [[r for k, _, r in data if k == kv] for kv in K_vals]
bp = axes[1].boxplot(box_data, labels=[str(k) for k in K_vals], patch_artist=True)
colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(K_vals)))
for patch, color in zip(bp['boxes'], colors):
    patch.set_facecolor(color)
    patch.set_alpha(0.7)
axes[1].set_xlabel('Pair Codegree K', fontsize=13)
axes[1].set_ylabel('Approximation Ratio |T|/τ*', fontsize=13)
axes[1].set_title('Approximation Ratio by Codegree Level', fontsize=14)
axes[1].axhline(y=d, color='red', linestyle='--', alpha=0.5, label=f'd = {d}')
axes[1].legend(fontsize=11)

plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")
