#!/usr/bin/env python3
"""
Visualization 3: Product Pressure Factorization and Free Energy

Visualizes the product structure of subgroup pressure, demonstrating:
- Product pressure factorization for product subgroups
- Free energy additivity (log-pressure is additive)
- Convergence of normalized log-pressure in direct powers

This connects to the statistical mechanics interpretation:
independent systems have additive free energy.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# ============================================================
# Inline functions
# ============================================================

def cyclic_indices(n):
    return [n // d for d in range(1, n) if n % d == 0]

def subgroup_pressure(indices, t):
    return sum(idx ** (-2 * t) for idx in indices if idx > 0)

def log_pressure(indices, t):
    Z = subgroup_pressure(indices, t)
    return math.log(Z) if Z > 0 else float('-inf')

def product_subgroup_indices(indices1, indices2):
    """Product subgroup indices [G1xG2 : H1xH2] = [G1:H1]*[G2:H2]."""
    product_idx = []
    # Both proper
    for i in indices1:
        for j in indices2:
            product_idx.append(i * j)
    # First proper, second full (index 1)
    for i in indices1:
        product_idx.append(i)
    # First full, second proper
    for j in indices2:
        product_idx.append(j)
    return product_idx

# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
t_range = np.linspace(0.1, 3.0, 150)

# Panel 1: Product factorization Z_{G×H} vs Z_G + Z_H + Z_G·Z_H
ax = axes[0, 0]
pairs = [
    ((6, "Z/6Z"), (10, "Z/10Z"), "#e74c3c"),
    ((4, "Z/4Z"), (9, "Z/9Z"), "#3498db"),
    ((6, "Z/6Z"), (6, "Z/6Z"), "#2ecc71"),
]

for (n1, name1), (n2, name2), color in pairs:
    idx1 = cyclic_indices(n1)
    idx2 = cyclic_indices(n2)
    prod_idx = product_subgroup_indices(idx1, idx2)

    z_prod = [subgroup_pressure(prod_idx, t) for t in t_range]
    z_factor = [subgroup_pressure(idx1, t) + subgroup_pressure(idx2, t)
                + subgroup_pressure(idx1, t) * subgroup_pressure(idx2, t) for t in t_range]

    ax.plot(t_range, z_prod, '-', color=color, linewidth=2,
            label=f'{name1}×{name2} actual')
    ax.plot(t_range, z_factor, '--', color=color, linewidth=2, alpha=0.6,
            label=f'{name1}×{name2} factored')

ax.set_xlabel("t", fontsize=12)
ax.set_ylabel("Pressure", fontsize=12)
ax.set_title("Product Pressure Factorization", fontsize=13, fontweight='bold')
ax.legend(fontsize=9, ncol=2)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Free energy additivity
ax = axes[0, 1]
for (n1, name1), (n2, name2), color in pairs:
    idx1 = cyclic_indices(n1)
    idx2 = cyclic_indices(n2)
    prod_idx = product_subgroup_indices(idx1, idx2)

    log_prod = [log_pressure(prod_idx, t) for t in t_range]
    log_sum = [log_pressure(idx1, t) + log_pressure(idx2, t) for t in t_range]

    diff = [lp - ls for lp, ls in zip(log_prod, log_sum)]
    ax.plot(t_range, diff, color=color, linewidth=2,
            label=f'{name1}×{name2}')

ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax.set_xlabel("t", fontsize=12)
ax.set_ylabel("log Z_{G×H} - (log Z_G + log Z_H)", fontsize=12)
ax.set_title("Free Energy Super-Additivity", fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Normalized log-pressure for G^m
ax = axes[1, 0]
for n, name, color in [(6, "Z/6Z", "#e74c3c"), (4, "Z/4Z", "#3498db")]:
    base_idx = cyclic_indices(n)
    t_fixed = 1.0

    m_values = range(1, 9)
    normalized = []
    for m in m_values:
        # Build product subgroup indices for G^m (product subgroups only)
        current_idx = list(base_idx)
        for _ in range(m - 1):
            current_idx = product_subgroup_indices(current_idx, base_idx)
        lp = log_pressure(current_idx, t_fixed)
        normalized.append(lp / m)

    ax.plot(list(m_values), normalized, 'o-', color=color, linewidth=2,
            markersize=6, label=f'{name}, t={t_fixed}')

ax.set_xlabel("m (number of copies)", fontsize=12)
ax.set_ylabel("log Z(G^m, t) / m", fontsize=12)
ax.set_title("Normalized Log-Pressure Convergence", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 4: Pressure heatmap over (n, t)
ax = axes[1, 1]
n_values = range(2, 31)
t_fine = np.linspace(0.1, 2.5, 100)
heatmap = np.zeros((len(list(n_values)), len(t_fine)))

n_list = list(n_values)
for i, n in enumerate(n_list):
    indices = cyclic_indices(n)
    if indices:
        for j, t in enumerate(t_fine):
            heatmap[i, j] = log_pressure(indices, t)
    else:
        heatmap[i, :] = 0

im = ax.imshow(heatmap, aspect='auto', origin='lower',
               extent=[t_fine[0], t_fine[-1], n_list[0], n_list[-1]],
               cmap='viridis')
ax.set_xlabel("Inverse temperature t", fontsize=12)
ax.set_ylabel("Group order n (Z/nZ)", fontsize=12)
ax.set_title("Log-Pressure Landscape", fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='log Z(t)')

plt.suptitle("Product Structure & Free Energy Landscape",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("product_pressure.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: product_pressure.png")
