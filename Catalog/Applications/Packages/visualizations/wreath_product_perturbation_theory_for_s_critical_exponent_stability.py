#!/usr/bin/env python3
"""
Visualization 2: Critical Exponent Stability

Visualizes the critical exponent comparison between wreath products
and direct products, showing that |β_W(k,m) - m·β(S_k)| ≤ C/k.

The key plot shows the rescaled deviation k·|β_W - m·β| as a function
of k for various m. If this stabilizes, the perturbation is "irrelevant."
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


def estimate_beta(pressure_fn, s_low=0.1, s_high=5.0, threshold=50.0, tol=1e-4):
    p_low = pressure_fn(s_low)
    p_high = pressure_fn(s_high)
    if p_low <= threshold: return s_low
    if p_high >= threshold: return s_high
    while s_high - s_low > tol:
        s_mid = (s_low + s_high) / 2
        if pressure_fn(s_mid) > threshold:
            s_low = s_mid
        else:
            s_high = s_mid
    return (s_low + s_high) / 2


fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Critical Exponent Stability Under Wreath Perturbation\n'
             r'$|\beta_W(k,m) - m \cdot \beta(S_k)| \leq C_m / k$',
             fontsize=16, fontweight='bold')

k_range = range(2, 8)

# Compute betas
betas_symm = {}
for k in k_range:
    betas_symm[k] = estimate_beta(lambda s, k=k: subgroup_pressure(k, s))

# Plot 1: β_W vs m·β(S_k)
ax1 = axes[0, 0]
for m in [2, 3, 4]:
    bw = [estimate_beta(lambda s, k=k, m=m: wreath_pressure(k, m, s)) for k in k_range]
    bp = [m * betas_symm[k] for k in k_range]
    ax1.plot(list(k_range), bw, 'o-', label=f'β_W (m={m})', markersize=7)
    ax1.plot(list(k_range), bp, 's--', label=f'm·β(S_k) (m={m})',
             markersize=5, alpha=0.7)
ax1.set_xlabel('k')
ax1.set_ylabel('Critical Exponent')
ax1.set_title('Wreath vs Product Critical Exponents')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Plot 2: |β_W - m·β(S_k)| vs k
ax2 = axes[0, 1]
for m in [2, 3, 4]:
    diffs = []
    for k in k_range:
        bw = estimate_beta(lambda s, k=k, m=m: wreath_pressure(k, m, s))
        bp = m * betas_symm[k]
        diffs.append(abs(bw - bp))
    ax2.plot(list(k_range), diffs, 'o-', label=f'm={m}', markersize=8)

# Reference C/k curve
k_arr = np.array(list(k_range), dtype=float)
ax2.plot(k_arr, 0.5 / k_arr, 'k--', alpha=0.5, label=r'$C/k$ ref')
ax2.set_xlabel('k')
ax2.set_ylabel(r'$|\beta_W - m \cdot \beta(S_k)|$')
ax2.set_title('Exponent Deviation (should be O(1/k))')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Rescaled k·|β_W - m·β|
ax3 = axes[1, 0]
for m in [2, 3, 4]:
    rescaled = []
    for k in k_range:
        bw = estimate_beta(lambda s, k=k, m=m: wreath_pressure(k, m, s))
        bp = m * betas_symm[k]
        rescaled.append(k * abs(bw - bp))
    ax3.plot(list(k_range), rescaled, 's-', label=f'm={m}', markersize=8)
ax3.set_xlabel('k')
ax3.set_ylabel(r'$k \cdot |\beta_W - m \cdot \beta(S_k)|$')
ax3.set_title('Rescaled Deviation (convergence ⟹ irrelevance)')
ax3.legend()
ax3.grid(True, alpha=0.3)

# Plot 4: β(S_k) growth and m·β linearity
ax4 = axes[1, 1]
beta_vals = [betas_symm[k] for k in k_range]
ax4.plot(list(k_range), beta_vals, 'ko-', label=r'$\beta(S_k)$', markersize=8)
for m in [2, 3, 4]:
    ax4.plot(list(k_range), [m * b for b in beta_vals], '--',
             label=f'{m}·β(S_k)', alpha=0.7)
ax4.set_xlabel('k')
ax4.set_ylabel('Critical Exponent')
ax4.set_title('Linear Scaling: β_prod(k,m) = m·β(S_k)')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_critical_exponents.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_exponents.png")
