#!/usr/bin/env python3
"""
Visualization 1: Oracle Hierarchy Separation Diagram

Visualizes the hierarchy of oracle capabilities and which arithmetic
consequences live at each level. Shows the strict separation between
point-value, derivative, zero-certificate, and Euler factor oracles.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Left panel: Oracle hierarchy as nested boxes
ax = axes[0]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Oracle Capability Hierarchy', fontsize=16, fontweight='bold', pad=20)

# Draw nested boxes from outer (strongest) to inner (weakest)
levels = [
    (0.5, 0.5, 9.0, 9.0, '#2196F3', 'Level 4: Full Oracle\n(Euler Factors + All Below)',
     'Factorization, Functoriality'),
    (1.2, 1.2, 7.6, 7.6, '#4CAF50', 'Level 3: Zero Certificate Oracle\n(Certified Zero Lists + Below)',
     'Decidable RH(T), Zero-Free Regions'),
    (1.9, 1.9, 6.2, 6.2, '#FF9800', 'Level 2: Derivative Oracle\n(All Derivatives + Below)',
     'Vanishing Order, Analytic Rank'),
    (2.6, 2.6, 4.8, 4.8, '#F44336', 'Level 1: Point-Value Oracle\n(Function Evaluation)',
     'Identity Principle\n⚠ CANNOT determine global zeros'),
]

for x, y, w, h, color, label, capability in levels:
    rect = mpatches.FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.2",
        facecolor=color, alpha=0.15,
        edgecolor=color, linewidth=2.5
    )
    ax.add_patch(rect)

for i, (x, y, w, h, color, label, capability) in enumerate(levels):
    label_y = y + h - 0.6
    ax.text(x + w/2, label_y, label, ha='center', va='top',
            fontsize=9, fontweight='bold', color=color)
    cap_y = y + 0.8
    ax.text(x + w/2, cap_y, capability, ha='center', va='bottom',
            fontsize=8, color='#333333', style='italic')

# Right panel: Barrier theorem visualization
ax2 = axes[1]
ax2.set_title('Finite-Query Barrier Theorem', fontsize=16, fontweight='bold', pad=20)

# Query points
Q = [0.0, 2.0, -1.0, 0.5]
x_range = np.linspace(-2, 3, 500)

# F(z) = ∏(z - q) (vanishing polynomial)
def vanish_poly(z, Q):
    result = np.ones_like(z)
    for q in Q:
        result = result * (z - q)
    return result

F_vals = vanish_poly(x_range, Q)
G_vals = np.zeros_like(x_range)

ax2.plot(x_range, F_vals, 'b-', linewidth=2, label='F(z) = ∏(z−q)', zorder=3)
ax2.plot(x_range, G_vals, 'r--', linewidth=2, label='G(z) = 0', zorder=3)

# Mark query points (where F = G = 0)
for q in Q:
    ax2.plot(q, 0, 'ko', markersize=10, zorder=5)
    ax2.annotate(f'q={q}', (q, 0), textcoords="offset points",
                xytext=(0, 15), ha='center', fontsize=9)

# Mark z = 1 (where they differ)
f1 = vanish_poly(np.array([1.0]), Q)[0]
ax2.plot(1.0, f1, 'b^', markersize=12, zorder=5, label=f'F(1) = {f1:.1f} ≠ 0')
ax2.plot(1.0, 0.0, 'rv', markersize=12, zorder=5, label='G(1) = 0')

# Vertical line at z = 1
ax2.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
ax2.annotate('z = 1\n(target)', (1.0, -3), ha='center',
            fontsize=10, fontweight='bold', color='purple')

ax2.set_xlabel('z (real axis)', fontsize=12)
ax2.set_ylabel('Function value', fontsize=12)
ax2.legend(loc='upper left', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-5, 8)

# Add annotation explaining the barrier
ax2.text(0.98, 0.02,
         'F and G agree on all query points\n'
         'but differ at the target z = 1.\n'
         '→ Point queries alone cannot\n'
         '   determine vanishing at z = 1.',
         transform=ax2.transAxes, fontsize=9,
         verticalalignment='bottom', horizontalalignment='right',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                  edgecolor='orange', alpha=0.9))

plt.tight_layout()
plt.savefig('viz_oracle_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved viz_oracle_hierarchy.png")
