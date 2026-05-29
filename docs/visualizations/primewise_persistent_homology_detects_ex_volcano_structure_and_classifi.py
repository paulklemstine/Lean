"""
Visualization: Volcano Graph Structure and Depth Classification

Shows the structure of a layered volcano graph with vertices colored by
depth and annotated with their topologically-predicted depth.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import deque
from typing import Dict, Set
import math


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


def fcr(G, vid):
    for r in range(G.max_depth + 2):
        vis = {vid}; q = deque([(vid, 0)])
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
        for a, b in edges:
            ra, rb = find(a), find(b)
            if ra != rb: parent[rb] = ra
        c = len(set(find(x) for x in vis))
        if max(0, len(edges) - len(vis) + c) > 0: return r
    return G.max_depth + 1


cs, br, md = 5, 2, 3
G = build(cs, br, md)

# Layout
pos = {}
crater_verts = sorted(v for v in G.V if G.depth[v] == 0)
for i, v in enumerate(crater_verts):
    angle = 2*math.pi*i/cs - math.pi/2
    pos[v] = (2.0*math.cos(angle), -0.5*math.sin(angle))
for d in range(1, md+1):
    verts = sorted(v for v in G.V if G.depth[v] == d)
    spread = 3.0 * (1.2**d)
    for i, v in enumerate(verts):
        pos[v] = (-spread/2 + spread*(i+0.5)/len(verts), -1.5*d)

fcr_map = {v: fcr(G, v) for v in G.V}

fig, axes = plt.subplots(1, 2, figsize=(16, 8))
cmap = plt.cm.RdYlBu_r
dc = {d: cmap(d/max(md, 1)) for d in range(md+1)}

# Left: True depth
ax = axes[0]
for v in G.V:
    for u in G.nbrs(v):
        if u > v:
            ax.plot([pos[v][0], pos[u][0]], [pos[v][1], pos[u][1]], 'k-', alpha=0.3, lw=1)
for v in sorted(G.V):
    ax.scatter(*pos[v], c=[dc[G.depth[v]]], s=200, zorder=5, edgecolors='black', lw=1.5)
    ax.annotate(str(v), pos[v], ha='center', va='center', fontsize=7, fontweight='bold', zorder=6)
ax.legend(handles=[mpatches.Patch(color=dc[d], label=f'Depth {d}') for d in range(md+1)],
          loc='lower right', fontsize=9)
ax.set_title('True Depth', fontsize=14, fontweight='bold')
ax.set_aspect('equal'); ax.axis('off')

# Right: FCR prediction
ax2 = axes[1]
for v in G.V:
    for u in G.nbrs(v):
        if u > v:
            ax2.plot([pos[v][0], pos[u][0]], [pos[v][1], pos[u][1]], 'k-', alpha=0.3, lw=1)
for v in sorted(G.V):
    f = fcr_map[v]; d = G.depth[v]
    color = dc.get(f, 'gray')
    correct = (f == d) if d > 0 else True  # crater handled separately
    ax2.scatter(*pos[v], c=[color], s=200, zorder=5,
                marker='o' if correct else 'X', edgecolors='black', lw=1.5)
    ax2.annotate(f'FCR={f}', (pos[v][0], pos[v][1]-0.35), ha='center', va='top',
                 fontsize=6, zorder=6, color='darkblue')
ax2.legend(handles=[mpatches.Patch(color=dc[d], label=f'FCR={d}') for d in range(md+1)],
           loc='lower right', fontsize=9)
nc_correct = sum(1 for v in G.V if G.depth[v] > 0 and fcr_map[v] == G.depth[v])
nc_total = sum(1 for v in G.V if G.depth[v] > 0)
ax2.text(0.02, 0.02, f'Non-crater: {nc_correct}/{nc_total} ({100*nc_correct/nc_total:.0f}%)',
         transform=ax2.transAxes, fontsize=12, fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
ax2.set_title('Topological Prediction (FCR)', fontsize=14, fontweight='bold')
ax2.set_aspect('equal'); ax2.axis('off')

fig.suptitle('Topological Depth Detection in Volcano Graphs', fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('volcano_structure.png', dpi=150, bbox_inches='tight')
print("Saved: volcano_structure.png")
