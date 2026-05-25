#!/usr/bin/env python3
"""
Visualization: Upward Closure of Threshold Family

This script visualizes the lattice structure of threshold sets,
showing how the threshold family is upward closed and how
feasibility is preserved under set inclusion.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from itertools import combinations

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# ──────────────────────────────────────────────────────────────────────────────
# Panel 1: Lattice of subsets with threshold-achievable sets highlighted
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[0]
ax.set_title("Upward Closure in the Subset Lattice\n(3 vertices, τ = 1/2)", fontsize=12, fontweight='bold')

# For V = {0,1,2}, show the full power set lattice
# Highlight: if S is achievable, all supersets are achievable
all_subsets = [
    frozenset(),
    frozenset({0}), frozenset({1}), frozenset({2}),
    frozenset({0,1}), frozenset({0,2}), frozenset({1,2}),
    frozenset({0,1,2}),
]

# Positions in Hasse diagram
positions = {
    frozenset(): (3, 0),
    frozenset({0}): (1, 1), frozenset({1}): (3, 1), frozenset({2}): (5, 1),
    frozenset({0,1}): (1.5, 2), frozenset({0,2}): (3, 2), frozenset({1,2}): (4.5, 2),
    frozenset({0,1,2}): (3, 3),
}

# All subsets are achievable as threshold sets (trivially: use indicator)
# But mark a specific example: x = (0.6, 0.3, 0.7), τ = 0.5
# T = {0, 2}. Upward closure: {0,2}, {0,1,2}
base_set = frozenset({0, 2})
upward_closure = {s for s in all_subsets if base_set <= s}

# Draw edges (Hasse diagram)
hasse_edges = []
for s1 in all_subsets:
    for s2 in all_subsets:
        if len(s2) == len(s1) + 1 and s1 < s2:
            hasse_edges.append((s1, s2))

for s1, s2 in hasse_edges:
    p1, p2 = positions[s1], positions[s2]
    both_up = s1 in upward_closure and s2 in upward_closure
    color = '#2185a8' if both_up else '#cccccc'
    lw = 2.5 if both_up else 1
    ax.plot([p1[0], p2[0]], [p1[1], p2[1]], '-', color=color, linewidth=lw, zorder=1)

# Draw nodes
for s in all_subsets:
    p = positions[s]
    in_closure = s in upward_closure
    is_base = s == base_set
    if is_base:
        color = '#ff6b35'
        edgecolor = '#cc4400'
        size = 800
    elif in_closure:
        color = '#2185a8'
        edgecolor = '#1a6b87'
        size = 600
    else:
        color = '#e8e8e8'
        edgecolor = '#999999'
        size = 400

    ax.scatter(*p, s=size, c=color, edgecolors=edgecolor, linewidth=2, zorder=3)

    label = '{' + ','.join(str(v) for v in sorted(s)) + '}' if s else '∅'
    text_color = 'white' if in_closure else '#666666'
    ax.text(p[0], p[1], label, ha='center', va='center', fontsize=9,
            fontweight='bold' if in_closure else 'normal', color=text_color, zorder=4)

# Annotations
ax.text(0.5, -0.08,
        'Orange = base set T_τ(x) = {0,2}\nBlue = upward closure (all achievable)\n'
        'Gray = not in upward closure of {0,2}',
        transform=ax.transAxes, ha='center', fontsize=9, style='italic')

ax.set_xlim(-0.5, 6.5)
ax.set_ylim(-0.7, 3.8)
ax.axis('off')

# ──────────────────────────────────────────────────────────────────────────────
# Panel 2: Feasibility preservation under upward closure
# ──────────────────────────────────────────────────────────────────────────────
ax = axes[1]
ax.set_title("Feasibility-Preserving Upward Closure\n(constructing y from x)", fontsize=12, fontweight='bold')

# Show how to construct y from x when S ⊂ S'
# Example: V = {0,1,2,3}, edge = {0,1,2}, d = 3, τ = 1/3
# x = (0.5, 0.1, 0.4, 0.0) → T = {0, 2}
# S' = {0, 1, 2} ⊃ S = {0, 2}
# y = (0.5, 1/3, 0.4, 0.0) → T = {0, 1, 2}

vertices = [0, 1, 2, 3]
x_vals = [0.5, 0.1, 0.4, 0.0]
y_vals = [0.5, 1/3, 0.4, 0.0]
tau = 1/3

x_pos = np.arange(len(vertices))
width = 0.35

bars_x = ax.bar(x_pos - width/2, x_vals, width, label='x(v) — original',
                color='#6bb3d1', alpha=0.8, edgecolor='#4a93a8')
bars_y = ax.bar(x_pos + width/2, y_vals, width, label='y(v) — constructed',
                color='#2185a8', alpha=0.8, edgecolor='#1a6b87')

# Threshold line
ax.axhline(y=tau, color='red', linewidth=2, linestyle='--', label=f'τ = 1/3', alpha=0.8)

# Mark the raised coordinate
ax.annotate('↑ raised\nto τ', xy=(1 + width/2, y_vals[1]),
            xytext=(1 + width/2 + 0.3, y_vals[1] + 0.15),
            arrowprops=dict(arrowstyle='->', color='#ff6b35', lw=2),
            fontsize=10, color='#ff6b35', fontweight='bold')

# Mark threshold membership
for i in range(len(vertices)):
    if x_vals[i] >= tau:
        ax.text(i - width/2, x_vals[i] + 0.02, '∈S', ha='center', fontsize=8, color='#6bb3d1')
    if y_vals[i] >= tau:
        ax.text(i + width/2, y_vals[i] + 0.02, "∈S'", ha='center', fontsize=8, color='#2185a8')

ax.set_xlabel('Vertices', fontsize=11)
ax.set_ylabel('Assignment value', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels([f'v{v}' for v in vertices])
ax.legend(fontsize=9, loc='upper right')
ax.set_ylim(0, 0.75)

# Edge feasibility check
edge = {0, 1, 2}
sum_x = sum(x_vals[v] for v in edge)
sum_y = sum(y_vals[v] for v in edge)
ax.text(0.5, -0.12,
        f'Edge {{0,1,2}}: Σx = {sum_x:.2f} ≥ 1 ✓   |   Σy = {sum_y:.2f} ≥ 1 ✓\n'
        f'S = {{0,2}} → S\' = {{0,1,2}}: feasibility preserved!',
        transform=ax.transAxes, ha='center', fontsize=10, style='italic')

plt.tight_layout()
plt.savefig('upward_closure_visualization.png', dpi=150, bbox_inches='tight')
print("Saved upward_closure_visualization.png")
