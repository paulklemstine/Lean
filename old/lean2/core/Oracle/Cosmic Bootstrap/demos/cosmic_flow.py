#!/usr/bin/env python3
"""
Cosmic Bootstrap Flow: The Universe as a Dynamical System
==========================================================

Visualizes the cosmological analogy:
- The Great Attractor pulling galaxies (superattracting fixed point)
- The Dipole Repeller pushing galaxies away (unstable fixed point)
- The cosmic web as basin boundaries
- Density evolution under bootstrap dynamics

Run: python cosmic_flow.py
Outputs: cosmic_flow.png, cosmic_density_evolution.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import Circle, FancyArrowPatch
from matplotlib import cm

def f(x):
    return 3 * x**2 - 2 * x**3

def f2d(x, y):
    """2D bootstrap: apply independently to radial coordinate.
    Maps density contrast δ through the bootstrap."""
    r = np.sqrt(x**2 + y**2)
    r_new = f(np.clip(r, 0, 1))
    # Preserve angle, update radius
    theta = np.arctan2(y, x)
    return r_new * np.cos(theta) - r * np.cos(theta), r_new * np.sin(theta) - r * np.sin(theta)

# ══════════════════════════════════════════════════════
# Figure 1: Cosmic Flow Diagram
# ══════════════════════════════════════════════════════
fig = plt.figure(figsize=(18, 10))
gs = gridspec.GridSpec(1, 2, width_ratios=[1.2, 1], wspace=0.3)

# Left: 1D flow with cosmological annotations
ax1 = fig.add_subplot(gs[0])

x = np.linspace(-0.1, 1.1, 1000)
ax1.plot(x, f(x), 'dodgerblue', linewidth=3, label='f(x) = 3x² − 2x³', zorder=3)
ax1.plot(x, x, 'gray', linewidth=1.5, linestyle='--', alpha=0.6, label='y = x')

# Draw flow arrows on x-axis
arrow_xs = [0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95]
for ax_val in arrow_xs:
    direction = f(ax_val) - ax_val
    color = 'green' if ax_val < 0.5 else 'red'
    ax1.annotate('', xy=(ax_val + 0.03 * np.sign(direction), -0.05),
                xytext=(ax_val, -0.05),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

# Cosmological labels
ax1.axvspan(-0.1, 0.5, alpha=0.06, color='blue', label='Cosmic Void (expanding)')
ax1.axvspan(0.5, 1.1, alpha=0.06, color='red', label='Overdensity (collapsing)')

# Fixed points with cosmic labels
ax1.plot(0, 0, 'o', color='navy', markersize=18, zorder=10,
         markeredgecolor='white', markeredgewidth=2)
ax1.plot(1, 1, 'o', color='darkred', markersize=18, zorder=10,
         markeredgecolor='white', markeredgewidth=2)
ax1.plot(0.5, 0.5, 'D', color='goldenrod', markersize=14, zorder=10,
         markeredgecolor='white', markeredgewidth=2)

# Labels
ax1.text(0.02, -0.18, 'COSMIC VOID\n(Heat Death)\nδ → −1', fontsize=10,
         ha='center', color='navy', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.7))
ax1.text(0.98, 1.12, 'GREAT ATTRACTOR\n(Total Collapse)\nδ → ∞', fontsize=10,
         ha='center', color='darkred', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))
ax1.text(0.5, 0.35, 'DIPOLE REPELLER\n(Unstable Equilibrium)\n|f\'| = 3/2 > 1', fontsize=9,
         ha='center', color='goldenrod', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))

# Flow arrows on the curve
for x_start in [0.1, 0.2, 0.3, 0.4]:
    ax1.annotate('', xy=(f(x_start), f(x_start)),
                xytext=(x_start, f(x_start)),
                arrowprops=dict(arrowstyle='->', color='green', lw=1.5, alpha=0.5))

for x_start in [0.6, 0.7, 0.8, 0.9]:
    ax1.annotate('', xy=(f(x_start), f(x_start)),
                xytext=(x_start, f(x_start)),
                arrowprops=dict(arrowstyle='->', color='red', lw=1.5, alpha=0.5))

ax1.set_xlim(-0.15, 1.15)
ax1.set_ylim(-0.25, 1.25)
ax1.set_xlabel('Density contrast δ (normalized)', fontsize=13)
ax1.set_ylabel('Bootstrap(δ)', fontsize=13)
ax1.set_title('The Cosmic Bootstrap: Gravitational Dynamics\n'
              'as an Oracle Self-Improvement Map', fontsize=14, fontweight='bold')
ax1.legend(loc='upper left', fontsize=9)
ax1.grid(True, alpha=0.2)

# Right: Schematic cosmic web
ax2 = fig.add_subplot(gs[1])
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')

# Draw "galaxies" flowing
np.random.seed(42)
n_galaxies = 200
theta = np.random.uniform(0, 2*np.pi, n_galaxies)
r = np.random.uniform(0.1, 1.4, n_galaxies)
gx = r * np.cos(theta)
gy = r * np.sin(theta)

# Determine which "attractor" each galaxy flows to
# Great Attractor at (0.7, 0.3), Void center at (-0.6, -0.4), Repeller at (0, 0.1)
attractor = np.array([0.7, 0.3])
repeller = np.array([0.0, 0.1])
void_center = np.array([-0.6, -0.4])

for i in range(n_galaxies):
    pos = np.array([gx[i], gy[i]])
    d_attr = np.linalg.norm(pos - attractor)
    d_void = np.linalg.norm(pos - void_center)
    d_rep = np.linalg.norm(pos - repeller)

    # Flow direction
    if d_attr < d_void:
        flow = (attractor - pos) * 0.08
        color = 'salmon'
        alpha = 0.5
    else:
        flow = (void_center - pos) * 0.05
        color = 'lightblue'
        alpha = 0.4

    # Repulsion from repeller
    if d_rep < 0.5:
        repel = (pos - repeller) * 0.15 / (d_rep + 0.1)
        flow += repel

    ax2.plot(gx[i], gy[i], '.', color=color, markersize=3, alpha=alpha)
    ax2.annotate('', xy=(gx[i] + flow[0], gy[i] + flow[1]),
                xytext=(gx[i], gy[i]),
                arrowprops=dict(arrowstyle='->', color=color, lw=0.5, alpha=0.3))

# Draw attractors and repeller
circle_attr = Circle(attractor, 0.15, facecolor='red', edgecolor='white',
                     linewidth=2, alpha=0.8, zorder=10)
circle_void = Circle(void_center, 0.12, facecolor='blue', edgecolor='white',
                     linewidth=2, alpha=0.6, zorder=10)
circle_rep = Circle(repeller, 0.1, facecolor='gold', edgecolor='white',
                    linewidth=2, alpha=0.8, zorder=10)
ax2.add_patch(circle_attr)
ax2.add_patch(circle_void)
ax2.add_patch(circle_rep)

ax2.text(attractor[0], attractor[1] + 0.3, 'Great\nAttractor', ha='center',
         fontsize=11, fontweight='bold', color='red')
ax2.text(void_center[0], void_center[1] - 0.3, 'Cosmic\nVoid', ha='center',
         fontsize=11, fontweight='bold', color='blue')
ax2.text(repeller[0] + 0.25, repeller[1] + 0.2, 'Dipole\nRepeller', ha='center',
         fontsize=11, fontweight='bold', color='goldenrod')

ax2.set_title('Galaxy Flow: The Cosmic Web\n'
              'Galaxies pulled by attractors, pushed by repellers',
              fontsize=13, fontweight='bold')
ax2.set_xlabel('Supergalactic X (arb. units)', fontsize=11)
ax2.set_ylabel('Supergalactic Y (arb. units)', fontsize=11)
ax2.grid(True, alpha=0.15)

plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/cosmic_flow.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✓ Generated: cosmic_flow.png")

# ══════════════════════════════════════════════════════
# Figure 2: Density Evolution
# ══════════════════════════════════════════════════════
fig, axes = plt.subplots(2, 3, figsize=(18, 10))
fig.suptitle('Cosmic Density Evolution Under Bootstrap Dynamics\n'
             'Starting from near-uniform density → cosmic web emergence',
             fontsize=14, fontweight='bold')

np.random.seed(123)
N = 500
x_init = np.random.normal(0.5, 0.05, N)  # Near-uniform density

iterations = [0, 1, 3, 5, 10, 30]
for idx, n_iter in enumerate(iterations):
    ax = axes.flat[idx]
    x_vals = x_init.copy()
    for _ in range(n_iter):
        x_vals = f(np.clip(x_vals, 0, 1))

    ax.hist(x_vals, bins=50, range=(0, 1), color='steelblue', edgecolor='navy', alpha=0.7)
    ax.axvline(x=0.5, color='gold', linestyle='--', linewidth=2, label='Repeller')
    ax.axvline(x=0, color='blue', linestyle='-', linewidth=2, alpha=0.5, label='Void')
    ax.axvline(x=1, color='red', linestyle='-', linewidth=2, alpha=0.5, label='Attractor')

    n_void = np.sum(x_vals < 0.01)
    n_attr = np.sum(x_vals > 0.99)
    ax.set_title(f'Iteration {n_iter}: {n_void} voids, {n_attr} clusters', fontsize=11)
    ax.set_xlim(-0.05, 1.05)
    ax.set_xlabel('Density δ')
    ax.set_ylabel('Count')
    if idx == 0:
        ax.legend(fontsize=8)

plt.tight_layout()
plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/cosmic_density_evolution.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✓ Generated: cosmic_density_evolution.png")
