"""
Visualization: Jacobian Group Landscape

Shows the distribution of Jacobian group structures (as direct sums
of cyclic groups) for random Erdős-Rényi graphs. Each bar represents
a distinct isomorphism class of the Jacobian, colored by the number
of cyclic summands (rank). This reveals the arithmetic diversity of
random graph Jacobians.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
from functools import reduce
from collections import Counter

# ── Inline algorithms ──

def smith_normal_form(M):
    A = M.copy().astype(int)
    rows, cols = A.shape
    n = min(rows, cols)
    for k in range(n):
        changed = True
        while changed:
            changed = False
            sub = A[k:, k:]
            nz = np.argwhere(sub != 0)
            if len(nz) == 0: break
            mv, mp = float('inf'), None
            for pos in nz:
                v = abs(sub[pos[0], pos[1]])
                if v < mv: mv, mp = v, (pos[0]+k, pos[1]+k)
            if mp[0] != k: A[[k, mp[0]]] = A[[mp[0], k]]
            if mp[1] != k: A[:, [k, mp[1]]] = A[:, [mp[1], k]]
            if A[k,k] < 0: A[k,:] = -A[k,:]
            if A[k,k] == 0: break
            for i in range(k+1, rows):
                if A[i,k] != 0:
                    q = A[i,k]//A[k,k]; A[i,:] -= q*A[k,:]
                    if A[i,k] != 0: changed = True
            for j in range(k+1, cols):
                if A[k,j] != 0:
                    q = A[k,j]//A[k,k]; A[:,j] -= q*A[:,k]
                    if A[k,j] != 0: changed = True
    diag = [abs(A[i,i]) for i in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if diag[i] and diag[j]:
                g = gcd(diag[i], diag[j]); diag[j] = diag[i]*diag[j]//g; diag[i] = g
    return diag

def graph_jacobian_factors(n, edges):
    A = np.zeros((n,n), dtype=int)
    for i,j in edges: A[i,j] = A[j,i] = 1
    L = np.diag(A.sum(axis=1)) - A
    idx = list(range(1, n))
    Lr = L[np.ix_(idx, idx)]
    return sorted([d for d in smith_normal_form(Lr) if d > 1])

def random_connected_graph(n, p):
    while True:
        edges = [(i,j) for i in range(n) for j in range(i+1,n) if np.random.random() < p]
        adj = {i: set() for i in range(n)}
        for i,j in edges: adj[i].add(j); adj[j].add(i)
        visited, queue = {0}, [0]
        while queue:
            v = queue.pop(0)
            for u in adj[v]:
                if u not in visited: visited.add(u); queue.append(u)
        if len(visited) == n: return edges

# ── Sampling ──
np.random.seed(77)
n = 8
p_edge = 0.5
num_samples = 500

group_types = Counter()
for _ in range(num_samples):
    edges = random_connected_graph(n, p_edge)
    factors = graph_jacobian_factors(n, edges)
    label = " × ".join(f"Z/{d}" for d in factors) if factors else "trivial"
    group_types[label] += 1

# Sort by frequency
sorted_types = sorted(group_types.items(), key=lambda x: -x[1])
top_k = min(20, len(sorted_types))
labels = [t[0] for t in sorted_types[:top_k]]
counts = [t[1] for t in sorted_types[:top_k]]
if len(sorted_types) > top_k:
    labels.append("other")
    counts.append(sum(t[1] for t in sorted_types[top_k:]))

# Color by number of cyclic summands
def rank_of_label(label):
    if label == "trivial" or label == "other":
        return 0
    return label.count("×") + 1

colors_map = {0: '#9E9E9E', 1: '#2196F3', 2: '#FF9800', 3: '#4CAF50',
              4: '#F44336', 5: '#9C27B0', 6: '#00BCD4'}
bar_colors = [colors_map.get(rank_of_label(l), '#795548') for l in labels]

# ── Plotting ──
fig, ax = plt.subplots(figsize=(14, 6))
bars = ax.barh(range(len(labels)), counts, color=bar_colors,
               edgecolor='black', linewidth=0.5, alpha=0.85)
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=9)
ax.set_xlabel('Frequency', fontsize=12)
ax.set_title(f'Distribution of Jacobian Group Types\n'
             f'G({n}, {p_edge}), {num_samples} random connected graphs',
             fontsize=14, fontweight='bold')
ax.invert_yaxis()
ax.grid(True, alpha=0.3, axis='x')

# Add frequency labels
for bar, count in zip(bars, counts):
    ax.text(bar.get_width() + 1, bar.get_y() + bar.get_height()/2,
            f'{count} ({100*count/num_samples:.1f}%)',
            va='center', fontsize=8)

# Legend for ranks
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=colors_map[r], label=f'Rank {r}')
                   for r in sorted(set(rank_of_label(l) for l in labels))
                   if r in colors_map]
ax.legend(handles=legend_elements, loc='lower right', fontsize=9)

plt.tight_layout()
plt.savefig('viz_jacobian_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_jacobian_landscape.png")
