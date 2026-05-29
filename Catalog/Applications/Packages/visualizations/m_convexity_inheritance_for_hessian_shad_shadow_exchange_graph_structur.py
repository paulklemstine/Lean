#!/usr/bin/env python3
"""
Visualization: M-Convex Shadow Structure

Visualizes the support sets and their shadows for U(3,5), showing how
the M-convex exchange structure is preserved through derivative shadows.
Each support element is a point in a projected 2D space, with edges
showing valid exchanges.

This script is fully self-contained — no local imports.
"""
import itertools
import matplotlib.pyplot as plt
import numpy as np
from typing import Set, Tuple

Vec = Tuple[int, ...]

def uniform_matroid_bases(n: int, r: int) -> Set[Vec]:
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def one_step_shadow(S: Set[Vec]) -> Set[Vec]:
    shadow = set()
    for alpha in S:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                v = list(alpha); v[i] -= 1; shadow.add(tuple(v))
    return shadow

def two_step_shadow(S: Set[Vec]) -> Set[Vec]:
    return one_step_shadow(one_step_shadow(S))

def exchange_edges(S: Set[Vec]):
    """Find all valid exchange edges."""
    edges = []
    S_list = list(S)
    n = len(S_list[0]) if S_list else 0
    for a in S_list:
        for t in range(n):
            if a[t] <= 0:
                continue
            for u in range(n):
                if t == u:
                    continue
                b = list(a); b[t] -= 1; b[u] += 1
                b = tuple(b)
                if b in S:
                    edges.append((a, b))
    return edges

def project_2d(vecs, seed=42):
    """Project high-dimensional vectors to 2D using random projection."""
    if not vecs:
        return np.array([]), np.array([])
    arr = np.array(list(vecs))
    rng = np.random.RandomState(seed)
    proj = rng.randn(arr.shape[1], 2)
    coords = arr @ proj
    return coords[:, 0], coords[:, 1]

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

n, r = 5, 3
bases = uniform_matroid_bases(n, r)
s1 = one_step_shadow(bases)
s2 = two_step_shadow(bases)

for ax, (S, title, color) in zip(axes, [
    (bases, f'U({r},{n}) Bases (d={r})', '#2196F3'),
    (s1, f'One-Step Shadow (d={r-1})', '#4CAF50'),
    (s2, f'Two-Step Shadow (d={r-2})', '#FF9800'),
]):
    S_list = list(S)
    x, y = project_2d(S_list)
    edges = exchange_edges(S)
    
    idx_map = {v: i for i, v in enumerate(S_list)}
    
    for a, b in edges:
        if a in idx_map and b in idx_map:
            i, j = idx_map[a], idx_map[b]
            ax.plot([x[i], x[j]], [y[i], y[j]], color=color, alpha=0.2, linewidth=0.8)
    
    ax.scatter(x, y, c=color, s=80, zorder=5, edgecolors='white', linewidth=1.5)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xlabel('Projection axis 1')
    ax.set_ylabel('Projection axis 2')
    
    n_edges = len(edges) // 2  # undirected
    ax.text(0.02, 0.98, f'|S| = {len(S)}\nExchanges = {n_edges}',
            transform=ax.transAxes, va='top', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.suptitle('M-Convexity Inheritance: Exchange Graphs Through Derivative Shadows',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_structure.png', dpi=150, bbox_inches='tight')
print("Saved shadow_structure.png")
