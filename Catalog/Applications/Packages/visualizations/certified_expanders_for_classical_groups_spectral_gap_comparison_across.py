"""
Visualization 1: Spectral Gap Comparison Across Classical Groups

This script visualizes the eigenvalue distribution of Cayley graphs
constructed from certified generator pairs in different finite groups.
It shows how the spectral gap varies across GL₂(GF(p)) for different
primes p, demonstrating the uniformity of certified expansion.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# === Inline helper functions (self-contained) ===

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

def build_cayley_adjacency(elements, generators, p):
    n = len(elements)
    def key(M): return tuple(M.flatten() % p)
    idx_map = {key(e): i for i, e in enumerate(elements)}
    sym_gens = []
    for g in generators:
        sym_gens.append(g % p)
        gi = mat_inv_gfp(g, p)
        if gi is not None: sym_gens.append(gi % p)
    adj = np.zeros((n, n), dtype=int)
    for i, elem in enumerate(elements):
        for gen in sym_gens:
            prod = mat_mul_gfp(elem, gen, p)
            k = key(prod)
            if k in idx_map: adj[i, idx_map[k]] = 1
    return adj


# === Main visualization ===

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Certified generators for GL₂(GF(p))
generators_by_p = {
    3: (np.array([[0,1],[2,0]]), np.array([[1,1],[0,1]])),
    5: (np.array([[0,1],[4,0]]), np.array([[1,1],[0,1]])),
    7: (np.array([[0,1],[6,0]]), np.array([[1,1],[0,1]])),
}

gaps = []
for idx, p in enumerate([3, 5, 7]):
    s, t = generators_by_p[p]
    elements = enumerate_subgroup([s, t], p)
    adj = build_cayley_adjacency(elements, [s, t], p)
    eigenvalues = np.sort(np.real(np.linalg.eigvalsh(adj)))[::-1]

    # Normalize
    d = eigenvalues[0]
    normalized = eigenvalues / d

    ax = axes[idx]
    ax.hist(normalized, bins=50,
            edgecolor='black', alpha=0.7, color='#2196F3')

    # Mark spectral gap
    lambda2 = max(abs(normalized[1]), abs(normalized[-1]))
    gap = 1 - lambda2
    gaps.append(gap)

    ax.axvline(x=1, color='#F44336', linewidth=2, label=f'λ₁/d = 1')
    ax.axvline(x=lambda2, color='#FF9800', linewidth=2, linestyle='--',
               label=f'|λ₂|/d = {lambda2:.3f}')
    ax.axvline(x=-lambda2, color='#FF9800', linewidth=2, linestyle='--')

    # Shade the gap
    ax.axvspan(lambda2, 1, alpha=0.15, color='#4CAF50', label=f'Gap = {gap:.3f}')

    ax.set_title(f'GL₂(GF({p}))  |G|={len(elements)}', fontsize=13, fontweight='bold')
    ax.set_xlabel('Normalized eigenvalue λ/d', fontsize=11)
    ax.set_ylabel('Count', fontsize=11)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(-1.1, 1.1)

plt.suptitle('Spectral Gap of Certified Cayley Graphs Across GL₂(GF(p))',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
print(f"Saved: viz_spectral_gap.png")
print(f"Normalized gaps: {dict(zip([3,5,7], [f'{g:.4f}' for g in gaps]))}")
