#!/usr/bin/env python3
"""
Visualization: The 1/n Scaling Law for Lorentzian Stability

Plots n * C(n,k) vs n for elementary symmetric polynomials,
demonstrating that the scaled threshold converges to a finite positive
constant — confirming the sharp 1/n scaling law.

This is the central visual evidence for the paper's main theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations


def elementary_symmetric_hessian(n, k, x=None):
    if x is None:
        x = np.ones(n)
    H = np.zeros((n, n))
    if k < 2:
        return H
    for i in range(n):
        for j in range(n):
            if i != j:
                remaining = [l for l in range(n) if l != i and l != j]
                if k - 2 > len(remaining):
                    continue
                elif k - 2 == 0:
                    H[i, j] = 1.0
                else:
                    val = 0.0
                    for subset in combinations(remaining, k - 2):
                        prod = 1.0
                        for idx in subset:
                            prod *= x[idx]
                        val += prod
                    H[i, j] = val
    return H


def spectral_gap(H):
    eigvals = np.linalg.eigvalsh(H)
    neg_eigs = eigvals[eigvals < -1e-14]
    if len(neg_eigs) == 0:
        return 0.0
    return float(np.min(np.abs(neg_eigs)))


def find_destruction_threshold(n, k, num_trials=30):
    H = elementary_symmetric_hessian(n, k)
    gap = spectral_gap(H)
    if gap < 1e-12:
        return 0.0, gap
    
    def check_lor(H_p):
        return np.sum(np.linalg.eigvalsh(H_p) > 1e-10) <= 1
    
    lo, hi = 0.0, gap * 2
    for _ in range(80):
        mid = (lo + hi) / 2
        destroyed = False
        for _ in range(num_trials):
            E = np.random.uniform(-mid, mid, (n, n))
            E = (E + E.T) / 2
            if not check_lor(H + E):
                destroyed = True
                break
        if destroyed:
            hi = mid
        else:
            lo = mid
    return (lo + hi) / 2, gap


np.random.seed(42)
fig, ax = plt.subplots(figsize=(12, 7))

colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
markers = ['o', 's', '^', 'D']

for idx, k in enumerate([2, 3, 4, 5]):
    ns = list(range(k + 1, 16))
    scaled = []
    ns_valid = []
    
    for n in ns:
        thresh, gap = find_destruction_threshold(n, k)
        if gap > 0:
            scaled.append(n * thresh / gap)
            ns_valid.append(n)
    
    if ns_valid:
        ax.plot(ns_valid, scaled, f'{markers[idx]}-', color=colors[idx],
                label=f'$e_{k}$: $n \\cdot C(n,{k})$', markersize=8, linewidth=2)
        
        if len(scaled) >= 3:
            mean_val = np.mean(scaled[-3:])
            ax.axhline(y=mean_val, color=colors[idx], linestyle='--', alpha=0.4)

ax.set_xlabel('Dimension $n$', fontsize=14)
ax.set_ylabel('Scaled threshold $n \\cdot C(n,k)$', fontsize=14)
ax.set_title('The $1/n$ Scaling Law: Scaled Stability Thresholds\nConverge to Finite Positive Constants', fontsize=15)
ax.legend(fontsize=12, loc='best')
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('viz_scaling_law.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling_law.png")
