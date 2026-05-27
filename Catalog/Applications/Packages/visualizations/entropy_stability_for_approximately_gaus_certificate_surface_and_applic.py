#!/usr/bin/env python3
"""
Visualization 3: 3D Certificate Surface and Application Landscape

Visualizes:
- 3D surface of certificate width as a function of (m, delta)
- Application landscape: different physical regimes
- Comparison across interaction strengths
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def binary_entropy(x):
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def region_entropy(spec):
    return np.sum(binary_entropy(spec))


def entropy_stability_constant(delta):
    return np.log((1 - delta) / delta)


fig = plt.figure(figsize=(18, 12))

# Panel 1: 3D surface of certificate width
ax = fig.add_subplot(2, 2, 1, projection='3d')
m_range = np.arange(1, 41)
delta_range = np.linspace(0.02, 0.48, 40)
M, D = np.meshgrid(m_range, delta_range)
eta_fixed = 0.05
L_vals = np.log((1 - D) / D)
W = 2 * M * L_vals * eta_fixed

surf = ax.plot_surface(M, D, W, cmap='viridis', alpha=0.8, edgecolor='none')
ax.set_xlabel('Subsystem size m', fontsize=10)
ax.set_ylabel('Spectral gap δ', fontsize=10)
ax.set_zlabel('Certificate width', fontsize=10)
ax.set_title('Certificate Width Surface\n(η = 0.05)', fontsize=12, fontweight='bold')
ax.view_init(elev=25, azim=135)

# Panel 2: Physical regime map
ax = fig.add_subplot(2, 2, 2)
# Different physical regimes with typical (delta, epsilon) values
regimes = {
    'Metal\n(gapless)': (0.05, 0.1, 'red'),
    'Weak Mott\ninsulator': (0.2, 0.05, 'blue'),
    'Strong\ninsulator': (0.4, 0.02, 'green'),
    'Near\nhalf-filling': (0.1, 0.08, 'orange'),
    'Superconductor': (0.15, 0.03, 'purple'),
}

for name, (d, e, color) in regimes.items():
    L = entropy_stability_constant(d)
    m_example = 20
    width = 2 * m_example * L * e
    ax.scatter(d, e, s=200, c=color, zorder=5, edgecolors='black')
    ax.annotate(f'{name}\nwidth={width:.2f}', (d, e),
                textcoords="offset points", xytext=(15, 5),
                fontsize=8, color=color)

# Background: contour of certificate width
d_bg = np.linspace(0.01, 0.49, 100)
e_bg = np.linspace(0.001, 0.15, 100)
D_bg, E_bg = np.meshgrid(d_bg, e_bg)
W_bg = 2 * 20 * np.log((1 - D_bg) / D_bg) * E_bg
cs = ax.contourf(D_bg, E_bg, W_bg, levels=20, cmap='YlOrRd', alpha=0.3)
plt.colorbar(cs, ax=ax, label='Certificate width (m=20)')
ax.contour(D_bg, E_bg, W_bg, levels=[1, 2, 5, 10], colors='gray', linewidths=0.5)
ax.set_xlabel('Spectral gap δ', fontsize=12)
ax.set_ylabel('Interaction ε', fontsize=12)
ax.set_title('Physical Regime Map', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel 3: Entropy vs interaction strength for different m
ax = fig.add_subplot(2, 2, 3)
delta = 0.15
np.random.seed(42)

for m_val, color in [(4, 'blue'), (8, 'green'), (16, 'red'), (32, 'purple')]:
    spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
    S0 = region_entropy(spec0)
    max_ent = m_val * np.log(2)

    eps_range = np.linspace(0, 0.2, 40)
    upper_bounds = []
    actual_maxes = []

    for eps in eps_range:
        L = entropy_stability_constant(delta)
        upper = S0 + m_val * L * eps
        upper_bounds.append(min(upper, max_ent))

        # Sample actual maximum
        max_s = S0
        for _ in range(100):
            pert = np.random.uniform(-eps, eps, m_val)
            spec = np.clip(spec0 + pert, delta, 1 - delta)
            max_s = max(max_s, region_entropy(spec))
        actual_maxes.append(max_s)

    ax.plot(eps_range, upper_bounds, '-', color=color, linewidth=2,
            label=f'm={m_val} bound')
    ax.plot(eps_range, actual_maxes, '--', color=color, linewidth=1, alpha=0.7)
    ax.axhline(max_ent, color=color, linestyle=':', alpha=0.3)

ax.set_xlabel('Interaction ε', fontsize=12)
ax.set_ylabel('Entropy', fontsize=12)
ax.set_title('Entropy Bound vs Interaction (δ=0.15)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Transfer theorem illustration
ax = fig.add_subplot(2, 2, 4)
m_val = 12
delta = 0.15
np.random.seed(42)
spec0 = np.random.uniform(delta + 0.05, 1 - delta - 0.05, m_val)
S_free = region_entropy(spec0)

# Free bound from variance lower bound
variance = sum(spec0[i] * (1 - spec0[i]) for i in range(m_val))
free_lower = 2 * variance
free_upper = m_val * np.log(2)

eps_range = np.linspace(0, 0.15, 50)
L = entropy_stability_constant(delta)

ax.axhline(S_free, color='blue', linewidth=2, label=f'S_free = {S_free:.3f}')
ax.axhline(free_upper, color='gray', linestyle=':', alpha=0.5,
           label=f'm·log2 = {free_upper:.3f}')

# Correction
corrections = m_val * L * eps_range
ax.fill_between(eps_range, S_free - corrections, S_free + corrections,
                alpha=0.2, color='red', label='Certified interval')
ax.plot(eps_range, S_free + corrections, 'r-', linewidth=2,
        label='Upper bound: S_free + m·L_δ·ε')

# Sample points
for eps in [0.03, 0.06, 0.1]:
    entropies = []
    for _ in range(200):
        pert = np.random.uniform(-eps, eps, m_val)
        spec = np.clip(spec0 + pert, delta, 1 - delta)
        entropies.append(region_entropy(spec))
    ax.scatter([eps] * len(entropies), entropies, s=3, alpha=0.3, c='green')

ax.set_xlabel('Interaction ε', fontsize=12)
ax.set_ylabel('Entropy', fontsize=12)
ax.set_title('Transfer Theorem: Free → Interacting', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

plt.suptitle('Certificate Surface and Application Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_3d.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_3d.png")
