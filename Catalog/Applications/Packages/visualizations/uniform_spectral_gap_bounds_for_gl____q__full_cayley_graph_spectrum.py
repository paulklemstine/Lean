#!/usr/bin/env python3
"""
Visualization: Full Cayley Graph Spectrum for GL₂(𝔽₅)

Shows the complete eigenvalue distribution of the Cayley graph
adjacency matrix, highlighting the spectral gap. This makes
the abstract spectral gap theorem (Theorem 7) visually concrete.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def mod_inverse(a, p):
    return pow(a % p, p - 2, p) % p

def mat_mul(A, B, q):
    return (A @ B) % q

def mat_det(A, q):
    return int((A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % q)

def mat_inv(A, q):
    det = mat_det(A, q)
    di = mod_inverse(det, q)
    return np.array([[A[1,1]*di%q, (-A[0,1])*di%q],
                     [(-A[1,0])*di%q, A[0,0]*di%q]]) % q

def charpoly_irreducible(A, q):
    tr = int((A[0,0] + A[1,1]) % q)
    det = mat_det(A, q)
    for x in range(q):
        if (x*x - tr*x + det) % q == 0:
            return False
    return True

def is_singer_like(A, q):
    return mat_det(A, q) != 0 and charpoly_irreducible(A, q)

def multiplicative_order(a, q):
    if a % q == 0: return 0
    val = a % q
    order, current = 1, val
    while current != 1:
        current = (current * val) % q
        order += 1
        if order > q: return 0
    return order

def is_primitive_det(A, q):
    det = mat_det(A, q)
    return det != 0 and multiplicative_order(det, q) == q - 1


q = 5
print(f"Building Cayley graph for GL₂(𝔽_{q})...")

# Enumerate GL₂(𝔽_q)
elements = []
for a, b, c, d in product(range(q), repeat=4):
    M = np.array([[a, b], [c, d]])
    if mat_det(M, q) != 0:
        elements.append(M)

n = len(elements)
print(f"|GL₂(𝔽_{q})| = {n}")

# Find certified pair
singer_g = None
for M in elements:
    if is_singer_like(M, q):
        singer_g = M
        break

prim_h = None
for M in elements:
    if is_primitive_det(M, q):
        prim_h = M
        break

print(f"Singer g = {singer_g.flatten().tolist()}")
print(f"Prim h = {prim_h.flatten().tolist()}")

g_inv = mat_inv(singer_g, q)
h_inv = mat_inv(prim_h, q)
generators = [singer_g, g_inv, prim_h, h_inv]

# Build adjacency matrix
def mat_to_tuple(M):
    return tuple(int(x) % q for x in M.flatten())

elem_idx = {mat_to_tuple(e): i for i, e in enumerate(elements)}

A = np.zeros((n, n))
for i, x in enumerate(elements):
    for s in generators:
        prod = mat_mul(x, s, q)
        j = elem_idx[mat_to_tuple(prod)]
        A[i, j] = 1.0

print("Computing eigenvalues...")
eigenvalues = np.linalg.eigvalsh(A)
eigenvalues = np.sort(eigenvalues)[::-1]

# Compute spectral gap
d = eigenvalues[0]
norm_eigs = eigenvalues / d
second = np.max(np.abs(norm_eigs[1:]))
gap = 1 - second

print(f"Degree = {d:.0f}")
print(f"Spectral gap γ = {gap:.6f}")
print(f"q · γ = {q * gap:.6f}")

# Create visualization
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Full eigenvalue distribution
axes[0].hist(norm_eigs, bins=50, color='steelblue', alpha=0.7, edgecolor='navy')
axes[0].axvline(x=1, color='red', linestyle='--', linewidth=2, label='λ₁ = 1')
axes[0].axvline(x=second, color='green', linestyle='--', linewidth=2, 
                label=f'|λ₂| = {second:.4f}')
axes[0].axvline(x=-second, color='green', linestyle='--', linewidth=2, alpha=0.5)
axes[0].set_xlabel('Normalized eigenvalue λ/d', fontsize=12)
axes[0].set_ylabel('Count', fontsize=12)
axes[0].set_title(f'Eigenvalue Distribution\nCay(GL₂(𝔽_{q}), S)', fontsize=13)
axes[0].legend(fontsize=10)

# Plot 2: Top eigenvalues (zoom into gap)
top_k = min(30, len(norm_eigs))
axes[1].bar(range(top_k), norm_eigs[:top_k], color='royalblue', alpha=0.7)
axes[1].axhline(y=1, color='red', linestyle='--', alpha=0.5)
axes[1].axhline(y=1-gap, color='green', linestyle='--', linewidth=2,
                label=f'1 - γ = {1-gap:.4f}')
axes[1].fill_between(range(top_k), 1-gap, 1, alpha=0.15, color='green')
axes[1].annotate(f'Spectral Gap\nγ = {gap:.4f}', 
                xy=(3, 1-gap/2), fontsize=11, fontweight='bold',
                ha='center', color='darkgreen')
axes[1].set_xlabel('Eigenvalue index', fontsize=12)
axes[1].set_ylabel('Normalized eigenvalue', fontsize=12)
axes[1].set_title(f'Top {top_k} Eigenvalues', fontsize=13)
axes[1].legend(fontsize=10)

# Plot 3: Eigenvalue sorted plot
axes[2].plot(range(len(norm_eigs)), norm_eigs, 'b-', linewidth=0.5)
axes[2].fill_between(range(len(norm_eigs)), 1-gap, 1, alpha=0.15, color='green')
axes[2].axhline(y=1, color='red', linestyle='--', alpha=0.5)
axes[2].axhline(y=-(1-gap), color='orange', linestyle='--', alpha=0.5)
axes[2].set_xlabel('Index', fontsize=12)
axes[2].set_ylabel('Normalized eigenvalue', fontsize=12)
axes[2].set_title(f'Complete Spectrum (n={n})', fontsize=13)

plt.suptitle(f'Cayley Graph Spectrum for Certified Pair in GL₂(𝔽_{q})\n'
            f'γ = {gap:.4f}, q·γ = {q*gap:.4f}', 
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('cayley_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved cayley_spectrum.png")
