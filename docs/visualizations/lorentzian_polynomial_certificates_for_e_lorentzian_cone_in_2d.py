#!/usr/bin/env python3
"""
Visualization 2: The Lorentzian Cone in 2D

Visualizes the Lorentzian condition for bivariate quadratic forms
Q(s,t) = a·s² + 2b·st + c·t².

The Lorentzian cone is the region where a,c ≥ 0 and b² ≥ ac.
Shows how this cone relates to the exchange direction restriction
and the AM-GM inequality √(ac) ≤ b.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: The Lorentzian cone in (a, c) space for fixed b
ax = axes[0]
a_vals = np.linspace(0, 4, 200)
c_vals = np.linspace(0, 4, 200)
A, C = np.meshgrid(a_vals, c_vals)

for b_val, color, alpha in [(0.5, 'blue', 0.3), (1.0, 'green', 0.3),
                              (2.0, 'red', 0.3)]:
    # Lorentzian region: b² ≥ a*c, i.e., a*c ≤ b²
    lorentzian = (A * C <= b_val**2).astype(float)
    ax.contourf(A, C, lorentzian, levels=[0.5, 1.5], colors=[color], alpha=alpha)
    # Boundary curve: c = b²/a
    a_pos = np.linspace(0.01, 4, 100)
    c_boundary = b_val**2 / a_pos
    c_boundary = np.clip(c_boundary, 0, 4)
    ax.plot(a_pos, c_boundary, color=color, linewidth=2, label=f'b = {b_val}')

ax.set_xlabel('a (coefficient of s²)', fontsize=12)
ax.set_ylabel('c (coefficient of t²)', fontsize=12)
ax.set_title('Lorentzian Cone: b² ≥ ac', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_xlim(0, 4)
ax.set_ylim(0, 4)
ax.set_aspect('equal')

# Panel 2: Exchange direction value Q(1,-1) = a - 2b + c
ax = axes[1]
b_vals = np.linspace(0, 3, 200)
a_vals = np.linspace(0, 3, 200)
B, A2 = np.meshgrid(b_vals, a_vals)

# Fix c = 1 for visualization
c_fixed = 1.0
# Exchange value: a - 2b + c
exchange_val = A2 - 2 * B + c_fixed
# Lorentzian region: b² ≥ a*c = a
lorentzian_region = (B**2 >= A2 * c_fixed)
# AM-GM bound: (√a - √c)²
amgm_bound = (np.sqrt(np.maximum(A2, 0)) - np.sqrt(c_fixed))**2

# Plot exchange value
im = ax.contourf(B, A2, exchange_val, levels=20, cmap='RdBu_r')
plt.colorbar(im, ax=ax, label='Q(1,-1) = a - 2b + c')

# Lorentzian boundary
a_boundary = np.linspace(0, 3, 100)
b_boundary = np.sqrt(a_boundary * c_fixed)
ax.plot(b_boundary, a_boundary, 'k-', linewidth=2.5, label='Lorentzian boundary: b = √(ac)')

# Mark the a = c = 1 point (where exchange is exactly 0 at b = 1)
ax.plot(1, 1, 'ko', markersize=10, zorder=5)
ax.annotate('a=c=1, b=1\nQ(1,-1)=0', (1, 1), textcoords="offset points",
            xytext=(15, 10), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='black'))

ax.set_xlabel('b (cross-term coefficient)', fontsize=12)
ax.set_ylabel('a (coefficient of s²)', fontsize=12)
ax.set_title(f'Exchange Direction (c={c_fixed})\nQ(1,−1) = a − 2b + c', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xlim(0, 3)
ax.set_ylim(0, 3)

plt.suptitle('Bivariate Lorentzian Polynomials and Exchange Certificates',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('lorentzian_cone.png', dpi=150, bbox_inches='tight')
print("Saved lorentzian_cone.png")
