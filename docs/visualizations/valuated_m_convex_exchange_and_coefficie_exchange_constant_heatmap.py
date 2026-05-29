#!/usr/bin/env python3
"""
Visualization: Exchange Constant Heatmap for Weighted U(2,3)

Visualizes how the optimal exchange constant K varies as we change
two of three weights in the weighted uniform matroid polynomial
p = a·x₀x₁ + b·x₀x₂ + c·x₁x₂.

Key insight: For degree-2 uniform matroid polynomials on 3 variables,
the exchange constant K=1 holds universally — the heatmap confirms
this theoretical result computationally.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations


def basis_vectors(n, d):
    vecs = []
    for S in combinations(range(n), d):
        v = [0] * n
        for i in S:
            v[i] = 1
        vecs.append(tuple(v))
    return vecs


def check_exchange_K(poly):
    support = list(poly.keys())
    n = len(support[0]) if support else 0
    optimal_K = 0.0
    for a in support:
        for b in support:
            for i in range(n):
                if b[i] >= a[i]:
                    continue
                best_ratio = float('inf')
                for j in range(n):
                    if a[j] >= b[j]:
                        continue
                    a_p = list(a); a_p[i] -= 1; a_p[j] += 1; a_pt = tuple(a_p)
                    b_p = list(b); b_p[i] += 1; b_p[j] -= 1; b_pt = tuple(b_p)
                    if a_p[i] < 0 or b_p[j] < 0:
                        continue
                    if a_pt not in poly or b_pt not in poly:
                        continue
                    lhs = poly[a] * poly[b]
                    rhs = poly[a_pt] * poly[b_pt]
                    if abs(rhs) > 1e-15:
                        best_ratio = min(best_ratio, lhs / rhs)
                if best_ratio != float('inf'):
                    optimal_K = max(optimal_K, best_ratio)
    return optimal_K


def partial_derivative(poly, var):
    result = {}
    for exp, coeff in poly.items():
        if exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            new_exp_t = tuple(new_exp)
            c = coeff * exp[var]
            result[new_exp_t] = result.get(new_exp_t, 0.0) + c
    return {k: v for k, v in result.items() if abs(v) > 1e-15}


# Generate data
bases = basis_vectors(3, 2)
N = 40
a_vals = np.linspace(0.1, 5.0, N)
b_vals = np.linspace(0.1, 5.0, N)
c_fixed = 1.0

K_orig = np.zeros((N, N))
K_deriv0 = np.zeros((N, N))
K_deriv1 = np.zeros((N, N))

for ia, a in enumerate(a_vals):
    for ib, b in enumerate(b_vals):
        weights = {bases[0]: a, bases[1]: b, bases[2]: c_fixed}
        K_orig[ib, ia] = check_exchange_K(weights)
        dp0 = partial_derivative(weights, 0)
        dp1 = partial_derivative(weights, 1)
        K_deriv0[ib, ia] = check_exchange_K(dp0) if dp0 else 0.0
        K_deriv1[ib, ia] = check_exchange_K(dp1) if dp1 else 0.0

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Original polynomial
im0 = axes[0].imshow(K_orig, extent=[0.1, 5.0, 0.1, 5.0],
                      origin='lower', aspect='auto', cmap='RdYlGn_r',
                      vmin=0.8, vmax=max(1.5, K_orig.max()))
axes[0].set_xlabel('Weight a', fontsize=12)
axes[0].set_ylabel('Weight b', fontsize=12)
axes[0].set_title('Optimal K for p\n(c = 1 fixed)', fontsize=13)
plt.colorbar(im0, ax=axes[0], label='K')

# Derivative ∂₀
im1 = axes[1].imshow(K_deriv0, extent=[0.1, 5.0, 0.1, 5.0],
                      origin='lower', aspect='auto', cmap='RdYlGn_r',
                      vmin=0.8, vmax=max(1.5, K_deriv0.max()))
axes[1].set_xlabel('Weight a', fontsize=12)
axes[1].set_ylabel('Weight b', fontsize=12)
axes[1].set_title('Optimal K for ∂₀p\n(derivative preserves K)', fontsize=13)
plt.colorbar(im1, ax=axes[1], label='K')

# Derivative ∂₁
im2 = axes[2].imshow(K_deriv1, extent=[0.1, 5.0, 0.1, 5.0],
                      origin='lower', aspect='auto', cmap='RdYlGn_r',
                      vmin=0.8, vmax=max(1.5, K_deriv1.max()))
axes[2].set_xlabel('Weight a', fontsize=12)
axes[2].set_ylabel('Weight b', fontsize=12)
axes[2].set_title('Optimal K for ∂₁p\n(derivative preserves K)', fontsize=13)
plt.colorbar(im2, ax=axes[2], label='K')

fig.suptitle('Valuated Exchange Constants: U(2,3) Weighted Matroid Polynomial',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('exchange_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved exchange_heatmap.png")
