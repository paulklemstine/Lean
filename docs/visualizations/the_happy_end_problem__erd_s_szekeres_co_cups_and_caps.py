#!/usr/bin/env python3
"""
Visualization: Cups and Caps in Point Configurations

This script visualizes the cup-cap decomposition of planar point sets,
showing how cups (concave-up chains) and caps (concave-down chains)
partition the orientation structure.
"""
import matplotlib.pyplot as plt
import numpy as np
import math


def orient(a, b, c):
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def find_longest_cup(points):
    """Find longest cup (concave-up chain) in x-sorted points."""
    n = len(points)
    dp = [1] * n
    parent = [-1] * n
    prev = [-1] * n  # previous point in the cup (for orient check)

    for i in range(1, n):
        # Any pair forms a cup of size 2
        for j in range(i):
            if dp[j] == 1:
                if 2 > dp[i]:
                    dp[i] = 2
                    parent[i] = j
                    prev[i] = j
            elif prev[j] >= 0:
                if orient(points[prev[j]], points[j], points[i]) > 0:
                    if dp[j] + 1 > dp[i]:
                        dp[i] = dp[j] + 1
                        parent[i] = j
                        prev[i] = j

    best = max(range(n), key=lambda i: dp[i])
    result = []
    idx = best
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


def find_longest_cap(points):
    """Find longest cap (concave-down chain) in x-sorted points."""
    n = len(points)
    dp = [1] * n
    parent = [-1] * n
    prev = [-1] * n

    for i in range(1, n):
        for j in range(i):
            if dp[j] == 1:
                if 2 > dp[i]:
                    dp[i] = 2
                    parent[i] = j
                    prev[i] = j
            elif prev[j] >= 0:
                if orient(points[prev[j]], points[j], points[i]) < 0:
                    if dp[j] + 1 > dp[i]:
                        dp[i] = dp[j] + 1
                        parent[i] = j
                        prev[i] = j

    best = max(range(n), key=lambda i: dp[i])
    result = []
    idx = best
    while idx != -1:
        result.append(idx)
        idx = parent[idx]
    return result[::-1]


# Generate point configurations
np.random.seed(123)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Cups and Caps: Orientation Structure of Point Sets',
             fontsize=14, fontweight='bold')

# Configuration 1: Points on a parabola (pure cup)
t = np.linspace(-2, 2, 8)
pts1 = list(zip(t, t**2))
cup1 = find_longest_cup(pts1)
cap1 = find_longest_cap(pts1)

ax = axes[0, 0]
ax.scatter(*zip(*pts1), c='gray', s=60, zorder=3)
cup_pts = [pts1[i] for i in cup1]
ax.plot(*zip(*cup_pts), 'b-o', linewidth=2, markersize=8,
        label=f'Cup (size {len(cup1)})', zorder=4)
ax.set_title(f'Parabola: Pure Cup', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Configuration 2: Inverted parabola (pure cap)
pts2 = list(zip(t, -t**2 + 5))
cup2 = find_longest_cup(pts2)
cap2 = find_longest_cap(pts2)

ax = axes[0, 1]
ax.scatter(*zip(*pts2), c='gray', s=60, zorder=3)
cap_pts = [pts2[i] for i in cap2]
ax.plot(*zip(*cap_pts), 'r-s', linewidth=2, markersize=8,
        label=f'Cap (size {len(cap2)})', zorder=4)
ax.set_title(f'Inverted Parabola: Pure Cap', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Configuration 3: Sine wave (mixed)
t3 = np.linspace(0, 2*np.pi, 12)
pts3 = list(zip(t3, np.sin(t3)))
cup3 = find_longest_cup(pts3)
cap3 = find_longest_cap(pts3)

ax = axes[1, 0]
ax.scatter(*zip(*pts3), c='gray', s=60, zorder=3)
cup_pts3 = [pts3[i] for i in cup3]
cap_pts3 = [pts3[i] for i in cap3]
ax.plot(*zip(*cup_pts3), 'b-o', linewidth=2, markersize=8,
        label=f'Cup (size {len(cup3)})', zorder=4, alpha=0.8)
ax.plot(*zip(*cap_pts3), 'r-s', linewidth=2, markersize=8,
        label=f'Cap (size {len(cap3)})', zorder=4, alpha=0.8)
ax.set_title(f'Sine Wave: Mixed', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

# Configuration 4: Random points with cup and cap
pts4 = sorted([(np.random.uniform(0, 10), np.random.uniform(0, 5))
               for _ in range(10)], key=lambda p: p[0])
cup4 = find_longest_cup(pts4)
cap4 = find_longest_cap(pts4)

ax = axes[1, 1]
ax.scatter(*zip(*pts4), c='gray', s=60, zorder=3)
cup_pts4 = [pts4[i] for i in cup4]
cap_pts4 = [pts4[i] for i in cap4]
ax.plot(*zip(*cup_pts4), 'b-o', linewidth=2, markersize=8,
        label=f'Cup (size {len(cup4)})', zorder=4, alpha=0.8)
ax.plot(*zip(*cap_pts4), 'r-s', linewidth=2, markersize=8,
        label=f'Cap (size {len(cap4)})', zorder=4, alpha=0.8)
ax.set_title(f'Random: Cup-Cap Theorem', fontsize=12)
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('cups_caps.png', dpi=150, bbox_inches='tight')
print("Saved cups_caps.png")
