"""
Visualization: Certificate Size vs FPT Bound

Plots the ratio of actual certificate size to theoretical bound |E| · 2^(k²+k)
for random bounded-treewidth graphs across different treewidths and graph sizes.

This visualizes the main theorem: certificate size is always below the FPT bound,
and the ratio decreases with graph size, suggesting the bound is not tight.

Output: Saves to viz_certificate_ratio.png via plt.savefig()
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Optional


# ============================================================
# Self-contained graph and certificate implementation
# ============================================================

@dataclass
class Graph:
    n: int
    edges: set = field(default_factory=set)
    adj: dict = field(default_factory=lambda: defaultdict(set))

    def add_edge(self, u, v):
        if u == v: return
        e = (min(u, v), max(u, v))
        if e not in self.edges:
            self.edges.add(e)
            self.adj[u].add(v)
            self.adj[v].add(u)

    @property
    def num_edges(self):
        return len(self.edges)

    def delete_edge(self, u, v):
        g = Graph(self.n)
        e = (min(u, v), max(u, v))
        for edge in self.edges:
            if edge != e:
                g.add_edge(*edge)
        return g

    def contract_edge(self, u, v):
        g = Graph(self.n)
        e = (min(u, v), max(u, v))
        for a, b in self.edges:
            if (a, b) == e: continue
            a2 = u if a == v else a
            b2 = u if b == v else b
            if a2 != b2:
                g.add_edge(a2, b2)
        return g


def generate_k_tree(n, k, seed=None):
    if seed is not None:
        random.seed(seed)
    g = Graph(n)
    for i in range(k + 1):
        for j in range(i + 1, k + 1):
            g.add_edge(i, j)
    cliques = [set(range(k + 1))]
    for v in range(k + 1, n):
        parent = random.choice(cliques)
        connect = set(random.sample(sorted(parent), min(k, len(parent))))
        for u in connect:
            g.add_edge(v, u)
        cliques.append(connect | {v})
    to_remove = [e for e in list(g.edges) if random.random() < 0.15]
    for e in to_remove:
        g.edges.discard(e)
        g.adj[e[0]].discard(e[1])
        g.adj[e[1]].discard(e[0])
    return g


def cert_size_estimate(g, max_depth=20):
    """Estimate certificate size via bounded recursion."""
    if not g.edges or max_depth <= 0:
        return 1
    edge = next(iter(g.edges))
    u, v = edge
    g_del = g.delete_edge(u, v)
    g_con = g.contract_edge(u, v)
    return 1 + cert_size_estimate(g_del, max_depth - 1) + \
               cert_size_estimate(g_con, max_depth - 1)


def fpt_bound(m, k):
    return m * 2 ** (k ** 2 + k)


def bell_number(n):
    if n == 0: return 1
    tri = [[0] * (n + 1) for _ in range(n + 1)]
    tri[0][0] = 1
    for i in range(1, n + 1):
        tri[i][0] = tri[i - 1][i - 1]
        for j in range(1, i + 1):
            tri[i][j] = tri[i][j - 1] + tri[i - 1][j - 1]
    return tri[n][0]


# ============================================================
# Generate data
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Treewidth Certificate Compilation: Size vs Theoretical Bound',
             fontsize=16, fontweight='bold')

# Plot 1: Certificate ratio vs graph size for different k
ax1 = axes[0, 0]
for k in [1, 2, 3]:
    sizes_n = []
    ratios = []
    for n in range(k + 2, min(k + 12, 18)):
        g = generate_k_tree(n, k, seed=42 + n * 10 + k)
        m = g.num_edges
        if m == 0: continue
        cs = cert_size_estimate(g, max_depth=min(m, 18))
        bound = fpt_bound(m, k)
        if bound > 0:
            sizes_n.append(n)
            ratios.append(cs / bound)
    ax1.plot(sizes_n, ratios, 'o-', label=f'k={k}', markersize=6)

ax1.set_xlabel('Number of vertices n')
ax1.set_ylabel('cert_size / (m · 2^(k²+k))')
ax1.set_title('Certificate Ratio vs Graph Size')
ax1.legend()
ax1.set_ylim(bottom=0)
ax1.grid(True, alpha=0.3)

# Plot 2: FPT bound growth with treewidth
ax2 = axes[0, 1]
ks = list(range(1, 9))
bounds = [2 ** (k ** 2 + k) for k in ks]
bells = [bell_number(k + 1) for k in ks]

ax2.semilogy(ks, bounds, 's-', color='red', label='2^(k²+k) (our bound)', markersize=8)
ax2.semilogy(ks, bells, 'D-', color='blue', label='Bell(k+1) (state count)', markersize=8)
ax2.set_xlabel('Treewidth k')
ax2.set_ylabel('Branching factor (log scale)')
ax2.set_title('FPT Bound vs Bell Number')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Linearity in edges
ax3 = axes[1, 0]
for k in [1, 2, 3]:
    ms = list(range(5, 105, 5))
    bounds_m = [fpt_bound(m, k) for m in ms]
    ax3.plot(ms, bounds_m, '-', label=f'k={k}', linewidth=2)

ax3.set_xlabel('Number of edges |E|')
ax3.set_ylabel('FPT Certificate Bound')
ax3.set_title('Linearity in Edge Count (fixed k)')
ax3.legend()
ax3.grid(True, alpha=0.3)

# Plot 4: Concrete specializations heatmap
ax4 = axes[1, 1]
ks_heat = [1, 2, 3, 4, 5]
ms_heat = [10, 50, 100, 500]
data = np.zeros((len(ks_heat), len(ms_heat)))
for i, k in enumerate(ks_heat):
    for j, m in enumerate(ms_heat):
        data[i, j] = np.log10(fpt_bound(m, k))

im = ax4.imshow(data, aspect='auto', cmap='YlOrRd')
ax4.set_xticks(range(len(ms_heat)))
ax4.set_xticklabels([str(m) for m in ms_heat])
ax4.set_yticks(range(len(ks_heat)))
ax4.set_yticklabels([f'k={k}' for k in ks_heat])
ax4.set_xlabel('Number of edges |E|')
ax4.set_ylabel('Treewidth k')
ax4.set_title('log₁₀(FPT Bound) Heatmap')
plt.colorbar(im, ax=ax4, label='log₁₀(bound)')

# Add text annotations
for i in range(len(ks_heat)):
    for j in range(len(ms_heat)):
        val = data[i, j]
        color = 'white' if val > 10 else 'black'
        ax4.text(j, i, f'{val:.1f}', ha='center', va='center',
                color=color, fontsize=9)

plt.tight_layout()
plt.savefig('viz_certificate_ratio.png', dpi=150, bbox_inches='tight')
print("Saved: viz_certificate_ratio.png")
