"""
Visualization: Shadow Lattice Structure (2D)

Shows the support set and its successive shadows in 2 variables,
illustrating how the shadow operator "erodes" the support inward
like a discrete geometric flow.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow


# Create a 2D support set
S0 = {(5, 0), (4, 1), (3, 2), (2, 3), (1, 4), (0, 5),
      (4, 0), (3, 1), (2, 2), (1, 3), (0, 4),
      (3, 3), (2, 4), (4, 2)}

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

max_val = 6
shadows = [S0]
for k in range(1, 6):
    shadows.append(kth_shadow(S0, k))

colors = ['#E91E63', '#FF9800', '#FFC107', '#4CAF50', '#2196F3', '#9C27B0']
titles = ['S (original)', 'Sh₁(S)', 'Sh₂(S)', 'Sh₃(S)', 'Sh₄(S)', 'Sh₅(S)']

for idx, (ax, shadow, color, title) in enumerate(zip(axes.flat, shadows, colors, titles)):
    # Draw grid
    for x in range(max_val + 1):
        for y in range(max_val + 1):
            ax.plot(x, y, '.', color='#E0E0E0', markersize=4)

    # Draw shadow points
    if shadow:
        xs = [p[0] for p in shadow]
        ys = [p[1] for p in shadow]
        ax.scatter(xs, ys, c=color, s=100, zorder=5, edgecolors='black', linewidth=0.5)

    # Draw original support outline on all panels
    if idx > 0 and S0:
        xs0 = [p[0] for p in S0]
        ys0 = [p[1] for p in S0]
        ax.scatter(xs0, ys0, c='none', s=60, zorder=4, edgecolors='#BDBDBD', linewidth=1)

    ax.set_xlim(-0.5, max_val + 0.5)
    ax.set_ylim(-0.5, max_val + 0.5)
    ax.set_aspect('equal')
    ax.set_title(f'{title}  (|·| = {len(shadow)})', fontsize=13, fontweight='bold')
    ax.set_xlabel('x exponent', fontsize=10)
    ax.set_ylabel('y exponent', fontsize=10)
    ax.grid(True, alpha=0.15)

fig.suptitle('Shadow Erosion: The Support Contracts Under Iterated Shadows\n'
             'Gray circles: original support. Colored: shadow at each depth.',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_lattice.png', dpi=150, bbox_inches='tight')
print("Saved shadow_lattice.png")
