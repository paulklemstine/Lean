#!/usr/bin/env python3
"""
Visualization 3: Perturbation Landscape Heatmap

Visualizes the perturbation ratio δΠ/Π_prod as a heatmap over (k, s)
parameter space for fixed m, showing the landscape of imprimitive
coupling strength. The theorem predicts this ratio is uniformly O(1/k).
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


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


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Perturbation Landscape: Defect Ratio δΠ/Π_prod over (k, s) Space',
             fontsize=14, fontweight='bold')

k_values = np.arange(2, 10)
s_values = np.linspace(0.3, 3.0, 50)

for idx, m in enumerate([2, 3, 4]):
    ax = axes[idx]
    ratio_grid = np.zeros((len(k_values), len(s_values)))

    for i, k in enumerate(k_values):
        for j, s in enumerate(s_values):
            pp = product_pressure(int(k), m, s)
            dp = imprimitive_defect(int(k), m, s)
            ratio_grid[i, j] = dp / pp if pp > 1e-15 else 0

    im = ax.imshow(ratio_grid, aspect='auto',
                   extent=[s_values[0], s_values[-1],
                           k_values[-1] + 0.5, k_values[0] - 0.5],
                   cmap='viridis', interpolation='bilinear')

    ax.set_xlabel('s (pressure parameter)')
    ax.set_ylabel('k (base group degree)')
    ax.set_title(f'm = {m}')

    cbar = plt.colorbar(im, ax=ax, label='δΠ/Π_prod')

    # Mark the approximate critical exponent line
    for k in k_values:
        beta_approx = 0.5 + 0.1 * k  # rough approximation
        if s_values[0] <= beta_approx <= s_values[-1]:
            ax.plot(beta_approx, k, 'w*', markersize=10)

plt.tight_layout()
plt.savefig('viz_perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_landscape.png")
