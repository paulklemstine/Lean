"""
Visualization 2: Vertex Expansion Heatmap

This script creates a heatmap showing vertex expansion ratios |∂A|/|A|
for different subset sizes in Cayley graphs from certified generators.
The heatmap compares expansion across multiple generator pairs and
group families, illustrating the certificate-driven expansion guarantee.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# === Inline helper functions ===

def mat_mul_gfp(A, B, p):
    return np.mod(A.astype(int) @ B.astype(int), p).astype(int)

def mat_det_gfp(M, p):
    n = M.shape[0]
    if n == 1: return int(M[0,0]) % p
    if n == 2: return (int(M[0,0])*int(M[1,1]) - int(M[0,1])*int(M[1,0])) % p
    det = 0
    for j in range(n):
        minor = np.delete(np.delete(M, 0, axis=0), j, axis=1)
        det = (det + ((-1)**j) * int(M[0,j]) * mat_det_gfp(minor, p)) % p
    return det

def mat_inv_gfp(M, p):
    det = mat_det_gfp(M, p)
    if det == 0: return None
    n = M.shape[0]
    det_inv = pow(det, p-2, p)
    adj = np.zeros_like(M)
    for i in range(n):
        for j in range(n):
            minor = np.delete(np.delete(M, i, axis=0), j, axis=1)
            adj[j,i] = ((-1)**(i+j) * mat_det_gfp(minor, p) * det_inv) % p
    return adj.astype(int)

def enumerate_subgroup(generators, p, max_size=100000):
    n = generators[0].shape[0]
    identity = np.eye(n, dtype=int)
    def key(M): return tuple(M.flatten() % p)
    seen = {key(identity)}
    queue = [identity.copy()]
    elements = [identity.copy()]
    all_gens = []
    for g in generators:
        all_gens.append(g % p)
        gi = mat_inv_gfp(g, p)
        if gi is not None: all_gens.append(gi % p)
    idx = 0
    while idx < len(queue) and len(elements) < max_size:
        cur = queue[idx]; idx += 1
        for gen in all_gens:
            prod = mat_mul_gfp(cur, gen, p)
            k = key(prod)
            if k not in seen:
                seen.add(k)
                queue.append(prod.copy())
                elements.append(prod.copy())
    return elements


# === Main visualization ===

np.random.seed(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Test groups
groups = [
    ("GL₂(GF(3))", 3, np.array([[0,1],[2,0]]), np.array([[1,1],[0,1]])),
    ("GL₂(GF(5))", 5, np.array([[0,1],[4,0]]), np.array([[1,1],[0,1]])),
    ("GL₂(GF(7))", 7, np.array([[0,1],[6,0]]), np.array([[1,1],[0,1]])),
]

# Compute expansion for each group
subset_fractions = np.linspace(0.02, 0.5, 15)
expansion_data = []

for name, p, s, t in groups:
    elements = enumerate_subgroup([s, t], p)
    n = len(elements)
    def key(M): return tuple(M.flatten() % p)
    idx_map = {key(e): i for i, e in enumerate(elements)}
    sym_gens = [s % p, t % p]
    for g in [s, t]:
        gi = mat_inv_gfp(g, p)
        if gi is not None: sym_gens.append(gi % p)

    row = []
    for frac in subset_fractions:
        k = max(1, int(frac * n))
        if k > n // 2: k = n // 2

        min_ratio = float('inf')
        for trial in range(min(30, max(1, 500 // k))):
            subset_indices = set(np.random.choice(n, size=k, replace=False))
            boundary = set()
            for idx_val in subset_indices:
                elem = elements[idx_val]
                for gen in sym_gens:
                    prod = mat_mul_gfp(elem, gen, p)
                    ky = key(prod)
                    if ky in idx_map:
                        j = idx_map[ky]
                        if j not in subset_indices:
                            boundary.add(j)
            ratio = len(boundary) / k
            min_ratio = min(min_ratio, ratio)
        row.append(min_ratio)
    expansion_data.append(row)

# Heatmap
heatmap_data = np.array(expansion_data)
im = ax1.imshow(heatmap_data, aspect='auto', cmap='YlOrRd_r',
                vmin=0, vmax=max(2.0, heatmap_data.max()))
ax1.set_yticks(range(len(groups)))
ax1.set_yticklabels([g[0] for g in groups], fontsize=11)
ax1.set_xticks(range(0, len(subset_fractions), 3))
ax1.set_xticklabels([f'{f:.0%}' for f in subset_fractions[::3]], fontsize=10)
ax1.set_xlabel('Subset size (fraction of group)', fontsize=12)
ax1.set_title('Minimum Vertex Expansion |∂A|/|A|', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax1, label='Expansion ratio')

# Add values to heatmap
for i in range(len(groups)):
    for j in range(len(subset_fractions)):
        ax1.text(j, i, f'{heatmap_data[i,j]:.2f}', ha='center', va='center',
                fontsize=7, color='black' if heatmap_data[i,j] > 1 else 'white')

# Line plot comparison
for i, (name, p, s, t) in enumerate(groups):
    ax2.plot(subset_fractions * 100, expansion_data[i],
             marker='o', markersize=4, linewidth=2, label=name)

ax2.set_xlabel('Subset size (% of group)', fontsize=12)
ax2.set_ylabel('Min vertex expansion |∂A|/|A|', fontsize=12)
ax2.set_title('Expansion vs Subset Size', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=0)
ax2.axhline(y=0, color='red', linewidth=1, linestyle='--', alpha=0.5)

plt.suptitle('Certified Vertex Expansion Across Classical Group Families',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_expansion_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_expansion_heatmap.png")
