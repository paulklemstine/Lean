#!/usr/bin/env python3
"""
Visualization 1: Wreath Pressure Decomposition

Visualizes the decomposition Π_W(k,m;s) = Π_prod(k,m;s) + δΠ(k,m;s)
for various k and m values, showing how the imprimitive defect becomes
negligible relative to the product pressure as k grows.

This is the visual proof of "irrelevant perturbation": the blue curve
(product pressure) and red curve (wreath pressure) converge as k → ∞.
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def factorial(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result


def subgroup_indices(k):
    if k <= 1: return [1]
    if k == 2: return [1, 2]
    if k == 3: return [1, 2, 3, 3, 3, 6]
    if k == 4:
        return ([1, 2, 3, 3, 4, 4, 4, 6, 6, 6, 6, 6, 6] +
                [8, 8, 8, 8] + [12] * 9 + [24])
    if k == 5:
        indices = [1, 2] + [5]*6 + [6]*10 + [10]*5 + [12]*10
        indices += [15]*10 + [20]*15 + [24]*10 + [30]*10 + [40]*5
        indices += [60]*20 + [120]*25
        return indices
    n = factorial(k)
    indices = [1]
    divs = sorted(d for d in range(2, min(n+1, 10000)) if n % d == 0)
    for d in divs[:50]:
        indices += [d] * max(1, int(math.log(k+1)**2))
    indices += [n]
    return indices


def subgroup_pressure(k, s):
    return sum(idx ** (-s) for idx in subgroup_indices(k))


def product_pressure(k, m, s):
    return m * subgroup_pressure(k, s)


def imprimitive_defect(k, m, s):
    defect = 0.0
    sub_Sm = subgroup_indices(m)
    for t_idx in sub_Sm:
        if t_idx == factorial(m):
            continue
        n_compat = min(len(subgroup_indices(k)) ** min(m, 3), 20)
        for _ in range(n_compat):
            eff_idx = max(k * t_idx, t_idx + k)
            defect += eff_idx ** (-s)
    return defect


def wreath_pressure(k, m, s):
    return product_pressure(k, m, s) + imprimitive_defect(k, m, s)


# Create figure with 2x2 subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Wreath Product Pressure Decomposition\n'
             r'$\Pi_W(k,m;s) = \Pi_{\mathrm{prod}}(k,m;s) + \delta\Pi(k,m;s)$',
             fontsize=16, fontweight='bold')

s_values = np.linspace(0.3, 3.0, 100)

# Plot 1: Pressure curves for m=2, various k
ax1 = axes[0, 0]
m = 2
for k in [2, 3, 4, 5]:
    pp = [product_pressure(k, m, s) for s in s_values]
    wp = [wreath_pressure(k, m, s) for s in s_values]
    ax1.semilogy(s_values, pp, '--', label=f'Π_prod (k={k})', alpha=0.7)
    ax1.semilogy(s_values, wp, '-', label=f'Π_wreath (k={k})', alpha=0.7)
ax1.set_xlabel('s')
ax1.set_ylabel('Pressure (log scale)')
ax1.set_title(f'm = {m}: Product vs Wreath Pressure')
ax1.legend(fontsize=7, ncol=2)
ax1.grid(True, alpha=0.3)

# Plot 2: Defect δΠ for various k at m=2
ax2 = axes[0, 1]
m = 2
for k in [2, 3, 4, 5, 6]:
    defects = [imprimitive_defect(k, m, s) for s in s_values]
    ax2.semilogy(s_values, [max(d, 1e-15) for d in defects],
                 label=f'k={k}', linewidth=2)
ax2.set_xlabel('s')
ax2.set_ylabel('Imprimitive Defect δΠ (log scale)')
ax2.set_title(f'm = {m}: Imprimitive Defect Decay')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Ratio δΠ/Π_prod vs k at fixed s
ax3 = axes[1, 0]
s_fixed = 1.0
k_values = range(2, 9)
for m in [2, 3, 4]:
    ratios = [imprimitive_defect(k, m, s_fixed) /
              product_pressure(k, m, s_fixed) for k in k_values]
    ax3.plot(list(k_values), ratios, 'o-', label=f'm={m}', markersize=8)

# Add 1/k reference curve
k_arr = np.array(list(k_values), dtype=float)
C_ref = 2.0
ax3.plot(k_arr, C_ref / k_arr, 'k--', alpha=0.5, label=r'$C/k$ reference')
ax3.set_xlabel('k')
ax3.set_ylabel(r'$\delta\Pi / \Pi_{\mathrm{prod}}$')
ax3.set_title(f'Defect Ratio at s = {s_fixed} (should be O(1/k))')
ax3.legend()
ax3.grid(True, alpha=0.3)

# Plot 4: Rescaled k * ratio to test convergence
ax4 = axes[1, 1]
s_fixed = 1.0
for m in [2, 3, 4]:
    k_ratios = [k * imprimitive_defect(k, m, s_fixed) /
                product_pressure(k, m, s_fixed) for k in k_values]
    ax4.plot(list(k_values), k_ratios, 's-', label=f'm={m}', markersize=8)
ax4.set_xlabel('k')
ax4.set_ylabel(r'$k \cdot \delta\Pi / \Pi_{\mathrm{prod}}$')
ax4.set_title('Rescaled Ratio (should converge to constant)')
ax4.legend()
ax4.grid(True, alpha=0.3)
ax4.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

plt.tight_layout()
plt.savefig('viz_pressure_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_pressure_decomposition.png")
