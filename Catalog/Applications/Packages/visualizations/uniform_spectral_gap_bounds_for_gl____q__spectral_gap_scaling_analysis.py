#!/usr/bin/env python3
"""
Visualization: Spectral Gap Scaling for Certified Expanders

Plots q·γ(S) vs q for certified pairs in GL₂(𝔽_q), testing the
Uniform Certified Gap Conjecture: q·γ ≥ C > 0.

The key insight: if q·γ stabilizes to a positive constant as q grows,
the conjecture holds and certified pairs yield uniformly good expanders.
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
    if a % q == 0:
        return 0
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

def projective_line_points(q):
    return [(1, b) for b in range(q)] + [(0, 1)]

def projective_action(M, point, q):
    a, b = point
    na = (M[0,0]*a + M[0,1]*b) % q
    nb = (M[1,0]*a + M[1,1]*b) % q
    if na != 0:
        return (1, (nb * mod_inverse(na, q)) % q)
    return (0, 1)

def projective_spectral_gap(generators, q):
    points = projective_line_points(q)
    n = len(points)
    pt_idx = {p: i for i, p in enumerate(points)}
    A = np.zeros((n, n))
    for M in generators:
        for i, p in enumerate(points):
            j = pt_idx[projective_action(M, p, q)]
            A[i, j] += 1
    eigs = np.linalg.eigvalsh(A)
    eigs = np.sort(eigs)[::-1]
    d = eigs[0]
    if d == 0: return 0
    norm = eigs / d
    return 1 - np.max(np.abs(norm[1:]))

def find_first_certified_pair(q):
    """Find the first certified pair for prime q."""
    singer_g = None
    for a, b, c, d in product(range(q), repeat=4):
        M = np.array([[a, b], [c, d]])
        if is_singer_like(M, q):
            singer_g = M
            break
    if singer_g is None:
        return None, None
    
    prim_h = None
    for a, b, c, d in product(range(q), repeat=4):
        M = np.array([[a, b], [c, d]])
        if is_primitive_det(M, q):
            prim_h = M
            break
    return singer_g, prim_h


# Compute data
primes = [5, 7, 11, 13, 17, 19, 23]
q_vals = []
proj_gaps = []
q_times_gaps = []

for q in primes:
    g, h = find_first_certified_pair(q)
    if g is not None and h is not None:
        gens = [g, mat_inv(g, q), h, mat_inv(h, q)]
        gap = projective_spectral_gap(gens, q)
        q_vals.append(q)
        proj_gaps.append(gap)
        q_times_gaps.append(q * gap)

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Spectral gap vs q
axes[0].plot(q_vals, proj_gaps, 'bo-', markersize=8, linewidth=2)
axes[0].set_xlabel('Prime q', fontsize=12)
axes[0].set_ylabel('Projective Spectral Gap γ_proj', fontsize=12)
axes[0].set_title('Spectral Gap vs Prime', fontsize=14)
axes[0].grid(True, alpha=0.3)

# Plot 2: q·γ vs q (should stabilize if conjecture holds)
axes[1].plot(q_vals, q_times_gaps, 'rs-', markersize=8, linewidth=2)
axes[1].axhline(y=min(q_times_gaps) if q_times_gaps else 0, 
                color='green', linestyle='--', alpha=0.7, label=f'Min = {min(q_times_gaps):.3f}')
axes[1].set_xlabel('Prime q', fontsize=12)
axes[1].set_ylabel('q · γ_proj', fontsize=12)
axes[1].set_title('Normalized Gap (Conjecture Test)', fontsize=14)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Plot 3: Eigenvalue spectrum for q=5
if q_vals:
    q_demo = 5
    g, h = find_first_certified_pair(q_demo)
    if g is not None and h is not None:
        gens = [g, mat_inv(g, q_demo), h, mat_inv(h, q_demo)]
        points = projective_line_points(q_demo)
        n = len(points)
        pt_idx = {p: i for i, p in enumerate(points)}
        A = np.zeros((n, n))
        for M in gens:
            for i, p in enumerate(points):
                j = pt_idx[projective_action(M, p, q_demo)]
                A[i, j] += 1
        eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
        axes[2].bar(range(len(eigs)), eigs/eigs[0], color='purple', alpha=0.7)
        axes[2].axhline(y=1, color='red', linestyle='--', alpha=0.5)
        axes[2].set_xlabel('Eigenvalue index', fontsize=12)
        axes[2].set_ylabel('Normalized eigenvalue', fontsize=12)
        axes[2].set_title(f'Projective Spectrum (q={q_demo})', fontsize=14)
        axes[2].grid(True, alpha=0.3)

plt.suptitle('Certified Expanders: Spectral Gap Analysis for GL₂(𝔽_q)', 
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")
