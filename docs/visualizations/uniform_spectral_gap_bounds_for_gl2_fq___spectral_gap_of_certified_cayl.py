#!/usr/bin/env python3
"""
Visualization: Spectral Gap of Certified Cayley Graphs

This script computes and visualizes the eigenvalue spectrum of Cayley graphs
built from algebraically certified pairs in GL₂(𝔽_q) for small primes.
It shows how the spectral gap γ (distance from eigenvalue 1 to the next
largest eigenvalue) scales with q, testing the Uniform Certified Gap Conjecture.

The visualization reveals the representation-theoretic structure: distinct
clusters of eigenvalues corresponding to different irreducible representations
of GL₂(𝔽_q).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


# Self-contained matrix operations over F_q
def mat_det(M, q):
    return int((M[0,0]*M[1,1] - M[0,1]*M[1,0]) % q)

def mat_mul(A, B, q):
    return (A @ B) % q

def mat_inv(M, q):
    d = mat_det(M, q)
    if d == 0: return None
    d_inv = pow(d, -1, q)
    return (d_inv * np.array([[M[1,1],-M[0,1]],[-M[1,0],M[0,0]]], dtype=int)) % q

def charpoly_irred(M, q):
    tr = int((M[0,0]+M[1,1]) % q)
    det = mat_det(M, q)
    disc = (tr*tr - 4*det) % q
    if disc == 0: return False
    return pow(int(disc), (q-1)//2, q) != 1

def is_prim(a, q):
    if a % q == 0: return False
    x = 1
    for k in range(1, q):
        x = (x*a) % q
        if x == 1: return k == q-1
    return False

def find_pair_fast(q):
    I = np.eye(2, dtype=int)
    singers, prims = [], []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        det = mat_det(M, q)
        if det == 0: continue
        if np.array_equal(M%q, I): continue
        if charpoly_irred(M, q): singers.append(M%q)
        if is_prim(det, q): prims.append(M%q)
        if len(singers) > 30 and len(prims) > 30: break

    gl2_size = (q**2-1)*(q**2-q)
    for g in singers[:15]:
        for h in prims[:15]:
            gen = {tuple(I.flatten())}
            front = [I]
            gi, hi = mat_inv(g,q), mat_inv(h,q)
            if gi is None or hi is None: continue
            gs = [g, gi, h, hi]
            while front:
                nf = []
                for m in front:
                    for gen_ in gs:
                        p = mat_mul(m, gen_, q)
                        t = tuple(p.flatten())
                        if t not in gen:
                            gen.add(t)
                            nf.append(p)
                            if len(gen) >= gl2_size:
                                return g, h
                front = nf
            if len(gen) >= gl2_size:
                return g, h
    return None, None

def compute_spectrum(g, h, q):
    gl2 = []
    for a,b,c,d in product(range(q), repeat=4):
        M = np.array([[a,b],[c,d]], dtype=int)
        if mat_det(M, q) != 0:
            gl2.append(M)
    n = len(gl2)
    idx = {tuple(M.flatten()): i for i, M in enumerate(gl2)}
    gi, hi = mat_inv(g, q), mat_inv(h, q)
    gs = [g, gi, h, hi]
    A = np.zeros((n, n))
    for i, M in enumerate(gl2):
        for gen in gs:
            j = idx[tuple(mat_mul(M, gen, q).flatten())]
            A[i, j] = 1.0
    A /= 4.0
    return np.linalg.eigvalsh(A)


# Compute spectra for q = 5 and q = 7
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

primes = [5, 7]
gaps = []

for idx, q in enumerate(primes):
    g, h = find_pair_fast(q)
    if g is None:
        continue
    eigs = compute_spectrum(g, h, q)
    eigs_sorted = np.sort(eigs)[::-1]
    gap = eigs_sorted[0] - max(abs(eigs_sorted[1]), abs(eigs_sorted[-1]))
    gaps.append((q, gap))

    # Histogram of eigenvalues
    axes[idx, 0].hist(eigs, bins=80, color='steelblue', alpha=0.8, edgecolor='navy')
    axes[idx, 0].axvline(x=1.0, color='red', linestyle='--', linewidth=2, label=f'λ₁ = 1')
    axes[idx, 0].axvline(x=eigs_sorted[1], color='orange', linestyle='--', linewidth=1.5,
                         label=f'λ₂ = {eigs_sorted[1]:.4f}')
    axes[idx, 0].set_title(f'Eigenvalue Spectrum: GL₂(𝔽_{q}), |G| = {len(eigs)}',
                           fontsize=12, fontweight='bold')
    axes[idx, 0].set_xlabel('Eigenvalue')
    axes[idx, 0].set_ylabel('Count')
    axes[idx, 0].legend(fontsize=9)
    axes[idx, 0].text(0.02, 0.95, f'γ = {gap:.5f}\nq·γ = {q*gap:.5f}',
                      transform=axes[idx, 0].transAxes, fontsize=10,
                      verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Sorted eigenvalues
    axes[idx, 1].plot(range(len(eigs_sorted)), eigs_sorted, 'b-', linewidth=0.5, alpha=0.7)
    axes[idx, 1].axhline(y=1.0, color='red', linestyle='--', alpha=0.5)
    axes[idx, 1].set_title(f'Sorted Eigenvalues: GL₂(𝔽_{q})', fontsize=12, fontweight='bold')
    axes[idx, 1].set_xlabel('Index')
    axes[idx, 1].set_ylabel('Eigenvalue')

plt.suptitle('Spectral Structure of Certified Cayley Graphs for GL₂(𝔽_q)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gaps.png")

for q, gap in gaps:
    print(f"q = {q}: γ = {gap:.6f}, q·γ = {q*gap:.6f}")
