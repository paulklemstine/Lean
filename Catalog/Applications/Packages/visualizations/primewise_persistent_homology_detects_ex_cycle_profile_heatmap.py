"""
Visualization: Cycle Profile Heatmap for Volcano Depth Detection

Visualizes the cycle rank β₁(B_r(v)) as a function of vertex depth and
ball radius, showing the sharp transition at the diagonal r = depth(v)
that is the core mechanism of topological depth detection.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from collections import deque
from typing import Dict, Set


# ─── Self-contained volcano infrastructure ───────────────────────────────────

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
    G = VG(); nid = 0
    crater = []
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


def ball(G, v, r):
    vis = {v}; q = deque([(v, 0)])
    while q:
        u, d = q.popleft()
        if d >= r: continue
        for w in G.nbrs(u):
            if w not in vis: vis.add(w); q.append((w, d+1))
    return vis


def beta1(G, v, r):
    b = ball(G, v, r)
    edges = [(u, w) for u in b for w in G.nbrs(u) if w in b and u < w]
    parent = {x: x for x in b}
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for u, w in edges:
        ru, rw = find(u), find(w)
        if ru != rw: parent[rw] = ru
    c = len(set(find(x) for x in b))
    return max(0, len(edges) - len(b) + c)


# ─── Build data ──────────────────────────────────────────────────────────────

cs, br, md = 6, 2, 4
G = build(cs, br, md)

depth_range = list(range(md + 1))
radius_range = list(range(md + 2))

data = np.zeros((len(depth_range), len(radius_range)))
reps = {}
for d in depth_range:
    for v in sorted(G.V):
        if G.depth[v] == d and d not in reps:
            reps[d] = v
    v = reps[d]
    for ri, r in enumerate(radius_range):
        data[d, ri] = beta1(G, v, r)

# ─── Plot ────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

ax = axes[0]
cmap = mcolors.LinearSegmentedColormap.from_list('custom',
    ['#f0f0f0', '#2196F3', '#1565C0', '#0D47A1', '#000051'])
im = ax.imshow(data, cmap=cmap, aspect='auto', origin='lower',
               extent=[-0.5, len(radius_range)-0.5, -0.5, len(depth_range)-0.5])
ax.plot([-0.5, md+0.5], [-0.5, md+0.5], 'r--', linewidth=2,
        label='r = depth (detection boundary)')
ax.set_xlabel('Ball Radius r', fontsize=12)
ax.set_ylabel('Vertex Depth d', fontsize=12)
ax.set_title(f'Cycle Rank β₁(B_r(v)) by Depth and Radius\n'
             f'(crater={cs}, branching={br}, max_depth={md})', fontsize=13)
ax.set_xticks(range(len(radius_range))); ax.set_xticklabels(radius_range)
ax.set_yticks(range(len(depth_range))); ax.set_yticklabels(depth_range)
ax.legend(loc='upper left', fontsize=10)
for i in range(len(depth_range)):
    for j in range(len(radius_range)):
        val = int(data[i, j])
        color = 'white' if val > 0 else 'gray'
        ax.text(j, i, str(val), ha='center', va='center', fontsize=10,
                fontweight='bold' if val > 0 else 'normal', color=color)
fig.colorbar(im, ax=ax, label='β₁', shrink=0.8)

ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.9, len(depth_range)))
for d in depth_range:
    profile = [data[d, r] for r in range(len(radius_range))]
    ax2.plot(radius_range, profile, 'o-', color=colors[d], linewidth=2,
             markersize=6, label=f'depth {d}')
    for r in range(len(radius_range)):
        if profile[r] > 0:
            ax2.plot(radius_range[r], profile[r], 's', color=colors[d],
                     markersize=12, markeredgecolor='red', markeredgewidth=2)
            break
ax2.set_xlabel('Ball Radius r', fontsize=12)
ax2.set_ylabel('Cycle Rank β₁', fontsize=12)
ax2.set_title('Cycle Profile by Vertex Depth\n(red squares = first cycle birth)', fontsize=13)
ax2.legend(loc='upper left', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(radius_range)

plt.tight_layout()
plt.savefig('cycle_profiles_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: cycle_profiles_heatmap.png")
