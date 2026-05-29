#!/usr/bin/env python3
"""
Visualization: Tropical Feasibility Certificate

Demonstrates the feasibility certificate theorem:
when a system of box constraints is infeasible, exactly which pair
of constraints conflicts. Shows both feasible and infeasible scenarios.

Uses matplotlib. Output: helly_certificate.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: Feasible system ---
ax = axes[0]

boxes_feasible = [
    (np.array([0, 0]), np.array([3, 3]), 'lightcoral', 'Constraint 1'),
    (np.array([1, 0.5]), np.array([4, 3.5]), 'lightgreen', 'Constraint 2'),
    (np.array([0.5, 1]), np.array([3.5, 4]), 'lightskyblue', 'Constraint 3'),
    (np.array([1.5, 0.5]), np.array([5, 2.5]), 'plum', 'Constraint 4'),
]

for lo, hi, color, label in boxes_feasible:
    rect = plt.Rectangle(lo, hi[0]-lo[0], hi[1]-lo[1],
                         alpha=0.25, facecolor=color, edgecolor='black', linewidth=1.5,
                         label=label)
    ax.add_patch(rect)

lo_max = np.max([lo for lo, _, _, _ in boxes_feasible], axis=0)
hi_min = np.min([hi for _, hi, _, _ in boxes_feasible], axis=0)

if np.all(lo_max <= hi_min):
    rect_int = plt.Rectangle(lo_max, hi_min[0]-lo_max[0], hi_min[1]-lo_max[1],
                             alpha=0.5, facecolor='gold', edgecolor='darkred', linewidth=2.5)
    ax.add_patch(rect_int)
    center = (lo_max + hi_min) / 2
    ax.plot(*center, 'r*', markersize=20, zorder=5, label='Feasible point')
    ax.annotate(f'({center[0]:.1f}, {center[1]:.1f})', center,
                fontsize=11, fontweight='bold', xytext=(10, 10),
                textcoords='offset points',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.8))

ax.set_xlim(-0.5, 6)
ax.set_ylim(-0.5, 5)
ax.set_title('Feasible System\n(All pairs intersect → global intersection)', 
             fontsize=13, fontweight='bold')
ax.set_xlabel('x₁', fontsize=12)
ax.set_ylabel('x₂', fontsize=12)
ax.legend(fontsize=9, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: Infeasible system with certificate ---
ax = axes[1]

boxes_infeasible = [
    (np.array([0, 0]), np.array([2, 3]), 'lightcoral', 'Constraint 1'),
    (np.array([1, 0.5]), np.array([3, 3.5]), 'lightgreen', 'Constraint 2'),
    (np.array([4, 0]), np.array([6, 3]), 'lightskyblue', 'Constraint 3'),
    (np.array([0.5, 1]), np.array([5, 4]), 'plum', 'Constraint 4'),
]

for lo, hi, color, label in boxes_infeasible:
    rect = plt.Rectangle(lo, hi[0]-lo[0], hi[1]-lo[1],
                         alpha=0.25, facecolor=color, edgecolor='black', linewidth=1.5,
                         label=label)
    ax.add_patch(rect)

# Find and highlight the conflicting pair
for i in range(len(boxes_infeasible)):
    for j in range(i+1, len(boxes_infeasible)):
        lo_i, hi_i = boxes_infeasible[i][0], boxes_infeasible[i][1]
        lo_j, hi_j = boxes_infeasible[j][0], boxes_infeasible[j][1]
        if not (np.all(lo_i <= hi_j) and np.all(lo_j <= hi_i)):
            # Highlight conflicting boxes
            rect1 = plt.Rectangle(lo_i, hi_i[0]-lo_i[0], hi_i[1]-lo_i[1],
                                 alpha=0, edgecolor='red', linewidth=3, linestyle='--')
            rect2 = plt.Rectangle(lo_j, hi_j[0]-lo_j[0], hi_j[1]-lo_j[1],
                                 alpha=0, edgecolor='red', linewidth=3, linestyle='--')
            ax.add_patch(rect1)
            ax.add_patch(rect2)
            
            # Arrow between them
            c1 = (lo_i + hi_i) / 2
            c2 = (lo_j + hi_j) / 2
            ax.annotate('', xy=c2, xytext=c1,
                       arrowprops=dict(arrowstyle='<->', color='red', lw=2.5))
            mid = (c1 + c2) / 2
            ax.annotate(f'CONFLICT\n(boxes {i+1} & {j+1})', mid,
                       fontsize=11, fontweight='bold', color='red',
                       ha='center', va='bottom',
                       bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))
            break
    else:
        continue
    break

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 5)
ax.set_title('Infeasible System with Certificate\n(Pair of conflicting constraints found)', 
             fontsize=13, fontweight='bold')
ax.set_xlabel('x₁', fontsize=12)
ax.set_ylabel('x₂', fontsize=12)
ax.legend(fontsize=9, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('helly_certificate.png', dpi=150, bbox_inches='tight')
print("Saved: helly_certificate.png")
