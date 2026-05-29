#!/usr/bin/env python3
"""
Visualization: Exchange Constant Heatmap for U(2,3) Polynomials

Visualizes how the minimal exchange constant K varies as we change the
coefficient ratios in the weighted uniform matroid polynomial
p = a*x0*x1 + b*x0*x2 + c*x1*x2.

With c=1 fixed, we vary a and b to create a heatmap showing K(a,b).
This reveals the geometry of the valuated exchange landscape.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
from fractions import Fraction

def compute_K_u23(a, b, c):
    """Compute minimal exchange constant for p = a*x0x1 + b*x0x2 + c*x1x2."""
    # Support: {(1,1,0), (1,0,1), (0,1,1)}
    # Exchange configurations:
    # (1,1,0) vs (0,1,1): coord 0 -> witness coord 2
    #   exchangeDown (1,1,0) 0 2 = (0,1,1), exchangeUp (0,1,1) 0 2 = (1,1,0)
    #   ratio = a*c / (c*a) = 1
    # (1,0,1) vs (0,1,1): coord 0 -> witness coord 1
    #   exchangeDown (1,0,1) 0 1 = (0,1,1), exchangeUp (0,1,1) 0 1 = (1,0,1)  [wait, need to check]
    #   Actually exchangeUp (0,1,1) 0 1 = (0,1,1) + e0 - e1 = (1,0,1)
    #   ratio = b*c / (c*b) = 1
    # (1,1,0) vs (1,0,1): coord 1 -> witness coord 2
    #   exchangeDown (1,1,0) 1 2 = (1,0,1), exchangeUp (1,0,1) 1 2 = (1,1,0)
    #   ratio = a*b / (b*a) = 1
    # And symmetric cases also give ratio 1
    # So K_min = 1 always for U(2,3)!
    
    # But let's also handle the case where exchangeDown gives a non-support vector
    # For U(2,3) all exchanges land back in support, so K=1.
    
    # For a more interesting visualization, let's compute K for higher degree
    return 1.0


def compute_K_general(poly, n):
    """Compute minimal exchange constant for a general polynomial."""
    support = [exp for exp, c in poly.items() if c != 0]
    if len(support) <= 1:
        return 0.0
    
    max_ratio = 0.0
    for a_exp in support:
        for b_exp in support:
            for i in range(n):
                if b_exp[i] >= a_exp[i]:
                    continue
                best_ratio = None
                for j in range(n):
                    if a_exp[j] >= b_exp[j]:
                        continue
                    a_p = list(a_exp); a_p[i] -= 1; a_p[j] += 1; a_p = tuple(a_p)
                    b_p = list(b_exp); b_p[i] += 1; b_p[j] -= 1; b_p = tuple(b_p)
                    ca_p = poly.get(a_p, 0.0)
                    cb_p = poly.get(b_p, 0.0)
                    if ca_p > 0 and cb_p > 0:
                        ratio = (poly[a_exp] * poly[b_exp]) / (ca_p * cb_p)
                        if best_ratio is None or ratio < best_ratio:
                            best_ratio = ratio
                if best_ratio is not None:
                    max_ratio = max(max_ratio, best_ratio)
    return max_ratio


def weighted_uniform_poly(n, d, weights_list):
    """Create weighted uniform matroid polynomial from weight list."""
    poly = {}
    subsets = list(itertools.combinations(range(n), d))
    for subset, w in zip(subsets, weights_list):
        exp = tuple(1 if i in subset else 0 for i in range(n))
        poly[exp] = w
    return poly


def partial_derivative(poly, var, n):
    """Compute partial derivative."""
    result = {}
    for exp, coeff in poly.items():
        if exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            new_exp = tuple(new_exp)
            factor = exp[var]
            result[new_exp] = result.get(new_exp, 0.0) + coeff * factor
    return {k: v for k, v in result.items() if abs(v) > 1e-15}


# Create figure with multiple panels
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: K values for U(2,4) as function of weight ratios
n_points = 40
w1_range = np.linspace(0.2, 5.0, n_points)
w2_range = np.linspace(0.2, 5.0, n_points)
K_grid = np.zeros((n_points, n_points))

for i, w1 in enumerate(w1_range):
    for j, w2 in enumerate(w2_range):
        # U(2,4) with weights [1, w1, w2, 1, 1, 1] on the 6 bases
        weights = [1.0, w1, w2, 1.0, 1.0, 1.0]
        poly = weighted_uniform_poly(4, 2, weights)
        K_grid[j, i] = compute_K_general(poly, 4)

im1 = axes[0].imshow(K_grid, extent=[0.2, 5.0, 0.2, 5.0], 
                       origin='lower', cmap='YlOrRd', aspect='auto')
axes[0].set_xlabel('Weight w₁ (basis {0,2})', fontsize=11)
axes[0].set_ylabel('Weight w₂ (basis {0,3})', fontsize=11)
axes[0].set_title('Exchange Constant K\nfor U(2,4)', fontsize=12, fontweight='bold')
plt.colorbar(im1, ax=axes[0], label='K')
# Mark K=1 contour
axes[0].contour(w1_range, w2_range, K_grid, levels=[1.0], colors='white', linewidths=2)

# Panel 2: K values for derivatives of U(2,4)
K_deriv_grid = np.zeros((n_points, n_points))
for i, w1 in enumerate(w1_range):
    for j, w2 in enumerate(w2_range):
        weights = [1.0, w1, w2, 1.0, 1.0, 1.0]
        poly = weighted_uniform_poly(4, 2, weights)
        max_K_d = 0.0
        for var in range(4):
            dp = partial_derivative(poly, var, 4)
            if dp:
                K_d = compute_K_general(dp, 4)
                max_K_d = max(max_K_d, K_d)
        K_deriv_grid[j, i] = max_K_d

im2 = axes[1].imshow(K_deriv_grid, extent=[0.2, 5.0, 0.2, 5.0],
                       origin='lower', cmap='YlOrRd', aspect='auto')
axes[1].set_xlabel('Weight w₁', fontsize=11)
axes[1].set_ylabel('Weight w₂', fontsize=11)
axes[1].set_title('Max K of Derivatives\nmax_i K(∂ᵢp)', fontsize=12, fontweight='bold')
plt.colorbar(im2, ax=axes[1], label='max K(∂ᵢp)')
axes[1].contour(w1_range, w2_range, K_deriv_grid, levels=[1.0], colors='white', linewidths=2)

# Panel 3: Ratio K(derivative) / K(original)
ratio_grid = np.where(K_grid > 0, K_deriv_grid / K_grid, 0)
im3 = axes[2].imshow(ratio_grid, extent=[0.2, 5.0, 0.2, 5.0],
                       origin='lower', cmap='RdYlGn_r', aspect='auto',
                       vmin=0, vmax=1.5)
axes[2].set_xlabel('Weight w₁', fontsize=11)
axes[2].set_ylabel('Weight w₂', fontsize=11)
axes[2].set_title('Scaling Ratio\nmax K(∂ᵢp) / K(p)', fontsize=12, fontweight='bold')
plt.colorbar(im3, ax=axes[2], label='Ratio')
axes[2].contour(w1_range, w2_range, ratio_grid, levels=[1.0], colors='black', linewidths=2)

plt.suptitle('Valuated Exchange Constants Under Differentiation', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('exchange_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved exchange_heatmap.png")
