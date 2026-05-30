"""
Visualization: The Stone Dual Map
====================================
Visualizes the Stone point map from R^2 to {0,1}^m.
The left panel shows the continuous input space partitioned into regions.
The right panel shows the discrete Stone space (activation patterns)
as points in a hypercube, with edges connecting patterns that differ
by exactly one bit (adjacent regions share a hyperplane boundary).

This illustrates the fundamental theorem: two inputs map to the same
Stone point iff they agree on which side of every hyperplane they lie on.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def activation_pattern(Ws, bs, x):
    return tuple(np.dot(w, x) + b > 0 for w, b in zip(Ws, bs))


def hamming_distance(p1, p2):
    return sum(a != b for a, b in zip(p1, p2))


# Setup: 4 hyperplanes in R^2
Ws = [np.array([1.0, 0.0]),
      np.array([0.0, 1.0]),
      np.array([1.0, -1.0]),
      np.array([1.0, 1.0])]
bs = [0.0, 0.0, 0.0, -0.5]
m = len(Ws)

# Create grid and compute patterns
resolution = 400
x_range = np.linspace(-3, 3, resolution)
y_range = np.linspace(-3, 3, resolution)
X, Y = np.meshgrid(x_range, y_range)

patterns = {}
pattern_grid = np.zeros((resolution, resolution), dtype=int)
pattern_centroids = {}

for i in range(resolution):
    for j in range(resolution):
        point = np.array([X[i, j], Y[i, j]])
        p = activation_pattern(Ws, bs, point)
        if p not in patterns:
            patterns[p] = len(patterns)
            pattern_centroids[p] = [[], []]
        idx = patterns[p]
        pattern_grid[i, j] = idx
        pattern_centroids[p][0].append(X[i, j])
        pattern_centroids[p][1].append(Y[i, j])

n_regions = len(patterns)

# Compute centroids
centroids = {}
for p, (xs, ys) in pattern_centroids.items():
    centroids[p] = (np.mean(xs), np.mean(ys))

# Create figure
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Input space with activation regions
ax1 = axes[0]
cmap = plt.cm.get_cmap('Set3', n_regions)
ax1.pcolormesh(X, Y, pattern_grid, cmap=cmap, shading='auto', alpha=0.7)

# Draw hyperplane boundaries
for k in range(m):
    w, b = Ws[k], bs[k]
    if abs(w[1]) > 1e-10:
        x_line = np.linspace(-3, 3, 100)
        y_line = -(w[0] * x_line + b) / w[1]
        mask = (y_line >= -3) & (y_line <= 3)
        ax1.plot(x_line[mask], y_line[mask], 'k-', linewidth=2, alpha=0.8)
    else:
        x_val = -b / w[0] if abs(w[0]) > 1e-10 else 0
        ax1.axvline(x=x_val, color='k', linewidth=2, alpha=0.8)

# Label centroids
for p, (cx, cy) in centroids.items():
    if -2.5 < cx < 2.5 and -2.5 < cy < 2.5:
        label = ''.join('1' if b else '0' for b in p)
        ax1.annotate(label, (cx, cy), fontsize=9, fontweight='bold',
                     ha='center', va='center',
                     bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

# Draw arrows showing the Stone map
for p, (cx, cy) in list(centroids.items())[:4]:
    if -2 < cx < 2 and -2 < cy < 2:
        ax1.annotate('', xy=(2.8, cy), xytext=(cx + 0.3, cy),
                     arrowprops=dict(arrowstyle='->', color='red', lw=1.5))

ax1.set_xlim(-3, 3)
ax1.set_ylim(-3, 3)
ax1.set_xlabel('x₁', fontsize=14)
ax1.set_ylabel('x₂', fontsize=14)
ax1.set_title('Input Space R²\n(Activation Regions)', fontsize=13)
ax1.set_aspect('equal')

# Right: Stone space (discrete points)
ax2 = axes[1]

# Position patterns in a 2D layout based on their binary coordinates
# Use first two principal components of the binary patterns for layout
pattern_list = list(patterns.keys())
n = len(pattern_list)

# Simple 2D layout: use sum of bits for y, hash for x
pos = {}
for p in pattern_list:
    # Map binary pattern to 2D position
    bits = [1 if b else 0 for b in p]
    x_pos = sum(bits[i] * (2 ** i) for i in range(len(bits)))
    y_pos = sum(bits)
    # Add jitter to avoid overlaps
    pos[p] = (x_pos + np.random.uniform(-0.2, 0.2),
              y_pos + np.random.uniform(-0.1, 0.1))

# Draw edges between adjacent patterns (Hamming distance 1)
for p1 in pattern_list:
    for p2 in pattern_list:
        if p1 < p2 and hamming_distance(p1, p2) == 1:
            x1, y1 = pos[p1]
            x2, y2 = pos[p2]
            ax2.plot([x1, x2], [y1, y2], 'gray', linewidth=0.8, alpha=0.4)

# Draw nodes
for p in pattern_list:
    x, y = pos[p]
    color = cmap(patterns[p])
    ax2.plot(x, y, 'o', markersize=20, color=color,
             markeredgecolor='black', markeredgewidth=1.5, zorder=5)
    label = ''.join('1' if b else '0' for b in p)
    ax2.annotate(label, (x, y), fontsize=7, fontweight='bold',
                 ha='center', va='center', zorder=6)

ax2.set_xlabel('Pattern index', fontsize=12)
ax2.set_ylabel('Number of active neurons', fontsize=12)
ax2.set_title(f'Stone Space S(B)\n({n_regions} points = realized patterns)', fontsize=13)

# Add annotation
ax2.text(0.5, -0.12,
         'The Stone point map φ : R² → S(B)\n'
         'sends each input to its activation pattern.\n'
         'Edges connect patterns differing by 1 bit\n'
         '(adjacent activation regions).',
         transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', horizontalalignment='center',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.suptitle('Stone Duality: Continuous Space ↔ Discrete Space',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('stone_map.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Saved stone_map.png ({n_regions} Stone space points)")
