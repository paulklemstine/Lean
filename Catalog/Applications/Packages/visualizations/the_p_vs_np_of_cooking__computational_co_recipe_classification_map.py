#!/usr/bin/env python3
"""
Visualization 1: Recipe Complexity Classification Map

Plots recipes in the (cook_time, verify_time) plane, showing the P/NP/HARD
classification regions. The diagonal C=V separates P from NP, and the line
C=2V marks the boundary of HARD recipes. Each recipe is plotted as a point
with size proportional to its number of outcomes.

This visualizes the central theorem: every recipe lies in exactly one class,
and the classification is determined by the C/V ratio.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# Recipe data: (name, cook_time, verify_time, outcomes)
recipes = [
    ("Salad", 5, 5, 3),
    ("Toast", 3, 2, 2),
    ("Grilled Cheese", 8, 3, 2),
    ("Omelette", 10, 3, 3),
    ("Caesar Salad", 8, 4, 4),
    ("Pasta", 20, 3, 4),
    ("Carbonara", 25, 3, 5),
    ("Soufflé", 45, 5, 6),
    ("Crème Brûlée", 50, 5, 4),
    ("Sushi", 60, 8, 10),
    ("Beef Wellington", 90, 10, 8),
    ("Sandwich", 5, 4, 3),
]

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Classification regions
v_range = np.linspace(0, 12, 300)

# P region: C ≤ V (below diagonal)
ax.fill_between(v_range, 0, v_range, alpha=0.15, color='green', label='P region (C ≤ V)')

# NP region: V < C < 2V
ax.fill_between(v_range, v_range, 2 * v_range, alpha=0.15, color='orange', label='NP region (V < C < 2V)')

# HARD region: C ≥ 2V
ax.fill_between(v_range, 2 * v_range, 100, alpha=0.15, color='red', label='HARD region (C ≥ 2V)')

# Boundary lines
ax.plot(v_range, v_range, 'g--', linewidth=1.5, alpha=0.7, label='C = V (P boundary)')
ax.plot(v_range, 2 * v_range, 'r--', linewidth=1.5, alpha=0.7, label='C = 2V (HARD boundary)')

# Plot recipes
colors = {'P': 'green', 'NP': 'orange', 'HARD': 'red'}
for name, c, v, outcomes in recipes:
    if c <= v:
        cls = 'P'
    elif c >= 2 * v:
        cls = 'HARD'
    else:
        cls = 'NP'

    ax.scatter(v, c, s=outcomes * 30, c=colors[cls], edgecolors='black',
               linewidths=0.8, zorder=5, alpha=0.85)
    ax.annotate(name, (v, c), textcoords="offset points",
                xytext=(8, 5), fontsize=8, ha='left')

ax.set_xlabel('Verification Time V(R)', fontsize=13)
ax.set_ylabel('Cooking Time C(R)', fontsize=13)
ax.set_title('Recipe Complexity Classification:\nThe P vs NP of the Kitchen', fontsize=15, fontweight='bold')
ax.legend(loc='upper left', fontsize=9)
ax.set_xlim(0, 12)
ax.set_ylim(0, 100)
ax.set_aspect('auto')
ax.grid(True, alpha=0.3)

# Add annotation about the gap
ax.annotate('Gap = C − V\n(cooking overhead)',
            xy=(4, 20), fontsize=10, ha='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_classification.png', dpi=150, bbox_inches='tight')
print("Saved viz_classification.png")
