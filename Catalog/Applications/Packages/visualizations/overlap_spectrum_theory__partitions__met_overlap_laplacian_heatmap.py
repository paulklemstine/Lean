#!/usr/bin/env python3
"""
Visualization: Overlap Laplacian Heatmap and Properties

Visualizes the overlap Laplacian matrix as a heatmap, demonstrating:
- Zero row sums (Laplacian property)
- Trace = 2 × overlap degree (handshaking lemma)
- Block structure from overlap classes

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def compute_overlap_data(family):
    """Compute all overlap data (self-contained)."""
    n = len(family)
    
    # Overlap graph adjacency
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                adj[i][j] = adj[j][i] = True
    
    # Vertex degrees
    degrees = [sum(1 for j in range(n) if j != i and adj[i][j]) for i in range(n)]
    
    # Overlap degree (edge count)
    edge_count = sum(1 for i in range(n) for j in range(i+1, n) if adj[i][j])
    
    # Laplacian
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = degrees[i]
        for j in range(n):
            if i != j and adj[i][j]:
                L[i][j] = -1
    
    # Overlap classes (union-find)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py: parent[px] = py
    
    for i in range(n):
        for j in range(i+1, n):
            if adj[i][j]:
                union(i, j)
    
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    
    # Reorder indices by class
    ordered = []
    for cls in classes.values():
        ordered.extend(sorted(cls))
    
    return {
        'L': L, 'degrees': degrees, 'edge_count': edge_count,
        'classes': list(classes.values()), 'ordered': ordered, 'n': n
    }


# Define support families
families = {
    "Disjoint": [{1,2}, {3,4}, {5,6}, {7,8}],
    "Chain": [{1,2}, {2,3}, {3,4}, {4,5}],
    "Mixed": [{1,2,3}, {3,4}, {5,6}, {6,7,8}, {9}, {10,11}],
    "Star": [{1,2}, {1,3}, {1,4}, {1,5}],
}

fig, axes = plt.subplots(2, 4, figsize=(20, 10))

for col, (name, family) in enumerate(families.items()):
    data = compute_overlap_data(family)
    n = data['n']
    L = data['L']
    ordered = data['ordered']
    
    # Reorder Laplacian by overlap class
    L_reordered = [[L[ordered[i]][ordered[j]] for j in range(n)] for i in range(n)]
    L_arr = np.array(L_reordered)
    
    # Top row: Laplacian heatmap
    ax1 = axes[0][col]
    im = ax1.imshow(L_arr, cmap='RdBu_r', vmin=-1.5, vmax=max(data['degrees'])+0.5,
                    aspect='equal')
    ax1.set_title(f"{name}\nn={n}", fontsize=12, fontweight='bold')
    
    # Add cell values
    for i in range(n):
        for j in range(n):
            val = L_arr[i][j]
            color = 'white' if abs(val) > 1 else 'black'
            ax1.text(j, i, str(int(val)), ha='center', va='center', 
                    fontsize=9, color=color, fontweight='bold')
    
    # Add class boundaries
    cum = 0
    for cls in data['classes']:
        cum += len(cls)
        if cum < n:
            ax1.axhline(y=cum - 0.5, color='yellow', linewidth=2)
            ax1.axvline(x=cum - 0.5, color='yellow', linewidth=2)
    
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels([f'F{ordered[i]}' for i in range(n)], fontsize=8)
    ax1.set_yticklabels([f'F{ordered[i]}' for i in range(n)], fontsize=8)
    
    # Bottom row: Properties
    ax2 = axes[1][col]
    ax2.axis('off')
    
    trace = sum(L[i][i] for i in range(n))
    row_sums = [sum(L[i][j] for j in range(n)) for i in range(n)]
    spectrum = sorted([len(c) for c in data['classes']], reverse=True)
    
    props = [
        f"Trace(L) = {trace}",
        f"2 × edges = {2 * data['edge_count']}",
        f"Trace = 2×edges? {'✓' if trace == 2*data['edge_count'] else '✗'}",
        "",
        f"Row sums: {row_sums}",
        f"All zero? {'✓' if all(s == 0 for s in row_sums) else '✗'}",
        "",
        f"Classes: {len(data['classes'])}",
        f"Spectrum: {spectrum}",
        f"Sum = {sum(spectrum)} = n? {'✓' if sum(spectrum)==n else '✗'}",
    ]
    
    for i, prop in enumerate(props):
        color = 'green' if '✓' in prop else ('red' if '✗' in prop else 'black')
        ax2.text(0.1, 0.9 - i * 0.09, prop, fontsize=10, 
                transform=ax2.transAxes, va='top', color=color,
                fontfamily='monospace')

plt.suptitle("Overlap Laplacian: Structure, Trace Formula, and Zero Row Sums",
             fontsize=16, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig("viz_laplacian.png", dpi=150, bbox_inches='tight')
print("Saved viz_laplacian.png")
