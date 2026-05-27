#!/usr/bin/env python3
"""
Visualization: Spectral Gap Universality for Hybrid Cayley Walks

This script visualizes the core mathematical discovery: adding bounded
global generators to a locally diffusive random walk cannot change the
spectral gap scaling order. The ratio γ_hybrid/γ_local stays bounded.

Self-contained — all functions are inlined.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def build_transition(elements, generators, group_op):
    n = len(elements)
    k = len(generators)
    idx = {g: i for i, g in enumerate(elements)}
    P = np.zeros((n, n))
    for i, x in enumerate(elements):
        for s in generators:
            j = idx[group_op(x, s)]
            P[i, j] += 1.0 / k
    return P


def spectral_gap(P):
    eigs = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    return 1.0 - eigs[1]


def torus_data(n):
    elts = [(i, j) for i in range(n) for j in range(n)]
    op = lambda x, y: ((x[0]+y[0])%n, (x[1]+y[1])%n)
    S_L = [(1,0), (n-1,0), (0,1), (0,n-1)]
    S_G = [(1,1), (n-1,n-1)]
    S_H = list(set(S_L + S_G))
    P_L = build_transition(elts, S_L, op)
    P_H = build_transition(elts, S_H, op)
    return spectral_gap(P_L), spectral_gap(P_H)


# Compute data
ns = list(range(3, 30))
gaps_L, gaps_H, ratios = [], [], []
for n in ns:
    gL, gH = torus_data(n)
    gaps_L.append(gL)
    gaps_H.append(gH)
    ratios.append(gH / gL)

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Locality-Protected Spectral Scaling on (ℤ/nℤ)²',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Spectral gaps
ax = axes[0]
ax.semilogy(ns, gaps_L, 'b-o', markersize=4, linewidth=1.5,
            label='Local: {±e₁, ±e₂}')
ax.semilogy(ns, gaps_H, 'r-s', markersize=4, linewidth=1.5,
            label='Hybrid: +{±(1,1)}')
ax.semilogy(ns, [4*np.pi**2/n**2 for n in ns], 'k--', alpha=0.4,
            label='Reference ~ n⁻²')
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Spectral gap γ', fontsize=12)
ax.set_title('Both gaps scale as Θ(n⁻²)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Ratio
ax = axes[1]
ax.plot(ns, ratios, 'g-o', markersize=5, linewidth=2)
ax.axhline(y=4/3, color='k', linestyle='--', alpha=0.5,
           label=f'Exact ratio = 4/3')
ax.fill_between(ns, 1.0, 2.0, alpha=0.1, color='green',
                label='Bounded region')
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('γ_hybrid / γ_local', fontsize=12)
ax.set_title('Ratio is exactly 4/3 (constant!)', fontsize=11)
ax.set_ylim(0.5, 2.5)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Dirichlet form comparison
ax = axes[2]
# Random function Dirichlet energies
n_test = 10
elts = [(i, j) for i in range(n_test) for j in range(n_test)]
idx = {g: i for i, g in enumerate(elts)}
op = lambda x, y: ((x[0]+y[0])%n_test, (x[1]+y[1])%n_test)
S_L = [(1,0), (n_test-1,0), (0,1), (0,n_test-1)]
S_G = [(1,1), (n_test-1,n_test-1)]
S_H = list(set(S_L + S_G))

np.random.seed(42)
E_Ls, E_Hs = [], []
for _ in range(500):
    f = np.random.randn(len(elts))
    E_L = sum((f[idx[op(elts[i], s)]] - f[i])**2
              for i in range(len(elts)) for s in S_L)
    E_H = sum((f[idx[op(elts[i], s)]] - f[i])**2
              for i in range(len(elts)) for s in S_H)
    E_Ls.append(E_L)
    E_Hs.append(E_H)

bound = 1 + len(S_G) * 4  # L=2, so L²=4
ax.scatter(E_Ls, E_Hs, alpha=0.3, s=10, color='blue', label='Random functions')
max_E = max(max(E_Ls), max(E_Hs))
ax.plot([0, max_E], [0, max_E], 'k-', alpha=0.5, label='E_H = E_L')
ax.plot([0, max_E/bound], [0, max_E], 'r--', alpha=0.5,
        label=f'E_H = {bound} · E_L (bound)')
ax.set_xlabel('E_local(f)', fontsize=12)
ax.set_ylabel('E_hybrid(f)', fontsize=12)
ax.set_title('Dirichlet Form Comparison', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_spectral_universality.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_universality.png")
