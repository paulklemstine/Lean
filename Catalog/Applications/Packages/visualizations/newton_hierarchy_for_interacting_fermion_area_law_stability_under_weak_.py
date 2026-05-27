#!/usr/bin/env python3
"""
Visualization: Area Law Stability Under Weak Interaction

Shows how the fermion entropy changes under increasing interaction strength,
demonstrating that area-law compatibility is preserved under weak perturbation.
"""

import numpy as np
import matplotlib.pyplot as plt

# ─── Inlined core functions ───

def binary_entropy(x):
    if x <= 1e-15 or x >= 1 - 1e-15:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)

def fermion_entropy(spectrum):
    return sum(binary_entropy(x) for x in spectrum)

def esymm_dp(spectrum, max_k):
    n = len(spectrum)
    K = min(max_k, n)
    e = [0.0] * (K + 1)
    e[0] = 1.0
    for x in spectrum:
        for j in range(min(K, n), 0, -1):
            e[j] += x * e[j - 1]
    return e + [0.0] * max(0, max_k - K)

def nr(spectrum, k, ev=None):
    if ev is None:
        ev = esymm_dp(spectrum, k + 1)
    if k - 1 < 0 or k + 1 >= len(ev):
        return 0.0
    d = ev[k - 1] * ev[k + 1]
    return ev[k] ** 2 / d if abs(d) > 1e-30 else 0.0

# ─── Parameters ───

n = 8
free_spec = np.array([0.97, 0.85, 0.70, 0.55, 0.45, 0.30, 0.15, 0.03])
delta = np.array([-0.05, -0.08, 0.03, 0.10, -0.10, -0.03, 0.08, 0.05])
K = 5

U_values = np.linspace(0, 1.0, 100)

entropies = []
entropy_free = fermion_entropy(free_spec)
sup_norms = []
nr_profiles = {k: [] for k in range(1, K + 1)}

for U in U_values:
    spec = np.clip(free_spec + U * delta, 0.001, 0.999)
    S = fermion_entropy(spec)
    entropies.append(S)
    sup_norms.append(max(abs(spec[i] - free_spec[i]) for i in range(n)))
    ev = esymm_dp(list(spec), K + 1)
    for k in range(1, K + 1):
        nr_profiles[k].append(nr(list(spec), k, ev))

# ─── Plot ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: Entropy vs coupling
ax = axes[0, 0]
ax.plot(U_values, entropies, 'b-', linewidth=2, label='S(λ(U))')
ax.axhline(y=entropy_free, color='r', linestyle='--', linewidth=1,
           label=f'S(λ(0)) = {entropy_free:.3f}')
area_law_bound = entropy_free + 0.5
ax.axhline(y=area_law_bound, color='green', linestyle=':', linewidth=1.5,
           label=f'Area law bound (C = {area_law_bound:.1f})')
ax.fill_between(U_values, 0, area_law_bound, alpha=0.05, color='green')
ax.set_xlabel('Coupling Strength U', fontsize=12)
ax.set_ylabel('Fermion Entropy S', fontsize=12)
ax.set_title('Area Law Stability Under Interaction', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Top right: Entropy deviation vs epsilon
ax2 = axes[0, 1]
entropy_devs = [abs(S - entropy_free) for S in entropies]
ax2.plot(sup_norms, entropy_devs, 'o', markersize=3, color='darkblue', alpha=0.6)
# Linear fit for small perturbations
mask = np.array(sup_norms) < 0.05
if sum(mask) > 2:
    coeffs = np.polyfit(np.array(sup_norms)[mask], np.array(entropy_devs)[mask], 1)
    x_fit = np.linspace(0, max(sup_norms), 100)
    ax2.plot(x_fit, coeffs[0] * x_fit + coeffs[1], 'r--', linewidth=1.5,
             label=f'Linear fit (slope ≈ {coeffs[0]:.2f})')
ax2.set_xlabel('Sup-norm distance ε', fontsize=12)
ax2.set_ylabel('|S(p) − S(q)|', fontsize=12)
ax2.set_title('Entropy Deviation vs. Perturbation Size', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Bottom left: Newton ratio profiles at different U
ax3 = axes[1, 0]
U_show = [0.0, 0.05, 0.1, 0.2, 0.5, 1.0]
cmap = plt.cm.coolwarm(np.linspace(0, 1, len(U_show)))
for i, U in enumerate(U_show):
    spec = np.clip(free_spec + U * delta, 0.001, 0.999)
    ev = esymm_dp(list(spec), K + 1)
    profile = [nr(list(spec), k, ev) for k in range(1, K + 1)]
    ax3.plot(range(1, K + 1), profile, 'o-', color=cmap[i], linewidth=2,
             markersize=7, label=f'U={U}')
ax3.set_xlabel('Newton Level k', fontsize=12)
ax3.set_ylabel('Newton Ratio ρ_k', fontsize=12)
ax3.set_title('Newton Ratio Profiles Across Coupling', fontsize=13)
ax3.legend(fontsize=9, ncol=2)
ax3.set_xticks(range(1, K + 1))
ax3.grid(True, alpha=0.3)

# Bottom right: Heatmap of Newton ratio deviations
ax4 = axes[1, 1]
U_heat = np.linspace(0, 0.5, 50)
dev_matrix = np.zeros((K, len(U_heat)))
for j, U in enumerate(U_heat):
    spec = np.clip(free_spec + U * delta, 0.001, 0.999)
    for k in range(1, K + 1):
        dev_matrix[k - 1, j] = abs(nr(list(spec), k) - nr(list(free_spec), k))

im = ax4.imshow(dev_matrix, aspect='auto', origin='lower',
                extent=[0, 0.5, 0.5, K + 0.5],
                cmap='inferno', interpolation='bilinear')
ax4.set_xlabel('Coupling Strength U', fontsize=12)
ax4.set_ylabel('Newton Level k', fontsize=12)
ax4.set_title('Newton Ratio Deviation Heatmap', fontsize=13)
ax4.set_yticks(range(1, K + 1))
plt.colorbar(im, ax=ax4, label='|ρ_k(U) − ρ_k(0)|')

plt.tight_layout()
plt.savefig('area_law_stability.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved area_law_stability.png")
