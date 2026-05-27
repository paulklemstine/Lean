#!/usr/bin/env python3
"""
Visualization 1: Entropy Stability Landscape

Visualizes the binary entropy function, its Lipschitz bounds, and the
certified entropy intervals as a function of spectral gap and perturbation.
Shows how the entropy stability constant L_delta diverges as delta -> 0.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch


def binary_entropy(x):
    x = np.asarray(x, dtype=float)
    result = np.zeros_like(x)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


def entropy_stability_constant(delta):
    return np.log((1 - delta) / delta)


fig, axes = plt.subplots(2, 3, figsize=(18, 11))

# Panel 1: Binary entropy with Lipschitz cones
ax = axes[0, 0]
x = np.linspace(0.001, 0.999, 500)
ax.plot(x, binary_entropy(x), 'b-', linewidth=2.5, label='h(x)')
ax.axhline(np.log(2), color='orange', linestyle='--', alpha=0.7, label='log 2')

# Draw Lipschitz cone at x=0.3 for delta=0.15
x0, delta = 0.3, 0.15
L = entropy_stability_constant(delta)
h0 = binary_entropy(np.array([x0]))[0]
x_cone = np.linspace(delta, 1-delta, 100)
upper_cone = h0 + L * np.abs(x_cone - x0)
lower_cone = h0 - L * np.abs(x_cone - x0)
ax.fill_between(x_cone, np.maximum(lower_cone, 0), upper_cone,
                alpha=0.15, color='red', label=f'Lipschitz cone (δ={delta})')
ax.plot(x0, h0, 'ro', markersize=8, zorder=5)
ax.axvline(delta, color='gray', linestyle=':', alpha=0.5)
ax.axvline(1-delta, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('h(x)', fontsize=12)
ax.set_title('Binary Entropy with Lipschitz Cone', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(-0.05, 0.85)

# Panel 2: Derivative and bounds
ax = axes[0, 1]
x_int = np.linspace(0.02, 0.98, 500)
deriv = np.log((1 - x_int) / x_int)
ax.plot(x_int, deriv, 'b-', linewidth=2, label="h'(x) = log((1-x)/x)")
for d, color in [(0.05, 'red'), (0.1, 'green'), (0.2, 'purple')]:
    L = entropy_stability_constant(d)
    ax.axhline(L, color=color, linestyle='--', alpha=0.7, label=f'L_{{δ={d}}} = {L:.2f}')
    ax.axhline(-L, color=color, linestyle='--', alpha=0.3)
    ax.axvline(d, color=color, linestyle=':', alpha=0.3)
    ax.axvline(1-d, color=color, linestyle=':', alpha=0.3)
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel("h'(x)", fontsize=12)
ax.set_title("Derivative Bound Controls Stability", fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: L_delta vs delta
ax = axes[0, 2]
delta_range = np.linspace(0.01, 0.49, 200)
L_vals = [entropy_stability_constant(d) for d in delta_range]
ax.plot(delta_range, L_vals, 'b-', linewidth=2.5)
ax.set_xlabel('δ (spectral gap)', fontsize=12)
ax.set_ylabel('L_δ = log((1-δ)/δ)', fontsize=12)
ax.set_title('Stability Constant vs Spectral Gap', fontsize=13, fontweight='bold')
ax.axhline(np.log(2), color='orange', linestyle='--', alpha=0.7, label='log 2 (δ→1/2)')
ax.annotate('Diverges as δ→0\n(no gap = no stability)',
            xy=(0.03, entropy_stability_constant(0.03)),
            xytext=(0.15, 3.5), fontsize=10,
            arrowprops=dict(arrowstyle='->', color='red'))
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 5)

# Panel 4: Certificate width heatmap (m vs epsilon)
ax = axes[1, 0]
m_vals = np.arange(1, 51)
eps_vals = np.linspace(0.001, 0.1, 50)
M, E = np.meshgrid(m_vals, eps_vals)
delta_fixed = 0.1
L_fixed = entropy_stability_constant(delta_fixed)
W = 2 * M * L_fixed * E
im = ax.pcolormesh(M, E, W, cmap='YlOrRd', shading='auto')
plt.colorbar(im, ax=ax, label='Certificate width')
ax.set_xlabel('Subsystem size m', fontsize=12)
ax.set_ylabel('Perturbation ε', fontsize=12)
ax.set_title(f'Certificate Width (δ={delta_fixed})', fontsize=13, fontweight='bold')
ax.contour(M, E, W, levels=[0.5, 1, 2, 5], colors='black', linewidths=0.5)

# Panel 5: Random perturbation samples with certificate
ax = axes[1, 1]
m = 8
delta = 0.15
np.random.seed(42)
spec0 = np.array([0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.4, 0.6])
S0 = sum(binary_entropy(x) for x in spec0)

eta_vals = [0.02, 0.05, 0.1]
colors = ['green', 'blue', 'red']
for eta, color in zip(eta_vals, colors):
    L = entropy_stability_constant(delta)
    lo = S0 - m * L * eta
    hi = S0 + m * L * eta
    entropies = []
    for _ in range(500):
        pert = np.random.uniform(-eta, eta, m)
        spec = np.clip(spec0 + pert, delta, 1 - delta)
        entropies.append(sum(binary_entropy(x) for x in spec))
    ax.hist(entropies, bins=30, alpha=0.3, color=color, density=True,
            label=f'η={eta}')
    ax.axvline(lo, color=color, linestyle='--', alpha=0.7)
    ax.axvline(hi, color=color, linestyle='--', alpha=0.7)
ax.axvline(S0, color='black', linewidth=2, label='S(ref)')
ax.set_xlabel('Entropy', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Entropy Distribution vs Certificate', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 6: Quadratic lower bound h(x) >= 2x(1-x)
ax = axes[1, 2]
x = np.linspace(0, 1, 500)
ax.plot(x, binary_entropy(x), 'b-', linewidth=2.5, label='h(x)')
ax.plot(x, 2*x*(1-x), 'r--', linewidth=2, label='2x(1-x)')
ax.fill_between(x, 2*x*(1-x), binary_entropy(x), alpha=0.15, color='green',
                label='Gap: entropy > quadratic')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Entropy ≥ 2x(1-x): Variance Lower Bound', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

plt.suptitle('Entropy Stability for Approximately Gaussian Fermionic States',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_landscape.png")
