#!/usr/bin/env python3
"""
Visualization 1: Spectral Gap Scaling

Plots the spectral gap γ_n and the normalized quantity n²·γ_n
for the bubble-rotation walk on S_n, demonstrating the conjectured
stabilization of n²·γ_n to a universal constant κ.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def bubble_rotation_generators(n):
    gens = set()
    for i in range(n - 1):
        p = list(range(n))
        p[i], p[i + 1] = p[i + 1], p[i]
        gens.add(tuple(p))
    rho = tuple((i + 1) % n for i in range(n))
    rho_inv = tuple((i - 1) % n for i in range(n))
    gens.add(rho)
    gens.add(rho_inv)
    return list(gens)


def compute_gap(n):
    perms = list(permutations(range(n)))
    idx = {p: i for i, p in enumerate(perms)}
    N = len(perms)
    gens = bubble_rotation_generators(n)
    k = len(gens)
    P = np.zeros((N, N))
    for i, s in enumerate(perms):
        for g in gens:
            t = tuple(g[s[j]] for j in range(n))
            P[i, idx[t]] += 1.0 / k
    eigs = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    return 1.0 - eigs[1], eigs


ns = list(range(3, 8))
gaps = []
n2_gaps = []
bounds = []

for n in ns:
    gap, _ = compute_gap(n)
    gaps.append(gap)
    n2_gaps.append(n ** 2 * gap)
    k = len(bubble_rotation_generators(n))
    bounds.append(k / (4.0 * n ** 4))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Spectral gap vs n
ax1 = axes[0]
ax1.semilogy(ns, gaps, 'bo-', linewidth=2, markersize=8, label='Actual gap γₙ')
ax1.semilogy(ns, bounds, 'r^--', linewidth=2, markersize=8, label='Lower bound |S|/(4n⁴)')
ax1.set_xlabel('n', fontsize=14)
ax1.set_ylabel('Spectral gap γₙ', fontsize=14)
ax1.set_title('Spectral Gap of Bubble-Rotation Walk', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xticks(ns)

# Plot 2: Normalized gap n²·γ_n
ax2 = axes[1]
ax2.plot(ns, n2_gaps, 'go-', linewidth=2, markersize=8, label='n²·γₙ')
ax2.axhline(y=np.mean(n2_gaps[-3:]), color='gray', linestyle='--', alpha=0.7,
            label=f'Mean (last 3) ≈ {np.mean(n2_gaps[-3:]):.3f}')
ax2.set_xlabel('n', fontsize=14)
ax2.set_ylabel('n² · γₙ', fontsize=14)
ax2.set_title('Normalized Gap (Conjectured to Stabilize)', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(ns)

# Plot 3: Eigenvalue spectrum for n=5
ax3 = axes[2]
_, eigs5 = compute_gap(5)
eigs5_real = np.sort(np.real(eigs5))[::-1]
ax3.bar(range(min(30, len(eigs5_real))), eigs5_real[:30], color='steelblue', alpha=0.7)
ax3.axhline(y=0, color='black', linewidth=0.5)
ax3.set_xlabel('Eigenvalue index', fontsize=14)
ax3.set_ylabel('Eigenvalue', fontsize=14)
ax3.set_title('Eigenvalue Spectrum (n=5, top 30)', fontsize=14)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")
