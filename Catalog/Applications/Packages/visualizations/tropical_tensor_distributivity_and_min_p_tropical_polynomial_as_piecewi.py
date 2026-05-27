"""
Visualization: Tropical Polynomial as Piecewise-Linear Function

This script visualizes a tropical polynomial p(x) = min(2+x, 5, 1+2x)
as the lower envelope of its constituent affine functions (monomials).
Each monomial corresponds to a path in the graph-theoretic interpretation.

The tropical normal form decomposes p(x) into these monomials, and the
minimum over them gives the piecewise-linear function.
"""

import numpy as np
import matplotlib.pyplot as plt

# Define the domain
x = np.linspace(-3, 7, 500)

# Three tropical monomials (affine functions)
m1 = 2 + x        # slope 1, intercept 2
m2 = 5 * np.ones_like(x)  # slope 0, intercept 5
m3 = 1 + 2 * x    # slope 2, intercept 1

# Tropical polynomial = min of monomials
p = np.minimum(np.minimum(m1, m2), m3)

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Individual monomials and their minimum
ax1.plot(x, m1, '--', color='#2196F3', alpha=0.6, linewidth=1.5, label='2 + x (path 1)')
ax1.plot(x, m2, '--', color='#4CAF50', alpha=0.6, linewidth=1.5, label='5 (path 2)')
ax1.plot(x, m3, '--', color='#FF9800', alpha=0.6, linewidth=1.5, label='1 + 2x (path 3)')
ax1.plot(x, p, 'k-', linewidth=3, label='min(...) = tropical sum')

# Mark breakpoints
ax1.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=3, color='gray', linestyle=':', alpha=0.5)
ax1.plot([1], [3], 'ko', markersize=8, zorder=5)
ax1.plot([3], [5], 'ko', markersize=8, zorder=5)

ax1.set_xlabel('x', fontsize=14)
ax1.set_ylabel('p(x)', fontsize=14)
ax1.set_title('Tropical Polynomial: Lower Envelope of Monomials', fontsize=14)
ax1.legend(fontsize=11, loc='upper left')
ax1.set_ylim(-5, 15)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3, 7)

# Annotate regions
ax1.annotate('slope 2\nregion', xy=(-1, 0), fontsize=10, ha='center',
            color='#FF9800', fontweight='bold')
ax1.annotate('slope 1\nregion', xy=(2, 3.5), fontsize=10, ha='center',
            color='#2196F3', fontweight='bold')
ax1.annotate('slope 0\nregion', xy=(5, 4.5), fontsize=10, ha='center',
            color='#4CAF50', fontweight='bold')

# Right panel: Which monomial achieves the minimum
colors = []
for xi in x:
    vals = [2 + xi, 5, 1 + 2 * xi]
    idx = np.argmin(vals)
    colors.append(['#2196F3', '#4CAF50', '#FF9800'][idx])

# Draw colored segments
for i in range(len(x) - 1):
    ax2.plot([x[i], x[i+1]], [p[i], p[i+1]], color=colors[i], linewidth=3)

ax2.axvline(x=1, color='gray', linestyle=':', alpha=0.5, label='breakpoints')
ax2.axvline(x=3, color='gray', linestyle=':', alpha=0.5)

# Legend patches
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#FF9800', label='1+2x wins'),
    Patch(facecolor='#2196F3', label='2+x wins'),
    Patch(facecolor='#4CAF50', label='5 wins'),
]
ax2.legend(handles=legend_elements, fontsize=11, loc='upper left')

ax2.set_xlabel('x', fontsize=14)
ax2.set_ylabel('p(x)', fontsize=14)
ax2.set_title('Tropical Normal Form: Active Monomial Regions', fontsize=14)
ax2.set_ylim(-5, 15)
ax2.set_xlim(-3, 7)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_tropical_polynomial.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_tropical_polynomial.png")
