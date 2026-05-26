#!/usr/bin/env python3
"""
Visualization 2: Stability Under Perturbation
Demonstrates the stability theorem: tropical barcode distance ≤ edge symmetric difference.
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

rng = np.random.RandomState(42)
n_points, dim = 20, 2
X = rng.randn(n_points, dim)
D = pairwise_distances(X)
thresholds = np.linspace(0, np.max(D) * 0.7, 30)
profile_orig = tropical_barcode(D, thresholds)

epsilons = np.linspace(0.01, 0.3, 15)
tb_dists, max_sds = [], []

for eps in epsilons:
    dists_eps, sds_eps = [], []
    for _ in range(15):
        X_p = X + rng.randn(n_points, dim) * eps
        D_p = pairwise_distances(X_p)
        p = tropical_barcode(D_p, thresholds)
        td = np.max(np.abs(profile_orig.astype(int) - p.astype(int)))
        sd = max(len(set(vietoris_rips_edges(D, t)).symmetric_difference(
                    set(vietoris_rips_edges(D_p, t)))) for t in thresholds)
        dists_eps.append(td)
        sds_eps.append(sd)
    tb_dists.append(np.mean(dists_eps))
    max_sds.append(np.mean(sds_eps))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

ax1.plot(epsilons, tb_dists, 'o-', label='Tropical barcode distance', color='C0', linewidth=2)
ax1.plot(epsilons, max_sds, 's-', label='Max edge symm. diff. (upper bound)', color='C3', linewidth=2)
ax1.fill_between(epsilons, tb_dists, max_sds, alpha=0.15, color='C3')
ax1.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax1.set_ylabel('Distance', fontsize=12)
ax1.set_title('Stability Theorem Verification', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

ax2.scatter(max_sds, tb_dists, c=epsilons, cmap='viridis', s=60, edgecolors='k', linewidth=0.5)
ax2.plot([0, max(max_sds)], [0, max(max_sds)], 'k--', alpha=0.5, label='y = x (bound)')
cbar = plt.colorbar(ax2.collections[0], ax=ax2, label='ε')
ax2.set_xlabel('Max edge symmetric difference', fontsize=12)
ax2.set_ylabel('Tropical barcode distance', fontsize=12)
ax2.set_title('Point-wise: tb_dist ≤ edge_symm_diff', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability.png")
