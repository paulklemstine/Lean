#!/usr/bin/env python3
"""
Visualization: The Retreat Theorem on the Infinite Board

Shows the king retreating from a threat, with distance increasing at each step.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def sign(x):
    return 1 if x > 0 else (-1 if x < 0 else 0)


def retreat_square(p, q):
    return (p[0] + sign(p[0] - q[0]), p[1] + sign(p[1] - q[1]))


def chebyshev_dist(p, q):
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def king_neighbors(p):
    offsets = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
    return [(p[0]+dx, p[1]+dy) for dx, dy in offsets]


# Generate retreat path
king_start = (0, 0)
threat = (3, 2)
steps = 8

path = [king_start]
current = king_start
for _ in range(steps):
    current = retreat_square(current, threat)
    path.append(current)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Board view with path
ax = axes[0]
ax.set_aspect('equal')

# Draw grid
for x in range(-3, 12):
    for y in range(-5, 10):
        rect = patches.Rectangle((x - 0.5, y - 0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray',
                                  facecolor='#f0f0f0' if (x + y) % 2 == 0 else 'white')
        ax.add_patch(rect)

# Draw Chebyshev distance circles around threat
for r in [1, 2, 3, 5, 8]:
    rect = patches.Rectangle((threat[0] - r - 0.5, threat[1] - r - 0.5),
                              2 * r + 1, 2 * r + 1,
                              linewidth=1, edgecolor='red', facecolor='none',
                              alpha=0.3, linestyle='--')
    ax.add_patch(rect)
    ax.text(threat[0] + r + 0.6, threat[1], f'd={r}', fontsize=7, color='red', alpha=0.6)

# Draw path
path_x = [p[0] for p in path]
path_y = [p[1] for p in path]
ax.plot(path_x, path_y, 'b-', linewidth=2, alpha=0.7, zorder=3)

# Draw path points
for i, p in enumerate(path):
    color = plt.cm.Blues(0.3 + 0.7 * i / len(path))
    ax.plot(p[0], p[1], 'o', color=color, markersize=10, zorder=4)
    ax.text(p[0] + 0.15, p[1] + 0.3, f'{i}', fontsize=8, fontweight='bold', zorder=5)

# Draw threat
ax.plot(threat[0], threat[1], 'rx', markersize=15, markeredgewidth=3, zorder=4)
ax.text(threat[0] + 0.3, threat[1] + 0.3, 'Threat', fontsize=9, color='red', fontweight='bold')

# Draw king neighbors at start
for n in king_neighbors(king_start):
    ax.plot(n[0], n[1], 's', color='lightblue', markersize=8, alpha=0.5, zorder=2)

ax.set_xlim(-3.5, 11.5)
ax.set_ylim(-5.5, 9.5)
ax.set_title('King Retreat Path on ℤ × ℤ\n(Chebyshev distance circles shown)', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('y')

# Right: Distance vs step
ax2 = axes[1]
distances = [chebyshev_dist(p, threat) for p in path]
step_nums = list(range(len(path)))

ax2.bar(step_nums, distances, color=[plt.cm.Blues(0.3 + 0.7 * i / len(path)) for i in step_nums],
        edgecolor='navy', alpha=0.8)
ax2.plot(step_nums, distances, 'ko-', markersize=5, zorder=3)

# Show the +1 increments
for i in range(1, len(distances)):
    ax2.annotate('', xy=(i, distances[i]), xytext=(i, distances[i-1]),
                 arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax2.text(i + 0.1, (distances[i] + distances[i-1]) / 2, '+1',
             fontsize=8, color='red', fontweight='bold')

ax2.set_xlabel('Step')
ax2.set_ylabel('Chebyshev Distance from Threat')
ax2.set_title('Distance Increases by ≥1 at Each Step\n(Retreat Theorem)', fontsize=12)
ax2.set_xticks(step_nums)

plt.tight_layout()
plt.savefig('viz_retreat.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_retreat.png")
