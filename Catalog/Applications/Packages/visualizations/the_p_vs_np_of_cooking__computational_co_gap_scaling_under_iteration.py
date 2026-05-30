#!/usr/bin/env python3
"""
Visualization 2: Gap Scaling Under Iterated Composition

Shows that the complexity gap grows linearly when a recipe is composed
with itself repeatedly. This visualizes the theorem:
    gap(R^(k+1)) = (k+1) * gap(R)

Three different base recipes are shown, demonstrating that the slope
equals the base gap. Also shows the C/V ratio remains constant.
"""

import matplotlib.pyplot as plt
import numpy as np

# Base recipes with different gaps
base_recipes = [
    ("Toast (gap=1)", 3, 2, 1),        # C=3, V=2, gap=1
    ("Pasta (gap=17)", 20, 3, 17),      # C=20, V=3, gap=17
    ("Soufflé (gap=40)", 45, 5, 40),    # C=45, V=5, gap=40
]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Gap scaling
ax1 = axes[0]
for name, c, v, gap in base_recipes:
    k_vals = range(0, 8)
    gaps = [(k + 1) * gap for k in k_vals]
    ax1.plot(list(k_vals), gaps, 'o-', label=name, linewidth=2, markersize=6)

ax1.set_xlabel('Composition depth k', fontsize=12)
ax1.set_ylabel('Gap(R^(k+1))', fontsize=12)
ax1.set_title('Gap Scales Linearly\nwith Composition', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Plot 2: Cook time scaling
ax2 = axes[1]
for name, c, v, gap in base_recipes:
    k_vals = range(0, 8)
    cook_times = [(k + 1) * c for k in k_vals]
    verify_times = [(k + 1) * v for k in k_vals]
    ax2.plot(list(k_vals), cook_times, 'o-', label=f'{name} (cook)', linewidth=2, markersize=5)
    ax2.plot(list(k_vals), verify_times, 's--', alpha=0.5, linewidth=1, markersize=4)

ax2.set_xlabel('Composition depth k', fontsize=12)
ax2.set_ylabel('Time', fontsize=12)
ax2.set_title('Cook & Verify Times\nScale Proportionally', fontsize=13, fontweight='bold')
ax2.legend(fontsize=7)
ax2.grid(True, alpha=0.3)

# Plot 3: C/V ratio stays constant
ax3 = axes[2]
for name, c, v, gap in base_recipes:
    k_vals = range(0, 8)
    ratios = [c / v for _ in k_vals]  # Constant!
    ax3.plot(list(k_vals), ratios, 'o-', label=name, linewidth=2, markersize=6)

ax3.set_xlabel('Composition depth k', fontsize=12)
ax3.set_ylabel('C/V Ratio', fontsize=12)
ax3.set_title('C/V Ratio Remains\nConstant Under Iteration', fontsize=13, fontweight='bold')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 10)

plt.tight_layout()
plt.savefig('viz_gap_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_scaling.png")
