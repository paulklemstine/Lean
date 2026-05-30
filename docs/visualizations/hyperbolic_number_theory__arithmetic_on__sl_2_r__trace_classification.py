"""
Visualization 2: SL(2,R) Trace Classification
==============================================
Visualizes the classification of SL(2,R) elements into elliptic,
parabolic, and hyperbolic types based on the trace, connecting
linear algebra to hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Trace vs Discriminant
ax1 = axes[0]
traces = np.linspace(-4, 4, 500)
discriminant = traces**2 - 4

# Color regions
ax1.fill_between(traces, discriminant, -5, where=(np.abs(traces) < 2),
                 alpha=0.3, color='blue', label='Elliptic (|tr| < 2)')
ax1.fill_between(traces, discriminant, 20, where=(np.abs(traces) > 2),
                 alpha=0.3, color='red', label='Hyperbolic (|tr| > 2)')

ax1.plot(traces, discriminant, 'k-', linewidth=2, label='Discriminant: tr² − 4')
ax1.axhline(y=0, color='green', linewidth=2, linestyle='--', label='Parabolic (tr² = 4)')
ax1.axvline(x=-2, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=2, color='gray', linestyle=':', alpha=0.5)

ax1.set_xlabel('Trace = a + d', fontsize=12)
ax1.set_ylabel('Discriminant = tr² − 4', fontsize=12)
ax1.set_title('SL(2,ℝ) Classification\nby Trace', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper center')
ax1.set_xlim(-4, 4)
ax1.set_ylim(-5, 13)
ax1.grid(True, alpha=0.3)

# Panel 2: Eigenvalue location
ax2 = axes[1]
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5)

# Elliptic: eigenvalues on unit circle
n_elliptic = 15
for i in range(n_elliptic):
    t = np.pi * (i + 1) / (n_elliptic + 1)
    ax2.plot(np.cos(t), np.sin(t), 'bo', markersize=8, alpha=0.7)
    ax2.plot(np.cos(t), -np.sin(t), 'bo', markersize=8, alpha=0.7)

# Parabolic: eigenvalue at ±1
ax2.plot(1, 0, 'gs', markersize=12, zorder=5, label='Parabolic (±1)')
ax2.plot(-1, 0, 'gs', markersize=12, zorder=5)

# Hyperbolic: eigenvalues on real axis
hyp_eigenvalues = [0.3, 0.5, 2.0, 3.3]
for lam in hyp_eigenvalues:
    ax2.plot(lam, 0, 'r^', markersize=10, alpha=0.8)
    ax2.plot(1/lam, 0, 'r^', markersize=10, alpha=0.8)

ax2.plot([], [], 'bo', markersize=8, label='Elliptic (on circle)')
ax2.plot([], [], 'r^', markersize=10, label='Hyperbolic (real, λ·1/λ)')

ax2.set_xlim(-3.8, 3.8)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Eigenvalue Location\nin the Complex Plane', fontsize=13, fontweight='bold')
ax2.set_xlabel('Re(λ)', fontsize=12)
ax2.set_ylabel('Im(λ)', fontsize=12)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)

# Panel 3: Orbits of each type
ax3 = axes[2]
ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Elliptic orbit (rotation)
t_vals = np.linspace(0, 2*np.pi, 20, endpoint=False)
r_orbit = 0.5
for t in t_vals:
    ax3.plot(r_orbit * np.cos(t), r_orbit * np.sin(t), 'bo', markersize=5, alpha=0.6)
ax3.annotate('Elliptic orbit\n(finite, circular)', xy=(0.5, 0.05),
             fontsize=9, color='blue', ha='center')

# Hyperbolic orbit (toward boundary)
for i in range(12):
    r = 1 - 0.9**i * 0.5
    angle = 0.3
    ax3.plot(r * np.cos(angle), r * np.sin(angle), 'r^', markersize=5, alpha=0.6)
    ax3.plot(-r * np.cos(angle), -r * np.sin(angle), 'r^', markersize=5, alpha=0.6)
ax3.annotate('Hyperbolic orbit\n(to boundary)', xy=(0.85, 0.4),
             fontsize=9, color='red', ha='center')

# Parabolic orbit (horocycle)
horocycle_t = np.linspace(-2, 2, 50)
horo_x = horocycle_t / (1 + horocycle_t**2)
horo_y = 1 - 1 / (1 + horocycle_t**2)
mask = horo_x**2 + horo_y**2 < 0.98
ax3.plot(horo_x[mask], horo_y[mask], 'g-', linewidth=2, alpha=0.7)
ax3.annotate('Parabolic orbit\n(horocycle)', xy=(0, 0.7),
             fontsize=9, color='green', ha='center')

ax3.set_xlim(-1.15, 1.15)
ax3.set_ylim(-1.15, 1.15)
ax3.set_aspect('equal')
ax3.set_title('Orbit Types in the\nPoincaré Disk', fontsize=13, fontweight='bold')
ax3.set_xlabel('Re(z)', fontsize=12)
ax3.set_ylabel('Im(z)', fontsize=12)

plt.tight_layout()
plt.savefig('trace_classification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved trace_classification.png")
