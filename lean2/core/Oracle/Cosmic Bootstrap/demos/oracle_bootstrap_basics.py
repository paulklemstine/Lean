#!/usr/bin/env python3
"""
Oracle Bootstrap: Basic Dynamics Visualization
===============================================

Demonstrates the core f(x) = 3x² - 2x³ map:
- Fixed points and their stability
- Cobweb diagram showing convergence
- Basin of attraction analysis
- Iteration sequences

Run: python oracle_bootstrap_basics.py
Outputs: bootstrap_basics.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec

def f(x):
    """The Oracle Bootstrap map: f(x) = 3x² - 2x³"""
    return 3 * x**2 - 2 * x**3

def f_deriv(x):
    """Derivative: f'(x) = 6x - 6x² = 6x(1-x)"""
    return 6 * x - 6 * x**2

def iterate(x0, n=50):
    """Iterate the bootstrap map n times."""
    trajectory = [x0]
    x = x0
    for _ in range(n):
        x = f(x)
        trajectory.append(x)
    return trajectory

# Create figure with 4 subplots
fig = plt.figure(figsize=(16, 14))
fig.suptitle('The Oracle Bootstrap: f(x) = 3x² − 2x³\nThe Equation That Fixes Itself',
             fontsize=16, fontweight='bold', y=0.98)
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# ══════════════════════════════════════════════════════
# Panel 1: The map and its fixed points
# ══════════════════════════════════════════════════════
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(-0.15, 1.15, 1000)
ax1.plot(x, f(x), 'b-', linewidth=2.5, label='f(x) = 3x² − 2x³', zorder=3)
ax1.plot(x, x, 'k--', linewidth=1, alpha=0.5, label='y = x')
ax1.fill_between(x, f(x), x, where=(x >= 0) & (x <= 0.5), alpha=0.15, color='blue',
                 label='Void Basin (→ 0)')
ax1.fill_between(x, f(x), x, where=(x >= 0.5) & (x <= 1), alpha=0.15, color='red',
                 label='Attractor Basin (→ 1)')

# Fixed points
ax1.plot(0, 0, 'go', markersize=14, zorder=5, markeredgecolor='darkgreen', markeredgewidth=2)
ax1.plot(1, 1, 'ro', markersize=14, zorder=5, markeredgecolor='darkred', markeredgewidth=2)
ax1.plot(0.5, 0.5, 'ko', markersize=12, zorder=5, markerfacecolor='white', markeredgewidth=2)

ax1.annotate('Void Attractor\nf\'(0) = 0', xy=(0, 0), xytext=(0.12, -0.12),
            fontsize=9, ha='center', color='darkgreen', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkgreen'))
ax1.annotate('Great Attractor\nf\'(1) = 0', xy=(1, 1), xytext=(0.82, 1.1),
            fontsize=9, ha='center', color='darkred', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkred'))
ax1.annotate('Great Repeller\nf\'(½) = 3/2', xy=(0.5, 0.5), xytext=(0.65, 0.25),
            fontsize=9, ha='center', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='black'))

ax1.set_xlim(-0.15, 1.15)
ax1.set_ylim(-0.15, 1.15)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('The Cosmic Trinity: Two Attractors, One Repeller', fontsize=11, fontweight='bold')
ax1.legend(loc='upper left', fontsize=8)
ax1.grid(True, alpha=0.3)
ax1.set_aspect('equal')

# ══════════════════════════════════════════════════════
# Panel 2: Cobweb diagram
# ══════════════════════════════════════════════════════
ax2 = fig.add_subplot(gs[0, 1])
x_fine = np.linspace(-0.05, 1.05, 500)
ax2.plot(x_fine, f(x_fine), 'b-', linewidth=2, zorder=2)
ax2.plot(x_fine, x_fine, 'k--', linewidth=1, alpha=0.5)

# Cobweb from x=0.48 (just below repeller → converges to 0)
x0 = 0.48
cx, cy = x0, 0
for i in range(15):
    y_new = f(cx)
    ax2.plot([cx, cx], [cy, y_new], 'g-', linewidth=1.2, alpha=0.7)
    ax2.plot([cx, y_new], [y_new, y_new], 'g-', linewidth=1.2, alpha=0.7)
    cx, cy = y_new, y_new

# Cobweb from x=0.52 (just above repeller → converges to 1)
x0 = 0.52
cx, cy = x0, 0
for i in range(15):
    y_new = f(cx)
    ax2.plot([cx, cx], [cy, y_new], 'r-', linewidth=1.2, alpha=0.7)
    ax2.plot([cx, y_new], [y_new, y_new], 'r-', linewidth=1.2, alpha=0.7)
    cx, cy = y_new, y_new

ax2.axvline(x=0.5, color='gray', linestyle=':', alpha=0.5)
ax2.set_xlim(-0.05, 1.05)
ax2.set_ylim(-0.05, 1.05)
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('f(x)', fontsize=12)
ax2.set_title('Cobweb Diagram: The Cosmic Divide at x = ½', fontsize=11, fontweight='bold')
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)

