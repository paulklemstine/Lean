#!/usr/bin/env python3
"""
Visualization: Tropical Bridge — Log-Concavity to Supermodularity

Shows the duality between mixed log-concavity of f and
discrete supermodularity of -log f (the tropical shadow).
"""

import matplotlib.pyplot as plt
import numpy as np
from math import factorial
from mpl_toolkits.mplot3d import Axes3D

def multinomial(m):
    total = sum(m)
    result = factorial(total)
    for mi in m:
        result //= factorial(mi)
    return result

# Degree-6 polynomial in 3 variables
d = 6
n = 3

# Collect data
points_2d = []
f_vals = []
g_vals = []  # -log f

for a in range(d+1):
    for b in range(d+1-a):
        c = d - a - b
        val = multinomial((a, b, c))
        if val > 0:
            points_2d.append((a, b))
            f_vals.append(val)
            g_vals.append(-np.log(val))

points_2d = np.array(points_2d)
f_vals = np.array(f_vals)
g_vals = np.array(g_vals)

fig = plt.figure(figsize=(16, 5))

# Plot 1: f values (log-concave dome)
ax1 = fig.add_subplot(131, projection='3d')
ax1.scatter(points_2d[:, 0], points_2d[:, 1], f_vals,
            c=f_vals, cmap='YlOrRd', s=80, alpha=0.8, edgecolors='darkred')
ax1.set_xlabel('$m_1$')
ax1.set_ylabel('$m_2$')
ax1.set_zlabel('$f(m)$')
ax1.set_title(f'Coefficient function $f$\n(multinomial, degree {d})')

# Plot 2: -log f (supermodular bowl)
ax2 = fig.add_subplot(132, projection='3d')
ax2.scatter(points_2d[:, 0], points_2d[:, 1], g_vals,
            c=g_vals, cmap='viridis', s=80, alpha=0.8, edgecolors='black')
ax2.set_xlabel('$m_1$')
ax2.set_ylabel('$m_2$')
ax2.set_zlabel('$-\\log f(m)$')
ax2.set_title('Tropical shadow $-\\log f$\n(supermodular)')

# Plot 3: Supermodularity verification
ax3 = fig.add_subplot(133)

# For each point, compute supermodularity gap
# g(m+ei) + g(m+ej) - g(m) - g(m+ei+ej) <= 0
gaps = []
coords = []
for a in range(d-1):
    for b in range(d-1-a):
        c = d - a - b
        if c >= 2:
            g_m = -np.log(multinomial((a, b, c)))
            g_mi = -np.log(multinomial((a+1, b, c-1)))
            g_mj = -np.log(multinomial((a, b+1, c-1)))
            g_mij = -np.log(multinomial((a+1, b+1, c-2)))
            gap = (g_mi + g_mj) - (g_m + g_mij)
            gaps.append(gap)
            coords.append((a, b))

gaps = np.array(gaps)
coords = np.array(coords)

scatter = ax3.scatter(coords[:, 0], coords[:, 1], c=gaps, cmap='RdYlGn_r',
                      s=100, alpha=0.8, edgecolors='black', vmin=min(gaps)-0.1, vmax=0.1)
plt.colorbar(scatter, ax=ax3, label='Supermodularity gap (≤0 = satisfied)')
ax3.set_xlabel('$m_1$')
ax3.set_ylabel('$m_2$')
ax3.set_title('Supermodularity gap\n$g(m+e_i)+g(m+e_j)-g(m)-g(m+e_i+e_j)$')
ax3.grid(True, alpha=0.3)

all_satisfied = np.all(gaps <= 1e-10)
ax3.text(0.5, -0.12, f'All gaps ≤ 0: {"✓ YES" if all_satisfied else "✗ NO"}',
         transform=ax3.transAxes, ha='center', fontsize=11,
         color='green' if all_satisfied else 'red', fontweight='bold')

fig.suptitle('Tropical Bridge: Log-Concavity ↔ Supermodularity',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved tropical_bridge.png")
