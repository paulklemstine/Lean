"""
Visualization: M-Convex Exchange Graph

Visualizes the M-convex exchange structure on a support set.
Nodes are support elements; edges connect pairs (α, β) where
M-convex exchange produces a valid swap. The graph structure
reveals the connectivity that prevents cancellation in derivative fibers.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def full_degree_simplex(n, r):
    if n == 1:
        return {(r,)}
    result = set()
    for v in range(r + 1):
        for rest in full_degree_simplex(n - 1, r - v):
            result.add((v,) + rest)
    return result


def mconvex_exchange_edges(S):
    """Find all exchange edges in the M-convex graph."""
    S_list = sorted(S)
    n = len(S_list[0])
    edges = []
    
    for a_idx, alpha in enumerate(S_list):
        for b_idx, beta in enumerate(S_list):
            if a_idx >= b_idx:
                continue
            for i in range(n):
                if alpha[i] > beta[i]:
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            ex = list(alpha)
                            ex[i] -= 1
                            ex[j] += 1
                            if tuple(ex) in S:
                                edges.append((a_idx, b_idx))
                                break
                    break
    return S_list, edges


def barycentric_coords(vec):
    """Convert a 3D integer vector to 2D barycentric coordinates."""
    s = sum(vec)
    if s == 0:
        return (0, 0)
    x = vec[1] + 0.5 * vec[2]
    y = vec[2] * np.sqrt(3) / 2
    return (x / s * 2, y / s * 2)


fig, axes = plt.subplots(1, 3, figsize=(16, 5.5))

# ─── Panel 1: Degree-2 simplex in 3 vars ───
S1 = full_degree_simplex(3, 2)
nodes1, edges1 = mconvex_exchange_edges(S1)

ax = axes[0]
positions = {i: barycentric_coords(v) for i, v in enumerate(nodes1)}

for i, j in edges1:
    x = [positions[i][0], positions[j][0]]
    y = [positions[i][1], positions[j][1]]
    ax.plot(x, y, 'b-', alpha=0.3, linewidth=1)

for i, v in enumerate(nodes1):
    x, y = positions[i]
    ax.plot(x, y, 'o', markersize=12, color='steelblue', 
            markeredgecolor='black', markeredgewidth=1)
    ax.annotate(str(v), (x, y), ha='center', va='center', fontsize=6,
                fontweight='bold', color='white')

ax.set_title(f'Degree-2, 3 vars\n|S|={len(S1)}, edges={len(edges1)}',
             fontsize=11, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

# ─── Panel 2: Degree-3 simplex in 3 vars ───
S2 = full_degree_simplex(3, 3)
nodes2, edges2 = mconvex_exchange_edges(S2)

ax = axes[1]
positions2 = {i: barycentric_coords(v) for i, v in enumerate(nodes2)}

for i, j in edges2:
    x = [positions2[i][0], positions2[j][0]]
    y = [positions2[i][1], positions2[j][1]]
    ax.plot(x, y, 'b-', alpha=0.2, linewidth=1)

for i, v in enumerate(nodes2):
    x, y = positions2[i]
    ax.plot(x, y, 'o', markersize=10, color='darkorange',
            markeredgecolor='black', markeredgewidth=1)
    ax.annotate(str(v), (x, y), ha='center', va='center', fontsize=5,
                fontweight='bold', color='white')

ax.set_title(f'Degree-3, 3 vars\n|S|={len(S2)}, edges={len(edges2)}',
             fontsize=11, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

# ─── Panel 3: Partial M-convex set ───
S3 = {(2,2,0), (2,1,1), (2,0,2), (1,2,1), (1,1,2), (0,2,2)}
nodes3, edges3 = mconvex_exchange_edges(S3)

ax = axes[2]
positions3 = {i: barycentric_coords(v) for i, v in enumerate(nodes3)}

for i, j in edges3:
    x = [positions3[i][0], positions3[j][0]]
    y = [positions3[i][1], positions3[j][1]]
    ax.plot(x, y, 'b-', alpha=0.3, linewidth=1.5)

for i, v in enumerate(nodes3):
    x, y = positions3[i]
    ax.plot(x, y, 'o', markersize=12, color='forestgreen',
            markeredgecolor='black', markeredgewidth=1)
    ax.annotate(str(v), (x, y), ha='center', va='center', fontsize=6,
                fontweight='bold', color='white')

ax.set_title(f'Partial M-convex (deg 4)\n|S|={len(S3)}, edges={len(edges3)}',
             fontsize=11, fontweight='bold')
ax.set_aspect('equal')
ax.axis('off')

fig.suptitle('M-Convex Exchange Graphs: Connectivity Structure',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_exchange_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_exchange_graph.png")
