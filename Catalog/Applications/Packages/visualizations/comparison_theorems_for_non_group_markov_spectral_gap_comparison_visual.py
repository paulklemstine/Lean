#!/usr/bin/env python3
"""
Visualization: Markov Chain Comparison Theorem

Visualizes how the comparison bound λ(P) ≥ λ(Q)/(b·C) tracks the actual
spectral gap as chain parameters vary. Shows that the bound is always
valid (as proven formally) and its tightness depends on structural similarity.
"""

import numpy as np
import matplotlib.pyplot as plt


def spectral_gap(pi, P):
    n = len(pi)
    if n <= 1: return 1.0
    D = np.diag(np.sqrt(np.maximum(pi, 1e-15)))
    Di = np.diag(1.0 / np.sqrt(np.maximum(pi, 1e-15)))
    M = D @ P @ Di
    ev = np.sort(np.real(np.linalg.eigvals(M)))[::-1]
    return 1.0 - ev[1]


def comparison_constant(pi, P, Q):
    n = len(pi)
    D = np.diag(np.sqrt(pi))
    Di = np.diag(1.0 / np.sqrt(np.maximum(pi, 1e-15)))
    LP = np.eye(n) - D @ P @ Di
    LQ = np.eye(n) - D @ Q @ Di
    _, S, Vt = np.linalg.svd(LP)
    S_inv = np.where(S > 1e-10, 1.0/S, 0.0)
    M = Vt.T @ np.diag(S_inv) @ Vt @ LQ
    ev = np.real(np.linalg.eigvals(M))
    return float(np.max(ev[np.abs(ev) > 1e-10]))


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Gap vs laziness parameter
n = 6
alphas = np.linspace(0.05, 0.95, 50)
gaps_P = []
bounds = []

# Reference chain
Q = np.zeros((n, n))
for i in range(n):
    Q[i][i] = 0.3
    for j in range(n):
        if abs(i-j) == 1:
            Q[i][j] = 0.7 / max(1, sum(1 for k in range(n) if abs(i-k)==1))
pi = np.ones(n) / n
gQ = spectral_gap(pi, Q)

for alpha in alphas:
    P = np.zeros((n, n))
    for i in range(n):
        P[i][i] = alpha
        nbrs = [j for j in range(n) if abs(i-j) == 1]
        for j in nbrs:
            P[i][j] = (1-alpha) / len(nbrs)
    gP = spectral_gap(pi, P)
    C = comparison_constant(pi, P, Q)
    gaps_P.append(gP)
    bounds.append(gQ / C if C > 0 else 0)

ax = axes[0]
ax.plot(alphas, gaps_P, 'b-', linewidth=2, label='Actual λ(P)')
ax.plot(alphas, bounds, 'r--', linewidth=2, label='Bound λ(Q)/C')
ax.fill_between(alphas, bounds, gaps_P, alpha=0.15, color='green')
ax.set_xlabel('Laziness α', fontsize=12)
ax.set_ylabel('Spectral Gap', fontsize=12)
ax.set_title('Comparison Bound vs Actual Gap\n(Path Walk, n=6)', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 2: Tightness ratio
tightness = [b/g if g > 0 else 0 for b, g in zip(bounds, gaps_P)]
ax = axes[1]
ax.plot(alphas, tightness, 'g-', linewidth=2)
ax.axhline(y=1.0, color='k', linestyle=':', alpha=0.5, label='Perfect tightness')
ax.set_xlabel('Laziness α', fontsize=12)
ax.set_ylabel('Bound / Actual', fontsize=12)
ax.set_title('Tightness of Comparison Bound', fontsize=13)
ax.set_ylim(0, 1.1)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Comparison constant C
Cs = []
for alpha in alphas:
    P = np.zeros((n, n))
    for i in range(n):
        P[i][i] = alpha
        nbrs = [j for j in range(n) if abs(i-j) == 1]
        for j in nbrs:
            P[i][j] = (1-alpha) / len(nbrs)
    C = comparison_constant(pi, P, Q)
    Cs.append(C)

ax = axes[2]
ax.plot(alphas, Cs, 'purple', linewidth=2)
ax.set_xlabel('Laziness α', fontsize=12)
ax.set_ylabel('Comparison Constant C', fontsize=12)
ax.set_title('Dirichlet Form Ratio\nC = sup E_Q(f)/E_P(f)', fontsize=13)
ax.grid(True, alpha=0.3)

plt.suptitle('Markov Chain Comparison Theorem: Spectral Gap Certification',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_comparison.png")
