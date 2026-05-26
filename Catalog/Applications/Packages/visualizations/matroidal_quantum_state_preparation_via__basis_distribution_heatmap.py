"""
Visualization: Weighted Basis Distribution Heatmap

Visualizes the probability distribution over matroid bases for the graphic
matroid of K₄ (complete graph on 4 vertices) under different weight functions.
Shows how the Lorentzian structure of the basis polynomial manifests as a
smooth, log-concave distribution over spanning trees.
"""

import itertools
import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.size'] = 11

# --- Inline matroid construction ---
def graphic_matroid_k4():
    edges = [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
    n = 4
    def is_forest(es):
        parent = list(range(n))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in es:
            u, v = edges[idx]
            rx, ry = find(u), find(v)
            if rx == ry: return False
            parent[rx] = ry
        return True
    def spans(es):
        adj = {i: set() for i in range(n)}
        for idx in es:
            u, v = edges[idx]
            adj[u].add(v); adj[v].add(u)
        visited = set(); stack = [0]
        while stack:
            nd = stack.pop()
            if nd in visited: continue
            visited.add(nd); stack.extend(adj[nd] - visited)
        return len(visited) == n
    bases = []
    for combo in itertools.combinations(range(6), 3):
        fs = frozenset(combo)
        if is_forest(fs) and spans(fs):
            bases.append(sorted(combo))
    return edges, bases

edges, bases = graphic_matroid_k4()
n_bases = len(bases)

# Three different weight scenarios
scenarios = {
    "Uniform w=1": {i: 1.0 for i in range(6)},
    "Linear w=i+1": {i: float(i+1) for i in range(6)},
    "Exponential w=2^i": {i: 2.0**i for i in range(6)},
}

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

for ax, (title, w) in zip(axes, scenarios.items()):
    probs = []
    labels = []
    for B in bases:
        bw = math.prod(w[e] for e in B)
        probs.append(bw)
        edge_strs = [f"e{e}" for e in B]
        labels.append("\n".join(edge_strs))
    
    Z = sum(probs)
    probs = [p/Z for p in probs]
    
    colors = plt.cm.YlOrRd(np.array(probs) / max(probs))
    
    bars = ax.bar(range(n_bases), probs, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel("Spanning Tree Index")
    ax.set_ylabel("Probability")
    ax.set_xticks(range(n_bases))
    ax.set_xticklabels([str(i) for i in range(n_bases)], fontsize=8)
    ax.set_ylim(0, max(probs) * 1.15)
    
    # Annotate top 3
    sorted_idx = sorted(range(n_bases), key=lambda i: -probs[i])
    for rank, idx in enumerate(sorted_idx[:3]):
        tree_edges = [edges[e] for e in bases[idx]]
        ax.annotate(f"{probs[idx]:.3f}", (idx, probs[idx]),
                   ha='center', va='bottom', fontsize=8,
                   fontweight='bold' if rank == 0 else 'normal')

fig.suptitle("Weighted Basis Distribution: Spanning Trees of K₄",
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_basis_distribution.png", dpi=150, bbox_inches='tight')
print("Saved viz_basis_distribution.png")
