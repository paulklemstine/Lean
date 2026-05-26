#!/usr/bin/env python3
"""
Visualization 3: Fiedler Eigenvalue vs Tropical Stability
Tests the spectral conjecture: higher Fiedler eigenvalue → lower instability.
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

def fiedler(n, edges):
    L = np.zeros((n, n))
    for u,v in edges:
        L[u,u] += 1; L[v,v] += 1; L[u,v] -= 1; L[v,u] -= 1
    eigs = np.sort(np.linalg.eigvalsh(L))
    return max(eigs[1], 0.0) if len(eigs) >= 2 else 0.0

rng = np.random.RandomState(123)
n_clouds = 40
fiedler_vals, instab_vals = [], []

for _ in range(n_clouds):
    n_pts = 15
    X = rng.randn(n_pts, 2) * rng.uniform(0.5, 2.0)
    D = pairwise_distances(X)
    thresholds = np.linspace(0, np.max(D)*0.6, 20)
    profile = tropical_barcode(D, thresholds)
    
    min_f = float('inf')
    for t in thresholds:
        edges = vietoris_rips_edges(D, t)
        if count_components(n_pts, edges) == 1:
            f = fiedler(n_pts, edges)
            if f > 0: min_f = min(min_f, f)
    if min_f == float('inf'): continue
    
    instabilities = []
    for _ in range(10):
        X_p = X + rng.randn(n_pts, 2) * 0.1
        D_p = pairwise_distances(X_p)
        p_p = tropical_barcode(D_p, thresholds)
        instabilities.append(np.max(np.abs(profile.astype(int) - p_p.astype(int))))
    
    fiedler_vals.append(min_f)
    instab_vals.append(np.mean(instabilities))

fig, ax = plt.subplots(figsize=(8, 6))
scatter = ax.scatter(fiedler_vals, instab_vals, c=fiedler_vals, cmap='coolwarm',
                     s=80, edgecolors='k', linewidth=0.5, zorder=3)

# Trend line
z = np.polyfit(fiedler_vals, instab_vals, 1)
p = np.poly1d(z)
x_line = np.linspace(min(fiedler_vals), max(fiedler_vals), 100)
ax.plot(x_line, p(x_line), 'k--', alpha=0.5, linewidth=2, label=f'Linear fit (slope={z[0]:.2f})')

corr = np.corrcoef(fiedler_vals, instab_vals)[0, 1]
ax.set_xlabel('Minimum Fiedler eigenvalue λ*', fontsize=13)
ax.set_ylabel('Mean tropical barcode instability', fontsize=13)
ax.set_title(f'Spectral Conjecture Test (r = {corr:.3f})', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
plt.colorbar(scatter, ax=ax, label='λ*')

plt.tight_layout()
plt.savefig('viz_fiedler.png', dpi=150, bbox_inches='tight')
print(f"Saved viz_fiedler.png (correlation = {corr:.4f})")
