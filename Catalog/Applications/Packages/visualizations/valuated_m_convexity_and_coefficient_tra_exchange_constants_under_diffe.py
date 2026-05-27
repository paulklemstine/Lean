#!/usr/bin/env python3
"""
Visualization: Exchange Constants under Differentiation

Visualizes how the valuated exchange constant K changes as we take successive
partial derivatives of weighted uniform matroid polynomials. Each column shows
a different (n,d) configuration; each row shows a random weight assignment.

The key insight: exchange constants generally decrease or stay bounded under
differentiation, providing evidence for the stability of valuated M-convexity.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random

# ─── Inline utility functions (self-contained) ──────────────────────────────

def compute_exchange_constant(coeffs, n_vars, tol=1e-12):
    support = [e for e, c in coeffs.items() if abs(c) > tol]
    if len(support) <= 1:
        return 0.0
    max_ratio = 0.0
    for a in support:
        for b in support:
            for i in range(n_vars):
                if b[i] >= a[i]:
                    continue
                best_ratio = float('inf')
                for j in range(n_vars):
                    if a[j] >= b[j]:
                        continue
                    a_p = list(a); a_p[i] -= 1; a_p[j] += 1
                    b_p = list(b); b_p[i] += 1; b_p[j] -= 1
                    ca = coeffs.get(tuple(a_p), 0.0)
                    cb = coeffs.get(tuple(b_p), 0.0)
                    if abs(ca) > tol and abs(cb) > tol:
                        ratio = (coeffs[a] * coeffs[b]) / (ca * cb)
                        best_ratio = min(best_ratio, ratio)
                if best_ratio < float('inf'):
                    max_ratio = max(max_ratio, best_ratio)
    return max_ratio

def compute_derivative(coeffs, var, n_vars):
    result = {}
    for e, c in coeffs.items():
        if e[var] > 0:
            new_e = list(e)
            new_e[var] -= 1
            new_e = tuple(new_e)
            result[new_e] = result.get(new_e, 0.0) + c * e[var]
    return result

def weighted_uniform_polynomial(n, d, weights=None):
    bases = list(combinations(range(n), d))
    if weights is None:
        weights = {S: 1.0 for S in bases}
    coeffs = {}
    for S in bases:
        e = [0] * n
        for i in S:
            e[i] = 1
        coeffs[tuple(e)] = weights[S]
    return coeffs, n

# ─── Main visualization ─────────────────────────────────────────────────────

random.seed(42)

configs = [(4, 2), (4, 3), (5, 2), (5, 3)]
n_samples = 8

fig, axes = plt.subplots(2, 2, figsize=(12, 9))
fig.suptitle('Exchange Constants K under Successive Differentiation',
             fontsize=14, fontweight='bold')

for idx, (n, d) in enumerate(configs):
    ax = axes[idx // 2][idx % 2]
    ax.set_title(f'U({d},{n}): Weighted Uniform Matroid', fontsize=11)

    for sample in range(n_samples):
        bases = list(combinations(range(n), d))
        weights = {S: random.uniform(0.5, 5.0) for S in bases}
        coeffs, nv = weighted_uniform_polynomial(n, d, weights)

        K_values = []
        current = coeffs
        curr_degree = d

        for step in range(d + 1):
            supp = [e for e, c in current.items() if abs(c) > 1e-12]
            if len(supp) <= 1:
                K_values.append(0.0)
                break
            K = compute_exchange_constant(current, nv)
            K_values.append(K)
            if curr_degree <= 1:
                break
            current = compute_derivative(current, step % nv, nv)
            curr_degree -= 1

        steps = list(range(len(K_values)))
        color = plt.cm.viridis(sample / n_samples)
        ax.plot(steps, K_values, 'o-', color=color, alpha=0.7, linewidth=1.5, markersize=4)

    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='K=1')
    ax.set_xlabel('Derivative Level', fontsize=10)
    ax.set_ylabel('Exchange Constant K', fontsize=10)
    ax.set_xticks(range(d + 1))
    ax.set_xticklabels([f'∂^{i}' for i in range(d + 1)])
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('exchange_constants_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: exchange_constants_visualization.png")
