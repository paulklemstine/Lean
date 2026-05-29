#!/usr/bin/env python3
"""
Visualization: βη-Reduction Graph

Visualizes the reduction graph for a simply typed λ-term, showing how
β-reductions and η-contractions navigate toward a unique normal form.
Each node is a term; edges are labeled β or η. The normal form is highlighted.

This illustrates the Church-Rosser property: all reduction paths converge.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass
from typing import Optional

# --- Inline term representation ---

@dataclass(frozen=True)
class V:
    i: int
    def size(self): return 1
    def __repr__(self): return f"x{self.i}"

@dataclass(frozen=True)
class A:
    f: 'T'
    a: 'T'
    def size(self): return 1 + self.f.size() + self.a.size()
    def __repr__(self): return f"({self.f} {self.a})"

@dataclass(frozen=True)
class L:
    b: 'T'
    def size(self): return 1 + self.b.size()
    def __repr__(self): return f"(λ.{self.b})"

T = V | A | L

def rn(f, t):
    match t:
        case V(i): return V(f(i))
        case A(g, a): return A(rn(f, g), rn(f, a))
        case L(b): return L(rn(lambda i: 0 if i==0 else f(i-1)+1, b))

def sb(s, t):
    match t:
        case V(i): return s(i)
        case A(f, a): return A(sb(s, f), sb(s, a))
        case L(b):
            def lf(i):
                return V(0) if i==0 else rn(lambda j: j+1, s(i-1))
            return L(sb(lf, b))

def hfv(t, v):
    match t:
        case V(i): return i==v
        case A(f,a): return hfv(f,v) or hfv(a,v)
        case L(b): return hfv(b,v+1)

def beta_top(t):
    if isinstance(t, A) and isinstance(t.f, L):
        return sb(lambda i: t.a if i==0 else V(i-1), t.f.b)
    return None

def eta_top(t):
    if isinstance(t, L) and isinstance(t.b, A) and t.b.a == V(0) and not hfv(t.b.f, 0):
        return rn(lambda i: i-1, t.b.f)
    return None

def all_reducts(t):
    """Find all one-step β and η reducts."""
    results = []
    r = beta_top(t)
    if r: results.append((r, 'β'))
    r = eta_top(t)
    if r: results.append((r, 'η'))
    match t:
        case A(f, a):
            for (rf, l) in all_reducts(f):
                results.append((A(rf, a), l))
            for (ra, l) in all_reducts(a):
                results.append((A(f, ra), l))
        case L(b):
            for (rb, l) in all_reducts(b):
                results.append((L(rb), l))
    return results

def build_graph(start, max_nodes=30):
    """BFS to build the reduction graph."""
    nodes = {repr(start): start}
    edges = []
    queue = [start]
    visited = {repr(start)}

    while queue and len(nodes) < max_nodes:
        t = queue.pop(0)
        for (r, label) in all_reducts(t):
            rk = repr(r)
            if rk not in visited:
                visited.add(rk)
                nodes[rk] = r
                queue.append(r)
            edges.append((repr(t), rk, label))

    return nodes, edges

# --- Layout and plotting ---

def is_normal(t):
    return len(all_reducts(t)) == 0

# Example term: (λ.λ.(x1 x0)) (λ.x0) = apply K to id
# K = λ.λ.x1, id = λ.x0
# K id = λ.x0 (discards second arg, returns id's arg? No...)
# Actually let's use: (λ.x0) ((λ.x0) x0)  --- id applied to (id x0)
# Or: (λ.(x0 x0)) (λ.x0)  --- self-apply id

start = A(L(A(V(0), V(0))), L(V(0)))  # (λ.(x0 x0)) (λ.x0)

# Also add η-example: λ.((λ.x0) x0) which is λ.(id x0) ≡η id
start2 = L(A(L(V(0)), V(0)))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax, s, title in [(axes[0], start, "β-reduction: (λ.x₀ x₀)(λ.x₀)"),
                       (axes[1], start2, "βη-reduction: λ.(λ.x₀) x₀")]:
    nodes, edges = build_graph(s, max_nodes=15)
    node_list = list(nodes.keys())
    n = len(node_list)

    # Simple layout: layered by distance from start
    pos = {}
    layers = {}
    from collections import deque
    dist = {repr(s): 0}
    q = deque([repr(s)])
    adj = {}
    for (a, b, l) in edges:
        adj.setdefault(a, []).append(b)
    while q:
        c = q.popleft()
        for nb in adj.get(c, []):
            if nb not in dist:
                dist[nb] = dist[c] + 1
                q.append(nb)

    for nk in node_list:
        d = dist.get(nk, 0)
        layers.setdefault(d, []).append(nk)

    for d, nks in layers.items():
        for i, nk in enumerate(nks):
            x = (i - (len(nks)-1)/2) * 2.0
            y = -d * 1.5
            pos[nk] = (x, y)

    # Draw edges
    for (a, b, label) in edges:
        if a in pos and b in pos:
            xa, ya = pos[a]
            xb, yb = pos[b]
            color = '#2196F3' if label == 'β' else '#FF9800'
            ax.annotate("", xy=(xb, yb), xytext=(xa, ya),
                        arrowprops=dict(arrowstyle="->", color=color, lw=1.5))
            mx, my = (xa+xb)/2 + 0.15, (ya+yb)/2 + 0.1
            ax.text(mx, my, label, fontsize=9, color=color, fontweight='bold')

    # Draw nodes
    for nk in node_list:
        if nk in pos:
            x, y = pos[nk]
            t = nodes[nk]
            nrm = is_normal(t)
            color = '#4CAF50' if nrm else '#BBDEFB'
            ec = '#1B5E20' if nrm else '#1565C0'
            lw = 3 if nrm else 1
            circle = plt.Circle((x, y), 0.4, facecolor=color,
                               edgecolor=ec, linewidth=lw, zorder=5)
            ax.add_patch(circle)
            label = repr(t)
            if len(label) > 15:
                label = label[:12] + "…"
            ax.text(x, y, label, ha='center', va='center', fontsize=6,
                    fontweight='bold' if nrm else 'normal', zorder=6)

    ax.set_xlim(-4, 4)
    ymin = min(p[1] for p in pos.values()) - 1 if pos else -3
    ax.set_ylim(ymin, 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.axis('off')

# Legend
beta_patch = mpatches.Patch(color='#2196F3', label='β-reduction')
eta_patch = mpatches.Patch(color='#FF9800', label='η-contraction')
nf_patch = mpatches.Patch(color='#4CAF50', label='Normal form')
fig.legend(handles=[beta_patch, eta_patch, nf_patch], loc='lower center',
          ncol=3, fontsize=10)

plt.suptitle("βη-Reduction Graphs: All Paths Lead to Normal Form",
            fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_reduction_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_reduction_graph.png")
