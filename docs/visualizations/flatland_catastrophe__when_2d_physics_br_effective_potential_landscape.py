#!/usr/bin/env python3
"""
Visualization: Effective Potential Comparison (2D vs 3D Gravity)
Shows why particles are trapped in 2D but can escape in 3D.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def v_eff_2d(r, k=1.0, L=1.0, m=1.0):
    """2D effective potential: k*ln(r) + L²/(2mr²)"""
    return k * np.log(r) + L**2 / (2 * m * r**2)


def v_eff_3d(r, k=1.0, L=1.0, m=1.0):
    """3D effective potential: -k/r + L²/(2mr²)"""
    return -k / r + L**2 / (2 * m * r**2)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
r = np.linspace(0.15, 8.0, 1000)

# 2D Effective Potential
ax1 = axes[0]
v2d = v_eff_2d(r)
ax1.plot(r, v2d, 'b-', linewidth=2, label=r'$V_{\rm eff}^{2D}(r) = k\ln r + \frac{L^2}{2mr^2}$')

# Mark minimum
r0_2d = 1.0  # |L|/sqrt(mk) = 1 for our parameters
v_min_2d = v_eff_2d(r0_2d)
ax1.plot(r0_2d, v_min_2d, 'ro', markersize=8, label=f'Circular orbit ($r_0 = {r0_2d:.1f}$)')

# Draw energy level
E_2d = v_min_2d + 0.3
ax1.axhline(y=E_2d, color='orange', linestyle='--', alpha=0.7, label=f'Energy E = {E_2d:.2f}')

# Shade trapped region
mask = v2d <= E_2d
if np.any(mask):
    r_trapped = r[mask]
    ax1.axvspan(r_trapped[0], r_trapped[-1], alpha=0.15, color='orange', label='Trapped region')

ax1.set_xlabel('Radius r', fontsize=12)
ax1.set_ylabel(r'$V_{\rm eff}(r)$', fontsize=12)
ax1.set_title('2D Gravity: ALL Particles Trapped\n$V_{\\rm eff} \\to +\\infty$ as $r \\to \\infty$', fontsize=12)
ax1.legend(fontsize=9, loc='upper right')
ax1.set_ylim(-1.5, 3.0)
ax1.grid(True, alpha=0.3)
ax1.annotate('No escape!\n$V \\to +\\infty$', xy=(6, v_eff_2d(6)), fontsize=10,
            ha='center', color='red', fontweight='bold')

# 3D Effective Potential
ax2 = axes[1]
v3d = v_eff_3d(r)
ax2.plot(r, v3d, 'g-', linewidth=2, label=r'$V_{\rm eff}^{3D}(r) = -\frac{k}{r} + \frac{L^2}{2mr^2}$')

# Mark minimum
r0_3d = 1.0  # L²/(mk) = 1 for our parameters
v_min_3d = v_eff_3d(r0_3d)
ax2.plot(r0_3d, v_min_3d, 'ro', markersize=8, label=f'Circular orbit ($r_0 = {r0_3d:.1f}$)')

# Draw bound energy level
E_3d_bound = v_min_3d + 0.15
ax2.axhline(y=E_3d_bound, color='orange', linestyle='--', alpha=0.7, label=f'Bound (E = {E_3d_bound:.2f})')

# Draw escape energy level
E_3d_escape = 0.05
ax2.axhline(y=E_3d_escape, color='red', linestyle='--', alpha=0.7, label=f'Escaping (E = {E_3d_escape:.2f})')
ax2.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

ax2.set_xlabel('Radius r', fontsize=12)
ax2.set_ylabel(r'$V_{\rm eff}(r)$', fontsize=12)
ax2.set_title('3D Gravity: Escape Possible\n$V_{\\rm eff} \\to 0$ as $r \\to \\infty$', fontsize=12)
ax2.legend(fontsize=9, loc='upper right')
ax2.set_ylim(-1.5, 1.0)
ax2.grid(True, alpha=0.3)
ax2.annotate('Escape to $\\infty$\n$V \\to 0$', xy=(6, 0.1), fontsize=10,
            ha='center', color='green', fontweight='bold')

plt.suptitle('Effective Potential: Why Flatland Has No Escape Velocity', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('effective_potential.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved effective_potential.png")
