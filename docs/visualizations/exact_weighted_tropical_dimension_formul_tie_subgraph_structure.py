#!/usr/bin/env python3
"""
Visualization: Tie Subgraph Structure

Illustrates how different weight assignments on the same graph produce
different tie subgraphs, and how the weighted Betti number and visible
defect change accordingly. Shows the original graph with all edges,
highlighting tie edges in red and non-tie edges in gray.

This directly visualizes the core definition: the tie subgraph captures
the "degeneracy geometry" where tropical ties can occur.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import defaultdict
import math


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

def is_tie_edge(G, u, v):
    wuv = G.w[(u,v)]
    t_u = any(G.w[(u,k)] == wuv for k in G.adj[u] if k != v)
    t_v = any(G.w[(v,k)] == G.w[(v,u)] for k in G.adj[v] if k != u)
    return t_u or t_v

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

def tie_sub(G):
    T = WG(G.n)
    for u,v in G.edges():
        if is_tie_edge(G, u, v):
            T.add(u, v, G.w[(u,v)])
    return T

def cr(G, S):
    if not S: return 0
    e = sum(1 for u,v in G.edges() if u in S and v in S)
    return max(0, e + len(cc(G, S)) - len(S))

def vc(G, q, S):
    return sum(1 for c in cc(G, S) if any(v in G.adj.get(q, set()) for v in c))


# ── Layout computation ──

def circular_layout(n, center=(0,0), radius=1.0):
    pos = {}
    for i in range(n):
        angle = 2 * math.pi * i / n - math.pi / 2
        pos[i] = (center[0] + radius * math.cos(angle),
                  center[1] + radius * math.sin(angle))
    return pos


# ── Draw a weighted graph ──

def draw_graph(ax, G, pos, q, S, title, show_ties=True):
    """Draw graph with tie edges highlighted."""
    T = tie_sub(G)

    # Draw edges
    for u, v in G.edges():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        is_tie = is_tie_edge(G, u, v)

        if is_tie and show_ties:
            ax.plot(x, y, '-', color='#E74C3C', linewidth=3.0, alpha=0.9, zorder=1)
        else:
            ax.plot(x, y, '-', color='#BDC3C7', linewidth=1.5, alpha=0.6, zorder=1)

        # Edge weight label
        mx, my = (pos[u][0] + pos[v][0]) / 2, (pos[u][1] + pos[v][1]) / 2
        # Offset perpendicular to edge
        dx, dy = pos[v][0] - pos[u][0], pos[v][1] - pos[u][1]
        length = max(math.sqrt(dx**2 + dy**2), 0.01)
        nx, ny = -dy/length * 0.12, dx/length * 0.12
        ax.text(mx + nx, my + ny, str(G.w[(u,v)]),
                fontsize=8, ha='center', va='center',
                color='#2C3E50', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.15', facecolor='white',
                         edgecolor='none', alpha=0.8))

    # Draw vertices
    for v in range(G.n):
        if v == q:
            color = '#F39C12'  # gold for basepoint
            size = 400
        elif v in S:
            color = '#3498DB'  # blue for S
            size = 300
        else:
            color = '#95A5A6'  # gray
            size = 250
        ax.scatter(pos[v][0], pos[v][1], s=size, c=color,
                  edgecolors='#2C3E50', linewidths=1.5, zorder=3)
        ax.text(pos[v][0], pos[v][1], str(v), fontsize=11,
               ha='center', va='center', fontweight='bold',
               color='white', zorder=4)

    # Compute and display invariants
    beta = cr(T, S)
    kappa = vc(T, q, S)
    dim = beta + kappa
    tie_count = sum(1 for _ in T.edges())

    info = f"β₁ʷ={beta}  κʷ={kappa}  dim={dim}\ntie edges: {tie_count}/{sum(1 for _ in G.edges())}"
    ax.text(0.02, 0.02, info, transform=ax.transAxes, fontsize=9,
            verticalalignment='bottom', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')


# ── Create figure ──

fig, axes = plt.subplots(2, 3, figsize=(18, 12))

n = 6
edge_list = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0), (0,3), (1,4), (2,5)]
pos = circular_layout(n, radius=1.1)
q = 0
S = {1, 2, 3, 4, 5}

weight_configs = [
    ("Uniform: all w=1", [1,1,1,1,1,1,1,1,1]),
    ("Generic: all distinct", [1,2,3,5,7,11,13,17,19]),
    ("Partial tie: some equal", [1,1,2,2,3,3,4,5,6]),
    ("Strong resonance", [1,1,1,2,2,2,3,3,3]),
    ("Two-level weights", [1,1,1,1,1,1,2,2,2]),
    ("Single tie pair", [1,2,3,4,5,6,7,8,1]),
]

for idx, (title, weights) in enumerate(weight_configs):
    ax = axes[idx // 3][idx % 3]
    G = WG(n)
    for (u, v), w in zip(edge_list, weights):
        G.add(u, v, w)
    draw_graph(ax, G, pos, q, S, title)

# Legend
legend_elements = [
    mpatches.Patch(color='#E74C3C', label='Tie edge (weight degeneracy)'),
    mpatches.Patch(color='#BDC3C7', label='Non-tie edge (generic)'),
    mpatches.Patch(color='#F39C12', label='Basepoint q'),
    mpatches.Patch(color='#3498DB', label='Vertex in S'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4,
          fontsize=11, frameon=True, fancybox=True)

plt.suptitle('Tie Subgraph Structure Under Different Weight Assignments\n'
             'Red edges form the degeneracy subgraph; their cycle rank gives β₁ʷ',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0.05, 1, 0.93])
plt.savefig('tie_subgraph.png', dpi=150, bbox_inches='tight')
print("Saved tie_subgraph.png")
