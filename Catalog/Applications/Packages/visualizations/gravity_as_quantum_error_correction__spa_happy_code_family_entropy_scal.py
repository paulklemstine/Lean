#!/usr/bin/env python3
"""
Visualization 1: HaPPY Code Family Entropy Scaling

Visualizes how the entanglement entropy, area, and boundary size scale
with the depth level L in the HaPPY holographic code family.
Shows the constant entropy-to-boundary ratio S/n = 4/5 (Bekenstein-Hawking area law).
"""

import matplotlib.pyplot as plt
import numpy as np

# HaPPY family parameters
levels = np.arange(0, 21)
n_boundary = 5 * (levels + 1)
k_bulk = levels + 1
entropy = n_boundary - k_bulk  # = 4*(L+1)
area = entropy.copy()  # A = S for this family
ratio = entropy / n_boundary  # = 4/5

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Parameter scaling
ax1 = axes[0]
ax1.plot(levels, n_boundary, 'b-o', markersize=4, label='n (boundary)')
ax1.plot(levels, k_bulk, 'r-s', markersize=4, label='k (bulk)')
ax1.plot(levels, entropy, 'g-^', markersize=4, label='S (entropy)')
ax1.set_xlabel('Level L', fontsize=12)
ax1.set_ylabel('Parameter Value', fontsize=12)
ax1.set_title('HaPPY Code Family Scaling', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: RT formula verification (Area = Entropy)
ax2 = axes[1]
ax2.plot(entropy, area, 'ko-', markersize=6, label='A vs S')
ax2.plot([0, max(entropy)], [0, max(entropy)], 'r--', alpha=0.5, label='A = S (RT)')
ax2.set_xlabel('Entropy S = n - k', fontsize=12)
ax2.set_ylabel('Area A', fontsize=12)
ax2.set_title('Ryu-Takayanagi: Area = Entropy', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Constant ratio (Bekenstein-Hawking area law)
ax3 = axes[2]
ax3.plot(levels, ratio, 'purple', linewidth=2, label='S/n')
ax3.axhline(y=0.8, color='red', linestyle='--', alpha=0.7, label='4/5 = 0.800')
ax3.set_xlabel('Level L', fontsize=12)
ax3.set_ylabel('Entropy / Boundary Ratio', fontsize=12)
ax3.set_title('Bekenstein-Hawking Area Law', fontsize=14)
ax3.set_ylim(0.75, 0.85)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_scaling.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved entropy_scaling.png")
