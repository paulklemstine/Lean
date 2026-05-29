"""
Visualization 1: Binary Entropy vs Tropical Surrogate
=====================================================

Compares the binary Shannon entropy h(x) = -x·log(x) - (1-x)·log(1-x)
with the tropical entropy surrogate h_trop(x) = 2·min(x, 1-x)·log(2).

The key theorem (formally verified) is that h_trop(x) ≤ h(x) for all x ∈ [0,1],
with equality at x = 0, x = 1/2, and x = 1. The shaded region shows the
"tropical entropy gap" — the price of the piecewise-linear approximation.
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute functions
x = np.linspace(0, 1, 1000)

# Binary entropy (handle endpoints)
h = np.zeros_like(x)
for i, xi in enumerate(x):
    if 0 < xi < 1:
        h[i] = -xi * np.log(xi) - (1 - xi) * np.log(1 - xi)

# Tropical entropy
h_trop = 2 * np.minimum(x, 1 - x) * np.log(2)

# Quadratic lower bound (from catalog: h(x) ≥ 2x(1-x))
h_quad = 2 * x * (1 - x)

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: entropy comparison
ax1.fill_between(x, h_trop, h, alpha=0.3, color='coral', label='Tropical gap')
ax1.plot(x, h, 'b-', linewidth=2.5, label=r'Binary entropy $h(x)$')
ax1.plot(x, h_trop, 'r--', linewidth=2.5, label=r'Tropical surrogate $2\min(x,1{-}x)\ln 2$')
ax1.plot(x, h_quad, 'g:', linewidth=2, label=r'Quadratic bound $2x(1{-}x)$')
ax1.axhline(y=np.log(2), color='gray', linestyle=':', alpha=0.5)
ax1.annotate(r'$\ln 2$', xy=(0.02, np.log(2)), fontsize=11, color='gray')

# Mark equality points
for xp in [0, 0.5, 1.0]:
    ax1.plot(xp, 2 * min(xp, 1-xp) * np.log(2), 'ko', markersize=8, zorder=5)
ax1.annotate('Equality at\n$x = 0, \\frac{1}{2}, 1$',
             xy=(0.5, np.log(2)), xytext=(0.65, 0.45),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

ax1.set_xlabel('$x$', fontsize=14)
ax1.set_ylabel('Entropy', fontsize=14)
ax1.set_title('Binary Entropy vs. Tropical Surrogate', fontsize=15, fontweight='bold')
ax1.legend(fontsize=11, loc='upper left')
ax1.set_xlim(-0.02, 1.02)
ax1.set_ylim(-0.02, 0.75)
ax1.grid(True, alpha=0.3)

# Right panel: relative approximation error
mask = h > 0.001
rel_error = np.zeros_like(x)
rel_error[mask] = (h[mask] - h_trop[mask]) / h[mask]

ax2.plot(x[mask], rel_error[mask], 'b-', linewidth=2)
ax2.fill_between(x[mask], 0, rel_error[mask], alpha=0.2, color='blue')
ax2.set_xlabel('$x$', fontsize=14)
ax2.set_ylabel('Relative error $(h - h_{\\mathrm{trop}})/h$', fontsize=14)
ax2.set_title('Approximation Quality', fontsize=15, fontweight='bold')
ax2.set_xlim(-0.02, 1.02)
ax2.grid(True, alpha=0.3)
ax2.annotate('Best near $x = 0, 1$\n(area-law regime)',
             xy=(0.1, rel_error[100]), xytext=(0.25, 0.35),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('viz_entropy_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_comparison.png")
