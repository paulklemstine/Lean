"""
Visualization: Cups and Caps in the Plane

Illustrates the key geometric concept: cups (convex-up chains) and caps
(convex-down chains) in a planar point set. Shows how the orientation
function determines whether three consecutive points form part of a
cup or a cap.
"""

import matplotlib.pyplot as plt
import numpy as np

def orient(a, b, c):
    """Signed area of triangle (a, b, c)."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])

# Create example point set
np.random.seed(42)
n = 12
xs = np.sort(np.random.uniform(0, 10, n))
ys = np.random.uniform(-3, 3, n)
points = list(zip(xs, ys))

# Find cups and caps (greedy)
def find_longest_cup(pts):
    """Find longest cup using DP."""
    n = len(pts)
    dp = [1] * n
    prev = [-1] * n
    for i in range(1, n):
        dp[i] = 2
        prev[i] = 0
        for j in range(1, i):
            if dp[j] >= 2 and prev[j] >= 0:
                if orient(pts[prev[j]], pts[j], pts[i]) > 0:
                    if dp[j] + 1 > dp[i]:
                        dp[i] = dp[j] + 1
                        prev[i] = j
    best_idx = max(range(n), key=lambda i: dp[i])
    path = []
    i = best_idx
    while i >= 0:
        path.append(i)
        i = prev[i]
    return list(reversed(path))

def find_longest_cap(pts):
    """Find longest cap using DP."""
    n = len(pts)
    dp = [1] * n
    prev = [-1] * n
    for i in range(1, n):
        dp[i] = 2
        prev[i] = 0
        for j in range(1, i):
            if dp[j] >= 2 and prev[j] >= 0:
                if orient(pts[prev[j]], pts[j], pts[i]) < 0:
                    if dp[j] + 1 > dp[i]:
                        dp[i] = dp[j] + 1
                        prev[i] = j
    best_idx = max(range(n), key=lambda i: dp[i])
    path = []
    i = best_idx
    while i >= 0:
        path.append(i)
        i = prev[i]
    return list(reversed(path))

cup_indices = find_longest_cup(points)
cap_indices = find_longest_cap(points)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: All points
ax = axes[0]
ax.scatter(xs, ys, c='#333333', s=80, zorder=3, edgecolors='black')
for i, (x, y) in enumerate(points):
    ax.annotate(f'{i}', (x, y), textcoords="offset points",
                xytext=(5, 8), fontsize=9, color='gray')
ax.set_title('Point Set in General Position', fontsize=14, fontweight='bold')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.grid(True, alpha=0.2)

# Panel 2: Longest cup
ax = axes[1]
ax.scatter(xs, ys, c='#CCCCCC', s=60, zorder=2, edgecolors='gray')
cup_pts = [points[i] for i in cup_indices]
cup_x = [p[0] for p in cup_pts]
cup_y = [p[1] for p in cup_pts]
ax.plot(cup_x, cup_y, 'o-', color='#2196F3', linewidth=2.5, markersize=10,
        zorder=3, label=f'Cup (length {len(cup_indices)})')
for i, idx in enumerate(cup_indices):
    ax.annotate(f'{idx}', (points[idx][0], points[idx][1]),
                textcoords="offset points", xytext=(5, 8), fontsize=10,
                color='#2196F3', fontweight='bold')

# Show orientation signs
for i in range(len(cup_pts) - 2):
    o = orient(cup_pts[i], cup_pts[i+1], cup_pts[i+2])
    mid_x = (cup_pts[i][0] + cup_pts[i+1][0] + cup_pts[i+2][0]) / 3
    mid_y = (cup_pts[i][1] + cup_pts[i+1][1] + cup_pts[i+2][1]) / 3
    sign = '+' if o > 0 else '−'
    ax.annotate(f'orient={sign}', (mid_x, mid_y), fontsize=8,
                color='#1565C0', ha='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='#E3F2FD'))

ax.set_title('Longest Cup (Convex-Up Chain)', fontsize=14, fontweight='bold')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.2)

# Panel 3: Longest cap
ax = axes[2]
ax.scatter(xs, ys, c='#CCCCCC', s=60, zorder=2, edgecolors='gray')
cap_pts = [points[i] for i in cap_indices]
cap_x = [p[0] for p in cap_pts]
cap_y = [p[1] for p in cap_pts]
ax.plot(cap_x, cap_y, 's-', color='#FF5722', linewidth=2.5, markersize=10,
        zorder=3, label=f'Cap (length {len(cap_indices)})')
for i, idx in enumerate(cap_indices):
    ax.annotate(f'{idx}', (points[idx][0], points[idx][1]),
                textcoords="offset points", xytext=(5, 8), fontsize=10,
                color='#FF5722', fontweight='bold')

for i in range(len(cap_pts) - 2):
    o = orient(cap_pts[i], cap_pts[i+1], cap_pts[i+2])
    mid_x = (cap_pts[i][0] + cap_pts[i+1][0] + cap_pts[i+2][0]) / 3
    mid_y = (cap_pts[i][1] + cap_pts[i+1][1] + cap_pts[i+2][1]) / 3
    sign = '+' if o > 0 else '−'
    ax.annotate(f'orient={sign}', (mid_x, mid_y), fontsize=8,
                color='#BF360C', ha='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='#FBE9E7'))

ax.set_title('Longest Cap (Convex-Down Chain)', fontsize=14, fontweight='bold')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_cups_caps.png', dpi=150, bbox_inches='tight')
print("Saved viz_cups_caps.png")
