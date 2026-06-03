#!/usr/bin/env python3
"""
Visualization: Knight Threat Radius and King Safety

Shows knight attack patterns and the safety radius theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def chebyshev_dist(p, q):
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def king_neighbors(p):
    offsets = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
    return [(p[0]+dx, p[1]+dy) for dx, dy in offsets]


def knight_attacks(p):
    offsets = [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)]
    return [(p[0]+dx, p[1]+dy) for dx, dy in offsets]


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Knight attack pattern
ax = axes[0]
knight = (0, 0)
attacks = knight_attacks(knight)

for x in range(-4, 5):
    for y in range(-4, 5):
        color = '#f0f0f0' if (x+y) % 2 == 0 else 'white'
        if (x, y) in attacks:
            color = '#ff6b6b'
        elif (x, y) == knight:
            color = '#4ecdc4'
        rect = patches.Rectangle((x-0.5, y-0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray', facecolor=color)
        ax.add_patch(rect)

# Chebyshev distance 2 box
rect = patches.Rectangle((-2.5, -2.5), 5, 5,
                          linewidth=2, edgecolor='blue', facecolor='none',
                          linestyle='--', label='Chebyshev dist ≤ 2')
ax.add_patch(rect)

ax.set_xlim(-4.5, 4.5)
ax.set_ylim(-4.5, 4.5)
ax.set_aspect('equal')
ax.set_title('Knight Attack Pattern\n(all within Chebyshev dist 2)', fontsize=11)
ax.legend(loc='upper right', fontsize=8)

# Panel 2: King at distance 3 (unsafe)
ax = axes[1]
knight = (0, 0)
king_pos = (3, 0)  # distance 3

attacks = set(knight_attacks(knight))
nbrs = set(king_neighbors(king_pos))
overlap = nbrs & attacks

for x in range(-3, 7):
    for y in range(-4, 5):
        color = '#f0f0f0' if (x+y) % 2 == 0 else 'white'
        if (x, y) in overlap:
            color = '#ff0000'  # Overlap = danger!
        elif (x, y) in attacks:
            color = '#ffcccc'
        elif (x, y) in nbrs:
            color = '#ccffcc'
        elif (x, y) == knight:
            color = '#4ecdc4'
        elif (x, y) == king_pos:
            color = '#ffd700'
        rect = patches.Rectangle((x-0.5, y-0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray', facecolor=color)
        ax.add_patch(rect)

ax.text(knight[0], knight[1], '♞', fontsize=20, ha='center', va='center')
ax.text(king_pos[0], king_pos[1], '♔', fontsize=20, ha='center', va='center')

ax.set_xlim(-3.5, 6.5)
ax.set_ylim(-4.5, 4.5)
ax.set_aspect('equal')
ax.set_title(f'King at dist 3: {len(overlap)} threatened neighbor(s)\n(UNSAFE)', fontsize=11, color='red')

# Panel 3: King at distance 4 (safe)
ax = axes[2]
knight = (0, 0)
king_pos = (4, 0)  # distance 4 > 3

attacks = set(knight_attacks(knight))
nbrs = set(king_neighbors(king_pos))
overlap = nbrs & attacks

for x in range(-3, 8):
    for y in range(-4, 5):
        color = '#f0f0f0' if (x+y) % 2 == 0 else 'white'
        if (x, y) in overlap:
            color = '#ff0000'
        elif (x, y) in attacks:
            color = '#ffcccc'
        elif (x, y) in nbrs:
            color = '#ccffcc'
        elif (x, y) == knight:
            color = '#4ecdc4'
        elif (x, y) == king_pos:
            color = '#ffd700'
        rect = patches.Rectangle((x-0.5, y-0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray', facecolor=color)
        ax.add_patch(rect)

ax.text(knight[0], knight[1], '♞', fontsize=20, ha='center', va='center')
ax.text(king_pos[0], king_pos[1], '♔', fontsize=20, ha='center', va='center')

ax.set_xlim(-3.5, 7.5)
ax.set_ylim(-4.5, 4.5)
ax.set_aspect('equal')
ax.set_title(f'King at dist 4: {len(overlap)} threatened neighbor(s)\n(SAFE ✓)', fontsize=11, color='green')

plt.tight_layout()
plt.savefig('viz_threat_radius.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_threat_radius.png")
