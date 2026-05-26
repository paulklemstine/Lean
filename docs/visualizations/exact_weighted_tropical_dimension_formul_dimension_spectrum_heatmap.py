#!/usr/bin/env python3
"""
Visualization: Weighted Tropical Kernel Dimension Spectrum

Shows how the weighted tropical kernel dimension varies as edge weights
change on a fixed graph topology (K₄). The heatmap reveals the
"degeneracy landscape" — regions where weight ties create higher-dimensional
tropical kernels, separated by generic-weight valleys of dimension zero.

This visualizes the core theorem: dim = β₁ʷ + κʷ, where both terms
depend on the weight-degeneracy (tie) subgraph structure.
"""

import itertools
from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# ── Self-contained graph utilities ──

class WG:
    def __init__(self, n):
        self.n = n
        self.adj = defaultdict(set)
        self.w = {}
    def add(self, u, v, w):
        if u == v: return
        self.adj[u].add(v); self.adj[v].add(u)
        self.w[(u,v)] = w; self.w[(v,u)] = w
    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v,u) not in seen:
                    seen.add((u,v)); yield (u,v)

def tie_sub(G):
    T = WG(G.n)
    for u,v in G.edges():
        wuv = G.w[(u,v)]
        t_u = any(G.w[(u,k)] == wuv for k in G.adj[u] if k != v)
        t_v = any(G.w[(v,k)] == G.w[(v,u)] for k in G.adj[v] if k != u)
        if t_u or t_v:
            T.add(u, v, wuv)
    return T

def cc(G, S):
    vis = set(); comps = []
    for s in S:
        if s in vis: continue
        c = set(); stk = [s]
        while stk:
            v = stk.pop()
            if v in c: continue
            c.add(v); vis.add(v)
            for nb in G.adj[v]:
                if nb in S and nb not in c: stk.append(nb)
        comps.append(c)
    return comps

def cr(G, S):
    if not S: return 0
    e = sum(1 for u,v in G.edges() if u in S and v in S)
    return max(0, e + len(cc(G, S)) - len(S))

def vc(G, q, S):
    return sum(1 for c in cc(G, S) if any(v in G.adj.get(q, set()) for v in c))

def wdim(G, q, S):
    T = tie_sub(G)
    return cr(T, S) + vc(T, q, S)


# ── Figure 1: Dimension heatmap for two varying weights ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# K4 graph: edges (0,1), (0,2), (0,3), (1,2), (1,3), (2,3)
# Fix 4 edge weights, vary 2
base_weights = [1, 2, 3, 4]  # weights for edges (0,2), (0,3), (1,3), (2,3)
edge_list = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
q = 0
S = {1, 2, 3}

wrange = range(1, 11)
dim_grid = np.zeros((len(wrange), len(wrange)))
beta_grid = np.zeros((len(wrange), len(wrange)))
kappa_grid = np.zeros((len(wrange), len(wrange)))

for i, w01 in enumerate(wrange):
    for j, w12 in enumerate(wrange):
        G = WG(4)
        ws = [w01, 2, 3, w12, 4, 5]
        for (u,v), w in zip(edge_list, ws):
            G.add(u, v, w)
        T = tie_sub(G)
        beta_grid[j, i] = cr(T, S)
        kappa_grid[j, i] = vc(T, q, S)
        dim_grid[j, i] = beta_grid[j, i] + kappa_grid[j, i]

# Plot dimension
im0 = axes[0].imshow(dim_grid, origin='lower', cmap='YlOrRd',
                      extent=[0.5, 10.5, 0.5, 10.5], aspect='auto')
axes[0].set_xlabel('w(0,1)', fontsize=12)
axes[0].set_ylabel('w(1,2)', fontsize=12)
axes[0].set_title('Kernel Dimension\ndim = β₁ʷ + κʷ', fontsize=13)
plt.colorbar(im0, ax=axes[0], label='dimension')

# Plot beta
im1 = axes[1].imshow(beta_grid, origin='lower', cmap='Blues',
                      extent=[0.5, 10.5, 0.5, 10.5], aspect='auto')
axes[1].set_xlabel('w(0,1)', fontsize=12)
axes[1].set_ylabel('w(1,2)', fontsize=12)
axes[1].set_title('Weighted Betti β₁ʷ\n(tie subgraph cycle rank)', fontsize=13)
plt.colorbar(im1, ax=axes[1], label='β₁ʷ')

# Plot kappa
im2 = axes[2].imshow(kappa_grid, origin='lower', cmap='Greens',
                      extent=[0.5, 10.5, 0.5, 10.5], aspect='auto')
axes[2].set_xlabel('w(0,1)', fontsize=12)
axes[2].set_ylabel('w(1,2)', fontsize=12)
axes[2].set_title('Visible Defect κʷ\n(q-visible tie components)', fontsize=13)
plt.colorbar(im2, ax=axes[2], label='κʷ')

plt.suptitle('Weighted Tropical Dimension Formula on K₄\n'
             'Fixed: w(0,2)=2, w(0,3)=3, w(1,3)=4, w(2,3)=5  |  q=0, S={1,2,3}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('dimension_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved dimension_spectrum.png")
