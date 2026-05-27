#!/usr/bin/env python3
"""
Visualization: Old vs New Certified Bounds vs Observed Threshold

Compares three quantities on a log scale:
1. The old 1/n² certified bound (conservative)
2. The new 1/n certified bound (sharp)
3. The numerically observed destruction threshold

Shows that the new bound closely tracks the observed threshold,
while the old bound becomes increasingly pessimistic with dimension.
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

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

for idx, k in enumerate([2, 3, 4]):
    ax = axes[idx]
    ns = list(range(k + 1, 18))
    observed = []
    old_bounds = []
    new_bounds = []
    ns_valid = []
    
    for n in ns:
        thresh, gap = find_destruction_threshold(n, k)
        if gap > 0:
            observed.append(thresh)
            old_bounds.append(gap / n**2)
            new_bounds.append(gap / n)
            ns_valid.append(n)
    
    if ns_valid:
        ax.semilogy(ns_valid, observed, 'ko-', label='Observed threshold', 
                     markersize=6, linewidth=2, zorder=3)
        ax.semilogy(ns_valid, new_bounds, 'b^--', label='New $\\varepsilon/n$ bound', 
                     markersize=7, linewidth=2)
        ax.semilogy(ns_valid, old_bounds, 'rv:', label='Old $\\varepsilon/n^2$ bound', 
                     markersize=6, linewidth=2)
        
        # Shade the gap between old and new
        ax.fill_between(ns_valid, old_bounds, new_bounds, alpha=0.15, color='green',
                        label='Improvement region')
    
    ax.set_xlabel('Dimension $n$', fontsize=13)
    ax.set_ylabel('Perturbation threshold $\\delta^*$', fontsize=13)
    ax.set_title(f'$e_{k}$: Bounds vs Observation', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')

plt.suptitle('The Gap Between Certified Bounds and Reality\nThe new $1/n$ bound nearly closes the gap', 
             fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('viz_bounds_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_bounds_comparison.png")