# Add annotations
ax2.annotate('x₀ = 0.48 → 0', xy=(0.48, 0.02), xytext=(0.15, 0.15),
            fontsize=10, color='darkgreen', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkgreen'))
ax2.annotate('x₀ = 0.52 → 1', xy=(0.52, 0.02), xytext=(0.7, 0.15),
            fontsize=10, color='darkred', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkred'))

# ══════════════════════════════════════════════════════
# Panel 3: Convergence rates
# ══════════════════════════════════════════════════════
ax3 = fig.add_subplot(gs[1, 0])

starts = [0.1, 0.2, 0.3, 0.4, 0.49, 0.51, 0.6, 0.7, 0.8, 0.9]
colors_lower = plt.cm.Greens(np.linspace(0.3, 0.9, 5))
colors_upper = plt.cm.Reds(np.linspace(0.3, 0.9, 5))

for i, x0 in enumerate(starts[:5]):
    traj = iterate(x0, 20)
    ax3.plot(traj, 'o-', color=colors_lower[i], markersize=3, linewidth=1.5,
             label=f'x₀ = {x0}', alpha=0.8)

for i, x0 in enumerate(starts[5:]):
    traj = iterate(x0, 20)
    ax3.plot(traj, 's-', color=colors_upper[i], markersize=3, linewidth=1.5,
             label=f'x₀ = {x0}', alpha=0.8)

ax3.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='Repeller (½)')
ax3.set_xlabel('Iteration n', fontsize=12)
ax3.set_ylabel('f ⁿ(x₀)', fontsize=12)
ax3.set_title('Superlinear Convergence: All Roads Lead to 0 or 1', fontsize=11, fontweight='bold')
ax3.legend(ncol=2, fontsize=7, loc='center right')
ax3.grid(True, alpha=0.3)
ax3.set_xlim(0, 15)

# ══════════════════════════════════════════════════════
# Panel 4: Derivative landscape
# ══════════════════════════════════════════════════════
ax4 = fig.add_subplot(gs[1, 1])
x = np.linspace(-0.1, 1.1, 1000)
deriv = f_deriv(x)

ax4.fill_between(x, deriv, 1, where=(np.abs(deriv) > 1), alpha=0.2, color='red',
                 label='Repelling region (|f\'| > 1)')
ax4.fill_between(x, deriv, 0, where=(np.abs(deriv) <= 1) & (deriv >= 0), alpha=0.2,
                 color='green', label='Attracting region (|f\'| ≤ 1)')

ax4.plot(x, deriv, 'b-', linewidth=2.5, zorder=3)
ax4.axhline(y=1, color='red', linestyle='--', alpha=0.5, linewidth=1)
ax4.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

ax4.plot(0, 0, 'go', markersize=12, zorder=5, markeredgecolor='darkgreen', markeredgewidth=2)
ax4.plot(1, 0, 'ro', markersize=12, zorder=5, markeredgecolor='darkred', markeredgewidth=2)
ax4.plot(0.5, 1.5, 'ko', markersize=10, zorder=5, markerfacecolor='white', markeredgewidth=2)

ax4.annotate("f'(0) = 0\nSuperattractor", xy=(0, 0), xytext=(0.15, -0.3),
            fontsize=9, color='darkgreen', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkgreen'))
ax4.annotate("f'(1) = 0\nSuperattractor", xy=(1, 0), xytext=(0.85, -0.3),
            fontsize=9, color='darkred', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkred'))
ax4.annotate("f'(½) = 3/2\nRepeller", xy=(0.5, 1.5), xytext=(0.65, 1.3),
            fontsize=9, fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='black'))

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel("f'(x) = 6x(1−x)", fontsize=12)
ax4.set_title('The Derivative Landscape: Stability Map', fontsize=11, fontweight='bold')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)
ax4.set_xlim(-0.1, 1.1)
ax4.set_ylim(-0.5, 2.0)

plt.savefig('/workspace/request-project/core/Oracle/CosmicBootstrap/demos/bootstrap_basics.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✓ Generated: bootstrap_basics.png")
