#!/usr/bin/env python3
"""
Visualization: Spectral Gaps of Cayley Graphs on SL₂(𝔽_p)

Visualizes the spectral gap data for canonical and random generating
pairs across small primes. Shows:
- Panel 1: Spectral gaps vs prime p for canonical generators
- Panel 2: Eigenvalue distribution comparison
- Panel 3: TV distance decay (mixing) for p=5

This demonstrates the key computational evidence for the spectral
expansion theorems proved formally.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
import random

# ─── Inline all needed functions ──────────────────────────────────────────

def mat_mul_mod(A, B, p):
    return np.array([
        [(A[0,0]*B[0,0] + A[0,1]*B[1,0]) % p,
         (A[0,0]*B[0,1] + A[0,1]*B[1,1]) % p],
        [(A[1,0]*B[0,0] + A[1,1]*B[1,0]) % p,
         (A[1,0]*B[0,1] + A[1,1]*B[1,1]) % p]
    ], dtype=int)

def mat_det_mod(A, p):
    return int((A[0,0]*A[1,1] - A[0,1]*A[1,0]) % p)

def mat_inv_mod(A, p):
    d_inv = pow(int(mat_det_mod(A, p)), p - 2, p)
    return np.array([
        [(A[1,1] * d_inv) % p, ((-A[0,1]) * d_inv) % p],
        [((-A[1,0]) * d_inv) % p, (A[0,0] * d_inv) % p]
    ], dtype=int)

def mat_to_tuple(A):
    return (int(A[0,0]), int(A[0,1]), int(A[1,0]), int(A[1,1]))

def enumerate_sl2(p):
    elements = []
    for a in range(1, p):
        a_inv = pow(a, p-2, p)
        for b in range(p):
            for c in range(p):
                d = ((1 + b*c) * a_inv) % p
                elements.append(np.array([[a, b], [c, d]], dtype=int))
    for b in range(1, p):
        b_inv = pow(b, p-2, p)
        c = (-b_inv) % p
        for d in range(p):
            elements.append(np.array([[0, b], [c, d]], dtype=int))
    return elements

def build_adj_and_spectral(elements, generators, p):
    n = len(elements)
    elem_to_idx = {mat_to_tuple(e): i for i, e in enumerate(elements)}
    adj = np.zeros((n, n), dtype=float)
    for i, g in enumerate(elements):
        for s in generators:
            sg = mat_mul_mod(s, g, p)
            j = elem_to_idx[mat_to_tuple(sg)]
            adj[i, j] = 1.0
    adj_norm = adj / len(generators)
    eigs = np.sort(np.linalg.eigvalsh(adj_norm))[::-1]
    return eigs

def compute_tv_evolution(p, num_steps=40):
    elements = enumerate_sl2(p)
    n = len(elements)
    elem_to_idx = {mat_to_tuple(e): i for i, e in enumerate(elements)}
    u = np.array([[1, 1], [0, 1]], dtype=int)
    v = np.array([[1, 0], [1, 1]], dtype=int)
    u_inv, v_inv = mat_inv_mod(u, p), mat_inv_mod(v, p)
    gens = [u, u_inv, v, v_inv]
    P = np.zeros((n, n))
    for i, g in enumerate(elements):
        for s in gens:
            sg = mat_mul_mod(s, g, p)
            j = elem_to_idx[mat_to_tuple(sg)]
            P[i, j] += 0.25
    dist = np.zeros(n)
    dist[elem_to_idx[mat_to_tuple(np.eye(2, dtype=int))]] = 1.0
    uniform = np.ones(n) / n
    tvs = []
    for _ in range(num_steps):
        tvs.append(0.5 * np.sum(np.abs(dist - uniform)))
        dist = dist @ P
    return tvs

# ─── Compute data ────────────────────────────────────────────────────────

primes = [3, 5, 7, 11, 13]
canonical_gaps = []
canonical_lam2 = []
all_eigenvalues = {}

for p in primes:
    elements = enumerate_sl2(p)
    u = np.array([[1, 1], [0, 1]], dtype=int)
    v = np.array([[1, 0], [1, 1]], dtype=int)
    u_inv, v_inv = mat_inv_mod(u, p), mat_inv_mod(v, p)
    gens = [u, u_inv, v, v_inv]
    eigs = build_adj_and_spectral(elements, gens, p)
    canonical_gaps.append(eigs[0] - eigs[1])
    canonical_lam2.append(eigs[1])
    all_eigenvalues[p] = eigs

# TV distance for p=5
tv_5 = compute_tv_evolution(5, 40)

# ─── Create figure ───────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Spectral gaps
ax1 = axes[0]
ax1.bar(range(len(primes)), canonical_gaps, color='#2196F3', alpha=0.8, width=0.6)
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels([f'p={p}' for p in primes])
ax1.set_ylabel('Spectral Gap (1 - λ₂)', fontsize=12)
ax1.set_title('Spectral Gap of Cay(SL₂(𝔽_p), {u±¹,v±¹})', fontsize=13)
ax1.set_ylim(0, max(canonical_gaps) * 1.3)
for i, g in enumerate(canonical_gaps):
    ax1.text(i, g + 0.005, f'{g:.3f}', ha='center', fontsize=9)

# Panel 2: Eigenvalue distributions
ax2 = axes[1]
ramanujan = 2 * np.sqrt(3) / 4
for i, p in enumerate([5, 7, 13]):
    eigs = all_eigenvalues[p]
    ax2.hist(eigs, bins=50, alpha=0.5, label=f'p={p}', density=True)
ax2.axvline(x=1, color='red', linestyle='--', linewidth=1.5, label='λ=1')
ax2.axvline(x=ramanujan, color='green', linestyle=':', linewidth=1.5,
            label=f'Ramanujan ({ramanujan:.3f})')
ax2.axvline(x=-ramanujan, color='green', linestyle=':', linewidth=1.5)
ax2.set_xlabel('Eigenvalue', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Eigenvalue Distribution of Cayley Graphs', fontsize=13)
ax2.legend(fontsize=9)

# Panel 3: TV distance decay
ax3 = axes[2]
steps = np.arange(len(tv_5))
ax3.semilogy(steps, tv_5, 'b-', linewidth=2, label='Random walk')
beta = 1 - canonical_gaps[1]  # p=5
ax3.semilogy(steps, [beta**n for n in steps], 'r--', linewidth=1.5,
             label=f'β^n (β={beta:.3f})')
ax3.set_xlabel('Number of Steps', fontsize=12)
ax3.set_ylabel('Total Variation Distance', fontsize=12)
ax3.set_title('Mixing on SL₂(𝔽₅): TV Distance Decay', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_ylim(1e-4, 1.5)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gaps_visualization.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gaps_visualization.png")
