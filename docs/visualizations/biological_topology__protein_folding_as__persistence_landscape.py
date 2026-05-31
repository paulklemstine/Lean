import numpy as np
import matplotlib.pyplot as plt

def compute_distance_matrix(coords):
    diff = coords[:, np.newaxis, :] - coords[np.newaxis, :, :]
    return np.sqrt(np.sum(diff**2, axis=-1))

def compute_persistence_intervals(dist_matrix):
    n = dist_matrix.shape[0]
    edges = sorted((dist_matrix[i,j], i, j) for i in range(n) for j in range(i+1, n))
    parent = list(range(n))
    rank_arr = [0] * n
    birth = [0.0] * n
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return False
        if rank_arr[rx] < rank_arr[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank_arr[rx] == rank_arr[ry]: rank_arr[rx] += 1
        return True
    intervals = []
    for dist, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            younger = rj if birth[ri] <= birth[rj] else ri
            intervals.append((birth[younger], dist))
            union(i, j)
    return intervals

def total_persistence(intervals):
    return sum(d - b for b, d in intervals)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
n = 25
radii = np.linspace(3, 25, 30)
tp_values = []
for r in radii:
    tps = []
    for seed in range(20):
        np.random.seed(seed * 100 + int(r * 10))
        coords = np.random.randn(n, 3)
        coords *= r / np.max(np.linalg.norm(coords, axis=1))
        dm = compute_distance_matrix(coords)
        tps.append(total_persistence(compute_persistence_intervals(dm)))
    tp_values.append((np.mean(tps), np.std(tps)))
means = [v[0] for v in tp_values]
stds = [v[1] for v in tp_values]
axes[0].fill_between(radii, [m-s for m,s in zip(means,stds)], [m+s for m,s in zip(means,stds)], alpha=0.3)
axes[0].plot(radii, means, 'o-', markersize=3)
axes[0].set_xlabel('Fold Radius'); axes[0].set_ylabel('Total Persistence')
axes[0].set_title('TP vs Compactness')
np.random.seed(42)
coords = np.random.randn(20, 3) * 8 / np.max(np.linalg.norm(np.random.randn(20,3), axis=1))
dm = compute_distance_matrix(coords)
intervals = sorted(compute_persistence_intervals(dm), key=lambda x: x[1]-x[0], reverse=True)
for i, (b, d) in enumerate(intervals):
    axes[1].barh(i, d-b, left=b, height=0.8, alpha=0.7)
axes[1].set_xlabel('Distance'); axes[1].set_title('H0 Barcode')
ns = np.arange(2, 101)
axes[2].plot(ns, ns*(ns-1)//2, 'b-', lw=2, label='n(n-1)/2')
axes[2].plot(ns, ns, 'r--', lw=1.5, label='n')
axes[2].set_xlabel('Atoms'); axes[2].set_title('Gradient Dimension')
axes[2].legend(); axes[2].set_yscale('log')
plt.tight_layout()
plt.savefig('persistence_landscape.png', dpi=150)
plt.close()
print('Saved persistence_landscape.png')