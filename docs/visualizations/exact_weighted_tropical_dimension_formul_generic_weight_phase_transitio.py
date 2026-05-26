#!/usr/bin/env python3
"""
Visualization: Generic-Weight Collapse Phase Transition

Shows how the weighted tropical kernel dimension drops to zero as weights
become generic. This illustrates the central theorem: generic weights
destroy all tie edges, collapsing the degeneracy subgraph and eliminating
tropical kernel dimensions.

The plot shows dimension as a function of a "perturbation parameter" ε,
where edge weights are w_i + ε·δ_i for random perturbation vectors δ.
At ε = 0 (uniform weights), dimension is maximal. As ε grows, ties break
and dimension drops sharply — a combinatorial phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
import random


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

def wbetti(G, q, S):
    T = tie_sub(G)
    return cr(T, S)

def wkappa(G, q, S):
    T = tie_sub(G)
    return vc(T, q, S)

def tie_edge_count(G):
    T = tie_sub(G)
    return sum(1 for _ in T.edges())


# ── Phase transition plot ──

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

random.seed(123)
np.random.seed(123)

# Graph topologies to test
topologies = [
    ("K₅ (complete)", 5, [(i,j) for i in range(5) for j in range(i+1,5)]),
    ("C₆ (cycle)", 6, [(i,(i+1)%6) for i in range(6)]),
    ("K₃,₃ (bipartite)", 6, [(i,j) for i in range(3) for j in range(3,6)]),
    ("Petersen-like", 5, [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(1,3),(2,4)]),
]

for idx, (name, n, edge_list) in enumerate(topologies):
    ax = axes[idx // 2][idx % 2]

    q = 0
    S = set(range(1, n))

    # Multiple random perturbation directions
    n_trials = 8
    colors = plt.cm.tab10(np.linspace(0, 1, n_trials))

    for trial in range(n_trials):
        # Random perturbation vector (integers for exact tie detection)
        delta = [random.randint(1, 100) for _ in edge_list]

        # Use integer weights: base + scale * delta
        # We use scale as our ε parameter (integer valued)
        scales = list(range(0, 21))
        dims = []
        betas = []
        kappas = []
        ties = []

        for scale in scales:
            G = WG(n)
            for i, (u, v) in enumerate(edge_list):
                w = 100 + scale * delta[i]  # base weight 100
                G.add(u, v, w)

            dims.append(wdim(G, q, S))
            betas.append(wbetti(G, q, S))
            kappas.append(wkappa(G, q, S))
            ties.append(tie_edge_count(G))

        alpha = 0.4 if trial > 0 else 1.0
        lw = 1.0 if trial > 0 else 2.5
        ax.plot(scales, dims, '-', color=colors[trial], alpha=alpha, lw=lw)

    ax.set_xlabel('Perturbation scale ε', fontsize=11)
    ax.set_ylabel('Kernel dimension', fontsize=11)
    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.set_ylim(-0.5, max(dims[0] for _ in [0]) + 2)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.grid(True, alpha=0.2)

    # Annotate uniform point
    G0 = WG(n)
    for u, v in edge_list:
        G0.add(u, v, 100)
    dim0 = wdim(G0, q, S)
    ax.annotate(f'Uniform: dim={dim0}', xy=(0, dim0),
                xytext=(3, dim0 + 0.5), fontsize=9,
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')

plt.suptitle('Generic-Weight Collapse: Phase Transition in Tropical Kernel Dimension\n'
             '8 random perturbation directions per graph topology  |  '
             'ε=0: uniform weights (max dim) → ε>0: generic weights (dim→0)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
