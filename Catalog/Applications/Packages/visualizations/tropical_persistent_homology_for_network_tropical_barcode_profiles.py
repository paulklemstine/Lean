#!/usr/bin/env python3
"""
Visualization 1: Tropical Barcode Profiles
Shows how tropical nullity grows along a Vietoris-Rips filtration
for point clouds in different dimensions.
"""
import numpy as np
import matplotlib.pyplot as plt

def pairwise_distances(X):
    diff = X[:, np.newaxis, :] - X[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))

def vietoris_rips_edges(D, t):
    n = D.shape[0]
    return [(i,j) for i in range(n) for j in range(i+1,n) if D[i,j] <= t]

def count_components(n, edges):
    parent = list(range(n))
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    def union(x,y):
        px, py = find(x), find(y)
        if px != py: parent[py] = px
    for u,v in edges: union(u,v)
    return len(set(find(i) for i in range(n)))

def tropical_nullity(n, edges):
    return len(edges) + count_components(n, edges) - n

def tropical_barcode(D, thresholds):
    n = D.shape[0]
    return np.array([tropical_nullity(n, vietoris_rips_edges(D, t)) for t in thresholds])

fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
rng = np.random.RandomState(42)

for idx, dim in enumerate([2, 3, 5]):
    X = rng.randn(20, dim)
    D = pairwise_distances(X)
    thresholds = np.linspace(0, np.max(D) * 0.75, 40)
    profile = tropical_barcode(D, thresholds)
    
    ax = axes[idx]
    ax.fill_between(thresholds, profile, alpha=0.3, color=f'C{idx}')
    ax.plot(thresholds, profile, 'o-', markersize=3, color=f'C{idx}', linewidth=1.5)
    ax.set_xlabel('Filtration threshold', fontsize=11)
    ax.set_ylabel('Tropical nullity', fontsize=11)
    ax.set_title(f'Dimension {dim}', fontsize=13)
    ax.grid(True, alpha=0.3)

fig.suptitle('Tropical Barcode Profiles — Monotone Growth of Cycle Rank', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_barcode_profiles.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_profiles.png")
