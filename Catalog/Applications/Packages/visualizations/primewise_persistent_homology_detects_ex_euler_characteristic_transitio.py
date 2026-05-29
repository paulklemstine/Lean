"""
Visualization: Euler Characteristic Transition in Volcano Graphs

Shows how χ(B_r(v)) transitions from χ ≈ 1 (tree-like, below crater) to χ < 1
(cycle-detecting, at/above crater). Visualizes the cross-domain bridge.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import deque
from typing import Dict, Set


class VG:
    def __init__(self):
        self.V: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.max_depth = 0
    def add_v(self, v, d):
        self.V.add(v); self.adj.setdefault(v, set()); self.depth[v] = d
        self.max_depth = max(self.max_depth, d)
    def add_e(self, u, v):
        if u == v: return
        self.adj.setdefault(u, set()).add(v); self.adj.setdefault(v, set()).add(u)
    def nbrs(self, v): return self.adj.get(v, set())


def build(cs, br, md):
    G = VG(); nid = 0; crater = []
    for i in range(cs): G.add_v(nid, 0); crater.append(nid); nid += 1
    for i in range(cs): G.add_e(crater[i], crater[(i+1)%cs])
    if md == 0: return G
    d1 = []
    for i in range(cs):
        c1, c2 = crater[i], crater[(i+1)%cs]
        for _ in range(br):
            G.add_v(nid, 1); G.add_e(c1, nid); G.add_e(c2, nid); d1.append(nid); nid += 1
    lev = d1
    for d in range(2, md+1):
        nl = []
        for p in lev:
            for _ in range(br): G.add_v(nid, d); G.add_e(p, nid); nl.append(nid); nid += 1
        lev = nl
    return G


def ball_stats(G, v, r):
    vis = {v}; q = deque([(v, 0)])
    while q:
        u, d = q.popleft()
        if d >= r: continue
        for w in G.nbrs(u):
            if w not in vis: vis.add(w); q.append((w, d+1))
    edges = [(u, w) for u in vis for w in G.nbrs(u) if w in vis and u < w]
    parent = {x: x for x in vis}
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for u, w in edges:
        ru, rw = find(u), find(w)
        if ru != rw: parent[rw] = ru
    c = len(set(find(x) for x in vis))
    nV, nE = len(vis), len(edges)
    return nV, nE, c, max(0, nE - nV + c), nV - nE


configs = [
    (5, 2, 4, "Volcano A: crater=5, branch=2, depth=4"),
    (8, 2, 3, "Volcano B: crater=8, branch=2, depth=3"),
    (4, 3, 3, "Volcano C: crater=4, branch=3, depth=3"),
]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, (cs, br, md, title) in enumerate(configs):
    ax = axes[idx]
    G = build(cs, br, md)
    reps = {}
    for v in sorted(G.V):
        d = G.depth[v]
        if d not in reps: reps[d] = v

    colors = plt.cm.plasma(np.linspace(0.1, 0.9, md + 1))
    rng = range(md + 2)

    for d in range(md + 1):
        v = reps[d]
        chi_vals = []; beta_vals = []
        for r in rng:
            nV, nE, c, beta, chi = ball_stats(G, v, r)
            chi_vals.append(chi); beta_vals.append(beta)
        ax.plot(list(rng), chi_vals, 'o-', color=colors[d], linewidth=2, markersize=5, label=f'd={d}')
        for r in rng:
            if beta_vals[r] > 0:
                ax.plot(r, chi_vals[r], 'v', color=colors[d], markersize=10,
                        markeredgecolor='black', markeredgewidth=1.5)
                break

    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, linewidth=1.5, label='χ=1 (tree)')
    ax.set_xlabel('Ball Radius r', fontsize=11)
    ax.set_ylabel('Euler Characteristic χ', fontsize=11)
    ax.set_title(title, fontsize=11)
    ax.legend(fontsize=8, loc='lower left')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(list(rng))

fig.suptitle('Euler Characteristic Transition: χ = 1 − β₁\n'
             '(▼ = first cycle detection, dashed = tree baseline)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('euler_char_transition.png', dpi=150, bbox_inches='tight')
print("Saved: euler_char_transition.png")
