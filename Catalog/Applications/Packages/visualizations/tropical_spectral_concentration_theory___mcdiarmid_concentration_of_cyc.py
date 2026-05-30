"""
Visualization 2: McDiarmid Concentration of Cycle-Birth Counts

Visualizes the concentration phenomenon: for random graphs G(n, p),
the cycle-birth count concentrates tightly around its mean as the
graph size increases. The McDiarmid bound provides a rigorous envelope.

What it shows:
- Histogram of cycle counts across random graph instances
- McDiarmid concentration envelope (theoretical bound)
- Convergence of relative deviation as n grows
"""

import matplotlib.pyplot as plt
import numpy as np
import math
import random


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True


def random_graph_cycle_count(n, p, seed):
    random.seed(seed)
    uf = UnionFind(n)
    cycles = 0
    total_edges = 0
    for i in range(n):
        for j in range(i+1, n):
            if random.random() < p:
                total_edges += 1
                w = random.random()
                if not uf.union(i, j):
                    cycles += 1
    return cycles, total_edges


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('McDiarmid Concentration of Cycle-Birth Counts',
             fontsize=16, fontweight='bold')

# Panel 1-3: Histograms for different n
p = 0.3
n_trials = 500

for panel_idx, n in enumerate([20, 50, 100]):
    ax = axes[panel_idx // 2][panel_idx % 2]

    cycle_counts = []
    edge_counts = []
    for trial in range(n_trials):
        cc, ec = random_graph_cycle_count(n, p, seed=10000 * panel_idx + trial)
        cycle_counts.append(cc)
        edge_counts.append(ec)

    mean_cc = np.mean(cycle_counts)
    std_cc = np.std(cycle_counts)
    mean_ec = np.mean(edge_counts)

    # McDiarmid bound
    m = int(mean_ec)
    r95 = math.sqrt(m * math.log(40) / 2) if m > 0 else 0
    r99 = math.sqrt(m * math.log(200) / 2) if m > 0 else 0

    ax.hist(cycle_counts, bins=30, density=True, alpha=0.7,
            color='#3498db', edgecolor='#2980b9', label='Empirical')

    # Theoretical envelope
    x_range = np.linspace(mean_cc - 3*r95, mean_cc + 3*r95, 200)
    # Gaussian approximation
    if std_cc > 0:
        gaussian = np.exp(-0.5 * ((x_range - mean_cc) / std_cc)**2) / (std_cc * np.sqrt(2*np.pi))
        ax.plot(x_range, gaussian, 'k--', linewidth=1.5, alpha=0.5, label='Gaussian fit')

    # McDiarmid bounds
    ax.axvline(mean_cc - r95, color='#e74c3c', linestyle='--', linewidth=2,
               label=f'95% McDiarmid: ±{r95:.1f}')
    ax.axvline(mean_cc + r95, color='#e74c3c', linestyle='--', linewidth=2)
    ax.axvline(mean_cc, color='#2ecc71', linestyle='-', linewidth=2,
               label=f'Mean: {mean_cc:.1f}')

    ax.set_title(f'G({n}, {p}): ~{m} edges', fontsize=13, fontweight='bold')
    ax.set_xlabel('Cycle count')
    ax.set_ylabel('Density')
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.2)

# Panel 4: Convergence of relative deviation
ax = axes[1][1]
ns = [10, 15, 20, 30, 40, 50, 70, 100, 150]
rel_devs_empirical = []
rel_devs_mcdiarmid = []

for n in ns:
    cycle_counts = []
    edge_counts = []
    for trial in range(300):
        cc, ec = random_graph_cycle_count(n, p, seed=50000 + n * 1000 + trial)
        cycle_counts.append(cc)
        edge_counts.append(ec)

    mean_cc = np.mean(cycle_counts)
    if mean_cc > 0:
        max_dev = max(abs(c - mean_cc) for c in cycle_counts)
        rel_dev = max_dev / mean_cc
        m = int(np.mean(edge_counts))
        r95 = math.sqrt(m * math.log(40) / 2) if m > 0 else 0
        mcdiarmid_rel = r95 / mean_cc if mean_cc > 0 else 0
    else:
        rel_dev = 0
        mcdiarmid_rel = 0

    rel_devs_empirical.append(rel_dev)
    rel_devs_mcdiarmid.append(mcdiarmid_rel)

ax.plot(ns, rel_devs_empirical, 'o-', color='#3498db', linewidth=2,
        markersize=6, label='Empirical max deviation')
ax.plot(ns, rel_devs_mcdiarmid, 's--', color='#e74c3c', linewidth=2,
        markersize=6, label='McDiarmid 95% bound')

# Theoretical 1/sqrt(n) decay
ns_theory = np.array(ns, dtype=float)
scale = rel_devs_mcdiarmid[0] * np.sqrt(ns[0]) if ns[0] > 0 else 1
theory = scale / np.sqrt(ns_theory)
ax.plot(ns, theory, ':', color='#95a5a6', linewidth=1.5, label=r'$O(1/\sqrt{n})$ reference')

ax.set_title('Concentration Improves with Size', fontsize=13, fontweight='bold')
ax.set_xlabel('Number of vertices n')
ax.set_ylabel('Relative deviation')
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_concentration.png', dpi=150, bbox_inches='tight')
print("Saved viz_concentration.png")
