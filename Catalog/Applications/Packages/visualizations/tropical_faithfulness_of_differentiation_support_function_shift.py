#!/usr/bin/env python3
"""
Visualization: Support Function Shift under Shadow Translation

Visualizes Theorem 5: the support function of the mixed shadow equals
the support function of the original set shifted by -(wᵢ + wⱼ).

Shows support functions as polar plots (or directional bar charts)
and demonstrates the exact linear shift relationship.

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def mixed_shadow(supp, i, j, n_vars):
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def support_function(supp, w):
    if not supp:
        return float('-inf')
    return max(sum(w[k] * a[k] for k in range(len(w))) for a in supp)


# Setup
supp_p = {(3, 2), (2, 3), (1, 1), (4, 1), (2, 2)}
shadow = mixed_shadow(supp_p, 0, 1, 2)

# Generate directions on unit circle
n_dirs = 72
angles = [2 * math.pi * k / n_dirs for k in range(n_dirs)]
directions = [(math.cos(a), math.sin(a)) for a in angles]
# Only use non-negative directions for the shift theorem
pos_directions = [(max(0.01, math.cos(a)), max(0.01, math.sin(a))) for a in angles]

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Support set and shadow
ax = axes[0]
ax.set_title('Support Set and Mixed Shadow', fontsize=13, fontweight='bold')

for x in range(6):
    for y in range(5):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=3)

for pt in supp_p:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=16, alpha=0.7, zorder=3)
for pt in shadow:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=13, alpha=0.7, zorder=3)
    # Arrow to ancestor
    ancestor = (pt[0] + 1, pt[1] + 1)
    if ancestor in supp_p:
        ax.annotate('', xy=ancestor, xytext=pt,
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.4, lw=1.5))

ax.set_xlabel('x exponent', fontsize=11)
ax.set_ylabel('y exponent', fontsize=11)
ax.set_xlim(-0.5, 5.5)
ax.set_ylim(-0.5, 4.5)
ax.set_aspect('equal')
ax.legend(['', 'supp(p)', 'shadow(0,1)'], fontsize=10)

# Panel 2: Support functions
ax = axes[1]
ax.set_title('Support Functions h_S(w) and h_shadow(w)', fontsize=13, fontweight='bold')

h_S_vals = [support_function(supp_p, d) for d in pos_directions]
h_shadow_vals = [support_function(shadow, d) for d in pos_directions]
shift_vals = [h_S - (d[0] + d[1]) for h_S, d in zip(h_S_vals, pos_directions)]

angle_deg = [a * 180 / math.pi for a in angles]

ax.plot(angle_deg, h_S_vals, '-', color='#2196F3', linewidth=2, label='h_S(w)')
ax.plot(angle_deg, h_shadow_vals, '--', color='#FF9800', linewidth=2, label='h_shadow(w)')
ax.plot(angle_deg, shift_vals, ':', color='#4CAF50', linewidth=2, label='h_S(w) − (w₀+w₁)')

ax.set_xlabel('Direction angle (degrees)', fontsize=11)
ax.set_ylabel('Support function value', fontsize=11)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Difference plot (should be zero for admissible directions)
ax = axes[2]
ax.set_title('Shift Theorem Verification\nh_shadow(w) − [h_S(w) − (w₀+w₁)]',
             fontsize=13, fontweight='bold')

diffs = [h_sh - sh for h_sh, sh in zip(h_shadow_vals, shift_vals)]

# Color by whether shift holds
colors = ['#4CAF50' if abs(d) < 0.01 else '#F44336' for d in diffs]
ax.bar(range(len(diffs)), diffs, color=colors, alpha=0.7, width=1.0)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Direction index', fontsize=11)
ax.set_ylabel('Difference', fontsize=11)

n_match = sum(1 for d in diffs if abs(d) < 0.01)
ax.text(0.5, 0.95, f'Exact match: {n_match}/{len(diffs)} directions',
        transform=ax.transAxes, ha='center', va='top', fontsize=11,
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_support_function.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_function.png")
